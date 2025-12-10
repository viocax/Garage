import 'package:equatable/equatable.dart';
import 'package:garage/core/models/vehicle_record.dart';

sealed class AddRecordEvent extends Equatable {
  const AddRecordEvent();

  @override
  List<Object?> get props => [];
}

class RecordTypeChanged extends AddRecordEvent {
  final RecordType type;

  const RecordTypeChanged(this.type);

  @override
  List<Object> get props => [type];
}

class AmountChanged extends AddRecordEvent {
  final double amount;

  const AmountChanged(this.amount);

  @override
  List<Object> get props => [amount];
}

class DateChanged extends AddRecordEvent {
  final DateTime date;

  const DateChanged(this.date);

  @override
  List<Object> get props => [date];
}

class KmChanged extends AddRecordEvent {
  final int km;

  const KmChanged(this.km);

  @override
  List<Object> get props => [km];
}

class NextMaintenanceKmChanged extends AddRecordEvent {
  final int km;

  const NextMaintenanceKmChanged(this.km);

  @override
  List<Object> get props => [km];
}

class MaintenanceItemToggled extends AddRecordEvent {
  final String item;

  const MaintenanceItemToggled(this.item);

  @override
  List<Object> get props => [item];
}

class NoteChanged extends AddRecordEvent {
  final String note;

  const NoteChanged(this.note);

  @override
  List<Object> get props => [note];
}

class SubmitRecord extends AddRecordEvent {
  const SubmitRecord();
}
