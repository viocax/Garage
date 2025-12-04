import 'package:flutter/material.dart';

sealed class TabbarType {
  const TabbarType();

  String get label;
  IconData get iconData;
}

class SpeedCameraTab extends TabbarType {
  const SpeedCameraTab();

  @override
  String get label => '測速';

  @override
  IconData get iconData => Icons.speed;
}

class RecordsTab extends TabbarType {
  const RecordsTab();

  @override
  String get label => '紀錄';

  @override
  IconData get iconData => Icons.book;
}

class SettingsTab extends TabbarType {
  const SettingsTab();

  @override
  String get label => '設定';

  @override
  IconData get iconData => Icons.settings;
}

// Tab 配置管理類
class TabConfig {
  static const List<TabbarType> tabs = [
    SpeedCameraTab(),
    RecordsTab(),
    SettingsTab(),
  ];

  static int getTabIndex(TabbarType tab) {
    return tabs.indexWhere((t) => t.runtimeType == tab.runtimeType);
  }

  static TabbarType getTab(int index) {
    if (index < 0 || index >= tabs.length) {
      return const SpeedCameraTab();
    }
    return tabs[index];
  }

  static bool duplicate(int currentIndex, TabbarType clickTab) {
    final isDuplicate = currentIndex == getTabIndex(clickTab);
    return isDuplicate;
  }
}
