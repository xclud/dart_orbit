import 'package:flutter/material.dart';

class IntrinsicButton extends StatelessWidget {
  const IntrinsicButton({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.widthSteps = 1,
    this.disabled = false,
    this.filled = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final int widthSteps;
  final bool disabled;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      stepWidth: 56.0 * widthSteps,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 42,
        ),
        child: filled
            ? FilledButton(
                onPressed: disabled ? null : onPressed,
                onLongPress: disabled ? null : onLongPress,
                child: child,
              )
            : TextButton(
                onPressed: disabled ? null : onPressed,
                onLongPress: disabled ? null : onLongPress,
                child: child,
              ),
      ),
    );
  }
}
