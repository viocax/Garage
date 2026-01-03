import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/models/vehicle_record.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/theme/app_theme.dart';

import 'bloc/add_record_bloc.dart';
import 'bloc/add_record_event.dart';
import 'bloc/add_record_state.dart';

class AddRecordPage extends StatelessWidget {
  final Vehicle vehicle;

  const AddRecordPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddRecordBloc(vehicle: vehicle),
      child: BlocListener<AddRecordBloc, AddRecordState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AddRecordStatus.success &&
              state.createdRecord != null) {
            // 透過 Bloc 顯示廣告（封裝了邏輯判斷）
            context.read<AddRecordBloc>().showAd(
              onComplete: () {
                if (context.mounted) {
                  Navigator.pop(context, state.createdRecord);
                }
              },
            );
          } else if (state.status == AddRecordStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${'common.error'.tr()}: ${state.errorMessage}'),
              ),
            );
          }
        },
        child: const _AddRecordViewContent(),
      ),
    );
  }
}

class _AddRecordViewContent extends StatelessWidget {
  const _AddRecordViewContent();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.dashboardBg,
        appBar: AppBar(
          backgroundColor: AppTheme.dashboardBg,
          surfaceTintColor:
              Colors.transparent, // Disable Material 3 surface tint
          centerTitle: true,
          leading: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text('common.back'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.dashboardAccentRed,
              padding: EdgeInsets.zero,
            ),
          ),
          leadingWidth: 80, // Allow width for text
          title: Text(
            'addRecord.title'.tr(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentColor,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: () {
                  context.read<AddRecordBloc>().add(const SubmitRecord());
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.dashboardAccentRed,
                ),
                child: Text(
                  'common.save'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Slider
                const _CategorySection(),
                const SizedBox(height: 20),

                // Form Card
                BlocBuilder<AddRecordBloc, AddRecordState>(
                  buildWhen: (previous, current) =>
                      previous.recordType.typeName !=
                      current.recordType.typeName,
                  builder: (context, state) {
                    final isMaintenance =
                        state.recordType is RecordTypeMaintenance;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.dashboardCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.whiteTransparent08),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 金額輸入 - 保養類型不顯示（在各項目中輸入）
                          if (!isMaintenance) ...[
                            const _AmountInput(),
                            const SizedBox(height: 16),
                          ],
                          // 日期和里程
                          Row(
                            children: const [
                              Expanded(child: _DateInput()),
                              SizedBox(width: 12),
                              Expanded(child: _MileageInput()),
                            ],
                          ),
                          // 動態欄位（加油、保養等）
                          const _DynamicFields(),
                          // 備註 - 保養類型不顯示（在各項目中輸入）
                          if (!isMaintenance) ...[
                            const SizedBox(height: 16),
                            const _NoteInput(),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  // 用於類別選擇的模板（date 和 odometer 只是占位，實際值在 bloc 中設定）
  static final _placeholderDate = DateTime(2000);
  static const _placeholderOdometer = 0;

  static final categories = [
    RecordTypeFuel(
      data: FuelData(),
      recordDate: _placeholderDate,
      odometer: _placeholderOdometer,
    ),
    RecordTypeMaintenance(
      data: [],
      recordDate: _placeholderDate,
      odometer: _placeholderOdometer,
    ),
    RecordTypeOther(
      data: OtherData(),
      recordDate: _placeholderDate,
      odometer: _placeholderOdometer,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'addRecord.selectCategory'.tr(),
            style: const TextStyle(color: AppTheme.systemGray, fontSize: 13),
          ),
        ),
        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final type = categories[index];
              return _CategoryItem(type: type);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final RecordType type;

  const _CategoryItem({required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) =>
          previous.recordType.typeName != current.recordType.typeName,
      builder: (context, state) {
        final isSelected = state.recordType.typeName == type.typeName;

        return GestureDetector(
          onTap: () {
            context.read<AddRecordBloc>().add(RecordTypeChanged(type));
          },
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected
                      ? AppTheme.accentRedTransparent15
                      : AppTheme.inputBg,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.dashboardAccentRed
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  type.icon,
                  color: isSelected
                      ? AppTheme.dashboardAccentRed
                      : AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? AppTheme.dashboardAccentRed
                      : AppTheme.systemGray,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AmountInput extends StatefulWidget {
  const _AmountInput();

  @override
  State<_AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<_AmountInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) =>
          previous.amount != current.amount ||
          previous.recordType.typeName != current.recordType.typeName ||
          previous.isAmountManuallyEdited != current.isAmountManuallyEdited,
      builder: (context, state) {
        final isFuel = state.recordType is RecordTypeFuel;
        // 當為加油類型且金額未被手動編輯時，自動更新顯示的金額
        if (isFuel && !state.isAmountManuallyEdited) {
          final displayAmount = state.amount > 0
              ? state.amount.toStringAsFixed(0)
              : '';
          if (_controller.text != displayAmount) {
            _controller.text = displayAmount;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'addRecord.amount'.tr(),
                  style: const TextStyle(
                    color: AppTheme.systemGray,
                    fontSize: 13,
                  ),
                ),
                if (isFuel &&
                    !state.isAmountManuallyEdited &&
                    state.fuelAmount > 0 &&
                    state.pricePerLiter > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '= ${state.fuelAmount.toStringAsFixed(1)}L × ${state.pricePerLiter.toStringAsFixed(1)}元',
                      style: const TextStyle(
                        color: AppTheme.placeholderGray,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                const Positioned(
                  left: 16,
                  child: Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.systemGray,
                    ),
                  ),
                ),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.whiteTransparent08,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.whiteTransparent08,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.dashboardAccentRed,
                      ),
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(40, 14, 16, 14),
                    hintText: '0',
                    hintStyle: const TextStyle(color: AppTheme.placeholderGray),
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0;
                    context.read<AddRecordBloc>().add(AmountChanged(amount));
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) => previous.date != current.date,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'addRecord.date'.tr(),
              style: const TextStyle(color: AppTheme.systemGray, fontSize: 13),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppTheme.dashboardAccentRed,
                          onPrimary: AppTheme.accentColor,
                          surface: AppTheme.darkSurface,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  // ignore: use_build_context_synchronously
                  context.read<AddRecordBloc>().add(DateChanged(picked));
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.whiteTransparent08),
                ),
                child: Text(
                  '${state.date.year}-${state.date.month.toString().padLeft(2, '0')}-${state.date.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MileageInput extends StatelessWidget {
  const _MileageInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) => previous.km != current.km,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'addRecord.currentMileage'.tr(),
              style: const TextStyle(color: AppTheme.systemGray, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: state.km > 0 ? state.km.toString() : null,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16, color: AppTheme.accentColor),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: 'km',
                hintStyle: const TextStyle(color: AppTheme.placeholderGray),
              ),
              onChanged: (value) {
                final km = int.tryParse(value) ?? 0;
                context.read<AddRecordBloc>().add(KmChanged(km));
              },
            ),
          ],
        );
      },
    );
  }
}

class _DynamicFields extends StatelessWidget {
  const _DynamicFields();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) =>
          previous.recordType.typeName != current.recordType.typeName,
      builder: (context, state) {
        return switch (state.recordType) {
          RecordTypeFuel() => const _FuelFields(),
          RecordTypeMaintenance() => const _MaintenanceFields(),
          RecordTypeOther() => const SizedBox.shrink(),
        };
      },
    );
  }
}

/// 加油相關欄位
class _FuelFields extends StatelessWidget {
  const _FuelFields();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppTheme.whiteTransparent08),
          const SizedBox(height: 16),
          const _FuelTypeSelector(),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _FuelAmountInput()),
              SizedBox(width: 12),
              Expanded(child: _PricePerLiterInput()),
            ],
          ),
          const SizedBox(height: 16),
          const _RemainingFuelSlider(),
        ],
      ),
    );
  }
}

/// 燃油種類選擇器
class _FuelTypeSelector extends StatelessWidget {
  const _FuelTypeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) => previous.fuelType != current.fuelType,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'addRecord.fuelType'.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: FuelType.values.map((type) {
                final isSelected = state.fuelType == type;
                return GestureDetector(
                  onTap: () {
                    context.read<AddRecordBloc>().add(FuelTypeChanged(type));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected
                          ? AppTheme.accentRedTransparent15
                          : AppTheme.inputBg,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.dashboardAccentRed
                            : AppTheme.whiteTransparent08,
                      ),
                    ),
                    child: Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppTheme.dashboardAccentRed
                            : AppTheme.systemGray,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

/// 加油量輸入
class _FuelAmountInput extends StatelessWidget {
  const _FuelAmountInput();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'addRecord.fuelAmount'.tr(),
          style: const TextStyle(color: AppTheme.systemGray, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 16, color: AppTheme.accentColor),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintText: '0.0',
            hintStyle: const TextStyle(color: AppTheme.placeholderGray),
            suffixText: 'L',
            suffixStyle: const TextStyle(
              color: AppTheme.systemGray,
              fontSize: 14,
            ),
          ),
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0;
            context.read<AddRecordBloc>().add(FuelAmountChanged(amount));
          },
        ),
      ],
    );
  }
}

/// 每公升油價輸入
class _PricePerLiterInput extends StatelessWidget {
  const _PricePerLiterInput();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'addRecord.pricePerLiter'.tr(),
          style: const TextStyle(color: AppTheme.systemGray, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 16, color: AppTheme.accentColor),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintText: '0.0',
            hintStyle: const TextStyle(color: AppTheme.placeholderGray),
            suffixText: 'common.unitPricePerLiter'.tr(),
            suffixStyle: const TextStyle(
              color: AppTheme.systemGray,
              fontSize: 14,
            ),
          ),
          onChanged: (value) {
            final price = double.tryParse(value) ?? 0;
            context.read<AddRecordBloc>().add(PricePerLiterChanged(price));
          },
        ),
      ],
    );
  }
}

/// 剩餘油量 Slider
class _RemainingFuelSlider extends StatelessWidget {
  const _RemainingFuelSlider();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) =>
          previous.remainingFuel != current.remainingFuel,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'addRecord.remainingFuel'.tr(),
                  style: const TextStyle(
                    color: AppTheme.systemGray,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${state.remainingFuel}%',
                  style: const TextStyle(
                    color: AppTheme.dashboardAccentRed,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.dashboardAccentRed,
                inactiveTrackColor: AppTheme.inputBg,
                thumbColor: AppTheme.dashboardAccentRed,
                overlayColor: AppTheme.dashboardAccentRed.withValues(
                  alpha: 0.2,
                ),
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: Slider(
                value: state.remainingFuel.toDouble(),
                min: 50,
                max: 100,
                divisions: 50,
                onChanged: (value) {
                  context.read<AddRecordBloc>().add(
                    RemainingFuelChanged(value.round()),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '50%',
                  style: TextStyle(
                    color: AppTheme.placeholderGray,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '100%',
                  style: TextStyle(
                    color: AppTheme.placeholderGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// 保養相關欄位 - 支援批次新增
class _MaintenanceFields extends StatelessWidget {
  const _MaintenanceFields();

  static const maintenanceItems = [
    '機油',
    '機油濾芯',
    '空氣濾芯',
    '冷氣濾網',
    '煞車油',
    '變速箱油',
    '火星塞',
    '輪胎',
    '煞車來令',
    '電瓶',
    '其他',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) =>
          previous.maintenanceEntries != current.maintenanceEntries,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: AppTheme.whiteTransparent08),
              const SizedBox(height: 16),

              // 總金額顯示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'addRecord.maintenanceItems'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  Text(
                    'addRecord.total'.tr(
                      args: [state.totalMaintenanceAmount.toStringAsFixed(0)],
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.dashboardAccentRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 保養項目列表
              ...state.maintenanceEntries.asMap().entries.map((mapEntry) {
                final index = mapEntry.key;
                final entry = mapEntry.value;
                return _MaintenanceEntryCard(
                  key: ValueKey(index),
                  entry: entry,
                  index: index,
                  canDelete: state.maintenanceEntries.length > 1,
                  items: maintenanceItems,
                );
              }),

              // 新增項目按鈕
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  context.read<AddRecordBloc>().add(
                    const AddMaintenanceEntry(),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.dashboardAccentRed.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.dashboardAccentRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'addRecord.addMaintenanceItem'.tr(),
                        style: const TextStyle(
                          color: AppTheme.dashboardAccentRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 單一保養項目卡片
class _MaintenanceEntryCard extends StatelessWidget {
  final MaintenanceData entry;
  final int index;
  final bool canDelete;
  final List<String> items;

  const _MaintenanceEntryCard({
    super.key,
    required this.entry,
    required this.index,
    required this.canDelete,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.whiteTransparent08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題列：項目編號 + 刪除按鈕
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'addRecord.itemNumber'.tr(args: [(index + 1).toString()]),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.systemGray,
                ),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: () {
                    context.read<AddRecordBloc>().add(
                      RemoveMaintenanceEntry(index),
                    );
                  },
                  child: const Icon(
                    Icons.close,
                    color: AppTheme.systemGray,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 保養項目選擇
          Text(
            'addRecord.maintenanceItems'.tr(),
            style: const TextStyle(color: AppTheme.systemGray, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              final isSelected = entry.item == item;
              return GestureDetector(
                onTap: () {
                  context.read<AddRecordBloc>().add(
                    UpdateMaintenanceEntry(index: index, item: item),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? AppTheme.accentRedTransparent15
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.dashboardAccentRed
                          : AppTheme.whiteTransparent08,
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppTheme.dashboardAccentRed
                          : AppTheme.systemGray,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 金額和下次保養里程
          Row(
            children: [
              // 金額
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'addRecord.amount'.tr(),
                      style: const TextStyle(
                        color: AppTheme.systemGray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.accentColor,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.dashboardCardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.whiteTransparent08,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.whiteTransparent08,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.dashboardAccentRed,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixText: '\$ ',
                        prefixStyle: const TextStyle(
                          color: AppTheme.systemGray,
                          fontSize: 14,
                        ),
                        hintText: '0',
                        hintStyle: const TextStyle(
                          color: AppTheme.placeholderGray,
                        ),
                      ),
                      onChanged: (value) {
                        final amount = double.tryParse(value) ?? 0;
                        context.read<AddRecordBloc>().add(
                          UpdateMaintenanceEntry(index: index, amount: amount),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 下次保養里程
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'addRecord.nextMaintenanceMileage'.tr(),
                      style: const TextStyle(
                        color: AppTheme.systemGray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.accentColor,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.dashboardCardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.whiteTransparent08,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppTheme.whiteTransparent08,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppTheme.dashboardAccentRed,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        hintText: 'common.unitKm'.tr(),
                        hintStyle: const TextStyle(
                          color: AppTheme.placeholderGray,
                        ),
                      ),
                      onChanged: (value) {
                        final km = int.tryParse(value);
                        context.read<AddRecordBloc>().add(
                          UpdateMaintenanceEntry(
                            index: index,
                            nextMaintenanceKm: km,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 備註
          Text(
            'addRecord.notes'.tr(),
            style: const TextStyle(color: AppTheme.systemGray, fontSize: 12),
          ),
          const SizedBox(height: 6),
          TextField(
            style: const TextStyle(fontSize: 14, color: AppTheme.accentColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.dashboardCardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.whiteTransparent08),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.whiteTransparent08),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppTheme.dashboardAccentRed,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              hintText: 'addRecord.notesPlaceholder'.tr(),
              hintStyle: const TextStyle(color: AppTheme.placeholderGray),
            ),
            onChanged: (value) {
              context.read<AddRecordBloc>().add(
                UpdateMaintenanceEntry(index: index, note: value),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NoteInput extends StatelessWidget {
  const _NoteInput();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'addRecord.notes'.tr(),
          style: const TextStyle(color: AppTheme.systemGray, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          style: const TextStyle(fontSize: 16, color: AppTheme.accentColor),
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
            hintText: 'addRecord.notesPlaceholder'.tr(),
            hintStyle: const TextStyle(color: AppTheme.placeholderGray),
          ),
          onChanged: (value) {
            context.read<AddRecordBloc>().add(NoteChanged(value));
          },
        ),
      ],
    );
  }
}
