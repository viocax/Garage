import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:garage/theme/grid_background_painter.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/screen/records/bloc/records_bloc.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/screen/speed/speedCamera/widgets/vehicle_picker_dialog.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: ThemedStatusBar(
        theme: StatusBarTheme.light,
        child: Scaffold(
          backgroundColor: AppTheme.dashboardBg,
          body: Stack(
            children: [
              // Background Grid Pattern
              Positioned.fill(
                child: CustomPaint(painter: GridBackgroundPainter()),
              ),
              SafeArea(
                child: BlocBuilder<RecordsBloc, RecordsState>(
                  builder: (context, state) {
                    return switch (state) {
                      RecordsLoading() => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      RecordsEmpty() => _RecordsContent(
                        vehicle: Vehicle.empty(),
                        vehicles: const [],
                        currentVehicleId: '',
                      ),
                      RecordsError(:final message) => Center(
                        child: Text('Error: $message'),
                      ),
                      RecordsLoaded(
                        :final currentVehicle,
                        :final vehicles,
                        :final currentVehicleId,
                      ) =>
                        _RecordsContent(
                          vehicle: currentVehicle,
                          vehicles: vehicles,
                          currentVehicleId: currentVehicleId,
                        ),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordsContent extends StatelessWidget {
  final Vehicle vehicle;
  final List<Vehicle> vehicles;
  final String currentVehicleId;

  const _RecordsContent({
    required this.vehicle,
    required this.vehicles,
    required this.currentVehicleId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Section
                _HeroSection(
                  textSecondary: AppTheme.dashboardTextSecondary,
                  textPrimary: AppTheme.dashboardTextPrimary,
                  vehicle: vehicle,
                  vehicles: vehicles,
                  currentVehicleId: currentVehicleId,
                ),

                const SizedBox(height: 24),

                // 2. Stats Grid
                _StatsGrid(
                  cardBg: AppTheme.dashboardCardBg,
                  textSecondary: AppTheme.dashboardTextSecondary,
                  textPrimary: AppTheme.dashboardTextPrimary,
                  accentRed: AppTheme.dashboardAccentRed,
                  vehicle: vehicle,
                ),

                const SizedBox(height: 24),

                // 3. Add Button
                _AddButton(accentRed: AppTheme.dashboardAccentRed),

                const SizedBox(height: 40),

                // 4. Recent Activity Stack
                _RecentActivitySection(
                  textPrimary: AppTheme.dashboardTextPrimary,
                  textSecondary: AppTheme.dashboardTextSecondary,
                  cardBg: AppTheme.dashboardCardBg,
                  accentRed: AppTheme.dashboardAccentRed,
                  records: vehicle.records,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Color textSecondary;
  final Color textPrimary;
  final Vehicle vehicle;
  final List<Vehicle> vehicles;
  final String currentVehicleId;

  const _HeroSection({
    required this.textSecondary,
    required this.textPrimary,
    required this.vehicle,
    required this.vehicles,
    required this.currentVehicleId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Car Image with Gradient Mask
        SizedBox(
          height: 160,
          width: double.infinity,
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0.0, 0.15, 0.75, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: Center(
              child: Icon(
                Icons.directions_car_filled,
                size: 100,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onLongPress: () => _showVehiclePicker(context),
          child: Column(
            children: [
              Text(
                vehicle.carName.toUpperCase(),
                style: TextStyle(
                  fontSize: 18, // ~1.1rem
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.dashboardGradientStart,
                    AppTheme.dashboardGradientEnd,
                  ],
                ).createShader(bounds),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      vehicle.currentMileage.toString().replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]},',
                      ),
                      style: const TextStyle(
                        fontSize: 45, // ~2.8rem
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'km',
                      style: TextStyle(fontSize: 16, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVehiclePicker(BuildContext context) {
    showPickerDialog(
      context: context,
      options: vehicles,
      currentSelectedIdentifier: currentVehicleId,
      onSelected: (option) {
        final vehicle = option as Vehicle;
        context.read<RecordsBloc>().add(SwitchVehicle(vehicle.id));
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Color cardBg;
  final Color textSecondary;
  final Color textPrimary;
  final Color accentRed;
  final Vehicle vehicle;

  const _StatsGrid({
    required this.cardBg,
    required this.textSecondary,
    required this.textPrimary,
    required this.accentRed,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Spent Card
          Expanded(
            flex: 6, // 1.2fr
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '總花費 Total Spent',
                    style: TextStyle(
                      fontSize: 13.6, // ~0.85rem
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    vehicle.totalSpent,
                    style: TextStyle(
                      fontSize: 24, // 1.5rem
                      fontWeight: FontWeight.w700,
                      color: accentRed,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '↑',
                        style: TextStyle(color: accentRed, fontSize: 11.2),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.spentThisMonth,
                        style: TextStyle(
                          fontSize: 12.5, // ~0.78rem
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Health Card
          Expanded(
            flex: 4, // 0.8fr
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '保養狀態',
                    style: TextStyle(
                      fontSize: 13.6,
                      color: textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Ring
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                              width: 4,
                            ),
                          ),
                        ),
                        // Progress Ring
                        Transform.rotate(
                          angle: -math.pi / 2,
                          child: SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              value: vehicle.maintenanceHealth,
                              strokeWidth: 4,
                              color: accentRed,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        Text(
                          '${(vehicle.maintenanceHealth * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 17.6, // 1.1rem
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '距離保養\n還剩 ${vehicle.distanceToNextMaintenance} km',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5, // 0.72rem
                      color: textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final Color accentRed;

  const _AddButton({required this.accentRed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: accentRed.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<RecordsBloc>().add(const ClickAddButton());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: accentRed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18),
            SizedBox(width: 8),
            Text(
              '新增紀錄',
              style: TextStyle(
                fontSize: 15.2, // 0.95rem
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  final Color textPrimary;
  final Color textSecondary;
  final Color cardBg;
  final Color accentRed;
  final List<VehicleRecord> records;

  const _RecentActivitySection({
    required this.textPrimary,
    required this.textSecondary,
    required this.cardBg,
    required this.accentRed,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    // Sort records by date descending
    final sortedRecords = List<VehicleRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Take top 3
    final displayRecords = sortedRecords.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '近期動態',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 15),
        // Stack Container
        SizedBox(
          height: 140, // Enough space for stack
          child: displayRecords.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    for (int i = 0; i < displayRecords.length; i++)
                      _buildStackedCard(i, displayRecords[i]),
                  ].reversed.toList(), // Reverse to paint bottom cards first
                ),
        ),
        if (displayRecords.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '輕觸卡片查看完整歷史',
              style: TextStyle(
                fontSize: 12,
                color: textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 32,
            color: textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 12),
          Text(
            '目前沒有維修紀錄',
            style: TextStyle(
              fontSize: 14,
              color: textSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackedCard(int index, VehicleRecord record) {
    // index 0 is top card
    double topOffset = 0;
    double scale = 1.0;
    double opacity = 1.0;
    Color bgColor = AppTheme.dashboardCardBg;

    if (index == 1) {
      topOffset = 11;
      scale = 0.96;
      opacity = 0.65;
      bgColor = AppTheme.dashboardCardBgStacked1;
    } else if (index == 2) {
      topOffset = 22;
      scale = 0.92;
      opacity = 0.4;
      bgColor = AppTheme.dashboardCardBgStacked2;
    }

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: _ActivityCard(
            icon: record.type.icon,
            iconColor: record.type.color,
            title: record.title,
            date: '${record.date.year}/${record.date.month}/${record.date.day}',
            cost: record.formattedCost,
            cardBg: bgColor,
            accentRed: AppTheme.dashboardAccentRed,
            textSecondary: AppTheme.dashboardTextSecondary,
            isTop: index == 0,
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;
  final String cost;
  final Color cardBg;
  final Color accentRed;
  final Color textSecondary;
  final bool isTop;

  const _ActivityCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.cost,
    required this.cardBg,
    required this.accentRed,
    required this.textSecondary,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: isTop
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.4, // 0.9rem
                    color: Colors.white,
                  ),
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12, // 0.75rem
                      color: textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (cost.isNotEmpty)
            Text(
              cost,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.4,
                color: accentRed,
              ),
            ),
        ],
      ),
    );
  }
}
