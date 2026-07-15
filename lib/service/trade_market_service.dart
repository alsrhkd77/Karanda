import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_preset_item.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/model/trade_market_wait_item.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/bdo_item_info_repository.dart';
import 'package:karanda/repository/trade_market_repository.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

/// 거래소 기능 운영 로그.
final _log = Logger('trade_market');

class TradeMarketService {
  final TradeMarketRepository _tradeMarketRepository;
  final AppSettingsRepository _settingsRepository;
  final BDOItemInfoRepository _itemInfoRepository;
  final _waitList = BehaviorSubject<List<TradeMarketWaitItem>>();
  StreamSubscription? _regionSubscription;

  TradeMarketService({
    required TradeMarketRepository tradeMarketRepository,
    required AppSettingsRepository settingsRepository,
    required BDOItemInfoRepository itemInfoRepository,
  })  : _tradeMarketRepository = tradeMarketRepository,
        _settingsRepository = settingsRepository,
        _itemInfoRepository = itemInfoRepository {
    _waitList.sink.addStream(_tradeMarketRepository.waitListStream);
    if (kIsWeb) {
      _waitList.onListen = _connectLiveData;
      _waitList.onCancel = _disconnectLiveData;
    } else {
      _connectLiveData();
    }
  }

  Stream<List<TradeMarketWaitItem>> get waitListStream =>
      _waitList.stream.map(_waitListItemFilter);

  void _connectLiveData() {
    if (_settingsRepository.region != null) {
      _tradeMarketRepository.getWaitItems(_settingsRepository.region!);
    }
    _regionSubscription = _settingsRepository.settingsStream
        .map((settings) => settings.region)
        .distinct()
        .listen(_onRegionUpdate);
  }

  Future<void> _disconnectLiveData() async {
    await _regionSubscription?.cancel();
    _tradeMarketRepository.disconnectLiveChannel();
  }

  void _onRegionUpdate(BDORegion region) {
    _log.info('Connect trade market live channel (region: ${region.name})');
    _tradeMarketRepository.disconnectLiveChannel();
    _tradeMarketRepository.connectLiveChannel(region);
  }

  List<TradeMarketWaitItem> _waitListItemFilter(
      List<TradeMarketWaitItem> items) {
    return items.where((item) {
      return _itemInfoRepository.keys.contains(item.itemCode.toString());
    }).toList();
  }

  Future<Map<String, List<TradeMarketPriceData>>> getPriceDetailData(
      String code, BDORegion region) async {
    _log.info('Fetch price detail (item: $code, region: ${region.name})');
    final items = await _tradeMarketRepository.getDetailedPriceData(
      itemCode: int.parse(code),
      region: region,
    );
    final Map<String, List<TradeMarketPriceData>> result = {};
    for (TradeMarketPriceData item in items) {
      if (!result.containsKey(item.enhancementLevel.toString())) {
        result[item.enhancementLevel.toString()] = [];
      }
      result[item.enhancementLevel.toString()]!.add(item);
    }
    return result;
  }

  Future<List<TradeMarketPresetItem>> getPresetData(String key) async {
    return await _tradeMarketRepository.getPresetData(key);
  }

  Future<List<TradeMarketPriceData>> getPresetPriceData(
    List<TradeMarketPresetItem> items,
    BDORegion region,
  ) async {
    return await _tradeMarketRepository.getLatestPriceData(
      items.map((item) => "${item.code}_${item.enhancementLevel}").toList(),
      region,
    );
  }

  /// 로컬 사용자 템플릿 목록. 추가/수정/삭제 시 최신 목록을 방출해
  /// 홈 그리드 등 구독자가 즉시 갱신되도록 한다.
  final _templates = BehaviorSubject<List<TradeMarketTemplate>>();

  Stream<List<TradeMarketTemplate>> get templatesStream => _templates.stream;

  /// 캐시된 템플릿 목록을 반환한다. 최초 호출 시 로컬 저장소에서 읽어 캐시한다.
  Future<List<TradeMarketTemplate>> getTemplates() async {
    if (!_templates.hasValue) {
      _templates.add(await _tradeMarketRepository.getTemplates());
    }
    return _templates.value;
  }

  Future<TradeMarketTemplate?> getTemplate(String id) async {
    final templates = await getTemplates();
    for (TradeMarketTemplate template in templates) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }

  Future<void> addTemplate(TradeMarketTemplate template) async {
    final templates = await getTemplates();
    final next = [...templates, template];
    await _tradeMarketRepository.saveTemplates(next);
    _templates.add(next);
  }

  Future<void> updateTemplate(TradeMarketTemplate template) async {
    final templates = await getTemplates();
    final next = List<TradeMarketTemplate>.from(templates);
    final index = next.indexWhere((item) => item.id == template.id);
    if (index >= 0) {
      next[index] = template;
    } else {
      next.add(template);
    }
    await _tradeMarketRepository.saveTemplates(next);
    _templates.add(next);
  }

  Future<void> deleteTemplate(String id) async {
    final templates = await getTemplates();
    final next = templates.where((template) => template.id != id).toList();
    await _tradeMarketRepository.saveTemplates(next);
    _templates.add(next);
  }
}
