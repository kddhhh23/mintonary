// 장비 데이터 모델

/// 등록 화면 드롭다운용 라켓 모델
class RacketModelOption {
  const RacketModelOption({
    required this.id,
    required this.brand,
    required this.name,
  });

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

  final int id;
  final String brand;
  final String name;
}

/// 장비 탭 목록
class EquipmentList {
  const EquipmentList({required this.rackets, required this.shoes});

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

  final String brand;
  final String? series;
  final String name;

  /// 라켓 무게 표기 (U2~U6)
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

  final int id;
  final String name;

  /// OVER, TOWEL, CUSHION
  final String? type;
  final DateTime wrappedAt;
}
