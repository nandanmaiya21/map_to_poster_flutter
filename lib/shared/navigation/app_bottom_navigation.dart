import 'package:flutter/material.dart';

import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(8),
        height: 72,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavigationItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'HOME',
                onTap: onTap,
              ),
            ),

            Expanded(
              child: _NavigationItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.add,
                activeIcon: Icons.add,
                label: 'CREATE',
                onTap: onTap,
                isPrimary: true,
              ),
            ),

            Expanded(
              child: _NavigationItem(
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.folder_outlined,
                activeIcon: Icons.folder,
                label: 'PROJECTS',
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final int index;
  final int currentIndex;

  final IconData icon;
  final IconData activeIcon;

  final String label;

  final ValueChanged<int> onTap;

  final bool isPrimary;

  const _NavigationItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,

      child: Stack(
        alignment: Alignment.center,
        children: [
          // Active top indicator
          if (isActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(height: 4, color: AppColors.neonLime),
            ),

          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 32,
                height: 28,
                alignment: Alignment.center,
                decoration: isActive && isPrimary
                    ? const BoxDecoration(color: AppColors.neonLime)
                    : null,
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 21,
                  color: isActive
                      ? (isPrimary ? AppColors.textPrimary : AppColors.neonLime)
                      : AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: isActive ? AppColors.textInverse : AppColors.textMuted,
                  fontSize: 8,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
