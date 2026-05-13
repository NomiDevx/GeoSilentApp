import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/zone_provider.dart';
import '../theme.dart';
import '../models/zone_model.dart';

class ActiveZonesScreen extends StatefulWidget {
  const ActiveZonesScreen({Key? key}) : super(key: key);

  @override
  State<ActiveZonesScreen> createState() => _ActiveZonesScreenState();
}

class _ActiveZonesScreenState extends State<ActiveZonesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zoneProvider = Provider.of<ZoneProvider>(context);
    final activeZones =
        zoneProvider.zones.where((zone) => zone.isActive).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Gradient SliverAppBar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.volume_off_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Zones',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${activeZones.length} zone${activeZones.length == 1 ? '' : 's'} monitoring',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────
          if (activeZones.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final zone = activeZones[index];
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final delay = index * 0.12;
                        final slideAnim = Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            delay.clamp(0.0, 0.8),
                            (delay + 0.4).clamp(0.0, 1.0),
                            curve: Curves.easeOutCubic,
                          ),
                        ));
                        final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              delay.clamp(0.0, 0.8),
                              (delay + 0.4).clamp(0.0, 1.0),
                            ),
                          ),
                        );
                        return FadeTransition(
                          opacity: fadeAnim,
                          child: SlideTransition(
                            position: slideAnim,
                            child: child,
                          ),
                        );
                      },
                      child: _buildZoneCard(context, zone, zoneProvider),
                    );
                  },
                  childCount: activeZones.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 56,
                color: AppTheme.primaryColor.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Zones',
              style: AppTheme.headline2.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'All your zones are currently inactive.\nEnable a zone from your zone list to\nstart automatic silent mode.',
              textAlign: TextAlign.center,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textHint,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Zone Card ────────────────────────────────────────────────────────
  Widget _buildZoneCard(
    BuildContext context,
    SilentZone zone,
    ZoneProvider zoneProvider,
  ) {
    final zoneColor = _zoneColor(zone.soundProfile);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: zoneColor.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showZoneDetails(context, zone, zoneProvider),
        borderRadius: BorderRadius.circular(20),
        splashColor: zoneColor.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon circle
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          zoneColor.withOpacity(0.2),
                          zoneColor.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        zone.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              _getZoneIcon(zone.type),
                              size: 13,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getZoneTypeName(zone.type),
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Active badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.successColor.withOpacity(0.3),
                        width: 1,
                      ),
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
                        const SizedBox(width: 5),
                        Text(
                          'Active',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Info chips row ──
              Row(
                children: [
                  _buildChip(
                    icon: Icons.radar_rounded,
                    label: '${zone.radius.toInt()} m radius',
                    color: AppTheme.infoColor,
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    icon: _soundIcon(zone.soundProfile),
                    label: _getSoundProfileName(zone.soundProfile),
                    color: zoneColor,
                  ),
                  if (zone.isRepeating) ...[
                    const SizedBox(width: 8),
                    _buildChip(
                      icon: Icons.repeat_rounded,
                      label: 'Repeating',
                      color: AppTheme.warningColor,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 14),

              // ── Divider ──
              Divider(
                color: AppTheme.surfaceColor,
                height: 1,
                thickness: 1,
              ),

              const SizedBox(height: 12),

              // ── Action buttons ──
              Row(
                children: [
                  // Details button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showZoneDetails(context, zone, zoneProvider),
                      icon: const Icon(Icons.info_outline_rounded, size: 16),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(
                            color: AppTheme.primaryColor.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Deactivate button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _confirmDeactivate(context, zone, zoneProvider),
                      icon: const Icon(Icons.pause_circle_outline_rounded,
                          size: 16),
                      label: const Text('Deactivate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Small info chip ──────────────────────────────────────────────────
  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirm deactivate bottom sheet ─────────────────────────────────
  void _confirmDeactivate(
    BuildContext context,
    SilentZone zone,
    ZoneProvider zoneProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _DeactivateSheet(
        zone: zone,
        onConfirm: () async {
          Navigator.pop(sheetContext); // use sheet's own context
          await zoneProvider.toggleZoneActive(zone.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text('"${zone.name}" deactivated'),
                  ],
                ),
                backgroundColor: AppTheme.textPrimary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  // ── Zone details bottom sheet ────────────────────────────────────────
  void _showZoneDetails(
    BuildContext context,
    SilentZone zone,
    ZoneProvider zoneProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          final zoneColor = _zoneColor(zone.soundProfile);
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            zoneColor.withOpacity(0.25),
                            zoneColor.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          zone.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.name,
                            style: AppTheme.headline2.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getZoneTypeName(zone.type),
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    // Active badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '● Active',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                _buildDetailSection('📍 Location', [
                  _buildDetailRow('Latitude',
                      zone.latitude.toStringAsFixed(6)),
                  _buildDetailRow('Longitude',
                      zone.longitude.toStringAsFixed(6)),
                ]),
                const SizedBox(height: 20),
                _buildDetailSection('⚙️ Zone Settings', [
                  _buildDetailRow('Radius', '${zone.radius.toInt()} m'),
                  _buildDetailRow(
                      'Sound Profile', _getSoundProfileName(zone.soundProfile)),
                  _buildDetailRow(
                      'Repeating', zone.isRepeating ? 'Yes' : 'No'),
                ]),
                const SizedBox(height: 20),
                _buildDetailSection('🕒 Metadata', [
                  _buildDetailRow('Created', _formatDate(zone.createdAt)),
                  if (zone.updatedAt != null)
                    _buildDetailRow('Updated', _formatDate(zone.updatedAt!)),
                ]),

                const SizedBox(height: 28),
                // Deactivate button inside sheet
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDeactivate(context, zone, zoneProvider);
                    },
                    icon: const Icon(Icons.pause_circle_outline_rounded),
                    label: const Text('Deactivate This Zone'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(context, zone, zoneProvider);
                    },
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text('Delete Zone'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: valueColor ?? AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  Color _zoneColor(SoundProfile profile) {
    switch (profile) {
      case SoundProfile.silent:
        return AppTheme.silentZoneColor;
      case SoundProfile.vibration:
        return AppTheme.vibrationZoneColor;
      case SoundProfile.normal:
        return AppTheme.normalZoneColor;
    }
  }

  IconData _soundIcon(SoundProfile profile) {
    switch (profile) {
      case SoundProfile.silent:
        return Icons.volume_off_rounded;
      case SoundProfile.vibration:
        return Icons.vibration_rounded;
      case SoundProfile.normal:
        return Icons.volume_up_rounded;
    }
  }

  IconData _getZoneIcon(ZoneType type) {
    switch (type) {
      case ZoneType.office:
        return Icons.business_rounded;
      case ZoneType.mosque:
        return Icons.mosque_rounded;
      case ZoneType.hospital:
        return Icons.local_hospital_rounded;
      case ZoneType.classroom:
        return Icons.school_rounded;
      case ZoneType.library:
        return Icons.library_books_rounded;
      case ZoneType.cinema:
        return Icons.movie_rounded;
      case ZoneType.other:
        return Icons.location_on_rounded;
    }
  }

  String _getZoneTypeName(ZoneType type) {
    switch (type) {
      case ZoneType.office:
        return 'Office';
      case ZoneType.mosque:
        return 'Mosque';
      case ZoneType.hospital:
        return 'Hospital';
      case ZoneType.classroom:
        return 'Classroom';
      case ZoneType.library:
        return 'Library';
      case ZoneType.cinema:
        return 'Cinema';
      case ZoneType.other:
        return 'Other';
    }
  }

  String _getSoundProfileName(SoundProfile profile) {
    switch (profile) {
      case SoundProfile.silent:
        return 'Silent';
      case SoundProfile.vibration:
        return 'Vibration';
      case SoundProfile.normal:
        return 'Normal';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _confirmDelete(BuildContext context, SilentZone zone, ZoneProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _DeleteSheet(
        zone: zone,
        onConfirm: () async {
          Navigator.pop(sheetContext); // close sheet with its own context
          final success = await provider.deleteZone(zone.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success
                    ? 'Zone "${zone.name}" deleted'
                    : 'Failed to delete zone'),
                backgroundColor:
                    success ? AppTheme.successColor : AppTheme.errorColor,
              ),
            );
          }
        },
      ),
    );
  }
}

// ── Deactivate confirmation sheet ────────────────────────────────────────
class _DeactivateSheet extends StatelessWidget {
  final SilentZone zone;
  final VoidCallback onConfirm;

  const _DeactivateSheet({
    required this.zone,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Warning icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pause_circle_outline_rounded,
              color: AppTheme.errorColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Deactivate Zone?',
            style: AppTheme.headline3,
          ),
          const SizedBox(height: 8),
          Text(
            '"${zone.name}" will no longer silence\nyour phone automatically.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Yes, Deactivate',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delete confirmation sheet ────────────────────────────────────────
class _DeleteSheet extends StatelessWidget {
  final SilentZone zone;
  final VoidCallback onConfirm;

  const _DeleteSheet({
    required this.zone,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Warning icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_forever_rounded,
              color: AppTheme.errorColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Delete Zone?',
            style: AppTheme.headline3,
          ),
          const SizedBox(height: 8),
          Text(
            '"${zone.name}" will be permanently removed.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Yes, Delete',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
