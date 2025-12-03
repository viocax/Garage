import 'package:flutter/material.dart';

enum RecordType {
  fuel,
  maintenance,
  modification,
  other;

  String get label {
    switch (this) {
      case RecordType.fuel:
        return '加油';
      case RecordType.maintenance:
        return '保養';
      case RecordType.modification:
        return '改裝';
      case RecordType.other:
        return '其他';
    }
  }

  IconData get icon {
    switch (this) {
      case RecordType.fuel:
        return Icons.local_gas_station;
      case RecordType.maintenance:
        return Icons.build;
      case RecordType.modification:
        return Icons.settings;
      case RecordType.other:
        return Icons.receipt;
    }
  }

  Color get color {
    switch (this) {
      case RecordType.fuel:
        return const Color(0xFFD9923B); // Orange
      case RecordType.maintenance:
        return const Color(0xFF7A8A99); // Grey Blue
      case RecordType.modification:
        return const Color(0xFFD64045); // Red
      case RecordType.other:
        return const Color(0xFF8E8E93); // Grey
    }
  }
}

class VehicleRecord {
  final String id;
  final RecordType type;
  final String title;
  final DateTime date;
  final double cost;
  final int mileage;
  final String? notes;

  const VehicleRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.cost,
    required this.mileage,
    this.notes,
  });

  // Helper to format cost
  String get formattedCost =>
      '\$${cost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

  // Helper to format mileage
  String get formattedMileage =>
      '${mileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km';
}
