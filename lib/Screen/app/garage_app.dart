import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/Screen/app/bloc/garage_bloc.dart';
import 'package:garage/Screen/app/bloc/garage_event.dart';
import 'package:garage/Screen/app/bloc/garage_state.dart';
import 'package:garage/models/tabbar_type.dart';

class GarageApp extends StatelessWidget {
  const GarageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '愛車管家',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => GarageBloc(),
        child: const GarageHomePage(),
      ),
    );
  }
}

class GarageHomePage extends StatelessWidget {
  const GarageHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GarageBloc, GarageState>(
      builder: (context, state) {
        return Scaffold(
          body: _buildBody(state.tabbarType),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: TabConfig.getTabIndex(state.tabbarType),
            onTap: (index) {
              context.read<GarageBloc>().add(
                TabChanged(TabConfig.getTab(index)),
              );
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.speed), label: '測速'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: '紀錄'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
            ],
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


// 測速頁面 (Placeholder)
class SpeedCameraPage extends StatelessWidget {
  const SpeedCameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('測速頁面'));
  }
}

// 紀錄頁面 (Placeholder)
class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('紀錄頁面'));
  }
}

// 設定頁面 (Placeholder)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('設定頁面'));
  }
}
