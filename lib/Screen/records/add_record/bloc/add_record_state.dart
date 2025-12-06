import 'package:equatable/equatable.dart';
import 'package:garage/core/models/vehicle_record.dart';

enum AddRecordStatus { initial, valid, submitting, success, failure }

class AddRecordState extends Equatable {
  final RecordType recordType;
  final double amount;
  final DateTime date;
  final int mileage;
  final int? nextMaintenanceMileage;
  final List<String> selectedMaintenanceItems;
  final String note;
  final AddRecordStatus status;
  final String? errorMessage;
  final VehicleRecord? createdRecord;

  const AddRecordState({
    this.recordType =
        RecordType.maintenance, // Default to maintenance as per HTML
    this.amount = 0,
    required this.date,
    this.mileage = 0,
    this.nextMaintenanceMileage,
    this.selectedMaintenanceItems = const [],
    this.note = '',
    this.status = AddRecordStatus.initial,
    this.errorMessage,
    this.createdRecord,
  });

  AddRecordState copyWith({
    RecordType? recordType,
    double? amount,
    DateTime? date,
    int? mileage,
    int? nextMaintenanceMileage,
    List<String>? selectedMaintenanceItems,
    String? note,
    AddRecordStatus? status,
    String? errorMessage,
    VehicleRecord? createdRecord,
  }) {
    return AddRecordState(
      recordType: recordType ?? this.recordType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      nextMaintenanceMileage:
          nextMaintenanceMileage ?? this.nextMaintenanceMileage,
      selectedMaintenanceItems:
          selectedMaintenanceItems ?? this.selectedMaintenanceItems,
      note: note ?? this.note,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdRecord: createdRecord ?? this.createdRecord,
    );
  }

  @override
  List<Object?> get props => [
    recordType,
    amount,
    date,
    mileage,
    nextMaintenanceMileage,
    selectedMaintenanceItems,
    note,
    status,
    errorMessage,
    createdRecord,
  ];
}
