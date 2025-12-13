import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'package:garage/screen/app/home/bloc/garage_home_bloc.dart';
import 'package:garage/screen/app/home/bloc/garage_home_event.dart';
import 'package:garage/core/models/tabbar_type.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class GarageHomePage extends StatelessWidget {
  final StatefulNavigationShell shell;

  const GarageHomePage({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GarageHomeBloc(),
      child: Builder(
        builder: (context) => _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final shouldUseDarkTheme = TabConfig.shouldUseDarkTheme(shell.currentIndex);

    return Scaffold(
      body: shell,
      bottomNavigationBar: Theme(
        data: shouldUseDarkTheme ? AppTheme.darkTheme : Theme.of(context),
        child: BottomNavigationBar(
          currentIndex: shell.currentIndex,
          onTap: (index) {
            TabbarType tabbarType = TabConfig.getTab(index);
            shell.goBranch(
              index,
              initialLocation: TabConfig.duplicate(index, tabbarType) == false,
            );
            // TODO: 到時候再看看需不需要，之後想知道相關點擊事件
            context.read<GarageHomeBloc>().add(TabChanged(tabbarType));
          },
          items: [
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
  }
}
