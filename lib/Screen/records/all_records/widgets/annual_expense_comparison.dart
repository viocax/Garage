import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';
import '../bloc/all_records_state.dart';

class AnnualExpenseComparison extends StatelessWidget {
  final List<AnnualExpenseData> data;

  const AnnualExpenseComparison({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.whiteTransparent05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.whiteTransparent10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '年度花費對比',
            style: TextStyle(fontSize: 12, color: AppTheme.systemGray),
          ),
          const SizedBox(height: 12),
          ...data.reversed.map((d) {
            final isLast = data.indexOf(d) == 0;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${d.year} 年',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$${d.totalCost.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.dashboardAccentRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(color: AppTheme.whiteTransparent10, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}
