import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PricePill extends StatefulWidget {
  final String label;
  final String price;
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;
  final Color? backgroundColor;

  const PricePill({
    super.key,
    required this.label,
    required this.price,
    this.icon = Icons.bolt,
    this.onTap,
    this.selected = false,
    this.backgroundColor,
  });

  @override
  State<PricePill> createState() => _PricePillState();
}

class _PricePillState extends State<PricePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTapDown:
                widget.onTap != null ? (_) => _controller.forward() : null,
            onTapUp: widget.onTap != null ? (_) => _controller.reverse() : null,
            onTapCancel:
                widget.onTap != null ? () => _controller.reverse() : null,
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.selected
                      ? AppTheme.lavender
                      : AppTheme.lavender.withOpacity(0.3),
                  width: widget.selected ? 2 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.selected
                        ? AppTheme.lavender
                        : AppTheme.lavender.withOpacity(0.7),
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color:
                          widget.selected ? AppTheme.lavender : AppTheme.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: widget.selected
                          ? AppTheme.lavender.withOpacity(0.1)
                          : AppTheme.lavender.withOpacity(0.05),
                      border: Border.all(
                        color: widget.selected
                            ? AppTheme.lavender
                            : AppTheme.lavender.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.price,
                      style: TextStyle(
                        color:
                            widget.selected ? AppTheme.lavender : AppTheme.text,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
