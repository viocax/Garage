import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:garage/theme/app_theme.dart';
import 'dart:ui';

abstract class PickerOption {
  String getIdentifier();
  String getTitle();
  String getSubTitle();
}

/// A floating vehicle picker dialog with a wheel selector
class PickerDialog extends StatefulWidget {
  final String? currentSelectedIdentifier;
  final List<PickerOption> options;
  final Function(PickerOption) onSelected;

  const PickerDialog({
    super.key,
    required this.currentSelectedIdentifier,
    required this.options,
    required this.onSelected,
  });

  @override
  State<PickerDialog> createState() => _PickerDialogState();
}

class _PickerDialogState extends State<PickerDialog>
    with SingleTickerProviderStateMixin {
  late FixedExtentScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Find initial index based on current vehicle
    if (widget.currentSelectedIdentifier != null) {
      _selectedIndex = widget.options.indexWhere(
        (v) => v.getIdentifier() == widget.currentSelectedIdentifier,
      );
      if (_selectedIndex == -1) _selectedIndex = 0;
    }

    _scrollController = FixedExtentScrollController(
      initialItem: _selectedIndex,
    );

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    // Call onSelected before dismissing
    widget.onSelected(widget.options[_selectedIndex]);

    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (_) {
        // When user releases finger anywhere, dismiss the picker
        _handleDismiss();
      },
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildPickerContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkSurface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.whiteTransparent20, width: 1),
            ),
            child: _buildPicker(),
          ),
        ),
      ),
    );
  }

  Widget _buildPicker() {
    return SizedBox(
      height: 220,
      child: CupertinoPicker(
        scrollController: _scrollController,
        itemExtent: 55,
        onSelectedItemChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Don't switch option here - wait until picker is dismissed
        },
        children: widget.options.map((option) {
          return Center(child: _buildPickerItem(option));
        }).toList(),
      ),
    );
  }

  Widget _buildPickerItem(PickerOption option) {
    final isSelected =
        option.getIdentifier() ==
        widget.options[_selectedIndex].getIdentifier();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            option.getTitle(),
            style: TextStyle(
              color: isSelected
                  ? AppTheme.accentColor
                  : AppTheme.whiteTransparent70,
              fontSize: isSelected ? 18 : 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Text(
              option.getSubTitle(),
              style: TextStyle(
                color: AppTheme.whiteTransparent30,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Helper function to show picker dialog
void showPickerDialog({
  required BuildContext context,
  required List<PickerOption> options,
  String? currentSelectedIdentifier,
  required Function(PickerOption) onSelected,
}) {
  if (options.isEmpty) {
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) => PickerDialog(
      options: options,
      currentSelectedIdentifier: currentSelectedIdentifier,
      onSelected: onSelected,
    ),
  );
}
