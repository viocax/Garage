import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:garage/core/models/vehicle_record.dart';

enum AllRecordsStatus { initial, loading, success, failure }

/// Filter model for month selection
class MonthFilter extends Equatable {
  final int year;
  final int month;

  const MonthFilter({required this.year, required this.month});

  String get displayName => '$year 年 $month 月';

  @override
  List<Object> get props => [year, month];
}

/// Data for monthly expense chart
class MonthlyExpenseData extends Equatable {
  final String monthLabel;
  final double totalCost;

  const MonthlyExpenseData({
    required this.monthLabel,
    required this.totalCost,
  });

  @override
  List<Object> get props => [monthLabel, totalCost];
}

/// Data for category pie chart
class CategoryExpenseData extends Equatable {
  final String typeName;
  final String label;
  final double totalCost;
  final double percentage;
  final Color color;

  const CategoryExpenseData({
    required this.typeName,
    required this.label,
    required this.totalCost,
    required this.percentage,
    required this.color,
  });

  @override
  List<Object> get props => [typeName, label, totalCost, percentage, color];
}

class AllRecordsState extends Equatable {
  final AllRecordsStatus status;
  final List<VehicleRecord> allRecords;
  final List<VehicleRecord> filteredRecords;

  // Filter state
  final MonthFilter? selectedMonth;
  final Set<String> selectedTypes;
  final List<MonthFilter> availableMonths;

  // Chart data
  final List<MonthlyExpenseData> monthlyExpenseData;
  final List<CategoryExpenseData> categoryExpenseData;

  // Summary
  final double totalExpense;
  final int recordCount;

  final String? errorMessage;

  const AllRecordsState({
    this.status = AllRecordsStatus.initial,
    this.allRecords = const [],
    this.filteredRecords = const [],
    this.selectedMonth,
    this.selectedTypes = const {},
    this.availableMonths = const [],
    this.monthlyExpenseData = const [],
    this.categoryExpenseData = const [],
    this.totalExpense = 0,
    this.recordCount = 0,
    this.errorMessage,
  });

  AllRecordsState copyWith({
    AllRecordsStatus? status,
    List<VehicleRecord>? allRecords,
    List<VehicleRecord>? filteredRecords,
    MonthFilter? selectedMonth,
    bool clearSelectedMonth = false,
    Set<String>? selectedTypes,
    List<MonthFilter>? availableMonths,
    List<MonthlyExpenseData>? monthlyExpenseData,
    List<CategoryExpenseData>? categoryExpenseData,
    double? totalExpense,
    int? recordCount,
    String? errorMessage,
  }) {
    return AllRecordsState(
      status: status ?? this.status,
      allRecords: allRecords ?? this.allRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      selectedMonth:
          clearSelectedMonth ? null : (selectedMonth ?? this.selectedMonth),
      selectedTypes: selectedTypes ?? this.selectedTypes,
      availableMonths: availableMonths ?? this.availableMonths,
      monthlyExpenseData: monthlyExpenseData ?? this.monthlyExpenseData,
      categoryExpenseData: categoryExpenseData ?? this.categoryExpenseData,
      totalExpense: totalExpense ?? this.totalExpense,
      recordCount: recordCount ?? this.recordCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allRecords,
        filteredRecords,
        selectedMonth,
        selectedTypes,
        availableMonths,
        monthlyExpenseData,
        categoryExpenseData,
        totalExpense,
        recordCount,
        errorMessage,
      ];
}
