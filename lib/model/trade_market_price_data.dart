class TradeMarketPriceData {
  final int itemCode;
  final int enhancementLevel;
  final int price;
  final int cumulativeVolume;
  final int currentStock;

  /// 해당 강화 단계의 구매 대기 수량. 상세 응답에만 존재하며 최신 값만 유효하다.
  final int buyOrders;
  final DateTime date;

  TradeMarketPriceData({
    required this.itemCode,
    required this.enhancementLevel,
    required this.price,
    required this.cumulativeVolume,
    required this.currentStock,
    this.buyOrders = 0,
    required this.date,
  });

  String get key => "${itemCode}_$enhancementLevel";

  factory TradeMarketPriceData.fromJson(Map json) {
    return TradeMarketPriceData(
      itemCode: json['item_num'] ?? json['itemNum'],
      enhancementLevel: json['enhancement_level'] ?? json['enhancementLevel'],
      price: json['price'],
      cumulativeVolume: json['cumulative_volume'] ?? json['cumulativeVolume'],
      currentStock: json['current_stock'] ?? json['currentStock'],
      buyOrders: json['buy_orders'] ?? json['buyOrders'] ?? 0,
      date: DateTime.parse(json['date']),
    );
  }

  /// 상세(`/trade-market/detail`) 응답의 한 항목을 일별 가격 데이터 리스트로 변환한다.
  ///
  /// 신규 형식은 강화 단계당 객체 하나에 `priceHistory`(90일 배열, index 0 = 오늘)와
  /// `updatedAt`을 담아 준다. 소비 측(상세 화면)은 강화 단계별 일별 레코드 리스트를
  /// 기대하므로 배열을 하루 단위로 펼친다. 누적 거래량·재고·구매 대기는 최신 값만
  /// 유효하므로 오늘(index 0) 레코드에만 반영한다.
  ///
  /// `priceHistory`가 없으면 구버전 단일 레코드 형식으로 보고 [fromJson]으로 폴백한다.
  static List<TradeMarketPriceData> listFromDetailJson(Map json) {
    final priceHistory = json['price_history'] ?? json['priceHistory'];
    if (priceHistory is! List) {
      return [TradeMarketPriceData.fromJson(json)];
    }

    final int itemCode = json['item_num'] ?? json['itemNum'];
    final int enhancementLevel =
        json['enhancement_level'] ?? json['enhancementLevel'];
    final int cumulativeVolume =
        json['cumulative_volume'] ?? json['cumulativeVolume'] ?? 0;
    final int currentStock =
        json['current_stock'] ?? json['currentStock'] ?? 0;
    final int buyOrders = json['buy_orders'] ?? json['buyOrders'] ?? 0;
    final DateTime baseDate = _parseDate(json['updated_at'] ?? json['updatedAt']);

    final List<TradeMarketPriceData> result = [];
    for (int i = 0; i < priceHistory.length; i++) {
      final value = priceHistory[i];
      result.add(TradeMarketPriceData(
        itemCode: itemCode,
        enhancementLevel: enhancementLevel,
        price: value is num ? value.toInt() : 0,
        cumulativeVolume: i == 0 ? cumulativeVolume : 0,
        currentStock: i == 0 ? currentStock : 0,
        buyOrders: i == 0 ? buyOrders : 0,
        date: baseDate.subtract(Duration(days: i)),
      ));
    }

    // priceHistory가 비어 있어도 소비 측의 `.first` 접근이 깨지지 않도록
    // 오늘 기준 레코드 하나는 보장한다.
    if (result.isEmpty) {
      result.add(TradeMarketPriceData(
        itemCode: itemCode,
        enhancementLevel: enhancementLevel,
        price: 0,
        cumulativeVolume: cumulativeVolume,
        currentStock: currentStock,
        buyOrders: buyOrders,
        date: baseDate,
      ));
    }
    return result;
  }

  /// `updatedAt`을 로컬 날짜(자정) 기준으로 정규화한다. 파싱 실패 시 오늘 날짜로 대체한다.
  static DateTime _parseDate(dynamic value) {
    DateTime dateTime;
    if (value is String) {
      dateTime = DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    } else {
      dateTime = DateTime.now();
    }
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
