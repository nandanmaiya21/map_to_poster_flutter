import 'package:flutter/material.dart';
import 'package:map_to_poster/core/theme/app_color.dart';
import 'package:map_to_poster/core/theme/app_text_styles.dart';

enum ActionButtonType { outlined, filled }

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Icon? icon;
  final Icon? prefixIcon;
  final ActionButtonType type;
  final double? fontSize;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.prefixIcon,
    this.type = ActionButtonType.filled,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    switch (type) {
      case ActionButtonType.outlined:
        decoration = BoxDecoration(
          color: Colors.transparent,

          border: Border.all(color: AppColors.border, width: 1),
        );
        break;
      case ActionButtonType.filled:
        decoration = BoxDecoration(color: AppColors.neonLime);
        break;
    }
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: decoration,
        child: Row(
          children: [
            if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 12)],
            Text(
              text,
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: fontSize,
              ),
            ),

            const Spacer(),

            icon ??
                const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }
}
