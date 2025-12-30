import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        body: CustomScrollView(
          slivers: [
            // Custom App Bar with gradient
            SliverAppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              pinned: true,
              expandedHeight: 280,
              leading: _CloseButton(),
              flexibleSpace: FlexibleSpaceBar(background: _HeroSection()),
            ),
            // Form content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  children: const [
                    _InputFieldCard(
                      stepNumber: 1,
                      icon: Icons.drive_file_rename_outline,
                      child: _VehicleNameInput(),
                    ),
                    SizedBox(height: 16),
                    _InputFieldCard(
                      stepNumber: 2,
                      icon: Icons.confirmation_number_outlined,
                      child: _LicensePlateInput(),
                    ),
                    SizedBox(height: 16),
                    _InputFieldCard(
                      stepNumber: 3,
                      icon: Icons.speed_outlined,
                      child: _MileageInput(),
                    ),
                    SizedBox(height: 16),
                    _InputFieldCard(
                      stepNumber: 4,
                      icon: Icons.build_outlined,
                      isOptional: true,
                      child: _MaintenanceIntervalInput(),
                    ),
                    SizedBox(height: 32),
                    _SubmitButton(),
                    SizedBox(height: 16),
                    _SkipText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: IconButton(
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          backgroundColor: AppTheme.whiteTransparent10,
          shape: const CircleBorder(),
        ),
        icon: const Icon(
          Icons.close,
          color: AppTheme.dashboardTextPrimary,
          size: 20,
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.dashboardAccentRed.withValues(alpha: 0.15),
            AppTheme.dashboardBg,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Animated car icon with glow effect
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.dashboardAccentRed.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Inner circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.whiteTransparent10,
                        AppTheme.whiteTransparent05,
                      ],
                    ),
                    border: Border.all(
                      color: AppTheme.whiteTransparent15,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    size: 50,
                    color: AppTheme.dashboardAccentRed.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '新增車輛',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.dashboardTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '填寫車輛資訊開始記錄',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.dashboardTextSecondary.withValues(alpha: 0.8),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputFieldCard extends StatelessWidget {
  final int stepNumber;
  final IconData icon;
  final Widget child;
  final bool isOptional;

  const _InputFieldCard({
    required this.stepNumber,
    required this.icon,
    required this.child,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.dashboardCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.whiteTransparent08),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with step number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.whiteTransparent06),
              ),
            ),
            child: Row(
              children: [
                // Step number badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.dashboardAccentRed,
                        AppTheme.dashboardAccentRed.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.dashboardAccentRed.withValues(
                          alpha: 0.3,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.whiteTransparent06,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: AppTheme.dashboardTextSecondary,
                  ),
                ),
                const Spacer(),
                if (isOptional)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.whiteTransparent06,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '選填',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.dashboardTextSecondary.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Input content
          Padding(padding: const EdgeInsets.all(20), child: child),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.dashboardTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '幫你的愛車取個獨特的名字',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.dashboardTextSecondary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 14),
        _StyledTextField(
          hintText: '例如：小紅、戰神 R35',
          onChanged: (value) {
            context.read<AddVehicleBloc>().add(VehicleNameChanged(value));
          },
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.dashboardTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '輸入車輛的車牌號碼',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.dashboardTextSecondary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 14),
        _StyledTextField(
          hintText: 'ABC-1234',
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            _UpperCaseTextFormatter(),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\-]')),
          ],
          onChanged: (value) {
            context.read<AddVehicleBloc>().add(LicensePlateChanged(value));
          },
        ),
      ],
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.dashboardTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '可從儀表板上查看目前總里程',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.dashboardTextSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 14),
            _StyledTextField(
              hintText: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              suffix: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.whiteTransparent08,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.speedUnit.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.dashboardTextSecondary,
                  ),
                ),
              ),
              onChanged: (value) {
                final km = int.tryParse(value) ?? 0;
                context.read<AddVehicleBloc>().add(VehicleKmChanged(km));
              },
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
          '保養週期',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.dashboardTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '例如：每 5000 或 10000 公里保養一次',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.dashboardTextSecondary.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 14),
        _StyledTextField(
          hintText: '5000',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          suffix: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.whiteTransparent08,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'km',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.dashboardTextSecondary,
              ),
            ),
          ),
          onChanged: (value) {
            final interval = int.tryParse(value) ?? 0;
            context.read<AddVehicleBloc>().add(
              MaintenanceIntervalChanged(interval),
            );
          },
        ),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final String hintText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const _StyledTextField({
    required this.hintText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: AppTheme.dashboardAccentRed,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppTheme.dashboardTextPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.inputBg.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.whiteTransparent08),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppTheme.dashboardAccentRed,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppTheme.placeholderGray.withValues(alpha: 0.6),
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 8), child: suffix)
            : null,
        suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
      ),
      onChanged: onChanged,
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
          text: '完成新增',
          icon: Icons.check_circle_outline,
        );
      },
    );
  }
}

class _SkipText extends StatelessWidget {
  const _SkipText();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
          size: 14,
          color: AppTheme.dashboardTextSecondary.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Text(
          '之後可以在設定中編輯車輛資訊',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.dashboardTextSecondary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
