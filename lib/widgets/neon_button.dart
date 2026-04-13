import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;
  final bool fullWidth;
  final bool outlined;
  final double height;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = TechnoColors.neonCyan,
    this.icon,
    this.fullWidth = true,
    this.outlined = false,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: outlined ? color : TechnoColors.bgPrimary, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          label.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: outlined ? color : TechnoColors.bgPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );

    final decoration = BoxDecoration(
      color: outlined ? Colors.transparent : color,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color, width: outlined ? 1.5 : 0),
      boxShadow: outlined
          ? null
          : [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: height,
        width: fullWidth ? double.infinity : null,
        padding: fullWidth ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 24),
        decoration: decoration,
        child: child,
      ),
    );
  }
}
