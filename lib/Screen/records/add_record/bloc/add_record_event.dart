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

// 保養項目批次新增相關事件
class AddMaintenanceEntry extends AddRecordEvent {
  const AddMaintenanceEntry();
}

class RemoveMaintenanceEntry extends AddRecordEvent {
  final int index;

  const RemoveMaintenanceEntry(this.index);

  @override
  List<Object> get props => [index];
}

class UpdateMaintenanceEntry extends AddRecordEvent {
  final int index;
  final String? item;
  final double? amount;
  final int? nextMaintenanceKm;
  final String? note;

  const UpdateMaintenanceEntry({
    required this.index,
    this.item,
    this.amount,
    this.nextMaintenanceKm,
    this.note,
  });

  @override
  List<Object?> get props => [index, item, amount, nextMaintenanceKm, note];
}

class NoteChanged extends AddRecordEvent {
  final String note;

  const NoteChanged(this.note);

  @override
  List<Object> get props => [note];
}

// 加油相關事件
class FuelTypeChanged extends AddRecordEvent {
  final FuelType fuelType;

  const FuelTypeChanged(this.fuelType);

  @override
  List<Object> get props => [fuelType];
}

class FuelAmountChanged extends AddRecordEvent {
  final double amount;

  const FuelAmountChanged(this.amount);

  @override
  List<Object> get props => [amount];
}

class PricePerLiterChanged extends AddRecordEvent {
  final double price;

  const PricePerLiterChanged(this.price);

  @override
  List<Object> get props => [price];
}

class RemainingFuelChanged extends AddRecordEvent {
  final int remaining;

  const RemainingFuelChanged(this.remaining);

  @override
  List<Object> get props => [remaining];
}

class SubmitRecord extends AddRecordEvent {
  const SubmitRecord();
}

/// 載入使用者設定事件
class LoadUserSettings extends AddRecordEvent {
  const LoadUserSettings();
}
