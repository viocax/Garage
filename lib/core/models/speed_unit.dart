/// 速度單位枚舉
enum SpeedUnit {
  /// 公里/小時
  kmh('km/h'),

  /// 英里/小時
  mph('mph');

  /// 顯示名稱
  final String displayName;

  const SpeedUnit(this.displayName);
}

extension SpeedUnitExtension on double {
  double get mile => this * 0.621371;
  double get km => this * 1.60934;
  String format(SpeedUnit unit) {
    return this.toStringAsFixed(2) + unit.displayName;
  }
}
