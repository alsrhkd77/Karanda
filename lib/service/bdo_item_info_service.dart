import 'package:flutter/foundation.dart';
import 'package:karanda/model/bdo_item_info.dart';
import 'package:karanda/repository/bdo_item_info_repository.dart';

class BDOItemInfoService extends ChangeNotifier {
  final BDOItemInfoRepository _itemInfoRepository;

  BDOItemInfoService({required BDOItemInfoRepository itemInfoRepository})
      : _itemInfoRepository = itemInfoRepository {
    _init();
  }

  List<BDOItemInfo> get tradeAbleItems => _itemInfoRepository.tradeAbleItems;

  /// 거래 불가 아이템을 포함한 전체 목록.
  List<BDOItemInfo> get items => _itemInfoRepository.items;

  BDOItemInfo itemInfo(String code) {
    return _itemInfoRepository.getItemInfo(code);
  }

  Future<void> _init() async {
    await _itemInfoRepository.getData();
    notifyListeners();
  }
}
