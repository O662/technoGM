import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsets? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const NeonCard({
    super.key,
    required this.child,
    this.borderColor = TechnoColors.cardBorder,
    this.padding,
    this.borderRadius = 16,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? TechnoColors.cardBg,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: borderColor != TechnoColors.cardBorder
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.12),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
