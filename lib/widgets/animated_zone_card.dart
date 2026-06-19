import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models/zone_model.dart';
import '../providers/zone_provider.dart';
import 'zone_dialogs.dart';

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
  late Animation<Offset> _translateAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _translateAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -6),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    if (!mounted) return;
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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: _translateAnimation.value,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: () {
            ZoneDialogs.showZoneOptionsSheet(
              context: context,
              zone: widget.zone,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.isActive
                    ? widget.zone.color.withOpacity(0.8)
                    : Colors.grey.shade100,
                width: widget.isActive ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isActive
                      ? widget.zone.color.withOpacity(_isHovering ? 0.25 : 0.15)
                      : Colors.black.withOpacity(_isHovering ? 0.08 : 0.04),
                  blurRadius: _isHovering ? 20 : 12,
                  offset: Offset(0, _isHovering ? 8 : 4),
                  spreadRadius: widget.isActive && _isHovering ? 2 : 0,
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Icon circle & Toggle Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.zone.color.withOpacity(0.2),
                              widget.zone.color.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            widget.zone.icon,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      
                      // Slick Animated Custom Switch
                      _buildCustomSwitch(context),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Middle Content: Name & Sound Profile Pill
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.zone.name,
                          style: AppTheme.headline3.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: widget.zone.isActive 
                                ? AppTheme.textPrimary 
                                : AppTheme.textSecondary.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _buildProfileBadge(),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Bottom Row: Radius Chip & "Current" pulsing badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📍 ${widget.zone.radius.toStringAsFixed(0)}m radius',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      if (widget.isActive) _buildPulseBadge(),
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

  Widget _buildCustomSwitch(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<ZoneProvider>(context, listen: false)
            .toggleZoneActive(widget.zone.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 40,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: widget.zone.isActive 
              ? widget.zone.color 
              : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.all(2),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: widget.zone.isActive 
              ? Alignment.centerRight 
              : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBadge() {
    String label;
    IconData icon;
    switch (widget.zone.soundProfile) {
      case SoundProfile.silent:
        label = 'Silent';
        icon = Icons.volume_off_rounded;
        break;
      case SoundProfile.vibration:
        label = 'Vibrate';
        icon = Icons.vibration_rounded;
        break;
      case SoundProfile.normal:
        label = 'Normal';
        icon = Icons.volume_up_rounded;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.zone.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: widget.zone.color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: widget.zone.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.successColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Current',
            style: TextStyle(
              color: AppTheme.successColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}