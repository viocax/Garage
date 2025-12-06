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

class MileageChanged extends AddRecordEvent {
  final int mileage;

  const MileageChanged(this.mileage);

  @override
  List<Object> get props => [mileage];
}

class NextMaintenanceMileageChanged extends AddRecordEvent {
  final int mileage;

  const NextMaintenanceMileageChanged(this.mileage);

  @override
  List<Object> get props => [mileage];
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
