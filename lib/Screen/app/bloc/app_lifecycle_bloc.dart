import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/core.dart';

// Events
abstract class AppLifecycleEvent {}

// States
abstract class AppLifecycleState {}

class AppLifecycleInitial extends AppLifecycleState {}

class AppLifecycleBloc extends Bloc<AppLifecycleEvent, AppLifecycleState>
    with AppLifecycleMixin<AppLifecycleEvent, AppLifecycleState> {
  final AppOpenAdRepository _appOpenAdRepository;

  AppLifecycleBloc({AppOpenAdRepository? appOpenAdRepository})
    : _appOpenAdRepository = appOpenAdRepository ?? getIt.repo.appOpenAd,
      super(AppLifecycleInitial()) {
    // 啟動生命週期監聽
    initLifecycleObserver();
  }

  @override
  void onAppResumed() {
    super.onAppResumed();
    _appOpenAdRepository.showAdIfAvailable();
  }
}
