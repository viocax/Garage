import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';

class ProFeatureOverlay extends StatelessWidget {
  final Widget child;
  final bool isPro;
  final VoidCallback onUpgrade;

  const ProFeatureOverlay({
    super.key,
    required this.child,
    required this.isPro,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    if (isPro) return child;

    return Stack(
      children: [
        // Blurry Child
        AbsorbPointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: child,
          ),
        ),
        // Lock Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.dashboardAccentRed.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.dashboardAccentRed.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: AppTheme.accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Garage Pro 專屬數據',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onUpgrade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.dashboardAccentRed,
                          Color(0xFFFF5252),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.dashboardAccentRed.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '立即解鎖',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
