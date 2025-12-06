import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import 'package:flutter/foundation.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsInitial()) {
    on<SettingsEvent>(_onEvent);
  }

  Future<void> _onEvent(
    SettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    switch (event) {
      case ExportData():
        _onExportData(emit);
      case ClearData():
        _onClearData(emit);
    }
  }


  void _onExportData(Emitter<SettingsState> emit) {
    // TODO: Implement export data logic
    debugPrint('Export Data Triggered');
  }

  void _onClearData(Emitter<SettingsState> emit) {
    // TODO: Implement clear data logic
    debugPrint('Clear Data Triggered');
  }
}
