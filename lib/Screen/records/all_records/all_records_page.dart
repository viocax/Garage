import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/theme/grid_background_painter.dart';

import 'bloc/all_records_bloc.dart';
import 'bloc/all_records_event.dart';
import 'bloc/all_records_state.dart';
import 'widgets/monthly_expense_chart.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/type_filter_chips.dart';
import 'widgets/month_filter_sheet.dart';
import 'widgets/all_records_list.dart';

class AllRecordsPage extends StatelessWidget {
  final Vehicle vehicle;

  const AllRecordsPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllRecordsBloc(vehicle: vehicle),
      child: const _AllRecordsContent(),
    );
  }
}

class _AllRecordsContent extends StatelessWidget {
  const _AllRecordsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dashboardBg,
      appBar: AppBar(
        backgroundColor: AppTheme.dashboardBg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppTheme.dashboardAccentRed,
          ),
        ),
        title: const Text(
          '全部記錄',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppTheme.accentColor,
          ),
        ),
        actions: [
          BlocBuilder<AllRecordsBloc, AllRecordsState>(
            builder: (context, state) {
              final hasFilter =
                  state.selectedMonth != null || state.selectedTypes.isNotEmpty;
              return IconButton(
                onPressed: () => _showFilterSheet(context, state),
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: AppTheme.dashboardAccentRed,
                    ),
                    if (hasFilter)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.systemGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Grid Pattern
          Positioned.fill(
            child: CustomPaint(painter: GridBackgroundPainter()),
          ),
          // Content
          SafeArea(
            child: BlocBuilder<AllRecordsBloc, AllRecordsState>(
              builder: (context, state) {
                if (state.status == AllRecordsStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.dashboardAccentRed,
                    ),
                  );
                }

                if (state.status == AllRecordsStatus.failure) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? '載入失敗',
                      style: const TextStyle(color: AppTheme.systemGray),
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    // Summary Section
                    SliverToBoxAdapter(
                      child: _SummarySection(state: state),
                    ),

                    // Charts Section
                    SliverToBoxAdapter(
                      child: _ChartsSection(state: state),
                    ),

                    // Active Filters Display
                    if (state.selectedMonth != null)
                      SliverToBoxAdapter(
                        child: _ActiveFilterBadge(
                          label: state.selectedMonth!.displayName,
                          onClear: () {
                            context.read<AllRecordsBloc>().add(const SelectMonth(null));
                          },
                        ),
                      ),

                    // Type Filter Chips
                    SliverToBoxAdapter(
                      child: TypeFilterChips(
                        selectedTypes: state.selectedTypes,
                      ),
                    ),

                    // Records List
                    AllRecordsList(records: state.filteredRecords),

                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, AllRecordsState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return MonthFilterSheet(
          availableMonths: state.availableMonths,
          selectedMonth: state.selectedMonth,
          onSelect: (month) {
            context.read<AllRecordsBloc>().add(SelectMonth(month));
          },
        );
      },
    );
  }
}

class _SummarySection extends StatelessWidget {
  final AllRecordsState state;

  const _SummarySection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.whiteTransparent10,
              AppTheme.whiteTransparent05,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.whiteTransparent20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '總花費',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.systemGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${state.totalExpense.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.dashboardAccentRed,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '記錄數',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.systemGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.recordCount} 筆',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartsSection extends StatelessWidget {
  final AllRecordsState state;

  const _ChartsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Monthly Bar Chart
          Expanded(
            flex: 2,
            child: MonthlyExpenseChart(
              data: state.monthlyExpenseData,
            ),
          ),
          const SizedBox(width: 12),
          // Category Pie Chart
          Expanded(
            flex: 1,
            child: CategoryPieChart(
              data: state.categoryExpenseData,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterBadge extends StatelessWidget {
  final String label;
  final VoidCallback onClear;

  const _ActiveFilterBadge({
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.dashboardAccentRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.dashboardAccentRed),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 14,
                  color: AppTheme.dashboardAccentRed,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.dashboardAccentRed,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppTheme.dashboardAccentRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
