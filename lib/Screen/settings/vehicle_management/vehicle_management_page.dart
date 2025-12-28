import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/extensions/dialog_extension.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/screen/settings/vehicle_management/bloc/vehicle_management_bloc.dart';
import 'package:garage/screen/settings/vehicle_management/bloc/vehicle_management_event.dart';
import 'package:garage/screen/settings/vehicle_management/bloc/vehicle_management_state.dart';
import 'package:garage/theme/app_theme.dart';

class VehicleManagementPage extends StatelessWidget {
  const VehicleManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VehicleManagementBloc(),
      child: const _VehicleManagementBody(),
    );
  }
}

class _VehicleManagementBody extends StatelessWidget {
  const _VehicleManagementBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('車輛管理'),
        elevation: 0,
      ),
      body: BlocConsumer<VehicleManagementBloc, VehicleManagementState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.vehicles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '目前沒有車輛',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.vehicles.length,
            onReorder: (oldIndex, newIndex) {
              context.read<VehicleManagementBloc>().add(
                    ReorderVehicles(
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                    ),
                  );
            },
            itemBuilder: (context, index) {
              final vehicle = state.vehicles[index];
              return Dismissible(
                key: ValueKey(vehicle.vehicleId),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await context.showAdaptiveConfirmDialog(
                    title: '確認刪除',
                    message: '確定要刪除「${vehicle.carName}」嗎？\n這將同時刪除所有相關記錄。',
                    cancelText: '取消',
                    confirmText: '刪除',
                    isDestructiveAction: true,
                  );
                },
                onDismissed: (direction) {
                  context.read<VehicleManagementBloc>().add(
                        DeleteVehicle(vehicle.vehicleId),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已刪除「${vehicle.carName}」')),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: theme.colorScheme.error,
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.accentColor,
                  ),
                ),
                child: _VehicleListTile(
                  vehicle: vehicle,
                  index: index,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VehicleListTile extends StatelessWidget {
  final Vehicle vehicle;
  final int index;

  const _VehicleListTile({
    required this.vehicle,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.directions_car,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          vehicle.carName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('${vehicle.currentKm} km'),
        trailing: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
