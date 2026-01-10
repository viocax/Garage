part of 'records_bloc.dart';

/// 油耗顯示數據
class FuelEfficiencyDisplay {
  final double kmPerLiter; // km/L 值

  const FuelEfficiencyDisplay({required this.kmPerLiter});

  /// 空數據（無油耗記錄）
  static const FuelEfficiencyDisplay empty = FuelEfficiencyDisplay(
    kmPerLiter: 0.0,
  );

  /// 是否有有效數據
  bool get hasData => kmPerLiter > 0.0;

  /// 格式化顯示字串
  /// 返回格式：10.5 km/L 或 N/A
  String format() {
    if (!hasData) return 'N/A';
    return '${kmPerLiter.toStringAsFixed(1)} km/L';
  }

  /// 計算車輛的最新油耗
  ///
  /// 處理三種情況：
  /// 1. 無加油記錄：返回 empty（顯示 N/A）
  /// 2. 只有一筆記錄：使用車輛初始里程計算
  /// 3. 多筆記錄：使用最近兩筆記錄計算
  static FuelEfficiencyDisplay calculateFromVehicle(Vehicle vehicle) {
    // 取得所有加油記錄，按日期排序（最新的在前）
    final fuelRecords =
        vehicle.records.where((r) => r.typeName == 'fuel').toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    // 情況 1：沒有任何加油記錄
    if (fuelRecords.isEmpty) {
      return FuelEfficiencyDisplay.empty;
    }

    // 情況 2：只有一筆加油記錄 - 使用車輛初始里程
    if (fuelRecords.length == 1) {
      final record = fuelRecords[0];
      final efficiency = record.calculateFuelEfficiency(vehicle.currentKm);

      if (efficiency <= 0) {
        return FuelEfficiencyDisplay.empty;
      }

      return FuelEfficiencyDisplay(kmPerLiter: efficiency);
    }

    // 情況 3：多筆記錄 - 使用最近兩筆
    final mostRecent = fuelRecords[0];
    final previousRecord = fuelRecords[1];

    final efficiency = mostRecent.calculateFuelEfficiency(previousRecord.km);

    if (efficiency <= 0) {
      return FuelEfficiencyDisplay.empty;
    }

    return FuelEfficiencyDisplay(kmPerLiter: efficiency);
  }
}

enum RecordsSideEffect {
  navigateToAddVehicle,
  navigateToAddRecord,
  navigateToEditVehicle,
}

class RecordsState extends Equatable {
  final List<Vehicle> vehicles;
  final String currentVehicleId;
  final UserSettings? userSettings;
  final String odometerString;
  final String unitString;
  final FuelEfficiencyDisplay fuelEfficiency;
  final bool isLoading;
  final String? errorMessage;
  final RecordsSideEffect? sideEffect;

  const RecordsState({
    this.vehicles = const [],
    this.currentVehicleId = '',
    this.userSettings,
    this.odometerString = '0',
    this.unitString = 'km',
    this.fuelEfficiency = FuelEfficiencyDisplay.empty,
    this.isLoading = false,
    this.errorMessage,
    this.sideEffect,
  });

  bool get isEmpty => vehicles.isEmpty;

  // Helper to get the current vehicle
  Vehicle get currentVehicle => vehicles.firstWhere(
    (v) => v.vehicleId == currentVehicleId,
    orElse: () => Vehicle.empty(),
  );

  @override
  List<Object?> get props => [
    vehicles,
    currentVehicleId,
    userSettings,
    odometerString,
    unitString,
    fuelEfficiency,
    isLoading,
    errorMessage,
    sideEffect,
  ];

  RecordsState copyWith({
    List<Vehicle>? vehicles,
    String? currentVehicleId,
    UserSettings? userSettings,
    String? odometerString,
    String? unitString,
    FuelEfficiencyDisplay? fuelEfficiency,
    bool? isLoading,
    String? errorMessage,
    RecordsSideEffect? sideEffect,
    bool clearSideEffect = false,
    bool clearError = false,
  }) {
    return RecordsState(
      vehicles: vehicles ?? this.vehicles,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
      userSettings: userSettings ?? this.userSettings,
      odometerString: odometerString ?? this.odometerString,
      unitString: unitString ?? this.unitString,
      fuelEfficiency: fuelEfficiency ?? this.fuelEfficiency,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sideEffect: clearSideEffect ? null : sideEffect,
    );
  }
}
