import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';
import '../bloc/all_records_state.dart';

class MonthFilterSheet extends StatelessWidget {
  final List<MonthFilter> availableMonths;
  final MonthFilter? selectedMonth;
  final Function(MonthFilter?) onSelect;

  const MonthFilterSheet({
    super.key,
    required this.availableMonths,
    required this.selectedMonth,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.whiteTransparent30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '選擇月份',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onSelect(null);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '全部',
                    style: TextStyle(color: AppTheme.dashboardAccentRed),
                  ),
                ),
              ],
            ),
          ),
          // Month list
          SizedBox(
            height: 300,
            child: availableMonths.isEmpty
                ? const Center(
                    child: Text(
                      '暫無記錄',
                      style: TextStyle(color: AppTheme.systemGray),
                    ),
                  )
                : ListView.builder(
                    itemCount: availableMonths.length,
                    itemBuilder: (context, index) {
                      final month = availableMonths[index];
                      final isSelected = selectedMonth == month;

                      return ListTile(
                        leading: Icon(
                          Icons.calendar_month,
                          color: isSelected
                              ? AppTheme.dashboardAccentRed
                              : AppTheme.systemGray,
                        ),
                        title: Text(
                          month.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.dashboardAccentRed
                                : AppTheme.accentColor,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                                color: AppTheme.dashboardAccentRed,
                              )
                            : null,
                        onTap: () {
                          onSelect(month);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
