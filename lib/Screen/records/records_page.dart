import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/router/app_router.dart';
import 'dart:math' as math;
import 'package:garage/theme/grid_background_painter.dart';
import 'package:garage/theme/themed_status_bar.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/screen/records/bloc/records_bloc.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/screen/app/home/bloc/garage_home_bloc.dart';
import 'package:garage/screen/app/home/bloc/garage_home_state.dart';
import 'package:garage/core/models/tabbar_type.dart';
import 'package:garage/widgets/primary_action_button.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecordsBloc(),
      child: BlocListener<GarageHomeBloc, GarageHomeState>(
        listener: (context, state) {
          // When tab changes to RecordsTab, reload the data
          if (state.tabbarType is RecordsTab) {
            context.read<RecordsBloc>().add(LoadVehicleRecord());
          }
        },
        child: BlocConsumer<RecordsBloc, RecordsState>(
          listener: (context, state) {
            // Handle error message
            if (state.errorMessage != null) {
              // TODO: Show toast or snackbar
              debugPrint('Error: ${state.errorMessage}');
            }

            // Handle side effects
            if (state.sideEffect != null) {
              switch (state.sideEffect!) {
                case RecordsSideEffect.navigateToAddVehicle:
                  _navigateToAddVehicle(context);
                  break;
                case RecordsSideEffect.navigateToAddRecord:
                  _navigateToAddRecord(context);
                  break;
                case RecordsSideEffect.navigateToEditVehicle:
                  _navigateToEditVehicle(context);
                  break;
              }
            }
          },
          builder: (context, state) {
            return _body(context, state);
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, RecordsState state) {
    return Theme(
      data: AppTheme.darkTheme,
      child: ThemedStatusBar(
        theme: StatusBarTheme.light,
        child: Scaffold(
          backgroundColor: AppTheme.dashboardBg,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              '車輛花費',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Stack(
            children: [
              // Background Grid Pattern
              Positioned.fill(
                child: CustomPaint(painter: GridBackgroundPainter()),
              ),
              // Loading or Content
              if (state.isLoading)
                const SafeArea(child: _LoadingView())
              else
                SafeArea(
                  child: _RecordsContent(
                    vehicle: state.currentVehicle,
                    vehicles: state.vehicles,
                    currentVehicleId: state.currentVehicleId,
                    odometerString: state.odometerString,
                    unitString: state.unitString,
                  ),
                ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryActionButton(
                onPressed: () => _navigateToAddVehicle(context),
                text: '新增車輛',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToAddVehicle(BuildContext context) async {
    final vehicle = await context.goPathWithResult<Vehicle>(AppPath.addVehicle);
    if (vehicle != null && context.mounted) {
      context.read<RecordsBloc>().add(
        LoadVehicleRecord(vehicleId: vehicle.vehicleId),
      );
    }
  }

  Future<void> _navigateToAddRecord(BuildContext context) async {
    final record = await context.goPathWithResult<VehicleRecord>(
      AppPath.addRecord,
    );
    if (record != null && context.mounted) {
      context.read<RecordsBloc>().add(AddRecord(record));
    }
  }

  Future<void> _navigateToEditVehicle(BuildContext context) async {
    // await context.goPathWithResult(AppPath.vehicleManagement);
    // if (context.mounted) {
    //   // Reload vehicle data after returning from vehicle management
    //   context.read<RecordsBloc>().add(const LoadVehicleRecord());
    // }
  }
}

class _RecordsContent extends StatefulWidget {
  final Vehicle vehicle;
  final List<Vehicle> vehicles;
  final String currentVehicleId;
  final String odometerString;
  final String unitString;

  const _RecordsContent({
    required this.vehicle,
    required this.vehicles,
    required this.currentVehicleId,
    required this.odometerString,
    required this.unitString,
  });

  @override
  State<_RecordsContent> createState() => _RecordsContentState();
}

class _RecordsContentState extends State<_RecordsContent> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.vehicles.indexWhere(
      (v) => v.vehicleId == widget.currentVehicleId,
    );
    if (_currentPage == -1) _currentPage = 0;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void didUpdateWidget(_RecordsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update page when vehicle changes externally
    if (widget.currentVehicleId != oldWidget.currentVehicleId) {
      final newIndex = widget.vehicles.indexWhere(
        (v) => v.vehicleId == widget.currentVehicleId,
      );
      if (newIndex != -1 && newIndex != _currentPage) {
        _currentPage = newIndex;
        _pageController.animateToPage(
          newIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vehicles.isEmpty) {
      return const Center(child: _EmptyRecordsView());
    }

    return Column(
      children: [
        // Page Indicator - Fixed at top
        if (widget.vehicles.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Center(
              child: _PageIndicator(
                count: widget.vehicles.length,
                currentIndex: _currentPage,
              ),
            ),
          ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.vehicles.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              // Switch vehicle when page changes
              final vehicle = widget.vehicles[index];
              context.read<RecordsBloc>().add(SwitchVehicle(vehicle.vehicleId));
            },
            itemBuilder: (context, index) {
              final vehicle = widget.vehicles[index];
              final odometerString = vehicle.currentKm.toString();
              final unitString = 'km'; // 這邊要根據使用者那邊資料

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.blackTransparent60,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.whiteTransparent20,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Hero Section
                      _HeroSection(
                        textSecondary: AppTheme.dashboardTextSecondary,
                        textPrimary: AppTheme.dashboardTextPrimary,
                        vehicle: vehicle,
                        odometerString: odometerString,
                        unitString: unitString,
                      ),

                      const SizedBox(height: 32),

                      // 2. Stats Grid
                      _StatsGrid(
                        cardBg: AppTheme.dashboardCardBg,
                        textSecondary: AppTheme.dashboardTextSecondary,
                        textPrimary: AppTheme.dashboardTextPrimary,
                        accentRed: AppTheme.dashboardAccentRed,
                        vehicle: vehicle,
                      ),

                      const SizedBox(height: 24),

                      // 3. Recent Activity Stack
                      Expanded(
                        child: _RecentActivitySection(
                          textPrimary: AppTheme.dashboardTextPrimary,
                          textSecondary: AppTheme.dashboardTextSecondary,
                          cardBg: AppTheme.dashboardCardBg,
                          accentRed: AppTheme.dashboardAccentRed,
                          records: vehicle.records.toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
  final String odometerString;
  final String unitString;

  const _HeroSection({
    required this.textSecondary,
    required this.textPrimary,
    required this.vehicle,
    required this.odometerString,
    required this.unitString,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Vehicle Badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF22C55E),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vehicle.licensePlate,
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                vehicle.carName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Mileage Display
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '目前里程',
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  odometerString,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  unitString,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
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
          Expanded(
            child: _StatCard(
              label: '本月花費',
              value: vehicle.spentThisMonth,
              textSecondary: textSecondary,
              textPrimary: textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: '本年花費',
              value: vehicle.totalSpent,
              textSecondary: textSecondary,
              textPrimary: textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: '平均油耗',
              value: '9.2 L',
              textSecondary: textSecondary,
              textPrimary: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color textSecondary;
  final Color textPrimary;

  const _StatCard({
    required this.label,
    required this.value,
    required this.textSecondary,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              // textTransform: TextTransform.uppercase,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ],
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Transaction List
          if (displayRecords.isEmpty)
            _buildEmptyState()
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < displayRecords.length; i++) ...[
                  _TransactionItem(
                    icon: displayRecords[i].type.icon,
                    iconColor: displayRecords[i].type.color,
                    title: displayRecords[i].title,
                    date:
                        '${displayRecords[i].date.month}月${displayRecords[i].date.day}日',
                    cost: displayRecords[i].formattedCost,
                    accentRed: accentRed,
                    textSecondary: textSecondary,
                  ),
                  if (i < displayRecords.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 24,
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
}

class _TransactionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;
  final String cost;
  final Color accentRed;
  final Color textSecondary;

  const _TransactionItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.cost,
    required this.accentRed,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
          Text(
            cost,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: accentRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == currentIndex;
          return Container(
            margin: EdgeInsets.only(left: index == 0 ? 0 : 6),
            width: isActive ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.dashboardAccentRed
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.blackTransparent60,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.whiteTransparent10, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Loading Indicator
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  color: AppTheme.dashboardAccentRed,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '載入中...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '正在讀取您的車輛資料',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.systemGray.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRecordsView extends StatelessWidget {
  const _EmptyRecordsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.blackTransparent60,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.whiteTransparent10, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _EmptyIllustration(),
            const SizedBox(height: 48),
            const Text(
              '目前沒有車輛花費紀錄',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '開始記錄您的車輛相關費用，以更好地管理您的開支。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.systemGray,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Wallet Outline
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 150,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          // Car icon inside wallet
          Positioned(
            left: 55,
            top: 72,
            child: Icon(
              Icons.directions_car,
              size: 55,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          // Plus button at bottom right
          Positioned(
            right: 15,
            bottom: 5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, size: 36, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
