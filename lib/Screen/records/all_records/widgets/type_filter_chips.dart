import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/theme/app_theme.dart';

import '../bloc/all_records_bloc.dart';
import '../bloc/all_records_event.dart';

class TypeFilterChips extends StatelessWidget {
  final Set<String> selectedTypes;

  const TypeFilterChips({super.key, required this.selectedTypes});

  static const _types = [
    ('fuel', '加油', Icons.local_gas_station, AppTheme.recordTypeFuelColor),
    ('maintenance', '保養', Icons.build, AppTheme.recordTypeMaintenanceColor),
    ('other', '其他', Icons.receipt, AppTheme.recordTypeOtherColor),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            '篩選：',
            style: TextStyle(fontSize: 12, color: AppTheme.systemGray),
          ),
          const SizedBox(width: 8),
          ..._types.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                typeName: type.$1,
                label: type.$2,
                icon: type.$3,
                color: type.$4,
                isSelected:
                    selectedTypes.isEmpty || selectedTypes.contains(type.$1),
                onTap: () {
                  context.read<AllRecordsBloc>().add(ToggleTypeFilter(type.$1));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String typeName;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.typeName,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? color.withValues(alpha: 0.15) : AppTheme.inputBg,
          border: Border.all(
            color: isSelected ? color : AppTheme.whiteTransparent08,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? color : AppTheme.systemGray,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : AppTheme.systemGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
