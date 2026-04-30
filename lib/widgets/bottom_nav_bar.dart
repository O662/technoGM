import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class TechnoNavBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const TechnoNavBar({super.key, required this.current, required this.onTap});

  static const _items = [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'HOME'),
    _NavItemData(icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center, label: 'WORKOUT'),
    _NavItemData(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: 'EXERCISES'),
    _NavItemData(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'STATS'),
    _NavItemData(icon: Icons.person_outline, activeIcon: Icons.person_rounded, label: 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: TechnoColors.neonCyan.withValues(alpha: 0.08),
              blurRadius: 40,
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TechnoColors.bgSecondary.withValues(alpha: 0.78),
                    TechnoColors.bgTertiary.withValues(alpha: 0.92),
                  ],
                ),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: TechnoColors.neonCyan.withValues(alpha: 0.22),
                  width: 1,
                ),
              ),
              child: Row(
                children: List.generate(
                  _items.length,
                  (i) => Expanded(
                    child: _NavItem(
                      data: _items[i],
                      isSelected: current == i,
                      onTap: () => onTap(i),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: isSelected ? 56 : 36,
            height: 34,
            decoration: BoxDecoration(
              color: isSelected
                  ? TechnoColors.neonCyan.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: isSelected
                  ? Border.all(
                      color: TechnoColors.neonCyan.withValues(alpha: 0.35),
                      width: 1,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: TechnoColors.neonCyan.withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isSelected ? data.activeIcon : data.icon,
              color: isSelected ? TechnoColors.neonCyan : TechnoColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.rajdhani(
              color: isSelected
                  ? TechnoColors.neonCyan
                  : TechnoColors.textMuted,
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.8,
            ),
            child: Text(
              data.label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
