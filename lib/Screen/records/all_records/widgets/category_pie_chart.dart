import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';
import '../bloc/all_records_state.dart';

class CategoryPieChart extends StatelessWidget {
  final List<CategoryExpenseData> data;

  const CategoryPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.whiteTransparent08, AppTheme.whiteTransparent04],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.whiteTransparent15),
      ),
      child: Column(
        children: [
          Text(
            'records.categories'.tr(),
            style: TextStyle(fontSize: 12, color: AppTheme.systemGray),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'common.noData'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.systemGray,
                      ),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 20,
                      sections: data
                          .map(
                            (d) => PieChartSectionData(
                              color: d.color,
                              value: d.totalCost,
                              title: '${d.percentage.toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentColor,
                              ),
                              radius: 35,
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          // Legend
          if (data.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data
                  .map((d) => _LegendItem(color: d.color, label: d.label))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppTheme.systemGray),
        ),
      ],
    );
  }
}
