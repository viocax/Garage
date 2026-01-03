import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';
import 'package:garage/core/di/service_locator.dart';

// Events
abstract class AppLifecycleEvent {}

// States
abstract class AppLifecycleState {}
class AppLifecycleInitial extends AppLifecycleState {}

class AppLifecycleBloc extends Bloc<AppLifecycleEvent, AppLifecycleState> with AppLifecycleMixin<AppLifecycleEvent, AppLifecycleState> {
  AppLifecycleBloc() : super(AppLifecycleInitial()) {
    // 啟動生命週期監聽
    initLifecycleObserver();
  }

  @override
  void onAppResumed() {
    super.onAppResumed();
    getIt.repo.appOpenAd.showAdIfAvailable();
  }
}
