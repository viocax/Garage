import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/router/app_router.dart';
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
import 'package:garage/widgets/banner_ad_widget.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.dashboardAccentRed,
                ),
              );
            }

            // Handle side effects
            if (state.sideEffect != null) {
              switch (state.sideEffect!) {
                case RecordsSideEffect.navigateToAddVehicle:
                  _navigateToAddVehicle(context);
                  break;
                case RecordsSideEffect.navigateToAddRecord:
                  _navigateToAddRecord(context, state.currentVehicle);
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
            title: Text(
              'records.title'.tr(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentColor,
              ),
            ),
            actions: state.vehicles.isNotEmpty
                ? [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.whiteTransparent08,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.whiteTransparent10,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => _navigateToAddVehicle(context),
                        icon: const Icon(
                          Icons.add,
                          color: AppTheme.accentColor,
                          size: 20,
                        ),
                        tooltip: 'vehicle.addVehicleTooltip'.tr(),
                      ),
                    ),
                  ]
                : null,
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  state.vehicles.isNotEmpty
                      ? PrimaryActionButton(
                          onPressed: () => _navigateToAddRecord(
                            context,
                            state.currentVehicle,
                          ),
                          text: 'records.addRecord'.tr(),
                          icon: Icons.add,
                        )
                      : PrimaryActionButton(
                          onPressed: () => _navigateToAddVehicle(context),
                          text: 'records.addVehicle'.tr(),
                        ),
                  const SizedBox(height: 12),
                  const BannerAdWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToAddVehicle(BuildContext context) async {
    final vehicle = await context.pushPathWithResult<Vehicle>(
      AppPath.addVehicle,
    );
    if (vehicle != null && context.mounted) {
      context.read<RecordsBloc>().add(
        LoadVehicleRecord(vehicleId: vehicle.vehicleId),
      );
    }
  }

  Future<void> _navigateToAddRecord(
    BuildContext context,
    Vehicle vehicle,
  ) async {
    final record = await context.pushPathWithResult<VehicleRecord>(
      AppPath.addRecord,
      extra: vehicle,
    );
    if (record != null && context.mounted) {
      context.read<RecordsBloc>().add(AddRecord(record));
    }
  }

  Future<void> _navigateToEditVehicle(BuildContext context) async {
    final state = context.read<RecordsBloc>().state;
    if (state.vehicles.isEmpty) return;

    // Use centralized getter instead of duplicating lookup logic
    final currentVehicle = state.currentVehicle;
    if (currentVehicle.vehicleId.isEmpty) return;

    // Navigate with result
    final updatedVehicle = await context.pushPathWithResult<Vehicle>(
      AppPath.addVehicle,
      extra: currentVehicle,
    );

    if (updatedVehicle != null && context.mounted) {
      // Reload is sufficient as it fetches fresh data
      context.read<RecordsBloc>().add(
        LoadVehicleRecord(vehicleId: updatedVehicle.vehicleId),
      );
    }
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
  final NumberFormat _odometerFormat = NumberFormat('#,###');

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
        // Page Indicator
        if (widget.vehicles.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: _PageIndicator(
              count: widget.vehicles.length,
              currentPage: _currentPage,
            ),
          ),
        // PageView
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
              final odometerString = _odometerFormat.format(vehicle.currentKm);
              final unitString =
                  widget.unitString; // ✅ Fix: Use unit from widget
              final fuelEfficiency = FuelEfficiencyDisplay.calculateFromVehicle(
                vehicle,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topLeft,
                      colors: [
                        AppTheme.blackTransparent60,
                        AppTheme.blackTransparent90,
                        AppTheme.recordCardWineRed,
                        AppTheme.recordCardCaramelOrange60,
                      ],
                      stops: const [0.0, 0.65, 0.85, 1.0], // 保持深色區塊比例
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.whiteTransparent20,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Hero Section (包含统计数据)
                      _HeroSection(
                        textSecondary: AppTheme.dashboardTextSecondary,
                        textPrimary: AppTheme.dashboardTextPrimary,
                        vehicle: vehicle,
                        odometerString: odometerString,
                        unitString: unitString,
                        fuelEfficiency: fuelEfficiency,
                      ),

                      const SizedBox(height: 16),

                      // 分隔线
                      Container(height: 1, color: AppTheme.whiteTransparent15),

                      const SizedBox(height: 16),

                      // 2. Recent Activity Section
                      Expanded(
                        child: _RecentActivitySection(
                          textPrimary: AppTheme.dashboardTextPrimary,
                          textSecondary: AppTheme.dashboardTextSecondary,
                          cardBg: AppTheme.dashboardCardBg,
                          accentRed: AppTheme.dashboardAccentRed,
                          vehicle: vehicle,
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
  final FuelEfficiencyDisplay fuelEfficiency;

  const _HeroSection({
    required this.textSecondary,
    required this.textPrimary,
    required this.vehicle,
    required this.odometerString,
    required this.unitString,
    required this.fuelEfficiency,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate health color
    Color healthColor = AppTheme.statusGreen;
    if (vehicle.maintenanceHealth < 0.2) {
      healthColor = AppTheme.dashboardAccentRed;
    } else if (vehicle.maintenanceHealth < 0.5) {
      healthColor = AppTheme.statusOrange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vehicle Name (Leading) and License Plate (Trailing) in same row
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  vehicle.carName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {
                context.read<RecordsBloc>().add(const ClickEditVehicleButton());
              },
              icon: Icon(Icons.edit_outlined, size: 18, color: textSecondary),
              tooltip: 'common.edit'.tr(),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.whiteTransparent08,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.whiteTransparent10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.statusGreen,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.statusGreenTransparent60,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    vehicle.licensePlate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Mileage Display
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'records.currentMileage'.tr(),
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  odometerString,
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  unitString,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Stats Row (本月花費 | 平均油耗)
        Row(
          children: [
            _StatChip(
              icon: Icons.payments_outlined,
              label: 'records.thisMonth'.tr(),
              value: vehicle.spentThisMonth,
              textSecondary: textSecondary,
              textPrimary: textPrimary,
            ),
            // 只有當有油耗數據時才顯示分隔線和油耗 chip
            if (fuelEfficiency.hasData) ...[
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 24,
                color: AppTheme.whiteTransparent20,
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.local_gas_station_outlined,
                label: 'records.fuelEfficiency'.tr(),
                value: fuelEfficiency.format(),
                textSecondary: textSecondary,
                textPrimary: textPrimary,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        // Maintenance Health Bar
        if (vehicle.maintenanceIntervalKm > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.whiteTransparent08,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'records.nextService'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'records.kmLeft'.tr(
                        args: [NumberFormat('#,###').format(vehicle.remindKm)],
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: healthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: vehicle.maintenanceHealth,
                    backgroundColor: AppTheme.blackTransparent20,
                    color: healthColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textSecondary;
  final Color textPrimary;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.textSecondary,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: textSecondary),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: textSecondary)),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatefulWidget {
  final Color textPrimary;
  final Color textSecondary;
  final Color cardBg;
  final Color accentRed;
  final Vehicle vehicle;
  final List<VehicleRecord> records;

  const _RecentActivitySection({
    required this.textPrimary,
    required this.textSecondary,
    required this.cardBg,
    required this.accentRed,
    required this.vehicle,
    required this.records,
  });

  @override
  State<_RecentActivitySection> createState() => _RecentActivitySectionState();
}

class _RecentActivitySectionState extends State<_RecentActivitySection> {
  static const int _maxDisplayCount = 5;
  static const double _cardHeight = 70.0;

  late FixedExtentScrollController _wheelController;
  late List<VehicleRecord> _sortedRecords;

  @override
  void initState() {
    super.initState();
    _wheelController = FixedExtentScrollController();
    _updateSortedRecords();
  }

  @override
  void didUpdateWidget(_RecentActivitySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.records != oldWidget.records) {
      _updateSortedRecords();
    }
  }

  void _updateSortedRecords() {
    // ✅ Optimization: Sort records only when list changes
    final sorted = List<VehicleRecord>.from(widget.records)
      ..sort((a, b) => b.date.compareTo(a.date));
    _sortedRecords = sorted.take(_maxDisplayCount).toList();
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and view all button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'records.recentActivity'.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.textPrimary,
              ),
            ),
            if (_sortedRecords.isNotEmpty)
              GestureDetector(
                onTap: () {
                  context.pushPathWithResult(
                    AppPath.allRecords,
                    extra: widget.vehicle,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'common.viewAll'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: widget.accentRed,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: widget.accentRed,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Wheel Card Stack
        if (_sortedRecords.isEmpty)
          _buildEmptyState()
        else
          Expanded(child: _buildWheelCards()),
      ],
    );
  }

  Widget _buildWheelCards() {
    final records = _sortedRecords;

    return ListWheelScrollView.useDelegate(
      controller: _wheelController,
      itemExtent: _cardHeight + 8, // 卡片高度 + 間距
      diameterRatio: 2.5, // 滾輪直徑比例，越小弧度越大
      perspective: 0.003, // 透視效果
      physics: const FixedExtentScrollPhysics(),
      overAndUnderCenterOpacity: 0.5, // 非中心項的透明度
      squeeze: 1.0, // 壓縮程度
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: records.length,
        builder: (context, index) {
          final record = records[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _WheelTransactionCard(
              icon: record.type.icon,
              iconColor: record.type.color,
              title: record.title,
              date: DateFormat.MMMd().format(record.date),
              cost: record.formattedCost,
              accentRed: widget.accentRed,
              textSecondary: widget.textSecondary,
              cardHeight: _cardHeight,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: widget.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 16),
            Text(
              'records.noRecords'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: widget.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WheelTransactionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String date;
  final String cost;
  final Color accentRed;
  final Color textSecondary;
  final double cardHeight;

  const _WheelTransactionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.cost,
    required this.accentRed,
    required this.textSecondary,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.blackTransparent60, AppTheme.blackTransparent90],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.whiteTransparent20, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackTransparent20,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
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
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppTheme.accentColor,
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
                  backgroundColor: AppTheme.whiteTransparent10,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'common.loading'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'records.loadingVehicles'.tr(),
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
            Text(
              'records.noExpenseRecords'.tr(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'records.startTrackingDesc'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
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
            color: AppTheme.whiteTransparent80,
          ),
          // Car icon inside wallet
          Positioned(
            left: 55,
            top: 72,
            child: Icon(
              Icons.directions_car,
              size: 55,
              color: AppTheme.whiteTransparent90,
            ),
          ),
          // Plus button at bottom right
          Positioned(
            right: 15,
            bottom: 5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.whiteTransparent90,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.blackTransparent20,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                size: 36,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentPage;

  const _PageIndicator({required this.count, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentColor
                : AppTheme.whiteTransparent20,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
