import 'package:flutter/material.dart';
import 'package:geo_silent/providers/zone_provider.dart';
import 'package:provider/provider.dart';
import 'package:geo_silent/models/zone_model.dart';
import '../providers/zone_provider.dart';
import '../theme.dart';
import '../widgets/zone_dialogs.dart';

class ZonesPage extends StatefulWidget {
  const ZonesPage({Key? key}) : super(key: key);

  @override
  _ZonesPageState createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  @override
  Widget build(BuildContext context) {
    final zoneProvider = Provider.of<ZoneProvider>(context);
    final zones = zoneProvider.zones;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Gradient SliverAppBar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            automaticallyImplyLeading: false,
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
                                Icons.layers_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Manage Zones',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${zones.length} silent zone${zones.length == 1 ? '' : 's'} total',
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

          // ── Zones list content ─────────────────────────────────────
          if (zoneProvider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            )
          else if (zones.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 100), // bottom padding for nav bar
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final zone = zones[index];
                    return _buildZoneItem(context, zone);
                  },
                  childCount: zones.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

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
              'No Silent Zones Added',
              style: AppTheme.headline2.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Text(
              'Create a silent zone using the Map tab to start automatic silent mode.',
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

  Widget _buildZoneItem(BuildContext context, SilentZone zone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Short tap opens the edit details directly
            ZoneDialogs.showEditZoneSheet(context: context, zone: zone);
          },
          onLongPress: () {
            // Long press shows options sheet
            ZoneDialogs.showZoneOptionsSheet(context: context, zone: zone);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Category Icon Circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        zone.color.withOpacity(0.2),
                        zone.color.withOpacity(0.05),
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
                const SizedBox(width: 14),

                // Name and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.radar_rounded,
                            size: 13,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${zone.radius.toInt()}m radius',
                            style: AppTheme.bodySmall
                                .copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildProfileBadge(zone),
                    ],
                  ),
                ),

                // Quick Toggle switch
                IconButton(
                  onPressed: () {
                    Provider.of<ZoneProvider>(context, listen: false)
                        .toggleZoneActive(zone.id);
                  },
                  icon: Icon(
                    zone.isActive
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded,
                    color: zone.isActive ? zone.color : Colors.grey.shade400,
                    size: 44,
                  ),
                ),

                // Delete button
                IconButton(
                  onPressed: () {
                    ZoneDialogs.showDeleteZoneDialog(
                        context: context, zone: zone);
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileBadge(SilentZone zone) {
    String label;
    IconData icon;
    switch (zone.soundProfile) {
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
        color: zone.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: zone.color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: zone.color,
            ),
          ),
        ],
      ),
    );
  }
}
