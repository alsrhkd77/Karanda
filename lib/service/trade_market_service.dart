import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:karanda/enums/bdo_region.dart';
import 'package:karanda/model/trade_market_price_data.dart';
import 'package:karanda/model/trade_market_template.dart';
import 'package:karanda/model/trade_market_wait_item.dart';
import 'package:karanda/repository/app_settings_repository.dart';
import 'package:karanda/repository/bdo_item_info_repository.dart';
import 'package:karanda/repository/caphras_requirement_repository.dart';
import 'package:karanda/repository/lifeskill_mastery_repository.dart';
import 'package:karanda/repository/trade_market_repository.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

/// 거래소 기능 운영 로그.
final _log = Logger('trade_market');

class TradeMarketService {
  final TradeMarketRepository _tradeMarketRepository;
  final AppSettingsRepository _settingsRepository;
  final BDOItemInfoRepository _itemInfoRepository;
  final LifeskillMasteryRepository _masteryRepository;
  final CaphrasRequirementRepository _caphrasRepository;
  final _waitList = BehaviorSubject<List<TradeMarketWaitItem>>();
  StreamSubscription? _regionSubscription;

  TradeMarketService({
    required TradeMarketRepository tradeMarketRepository,
    required AppSettingsRepository settingsRepository,
    required BDOItemInfoRepository itemInfoRepository,
    required LifeskillMasteryRepository masteryRepository,
    required CaphrasRequirementRepository caphrasRepository,
  })  : _tradeMarketRepository = tradeMarketRepository,
        _settingsRepository = settingsRepository,
        _itemInfoRepository = itemInfoRepository,
        _masteryRepository = masteryRepository,
        _caphrasRepository = caphrasRepository {
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

  /// `{코드}_{강화단계}` 키 목록으로 최신가를 **한 번에** 조회한다.
  ///
  /// 서버가 100개 제한을 두므로 템플릿 하나의 모든 아이템을 모아 한 번만 호출한다.
  Future<List<TradeMarketPriceData>> getPriceDataByKeys(
    List<String> keys,
    BDORegion region,
  ) async {
    if (keys.isEmpty) {
      return const [];
    }
    return await _tradeMarketRepository.getLatestPriceData(keys, region);
  }

  /// 생활별 사용자 숙련도. 템플릿마다 다시 입력받지 않도록 한곳에 저장한다.
  Future<int> getMastery(TradeMarketLifeskill lifeskill) =>
      _masteryRepository.getMastery(lifeskill);

  Future<void> setMastery(TradeMarketLifeskill lifeskill, int value) async {
    await _masteryRepository.setMastery(lifeskill, value);
    _log.info(
        'Update lifeskill mastery (skill: ${lifeskill.name}, value: $value)');
  }

  /// 황실 납품 은화 보너스. 요리상자가 쓴다.
  Future<double> royalTradeSilverBonusOf(
    TradeMarketLifeskill lifeskill,
    int mastery,
  ) =>
      _masteryRepository.royalTradeSilverBonusOf(lifeskill, mastery);

  /// 숙련도에 따른 결과물 산출 배율.
  Future<double> outputMultiplierOf(TradeMarketLifeskill lifeskill) =>
      _masteryRepository.outputMultiplierOf(lifeskill);

  /// 카프라스의 돌 아이템 코드.
  static const int caphrasStoneCode = 721003;

  /// 최저가 슬롯의 후보를 카탈로그에서 실제 아이템 목록으로 펼친다.
  ///
  /// prefix 매칭은 `mainCategory`로 좁힌다 — 안 그러면 `쿠툼의 심장`(30/2),
  /// `크자카 조각상`(80/8) 같은 동명 아이템이 후보에 섞인다.
  /// 카프라스 돌파 후보는 `동 장비 + 카프라스의 돌 × N`짜리 `derived` 아이템이 된다.
  Future<List<TradeMarketTemplateItem>> resolveSlot(
    TradeMarketItemSlot slot,
  ) async {
    final result = <TradeMarketTemplateItem>[];
    for (final candidate in slot.candidates) {
      for (final info in _itemInfoRepository.items) {
        final code = int.tryParse(info.code);
        if (code == null) {
          continue;
        }
        if (int.tryParse(info.mainCategory) != candidate.mainCategory) {
          continue;
        }
        final matched = candidate.codes.isNotEmpty
            ? candidate.codes.contains(code)
            : candidate.prefixes.any(info.kr.startsWith);
        if (!matched) {
          continue;
        }

        final base = TradeMarketTemplateItem(
          code: code,
          enhancementLevel: candidate.enhancementLevel,
        );
        if (candidate.caphrasLevel <= 0) {
          result.add(base);
          continue;
        }

        final count = await _caphrasRepository.countOf(
          code: code,
          mainCategory: candidate.mainCategory,
          name: info.kr,
          enhancementLevel: candidate.enhancementLevel,
        );
        if (count == null) {
          // 개수를 모르면 총원가가 과소 계산되어 엉뚱한 후보가 최저가로 뽑힌다.
          // 값이 채워질 때까지 후보에서 제외한다.
          _log.warning(
              'No caphras requirement data (item: $code, level: ${candidate.enhancementLevel})');
          continue;
        }
        result.add(TradeMarketTemplateItem(
          source: TradeMarketItemSource.derived,
          customName: info.kr,
          components: [
            base,
            TradeMarketTemplateItem(
              code: caphrasStoneCode,
              quantity: count,
            ),
          ],
        ));
      }
    }
    return result;
  }

  /// 앱이 기본 제공하는 템플릿 키. 키가 곧 id·i18n 키·라우트 경로다.
  static const List<String> builtInTemplateKeys = [
    "melody_of_stars",
    "dehkias_light",
    "magical_lightstone_crystal",
    "essence_of_dawn",
    "sovereign_main_weapon",
    "sovereign_sub_weapon",
    "sovereign_awakening_weapon",
    "crescent_incense_burner",
  ];

  List<TradeMarketTemplate>? _builtInTemplates;

  /// 빌트인 템플릿 목록. 에셋에서 한 번만 읽어 캐시한다.
  Future<List<TradeMarketTemplate>> getBuiltInTemplates() async {
    if (_builtInTemplates != null) {
      return _builtInTemplates!;
    }
    final result = <TradeMarketTemplate>[];
    for (final key in builtInTemplateKeys) {
      try {
        result.add(await _tradeMarketRepository.getBuiltInTemplate(key));
      } catch (e, s) {
        // 에셋 하나가 깨져도 나머지 템플릿은 살린다.
        _log.warning('Failed to load built-in template (key: $key)', e, s);
      }
    }
    _builtInTemplates = result;
    return result;
  }

  /// 로컬 사용자 템플릿 목록. 추가/수정/삭제 시 최신 목록을 방출해
  /// 홈 그리드 등 구독자가 즉시 갱신되도록 한다.
  ///
  /// 빌트인 템플릿은 여기 섞지 않는다 — 메인 페이지가 아직 고정 프리셋 카드를
  /// 따로 그리고 있어 함께 방출하면 카드가 중복된다. 통합은 라우트 정리 단계에서 한다.
  final _templates = BehaviorSubject<List<TradeMarketTemplate>>();

  Stream<List<TradeMarketTemplate>> get templatesStream => _templates.stream;

  /// 캐시된 템플릿 목록을 반환한다. 최초 호출 시 로컬 저장소에서 읽어 캐시한다.
  Future<List<TradeMarketTemplate>> getTemplates() async {
    if (!_templates.hasValue) {
      _templates.add(await _tradeMarketRepository.getTemplates());
    }
    return _templates.value;
  }

  /// id로 템플릿을 찾는다. 사용자 템플릿과 빌트인을 모두 뒤진다.
  Future<TradeMarketTemplate?> getTemplate(String id) async {
    final templates = await getTemplates();
    for (TradeMarketTemplate template in templates) {
      if (template.id == id) {
        return template;
      }
    }
    for (TradeMarketTemplate template in await getBuiltInTemplates()) {
      if (template.id == id) {
        return template;
      }
    }
    return null;
  }

  /// 빌트인을 "내 템플릿"으로 복제해 저장한다.
  Future<TradeMarketTemplate> copyTemplate(
    TradeMarketTemplate source, {
    required String name,
  }) async {
    final copied = source.copyAsUserTemplate(name: name);
    await addTemplate(copied);
    _log.info('Copy trade market template (source: ${source.id})');
    return copied;
  }

  Future<void> addTemplate(TradeMarketTemplate template) async {
    final templates = await getTemplates();
    final next = [...templates, template];
    await _tradeMarketRepository.saveTemplates(next);
    _templates.add(next);
  }

  Future<void> updateTemplate(TradeMarketTemplate template) async {
    // 빌트인은 읽기 전용이다. 편집은 복제본으로만 한다.
    if (template.isBuiltIn) {
      return;
    }
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
