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
            Navigator.pop(context, state.createdRecord);
          } else if (state.status == AddRecordStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}')),
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
    return Scaffold(
      backgroundColor: AppTheme.dashboardBg,
      appBar: AppBar(
        backgroundColor: AppTheme.dashboardBg,
        surfaceTintColor: Colors.transparent, // Disable Material 3 surface tint
        centerTitle: true,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('返回'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.dashboardAccentRed,
            padding: EdgeInsets.zero,
          ),
        ),
        leadingWidth: 80, // Allow width for text
        title: const Text(
          '新增紀錄',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                context.read<AddRecordBloc>().add(const SubmitRecord());
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.dashboardAccentRed),
              child: const Text(
                '儲存',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.dashboardCardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.whiteTransparent08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AmountInput(),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(child: _DateInput()),
                        SizedBox(width: 12),
                        Expanded(child: _MileageInput()),
                      ],
                    ),
                    const _DynamicFields(),
                    const SizedBox(height: 16),
                    const _NoteInput(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const _SaveButton(),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  static const categories = [
    (RecordType.fuel, '加油'),
    (RecordType.maintenance, '保養'),
    (RecordType.modification, '改裝'),
    (RecordType.other, '其他'),
    // Add more if we extend RecordType, currently limited by Enum
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '選擇類別',
            style: TextStyle(color: AppTheme.systemGray, fontSize: 13),
          ),
        ),
        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final (type, label) = categories[index];
              return _CategoryItem(type: type, label: label);
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final RecordType type;
  final String label;

  const _CategoryItem({required this.type, required this.label});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) =>
          previous.recordType != current.recordType,
      builder: (context, state) {
        final isSelected = state.recordType == type;

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
                    color: isSelected ? AppTheme.dashboardAccentRed : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  type.icon,
                  color: isSelected ? AppTheme.dashboardAccentRed : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppTheme.dashboardAccentRed : AppTheme.systemGray,
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

class _AmountInput extends StatelessWidget {
  const _AmountInput();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '金額',
          style: TextStyle(color: AppTheme.systemGray, fontSize: 13),
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
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
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
                  borderSide: const BorderSide(color: AppTheme.dashboardAccentRed),
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
            const Text(
              '日期',
              style: TextStyle(color: AppTheme.systemGray, fontSize: 13),
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
                          onPrimary: Colors.white,
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
                  border: Border.all(
                    color: AppTheme.whiteTransparent08,
                  ),
                ),
                child: Text(
                  '${state.date.year}-${state.date.month.toString().padLeft(2, '0')}-${state.date.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
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
      buildWhen: (previous, current) => previous.mileage != current.mileage,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '當下里程',
              style: TextStyle(color: AppTheme.systemGray, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: state.mileage > 0 ? state.mileage.toString() : null,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16, color: Colors.white),
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
                  borderSide: const BorderSide(color: AppTheme.dashboardAccentRed),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: 'km',
                hintStyle: const TextStyle(color: AppTheme.placeholderGray),
              ),
              onChanged: (value) {
                final mileage = int.tryParse(value) ?? 0;
                context.read<AddRecordBloc>().add(MileageChanged(mileage));
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
          previous.recordType != current.recordType,
      builder: (context, state) {
        if (state.recordType != RecordType.maintenance) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: AppTheme.whiteTransparent08),
              const SizedBox(height: 16),
              const Text(
                '保養項目',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const _MaintenanceList(),
              const SizedBox(height: 16),
              // Next Maintenance
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '下次保養里程',
                    style: TextStyle(color: AppTheme.systemGray, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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
                        borderSide: const BorderSide(color: AppTheme.dashboardAccentRed),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      hintText: '例：50,000',
                      hintStyle: const TextStyle(color: AppTheme.placeholderGray),
                    ),
                    onChanged: (value) {
                      final mileage = int.tryParse(value) ?? 0;
                      context.read<AddRecordBloc>().add(
                        NextMaintenanceMileageChanged(mileage),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MaintenanceList extends StatelessWidget {
  const _MaintenanceList();

  static const items = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      buildWhen: (previous, current) =>
          previous.selectedMaintenanceItems != current.selectedMaintenanceItems,
      builder: (context, state) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = state.selectedMaintenanceItems.contains(item);

            return GestureDetector(
              onTap: () {
                context.read<AddRecordBloc>().add(MaintenanceItemToggled(item));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
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
                  item,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? AppTheme.dashboardAccentRed : AppTheme.systemGray,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
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
        const Text(
          '備註',
          style: TextStyle(color: AppTheme.systemGray, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 3,
          style: const TextStyle(fontSize: 16, color: Colors.white),
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
              borderSide: const BorderSide(color: AppTheme.dashboardAccentRed),
            ),
            contentPadding: const EdgeInsets.all(16),
            hintText: '輸入備註內容...',
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

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddRecordBloc, AddRecordState>(
      builder: (context, state) {

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppTheme.dashboardAccentRed.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: state.status == AddRecordStatus.submitting
                ? null
                : () {
                    context.read<AddRecordBloc>().add(const SubmitRecord());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dashboardAccentRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: state.status == AddRecordStatus.submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '儲存紀錄',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        );
      },
    );
  }
}
