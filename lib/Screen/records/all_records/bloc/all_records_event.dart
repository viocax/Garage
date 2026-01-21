import 'package:equatable/equatable.dart';
import 'all_records_state.dart';

sealed class AllRecordsEvent extends Equatable {
  const AllRecordsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all records for a vehicle
final class LoadAllRecords extends AllRecordsEvent {
  const LoadAllRecords();
}

/// Filter by specific month
final class SelectMonth extends AllRecordsEvent {
  final MonthFilter? month;

  const SelectMonth(this.month);

  @override
  List<Object?> get props => [month];
}

/// Toggle record type filter (fuel, maintenance, other)
final class ToggleTypeFilter extends AllRecordsEvent {
  final String typeName;

  const ToggleTypeFilter(this.typeName);

  @override
  List<Object> get props => [typeName];
}

/// Clear all filters
final class ClearFilters extends AllRecordsEvent {
  const ClearFilters();
}

/// Update pro status
final class UpdateProStatus extends AllRecordsEvent {
  final bool isPro;
  const UpdateProStatus(this.isPro);

  @override
  List<Object?> get props => [isPro];
}
