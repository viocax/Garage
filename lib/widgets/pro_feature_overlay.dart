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
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: child,
          ),
        ),
        // Lock Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.blackTransparent20,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pro 會員專屬數據',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onUpgrade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.dashboardAccentRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '立即解鎖',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
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
