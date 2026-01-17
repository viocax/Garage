import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:garage/core/models/speed_unit.dart';
import 'package:garage/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';

class IntervalInfoWidget extends StatelessWidget {
  final double averageSpeed;
  final double remainingDistance;
  final int speedLimit;
  final SpeedUnit unit;
  final bool isOverSpeed;

  const IntervalInfoWidget({
    super.key,
    required this.averageSpeed,
    required this.remainingDistance,
    required this.speedLimit,
    required this.unit,
    required this.isOverSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final displayAvgSpeed = unit == SpeedUnit.kmh 
        ? averageSpeed.round().toString() 
        : averageSpeed.round().toString(); // Bloc already converted it

    final distanceText = remainingDistance > 1000
        ? '${(remainingDistance / 1000).toStringAsFixed(1)} km'
        : '${remainingDistance.round()} m';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOverSpeed 
                ? AppTheme.dashboardAccentRed.withValues(alpha: 0.3)
                : AppTheme.blackTransparent30,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverSpeed 
                  ? AppTheme.dashboardAccentRed.withValues(alpha: 0.5)
                  : AppTheme.whiteTransparent20,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'speedCamera.interval.averageSpeed'.tr(),
                style: TextStyle(
                  color: AppTheme.whiteTransparent70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    displayAvgSpeed,
                    style: TextStyle(
                      color: isOverSpeed ? AppTheme.dashboardAccentRed : AppTheme.accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit.displayName,
                    style: TextStyle(
                      color: AppTheme.whiteTransparent70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: AppTheme.whiteTransparent20, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSmallInfo(
                    'speedCamera.interval.limit'.tr(),
                    '$speedLimit',
                  ),
                  _buildSmallInfo(
                    'speedCamera.interval.remaining'.tr(),
                    distanceText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.whiteTransparent70,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.accentColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
