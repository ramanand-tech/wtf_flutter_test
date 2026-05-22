import 'package:flutter/material.dart';

import '../utils/spacing.dart';

/// Subtle scale on press (150–250ms).
class ScaleOnPress extends StatefulWidget {
  const ScaleOnPress({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<ScaleOnPress> createState() => _ScaleOnPressState();
}

class _ScaleOnPressState extends State<ScaleOnPress> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AppMotion.fast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ScaleOnPress(
      enabled: onPressed != null,
      onTap: onPressed,
      child: icon != null
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            )
          : FilledButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleOnPress(
      enabled: onPressed != null,
      onTap: onPressed,
      child: OutlinedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

class AppTertiaryButton extends StatelessWidget {
  const AppTertiaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ScaleOnPress(
      enabled: onPressed != null,
      onTap: onPressed,
      child: TextButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
