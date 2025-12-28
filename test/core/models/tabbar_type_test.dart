import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/models/tabbar_type.dart';

void main() {
  group('TabbarType Sealed Class', () {
    group('SpeedCameraTab', () {
      test('應該有正確的 label', () {
        const tab = SpeedCameraTab();
        expect(tab.label, '測速');
      });

      test('應該有正確的 iconData', () {
        const tab = SpeedCameraTab();
        expect(tab.iconData, Icons.speed);
      });
    });

    group('RecordsTab', () {
      test('應該有正確的 label', () {
        const tab = RecordsTab();
        expect(tab.label, '紀錄');
      });

      test('應該有正確的 iconData', () {
        const tab = RecordsTab();
        expect(tab.iconData, Icons.book);
      });
    });

    group('SettingsTab', () {
      test('應該有正確的 label', () {
        const tab = SettingsTab();
        expect(tab.label, '設定');
      });

      test('應該有正確的 iconData', () {
        const tab = SettingsTab();
        expect(tab.iconData, Icons.settings);
      });
    });
  });

  group('TabConfig', () {
    group('tabs 靜態列表', () {
      test('應該有 3 個 tab', () {
        expect(TabConfig.tabs.length, 3);
      });

      test('應該按正確順序排列', () {
        expect(TabConfig.tabs[0], isA<SpeedCameraTab>());
        expect(TabConfig.tabs[1], isA<RecordsTab>());
        expect(TabConfig.tabs[2], isA<SettingsTab>());
      });
    });

    group('getTabIndex', () {
      test('應該返回 SpeedCameraTab 的正確索引', () {
        expect(TabConfig.getTabIndex(const SpeedCameraTab()), 0);
      });

      test('應該返回 RecordsTab 的正確索引', () {
        expect(TabConfig.getTabIndex(const RecordsTab()), 1);
      });

      test('應該返回 SettingsTab 的正確索引', () {
        expect(TabConfig.getTabIndex(const SettingsTab()), 2);
      });
    });

    group('getTab', () {
      test('應該根據索引 0 返回 SpeedCameraTab', () {
        final tab = TabConfig.getTab(0);
        expect(tab, isA<SpeedCameraTab>());
      });

      test('應該根據索引 1 返回 RecordsTab', () {
        final tab = TabConfig.getTab(1);
        expect(tab, isA<RecordsTab>());
      });

      test('應該根據索引 2 返回 SettingsTab', () {
        final tab = TabConfig.getTab(2);
        expect(tab, isA<SettingsTab>());
      });

      test('負數索引應該返回預設的 SpeedCameraTab', () {
        final tab = TabConfig.getTab(-1);
        expect(tab, isA<SpeedCameraTab>());
      });

      test('超出範圍的索引應該返回預設的 SpeedCameraTab', () {
        final tab = TabConfig.getTab(100);
        expect(tab, isA<SpeedCameraTab>());
      });
    });

    group('duplicate', () {
      test('當前索引與點擊的 tab 相同時應該返回 true', () {
        expect(TabConfig.duplicate(0, const SpeedCameraTab()), true);
        expect(TabConfig.duplicate(1, const RecordsTab()), true);
        expect(TabConfig.duplicate(2, const SettingsTab()), true);
      });

      test('當前索引與點擊的 tab 不同時應該返回 false', () {
        expect(TabConfig.duplicate(0, const RecordsTab()), false);
        expect(TabConfig.duplicate(1, const SpeedCameraTab()), false);
        expect(TabConfig.duplicate(2, const RecordsTab()), false);
      });
    });

    group('shouldUseDarkTheme', () {
      test('SpeedCameraTab 應該使用 dark theme', () {
        expect(TabConfig.shouldUseDarkTheme(0), true);
      });

      test('RecordsTab 應該使用 dark theme', () {
        expect(TabConfig.shouldUseDarkTheme(1), true);
      });

      test('SettingsTab 不應該使用 dark theme', () {
        expect(TabConfig.shouldUseDarkTheme(2), false);
      });

      test('無效索引應該返回預設值 (SpeedCameraTab = true)', () {
        // 當索引無效時，getTab 返回 SpeedCameraTab，所以應該是 true
        expect(TabConfig.shouldUseDarkTheme(-1), true);
        expect(TabConfig.shouldUseDarkTheme(100), true);
      });
    });
  });

  group('Pattern Matching', () {
    test('應該可以使用 switch expression 匹配 TabbarType', () {
      String getTabName(TabbarType tab) {
        return switch (tab) {
          SpeedCameraTab() => 'speed',
          RecordsTab() => 'records',
          SettingsTab() => 'settings',
        };
      }

      expect(getTabName(const SpeedCameraTab()), 'speed');
      expect(getTabName(const RecordsTab()), 'records');
      expect(getTabName(const SettingsTab()), 'settings');
    });
  });
}
