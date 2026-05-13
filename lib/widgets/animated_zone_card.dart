import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme.dart';
import '../models/zone_model.dart';

class AnimatedZoneCard extends StatefulWidget {
  final SilentZone zone;
  final VoidCallback? onTap;
  final bool isActive;

  const AnimatedZoneCard({
    Key? key,
    required this.zone,
    this.onTap,
    this.isActive = false,
  }) : super(key: key);

  @override
  _AnimatedZoneCardState createState() => _AnimatedZoneCardState();
}

class _AnimatedZoneCardState extends State<AnimatedZoneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    setState(() {
      _isHovering = hovering;
    });
    if (hovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Card(
            color: widget.zone.color.withOpacity(0.1),
            elevation: _isHovering ? 8 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: widget.isActive
                    ? widget.zone.color
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.zone.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.zone.name,
                    style: AppTheme.headline3.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.zone.radius.toStringAsFixed(0)}m radius',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.zone.isActive
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: widget.zone.isActive
                            ? AppTheme.successColor
                            : AppTheme.textHint,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.zone.isActive ? 'Active' : 'Inactive',
                        style: AppTheme.bodySmall.copyWith(
                          color: widget.zone.isActive
                              ? AppTheme.successColor
                              : AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}