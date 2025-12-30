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
            title: const Text(
              '我的車庫',
              style: TextStyle(
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
                        tooltip: '新增車輛',
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
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: state.vehicles.isNotEmpty
                  ? PrimaryActionButton(
                      onPressed: () =>
                          _navigateToAddRecord(context, state.currentVehicle),
                      text: '新增紀錄',
                      icon: Icons.add,
                    )
                  : PrimaryActionButton(
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

  Future<void> _navigateToAddRecord(
    BuildContext context,
    Vehicle vehicle,
  ) async {
    final record = await context.goPathWithResult<VehicleRecord>(
      AppPath.addRecord,
      extra: vehicle,
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
              final odometerString = vehicle.currentKm.toString();
              final unitString = 'km'; // 這邊要根據使用者那邊資料

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
                      // 1. Hero Section
                      _HeroSection(
                        textSecondary: AppTheme.dashboardTextSecondary,
                        textPrimary: AppTheme.dashboardTextPrimary,
                        vehicle: vehicle,
                        odometerString: odometerString,
                        unitString: unitString,
                      ),

                      const SizedBox(height: 20),

                      // 2. Stats Grid
                      _StatsGrid(
                        textSecondary: AppTheme.dashboardTextSecondary,
                        textPrimary: AppTheme.dashboardTextPrimary,
                        vehicle: vehicle,
                      ),

                      const SizedBox(height: 16),

                      // 3. Recent Activity Stack
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
            const SizedBox(width: 12),
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
        const SizedBox(height: 24),
        // Mileage Display
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '目前里程',
              style: TextStyle(
                fontSize: 12,
                color: textSecondary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  odometerString,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  unitString,
                  style: TextStyle(
                    fontSize: 18,
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
  final Color textSecondary;
  final Color textPrimary;
  final Vehicle vehicle;

  const _StatsGrid({
    required this.textSecondary,
    required this.textPrimary,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: '本月花費',
            value: vehicle.spentThisMonth,
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            isPrimary: false,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          height: 100,
          child: _StatCard(
            label: '平均油耗',
            value: '9.2 L',
            textSecondary: textSecondary,
            textPrimary: textPrimary,
            isPrimary: false,
            isSquare: true,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color textSecondary;
  final Color textPrimary;
  final bool isPrimary;
  final bool isSquare;

  const _StatCard({
    required this.label,
    required this.value,
    required this.textSecondary,
    required this.textPrimary,
    this.isPrimary = false,
    this.isSquare = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = isPrimary ? 100.0 : 100.0;
    final fontSize = isPrimary ? 28.0 : (isSquare ? 20.0 : 18.0);
    final labelSize = isPrimary ? 11.0 : 10.0;
    final padding = isPrimary ? 20.0 : 20.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label 詳情（待開發）'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Ink(
          height: isSquare ? null : cardHeight,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isPrimary
                  ? [AppTheme.whiteTransparent12, AppTheme.whiteTransparent06]
                  : [AppTheme.whiteTransparent10, AppTheme.whiteTransparent05],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.whiteTransparent20, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.blackTransparent10,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isSquare
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            mainAxisAlignment: isSquare
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: labelSize,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              if (isSquare) const SizedBox(height: 8),
              Row(
                mainAxisAlignment: isSquare
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: isSquare ? TextAlign.center : TextAlign.start,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
  Widget build(BuildContext context) {
    // Sort records by date descending
    final sortedRecords = List<VehicleRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.whiteTransparent08, AppTheme.whiteTransparent04],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.whiteTransparent15, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackTransparent10,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and view all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '近期動態',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              if (sortedRecords.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    context.goPathWithResult(AppPath.allRecords, extra: vehicle);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '查看全部',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: accentRed,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 10, color: accentRed),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Scrollable Transaction List
          if (sortedRecords.isEmpty)
            _buildEmptyState()
          else
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: sortedRecords.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final record = sortedRecords[index];
                  return _TransactionItem(
                    icon: record.type.icon,
                    iconColor: record.type.color,
                    title: record.title,
                    date: '${record.date.month}月${record.date.day}日',
                    cost: record.formattedCost,
                    accentRed: accentRed,
                    textSecondary: textSecondary,
                  );
                },
              ),
            ),
        ],
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
              color: textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 16),
            Text(
              '目前沒有維修紀錄',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
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
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('記錄詳情: $title（待開發）'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
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
        ),
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
              const Text(
                '載入中...',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
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
                color: AppTheme.accentColor,
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
