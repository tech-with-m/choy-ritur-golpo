import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({
    super.key,
    required this.buttonName,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
  });
  final String buttonName;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final buttonChild = icon == null
        ? Text(buttonName, style: context.textTheme.titleMedium?.copyWith(color: textColor))
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              const SizedBox(width: 8),
              Text(buttonName, style: context.textTheme.titleMedium?.copyWith(color: textColor)),
            ],
          );
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: borderColor != null
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: borderColor!, width: 2),
                foregroundColor: textColor,
                backgroundColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onPressed,
              child: buttonChild,
            )
          : ElevatedButton(
              style: ButtonStyle(
                shadowColor: const WidgetStatePropertyAll(Colors.transparent),
                backgroundColor: WidgetStatePropertyAll(
                  backgroundColor ?? context.theme.colorScheme.secondaryContainer.withAlpha(80),
                ),
                foregroundColor: WidgetStatePropertyAll(textColor),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              onPressed: onPressed,
              child: buttonChild,
            ),
    );
  }
}
