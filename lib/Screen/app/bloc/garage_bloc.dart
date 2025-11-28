import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/screen/app/bloc/garage_event.dart';
import 'package:garage/screen/app/bloc/garage_state.dart';

class GarageBloc extends Bloc<GarageEvent, GarageState> {
  GarageBloc() : super(const GarageInitialState()) {
    on<TabChanged>(_onTabChanged);
  }

  void _onTabChanged(TabChanged event, Emitter<GarageState> emit) {
    emit(GarageTabChanged(event.tabbarType));
  }
}
