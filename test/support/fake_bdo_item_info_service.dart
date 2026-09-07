import 'package:karanda/model/bdo_item_info.dart';
import 'package:karanda/service/bdo_item_info_service.dart';

BDOItemInfo fakeItem({
  required String code,
  required String name,
  bool tradeAble = true,
  int maxEnhancement = 0,
  int grade = 0,
}) {
  return BDOItemInfo(
    code: code,
    kr: name,
    en: name,
    maxEnhancement: maxEnhancement,
    grade: grade,
    mainCategory: "1",
    subCategory: "1",
    tradeAble: tradeAble,
  );
}

/// 실제 [BDOItemInfoService]의 공개 인터페이스만 구현한 가짜.
/// 번들 카탈로그(`assets/Hammuu`)를 읽지 않는다.
class FakeBDOItemInfoService implements BDOItemInfoService {
  final List<BDOItemInfo> catalog;

  FakeBDOItemInfoService(this.catalog);

  @override
  List<BDOItemInfo> get items => catalog;

  @override
  List<BDOItemInfo> get tradeAbleItems =>
      catalog.where((item) => item.tradeAble).toList();

  @override
  BDOItemInfo itemInfo(String code) {
    return catalog.firstWhere((item) => item.code == code);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
