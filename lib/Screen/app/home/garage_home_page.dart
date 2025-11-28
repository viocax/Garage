import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'package:garage/screen/app/home/bloc/garage_home_bloc.dart';
import 'package:garage/screen/app/home/bloc/garage_home_event.dart';
import 'package:garage/core/models/tabbar_type.dart';
import 'package:go_router/go_router.dart';

class GarageHomePage extends StatelessWidget {
  final StatefulNavigationShell shell;

  const GarageHomePage({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: (index) => {
          shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex ? false : true,
          ),
          // TODO: 到時候再看看需不需要，之後想知道相關點擊事件
          context.read<GarageHomeBloc>().add(
            TabChanged(TabConfig.getTab(index)),
          ),
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
    );
  }
}
