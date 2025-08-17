import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool? isCorrect;
  final bool isIncorrect;
  final VoidCallback? onTap;

  const OptionButton({
    super.key,
    required this.label,
    required this.text,
    this.isSelected = false,
    this.isCorrect,
    this.isIncorrect = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    Color? backgroundColor;
    Color? textColor;
    Widget? trailing;

    if (isCorrect == true) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green[700];
      trailing = const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 20,
      );
    } else if (isIncorrect) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red[700];
      trailing = const Icon(
        Icons.cancel,
        color: Colors.red,
        size: 20,
      );
    } else if (isSelected) {
      borderColor = Theme.of(context).colorScheme.primary;
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      textColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Theme.of(context).colorScheme.outline,
          width: borderColor != null ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Option label (A, B, C, D)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected || isCorrect == true || isIncorrect
                      ? (textColor ?? Theme.of(context).colorScheme.primary)
                      : Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected || isCorrect == true || isIncorrect
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Option text
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor ?? Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),

              // Trailing icon (correct/incorrect indicator)
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
