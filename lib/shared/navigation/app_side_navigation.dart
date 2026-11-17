import 'package:flutter/material.dart';

import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';

/// Left-hand navigation for wide web windows. Same destinations and
/// styling as [AppBottomNavigation], laid out vertically.
class AppSideNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppSideNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double width = 232;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Text(
                'MAP\nTO\nPOSTER',
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.textInverse,
                  height: 1.05,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Container(width: 40, height: 4, color: AppColors.neonLime),
            ),
            _SideItem(
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'HOME',
              onTap: onTap,
            ),
            _SideItem(
              index: 1,
              currentIndex: currentIndex,
              icon: Icons.add,
              activeIcon: Icons.add,
              label: 'CREATE',
              onTap: onTap,
              isPrimary: true,
            ),
            _SideItem(
              index: 2,
              currentIndex: currentIndex,
              icon: Icons.folder_outlined,
              activeIcon: Icons.folder,
              label: 'PROJECTS',
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;
  final bool isPrimary;

  const _SideItem({
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
      hoverColor: AppColors.textInverse.withValues(alpha: 0.05),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            // Active side indicator
            Container(
              width: 4,
              height: double.infinity,
              color: isActive ? AppColors.neonLime : Colors.transparent,
            ),
            const SizedBox(width: 20),
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
            const SizedBox(width: 14),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: isActive ? AppColors.textInverse : AppColors.textMuted,
                fontSize: 11,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
