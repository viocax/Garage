import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/screen/app/home/bloc/garage_home_event.dart';
import 'package:garage/screen/app/home/bloc/garage_home_state.dart';

class GarageHomeBloc extends Bloc<GarageHomeEvent, GarageHomeState> {
  GarageHomeBloc() : super(const GarageHomeInitialState()) {
    on<TabChanged>(_onTabChanged);
  }

  void _onTabChanged(TabChanged event, Emitter<GarageHomeState> emit) {
    emit(GarageHomeTabChanged(event.tabbarType));
  }
}
