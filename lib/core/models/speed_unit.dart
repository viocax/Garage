/// 速度單位枚舉
enum SpeedUnit {
  /// 公里/小時
  kmh('km/h', 'km/h'),

  /// 英里/小時
  mph('mph', 'mph');

  /// 顯示名稱
  final String displayName;

  /// 值
  final String value;

  const SpeedUnit(this.displayName, this.value);

  /// 從字串轉換為 SpeedUnit
  static SpeedUnit fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mph':
        return SpeedUnit.mph;
      case 'km/h':
      case 'kmh':
      default:
        return SpeedUnit.kmh;
    }
  }

  /// 轉換速度值
  ///
  /// 將速度從當前單位轉換為指定單位
  double convertTo(double speed, SpeedUnit targetUnit) {
    if (this == targetUnit) return speed;

    // km/h to mph
    if (this == SpeedUnit.kmh && targetUnit == SpeedUnit.mph) {
      return speed * 0.621371;
    }

    // mph to km/h
    if (this == SpeedUnit.mph && targetUnit == SpeedUnit.kmh) {
      return speed * 1.60934;
    }

    return speed;
  }

  /// 格式化速度顯示
  String formatSpeed(double speed) {
    return '${speed.toStringAsFixed(0)} $displayName';
  }
}
