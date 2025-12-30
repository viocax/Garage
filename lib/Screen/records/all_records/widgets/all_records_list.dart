import 'package:flutter/material.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/theme/app_theme.dart';

class AllRecordsList extends StatelessWidget {
  final List<VehicleRecord> records;

  const AllRecordsList({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppTheme.systemGray.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '沒有符合條件的記錄',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.systemGray.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final record = records[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecordItem(record: record),
            );
          },
          childCount: records.length,
        ),
      ),
    );
  }
}

class _RecordItem extends StatelessWidget {
  final VehicleRecord record;

  const _RecordItem({required this.record});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to record detail
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.whiteTransparent08,
                AppTheme.whiteTransparent04,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.whiteTransparent10, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: record.type.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  record.type.icon,
                  size: 20,
                  color: record.type.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${record.date.year}/${record.date.month}/${record.date.day}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.systemGray,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                record.formattedCost,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.dashboardAccentRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
