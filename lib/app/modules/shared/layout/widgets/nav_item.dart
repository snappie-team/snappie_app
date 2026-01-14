import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NavItem extends StatelessWidget {
  /// Icon widget for inactive state (use AppIcon)
  final Widget inactiveIcon;
  
  /// Icon widget for active state (use AppIcon)
  final Widget activeIcon;
  
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.inactiveIcon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isActive
                ? SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      duration: const Duration(milliseconds: 200),
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.withOpacity(AppColors.primary, 0.5),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(height: 6),
            const SizedBox(height: 8),
            IconTheme(
              data: IconThemeData(color: color, size: 24),
              child: isActive ? activeIcon : inactiveIcon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
