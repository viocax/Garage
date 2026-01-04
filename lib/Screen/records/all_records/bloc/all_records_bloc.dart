import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/repositories/subscription_repository.dart';
import 'package:garage/theme/app_theme.dart';

import 'all_records_event.dart';
import 'all_records_state.dart';

class AllRecordsBloc extends Bloc<AllRecordsEvent, AllRecordsState> {
  final Vehicle vehicle;
  final SubscriptionRepository _subscriptionRepository;
  StreamSubscription<bool>? _subscriptionSubscription;

  AllRecordsBloc({
    required this.vehicle,
    required SubscriptionRepository subscriptionRepository,
  }) : _subscriptionRepository = subscriptionRepository,
       super(const AllRecordsState()) {
    on<LoadAllRecords>(_onLoadAllRecords);
    on<SelectMonth>(_onSelectMonth);
    on<ToggleTypeFilter>(_onToggleTypeFilter);
    on<ClearFilters>(_onClearFilters);
    on<UpdateProStatus>(_onUpdateProStatus);

    // Listen for pro status changes
    _subscriptionSubscription = _subscriptionRepository.isProStream.listen((
      isPro,
    ) {
      add(UpdateProStatus(isPro));
    });

    // Auto-load on creation
    add(const LoadAllRecords());
  }

  Future<void> _onLoadAllRecords(
    LoadAllRecords event,
    Emitter<AllRecordsState> emit,
  ) async {
    emit(state.copyWith(status: AllRecordsStatus.loading));

    try {
      // Ensure records are loaded from database
      await vehicle.records.load();
      final records = vehicle.records.toList();

      // Sort by date descending
      records.sort((a, b) => b.date.compareTo(a.date));

      // Generate available months from records
      final availableMonths = _extractAvailableMonths(records);

      // Calculate chart data

      final monthlyData = _calculateMonthlyExpense(records);
      final categoryData = _calculateCategoryExpense(records);
      final fuelEfficiencyData = _calculateFuelEfficiencyData(records);
      final annualData = _calculateAnnualExpense(records);
      final totalExpense = records.fold(0.0, (sum, r) => sum + r.cost);
      final isPro = await _subscriptionRepository.isPro();

      emit(
        state.copyWith(
          status: AllRecordsStatus.success,
          allRecords: records,
          filteredRecords: records,
          availableMonths: availableMonths,
          monthlyExpenseData: monthlyData,
          categoryExpenseData: categoryData,
          fuelEfficiencyData: fuelEfficiencyData,
          annualExpenseData: annualData,
          totalExpense: totalExpense,
          recordCount: records.length,
          isPro: isPro,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AllRecordsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSelectMonth(SelectMonth event, Emitter<AllRecordsState> emit) {
    if (event.month == null) {
      emit(state.copyWith(clearSelectedMonth: true));
    } else {
      emit(state.copyWith(selectedMonth: event.month));
    }
    _applyFilters(emit);
  }

  void _onToggleTypeFilter(
    ToggleTypeFilter event,
    Emitter<AllRecordsState> emit,
  ) {
    final newTypes = Set<String>.from(state.selectedTypes);
    if (newTypes.contains(event.typeName)) {
      newTypes.remove(event.typeName);
    } else {
      newTypes.add(event.typeName);
    }
    if (newTypes.isEmpty) {
      return;
    }
    emit(state.copyWith(selectedTypes: newTypes));
    _applyFilters(emit);
  }

  void _onClearFilters(ClearFilters event, Emitter<AllRecordsState> emit) {
    final monthlyData = _calculateMonthlyExpense(state.allRecords);
    final categoryData = _calculateCategoryExpense(state.allRecords);

    final totalExpense = state.allRecords.fold(0.0, (sum, r) => sum + r.cost);
    emit(
      state.copyWith(
        clearSelectedMonth: true,
        selectedTypes: {},
        filteredRecords: state.allRecords,
        totalExpense: totalExpense,
        recordCount: state.allRecords.length,
        monthlyExpenseData: monthlyData,
        categoryExpenseData: categoryData,
      ),
    );
  }

  void _applyFilters(Emitter<AllRecordsState> emit) {
    var filtered = state.allRecords.toList();

    // Apply month filter
    if (state.selectedMonth != null) {
      final month = state.selectedMonth!;
      filtered = filtered
          .where(
            (r) => r.date.year == month.year && r.date.month == month.month,
          )
          .toList();
    }

    // Apply type filter
    if (state.selectedTypes.isNotEmpty) {
      filtered = filtered
          .where((r) => state.selectedTypes.contains(r.typeName))
          .toList();
    }

    final monthlyData = _calculateMonthlyExpense(filtered);
    final categoryData = _calculateCategoryExpense(filtered);
    final fuelEfficiencyData = _calculateFuelEfficiencyData(filtered);
    final annualData = _calculateAnnualExpense(filtered);

    final totalExpense = filtered.fold(0.0, (sum, r) => sum + r.cost);
    emit(
      state.copyWith(
        filteredRecords: filtered,
        totalExpense: totalExpense,
        recordCount: filtered.length,
        monthlyExpenseData: monthlyData,
        categoryExpenseData: categoryData,
        fuelEfficiencyData: fuelEfficiencyData,
        annualExpenseData: annualData,
      ),
    );
  }

  List<MonthFilter> _extractAvailableMonths(List<VehicleRecord> records) {
    final months = <MonthFilter>{};
    for (final record in records) {
      months.add(MonthFilter(year: record.date.year, month: record.date.month));
    }
    // Sort descending
    final list = months.toList();
    list.sort((a, b) {
      final yearCompare = b.year.compareTo(a.year);
      if (yearCompare != 0) return yearCompare;
      return b.month.compareTo(a.month);
    });
    return list;
  }

  List<MonthlyExpenseData> _calculateMonthlyExpense(
    List<VehicleRecord> records,
  ) {
    if (records.isEmpty) return [];

    // Group by month and calculate totals
    final monthlyTotals = <String, double>{};

    for (final record in records) {
      final key =
          '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + record.cost;
    }

    // Take last 6 months for chart
    final sortedKeys = monthlyTotals.keys.toList()..sort();
    final recentKeys = sortedKeys.length > 6
        ? sortedKeys.sublist(sortedKeys.length - 6)
        : sortedKeys;

    return recentKeys.map((key) {
      final parts = key.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      return MonthlyExpenseData(
        monthLabel: DateFormat.MMM().format(date),
        totalCost: monthlyTotals[key]!,
      );
    }).toList();
  }

  List<CategoryExpenseData> _calculateCategoryExpense(
    List<VehicleRecord> records,
  ) {
    if (records.isEmpty) return [];

    final categoryTotals = <String, double>{
      'fuel': 0,
      'maintenance': 0,
      'other': 0,
    };

    for (final record in records) {
      categoryTotals[record.typeName] =
          (categoryTotals[record.typeName] ?? 0) + record.cost;
    }

    final total = categoryTotals.values.fold(0.0, (a, b) => a + b);

    const colorMap = {
      'fuel': AppTheme.recordTypeFuelColor,
      'maintenance': AppTheme.recordTypeMaintenanceColor,
      'other': AppTheme.recordTypeOtherColor,
    };

    final labelMap = {
      'fuel': 'recordType.fuel'.tr(),
      'maintenance': 'recordType.maintenance'.tr(),
      'other': 'recordType.other'.tr(),
    };

    return categoryTotals.entries
        .where((e) => e.value > 0)
        .map(
          (e) => CategoryExpenseData(
            typeName: e.key,
            label: labelMap[e.key]!,
            totalCost: e.value,
            percentage: total > 0 ? (e.value / total * 100) : 0,
            color: colorMap[e.key]!,
          ),
        )
        .toList();
  }

  List<FuelEfficiencyData> _calculateFuelEfficiencyData(
    List<VehicleRecord> records,
  ) {
    // 取得所有加油紀錄，依照日期從舊到新排列（為了計算里程差）
    final fuelRecords = records.where((r) => r.typeName == 'fuel').toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (fuelRecords.length < 2) return [];

    final result = <FuelEfficiencyData>[];

    for (int i = 1; i < fuelRecords.length; i++) {
      final current = fuelRecords[i];
      final previous = fuelRecords[i - 1];

      final efficiency = current.calculateFuelEfficiency(previous.km);
      if (efficiency > 0) {
        result.add(
          FuelEfficiencyData(date: current.date, kmPerLiter: efficiency),
        );
      }
    }

    // 回傳時保持日期從舊到新（適合折線圖）
    return result;
  }

  List<AnnualExpenseData> _calculateAnnualExpense(List<VehicleRecord> records) {
    if (records.isEmpty) return [];

    final annualTotals = <int, double>{};
    for (final record in records) {
      final year = record.date.year;
      annualTotals[year] = (annualTotals[year] ?? 0) + record.cost;
    }

    final sortedYears = annualTotals.keys.toList()..sort();
    return sortedYears
        .map(
          (year) =>
              AnnualExpenseData(year: year, totalCost: annualTotals[year]!),
        )
        .toList();
  }

  void _onUpdateProStatus(
    UpdateProStatus event,
    Emitter<AllRecordsState> emit,
  ) {
    emit(state.copyWith(isPro: event.isPro));
  }

  @override
  Future<void> close() {
    _subscriptionSubscription?.cancel();
    return super.close();
  }
}
