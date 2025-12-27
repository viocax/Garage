import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/widgets/primary_action_button.dart';

import 'bloc/add_vehicle_bloc.dart';

class AddVehiclePage extends StatelessWidget {
  const AddVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddVehicleBloc(),
      child: BlocListener<AddVehicleBloc, AddVehicleState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AddVehicleStatus.success &&
              state.createdVehicle != null) {
            Navigator.pop(context, state.createdVehicle);
          } else if (state.status == AddVehicleStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? '發生錯誤'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: const _AddVehicleViewContent(),
      ),
    );
  }
}

class _AddVehicleViewContent extends StatelessWidget {
  const _AddVehicleViewContent();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.dashboardBg,
        appBar: AppBar(
        backgroundColor: AppTheme.dashboardBg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          label: const Text('返回'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.dashboardAccentRed,
            padding: EdgeInsets.zero,
          ),
        ),
        leadingWidth: 80,
        title: const Text(
          '新增車輛',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppTheme.dashboardTextPrimary,
          ),
        ),
        actions: const [
          SizedBox(width: 80), // Spacer for symmetry
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              SizedBox(height: 20),
              _HeroSection(),
              SizedBox(height: 24),
              _FormCard(),
              SizedBox(height: 24),
              _SubmitButton(),
              SizedBox(height: 16),
              _SkipText(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Car illustration
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.inputBg.withValues(alpha: 0.6),
                AppTheme.darkSurface.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(color: AppTheme.whiteTransparent08),
          ),
          child: Stack(
            children: [
              // Shine effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.4, -0.4),
                      radius: 1.0,
                      colors: [
                        AppTheme.whiteTransparent08,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5],
                    ),
                  ),
                ),
              ),
              // Car emoji
              Center(
                child: Icon(
                  Icons.directions_car_filled,
                  size: 100,
                  color: AppTheme.whiteTransparent50,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '添加你的愛車',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.dashboardTextPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '開始記錄保養、改裝與花費',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.dashboardTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.dashboardCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.whiteTransparent08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _VehicleNameInput(),
          SizedBox(height: 4),
          Divider(color: AppTheme.dashboardTextSecondary, height: 1),
          SizedBox(height: 20),
          _LicensePlateInput(),
          SizedBox(height: 4),
          Divider(color: AppTheme.dashboardTextSecondary, height: 1),
          SizedBox(height: 20),
          _MileageInput(),
          SizedBox(height: 4),
          Divider(color: AppTheme.dashboardTextSecondary, height: 1),
          SizedBox(height: 20),
          _MaintenanceIntervalInput(),
        ],
      ),
    );
  }
}

class _VehicleNameInput extends StatelessWidget {
  const _VehicleNameInput();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '車輛名稱',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.dashboardTextSecondary,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          cursorColor: AppTheme.accentColor,
          style: const TextStyle(
            fontSize: 18,
            color: AppTheme.dashboardTextPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.whiteTransparent08),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.whiteTransparent08),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.dashboardAccentRed),
            ),
            contentPadding: const EdgeInsets.all(16),
            hintText: '愛車名稱',
            hintStyle: const TextStyle(color: AppTheme.placeholderGray),
          ),
          onChanged: (value) {
            context.read<AddVehicleBloc>().add(VehicleNameChanged(value));
          },
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '幫你的愛車取個名字吧',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.dashboardTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LicensePlateInput extends StatelessWidget {
  const _LicensePlateInput();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '車牌號碼',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.dashboardTextSecondary,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          cursorColor: AppTheme.accentColor,
          style: const TextStyle(
            fontSize: 18,
            color: AppTheme.dashboardTextPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.whiteTransparent08),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.whiteTransparent08),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.dashboardAccentRed),
            ),
            contentPadding: const EdgeInsets.all(16),
            hintText: 'ABC-1234',
            hintStyle: const TextStyle(color: AppTheme.placeholderGray),
          ),
          onChanged: (value) {
            context.read<AddVehicleBloc>().add(LicensePlateChanged(value));
          },
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '輸入車輛的車牌號碼',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.dashboardTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _MileageInput extends StatelessWidget {
  const _MileageInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddVehicleBloc, AddVehicleState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '目前里程',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.dashboardTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  cursorColor: AppTheme.accentColor,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.dashboardTextPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.whiteTransparent08),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.whiteTransparent08),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.dashboardAccentRed,
                      ),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(16, 16, 50, 16),
                    hintText: '0',
                    hintStyle: const TextStyle(color: AppTheme.placeholderGray),
                  ),
                  onChanged: (value) {
                    final km = int.tryParse(value) ?? 0;
                    context.read<AddVehicleBloc>().add(
                      VehicleKmChanged(km),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    state.speedUnit.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.dashboardTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                '可從儀表板上查看目前總里程',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.dashboardTextSecondary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MaintenanceIntervalInput extends StatelessWidget {
  const _MaintenanceIntervalInput();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '保養週期 (選填)',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.dashboardTextSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              cursorColor: AppTheme.accentColor,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.dashboardTextPrimary,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.whiteTransparent08),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.whiteTransparent08),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.dashboardAccentRed,
                  ),
                ),
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 50, 16),
                hintText: '0',
                hintStyle: const TextStyle(color: AppTheme.placeholderGray),
              ),
              onChanged: (value) {
                final interval = int.tryParse(value) ?? 0;
                context.read<AddVehicleBloc>().add(
                  MaintenanceIntervalChanged(interval),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                'km',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.dashboardTextSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '例如：每 5000 或 10000 公里保養一次',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.dashboardTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddVehicleBloc, AddVehicleState>(
      builder: (context, state) {
        return PrimaryActionButton(
          onPressed: () {
            context.read<AddVehicleBloc>().add(const SubmitVehicle());
          },
          text: '新增車輛',
          icon: Icons.check,
          isLoading: state.status == AddVehicleStatus.submitting,
        );
      },
    );
  }
}

class _SkipText extends StatelessWidget {
  const _SkipText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '之後可以在設定中編輯車輛資訊',
      style: TextStyle(fontSize: 14, color: AppTheme.dashboardTextSecondary),
      textAlign: TextAlign.center,
    );
  }
}
