import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garage/core/extensions/dialog_extension.dart';
import 'package:garage/core/models/vehicle.dart';
import 'package:garage/screen/settings/vehicle_management/bloc/vehicle_management_bloc.dart';
import 'package:garage/screen/settings/vehicle_management/bloc/vehicle_management_event.dart';
import 'package:garage/screen/settings/vehicle_management/bloc/vehicle_management_state.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:garage/widgets/widgets.dart';

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
        title: Text('settings.vehicleManagement'.tr()),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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

          return Column(
            children: [
              Expanded(
                child: state.vehicles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'vehicle.noVehicles'.tr(),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
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
                                title: 'vehicle.confirmDelete'.tr(),
                                message: 'vehicle.deleteConfirmMessage'.tr(
                                  args: [vehicle.carName],
                                ),
                                cancelText: 'common.cancel'.tr(),
                                confirmText: 'common.delete'.tr(),
                                isDestructiveAction: true,
                              );
                            },
                            onDismissed: (direction) {
                              context.read<VehicleManagementBloc>().add(
                                DeleteVehicle(vehicle.vehicleId),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'vehicle.deletedMessage'.tr(
                                      args: [vehicle.carName],
                                    ),
                                  ),
                                ),
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
                      ),
              ),
              const BannerAdWidget(),
            ],
          );
        },
      ),
    );
  }
}

class _VehicleListTile extends StatelessWidget {
  final Vehicle vehicle;
  final int index;

  const _VehicleListTile({required this.vehicle, required this.index});

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
        subtitle: Text('${vehicle.currentKm} ${'common.unitKm'.tr()}'),
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
