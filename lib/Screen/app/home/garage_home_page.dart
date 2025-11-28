import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/screen/app/home/bloc/garage_home_bloc.dart';
import 'package:garage/screen/app/home/bloc/garage_home_event.dart';
import 'package:garage/screen/app/home/bloc/garage_home_state.dart';
import 'package:garage/screen/records/records_page.dart';
import 'package:garage/screen/settings/settings_page.dart';
import 'package:garage/screen/speed/speedCamera/speed_camera_page.dart';
import 'package:garage/core/models/tabbar_type.dart';

class GarageHomePage extends StatelessWidget {
  const GarageHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarageHomeBloc, GarageHomeState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(state.tabbarType),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: TabConfig.getTabIndex(state.tabbarType),
              onTap: (index) {
                context.read<GarageHomeBloc>().add(
                  TabChanged(TabConfig.getTab(index)),
                );
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.speed_outlined),
                  activeIcon: Icon(Icons.speed),
                  label: '測速',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined),
                  activeIcon: Icon(Icons.book),
                  label: '紀錄',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: '設定',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(TabbarType tabIndex) {
    switch (tabIndex) {
      case SpeedCameraTab():
        return const SpeedCameraPage();
      case RecordsTab():
        return const RecordsPage();
      case SettingsTab():
        return const SettingsPage();
    }
  }
}
