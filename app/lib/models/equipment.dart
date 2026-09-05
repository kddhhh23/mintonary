// 장비 API 응답을 담는 데이터 모델

DateTime? _date(String? value) => value == null ? null : DateTime.parse(value);

/// 등록 화면 드롭다운용 라켓 모델
class RacketModelOption {
  const RacketModelOption({
    required this.id,
    required this.brand,
    required this.name,
  });

  RacketModelOption.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      brand = json['brand'] as String,
      name = json['name'] as String;

  final int id;
  final String brand;
  final String name;
}

/// 등록 화면 드롭다운용 신발 모델
class ShoeModelOption {
  const ShoeModelOption({
    required this.id,
    required this.brand,
    required this.name,
  });

  ShoeModelOption.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      brand = json['brand'] as String,
      name = json['name'] as String;

  final int id;
  final String brand;
  final String name;
}

/// 장비 탭 목록
class EquipmentList {
  const EquipmentList({required this.rackets, required this.shoes});

  EquipmentList.fromJson(Map<String, dynamic> json)
    : rackets = (json['rackets'] as List)
          .map((e) => RacketSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      shoes = (json['shoes'] as List)
          .map((e) => ShoeSummary.fromJson(e as Map<String, dynamic>))
          .toList();

  final List<RacketSummary> rackets;
  final List<ShoeSummary> shoes;
}

class RacketSummary {
  const RacketSummary({
    required this.id,
    required this.brand,
    required this.name,
    required this.purchaseDate,
    required this.price,
    required this.inUse,
    required this.stringName,
    required this.tension,
    required this.strungAt,
    required this.gripName,
    required this.wrappedAt,
  });

  RacketSummary.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      brand = json['brand'] as String,
      name = json['name'] as String,
      purchaseDate = _date(json['purchaseDate'] as String?),
      price = json['price'] as int?,
      inUse = json['inUse'] as bool,
      stringName = json['stringName'] as String?,
      tension = json['tension'] as int?,
      strungAt = _date(json['strungAt'] as String?),
      gripName = json['gripName'] as String?,
      wrappedAt = _date(json['wrappedAt'] as String?);

  final int id;
  final String brand;
  final String name;
  final DateTime? purchaseDate;
  final int? price;
  final bool inUse;
  final String? stringName;
  final int? tension;
  final DateTime? strungAt;
  final String? gripName;
  final DateTime? wrappedAt;
}

class ShoeSummary {
  const ShoeSummary({
    required this.id,
    required this.brand,
    required this.name,
    required this.purchaseDate,
    required this.price,
    required this.inUse,
  });

  ShoeSummary.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      brand = json['brand'] as String,
      name = json['name'] as String,
      purchaseDate = _date(json['purchaseDate'] as String?),
      price = json['price'] as int?,
      inUse = json['inUse'] as bool;

  final int id;
  final String brand;
  final String name;
  final DateTime? purchaseDate;
  final int? price;
  final bool inUse;
}

/// 장비 상세 — type에 따라 racket 또는 shoe 중 하나만 채워진다
class EquipmentDetail {
  const EquipmentDetail({
    required this.id,
    required this.type,
    required this.purchaseDate,
    required this.price,
    required this.memo,
    required this.inUse,
    required this.racket,
    required this.shoe,
  });

  EquipmentDetail.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      type = json['type'] as String,
      purchaseDate = _date(json['purchaseDate'] as String?),
      price = json['price'] as int?,
      memo = json['memo'] as String?,
      inUse = json['inUse'] as bool,
      racket = json['racket'] == null
          ? null
          : RacketInfo.fromJson(json['racket'] as Map<String, dynamic>),
      shoe = json['shoe'] == null
          ? null
          : ShoeInfo.fromJson(json['shoe'] as Map<String, dynamic>);

  final int id;
  final String type;
  final DateTime? purchaseDate;
  final int? price;
  final String? memo;
  final bool inUse;
  final RacketInfo? racket;
  final ShoeInfo? shoe;
}

class RacketInfo {
  const RacketInfo({
    required this.brand,
    required this.series,
    required this.name,
    required this.weight,
    required this.balance,
    required this.flex,
    required this.stringAlarmDate,
    required this.stringHistories,
    required this.gripHistories,
  });

  RacketInfo.fromJson(Map<String, dynamic> json)
    : brand = json['brand'] as String,
      series = json['series'] as String?,
      name = json['name'] as String,
      weight = json['weight'] as String?,
      balance = json['balance'] as String?,
      flex = json['flex'] as String?,
      stringAlarmDate = _date(json['stringAlarmDate'] as String?),
      stringHistories = (json['stringHistories'] as List)
          .map((e) => StringHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      gripHistories = (json['gripHistories'] as List)
          .map((e) => GripHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();

  final String brand;
  final String? series;
  final String name;

  /// 서버 표기 그대로 (U2~U6)
  final String? weight;
  final String? balance;
  final String? flex;
  final DateTime? stringAlarmDate;

  /// 최신순
  final List<StringHistoryItem> stringHistories;
  final List<GripHistoryItem> gripHistories;
}

class ShoeInfo {
  const ShoeInfo({
    required this.brand,
    required this.name,
    required this.width,
  });

  ShoeInfo.fromJson(Map<String, dynamic> json)
    : brand = json['brand'] as String,
      name = json['name'] as String,
      width = json['width'] as String?;

  final String brand;
  final String name;
  final String? width;
}

class StringHistoryItem {
  const StringHistoryItem({
    required this.id,
    required this.name,
    required this.tension,
    required this.strungAt,
  });

  StringHistoryItem.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      name = json['name'] as String,
      tension = json['tension'] as int?,
      strungAt = DateTime.parse(json['strungAt'] as String);

  final int id;
  final String name;
  final int? tension;
  final DateTime strungAt;
}

class GripHistoryItem {
  const GripHistoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.wrappedAt,
  });

  GripHistoryItem.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int,
      name = json['name'] as String,
      type = json['type'] as String?,
      wrappedAt = DateTime.parse(json['wrappedAt'] as String);

  final int id;
  final String name;

  /// OVER, TOWEL, CUSHION
  final String? type;
  final DateTime wrappedAt;
}
