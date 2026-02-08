import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BarlyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  const BarlyButton(
      {super.key, required this.label, this.onPressed, this.expanded = true});

  @override
  State<BarlyButton> createState() => _BarlyButtonState();
}

class _BarlyButtonState extends State<BarlyButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final btn = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 150),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTapDown: (_) => setState(() => _scale = 0.98),
        onTapCancel: () => setState(() => _scale = 1),
        onTap: () {
          setState(() => _scale = 1);
          widget.onPressed?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: AppTheme.lavenderGradient(radius: 12),
          child: Center(
            child: Text(widget.label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
    if (widget.expanded) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }
}

