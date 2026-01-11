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

class _ActiveZonesScreenState extends State<ActiveZonesScreen> {
  @override
  Widget build(BuildContext context) {
    final zoneProvider = Provider.of<ZoneProvider>(context);
    final activeZones =
        zoneProvider.zones.where((zone) => zone.isActive).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Active Zones'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: activeZones.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 80,
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Zones',
                    style: AppTheme.headline2.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a zone to get started',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeZones.length,
              itemBuilder: (context, index) {
                final zone = activeZones[index];
                return _buildZoneCard(context, zone);
              },
            ),
    );
  }

  Widget _buildZoneCard(BuildContext context, SilentZone zone) {
    return GestureDetector(
      onTap: () => _showZoneDetails(context, zone),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getZoneIcon(zone.type),
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: AppTheme.headline3.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getZoneTypeName(zone.type),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Active',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    'Radius',
                    '${zone.radius.toInt()}m',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    'Sound',
                    _getSoundProfileName(zone.soundProfile),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to view details',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textHint,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showZoneDetails(BuildContext context, SilentZone zone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getZoneIcon(zone.type),
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.name,
                            style: AppTheme.headline2.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getZoneTypeName(zone.type),
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildDetailSection('Location', [
                  _buildDetailRow(
                    'Latitude',
                    zone.latitude.toStringAsFixed(6),
                  ),
                  _buildDetailRow(
                    'Longitude',
                    zone.longitude.toStringAsFixed(6),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildDetailSection('Zone Settings', [
                  _buildDetailRow('Radius', '${zone.radius.toInt()} meters'),
                  _buildDetailRow(
                    'Sound Profile',
                    _getSoundProfileName(zone.soundProfile),
                  ),
                  _buildDetailRow(
                    'Repeating',
                    zone.isRepeating ? 'Yes' : 'No',
                  ),
                ]),
                const SizedBox(height: 24),
                _buildDetailSection('Status', [
                  _buildDetailRow(
                    'Status',
                    zone.isActive ? 'Active' : 'Inactive',
                    valueColor: zone.isActive
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                  _buildDetailRow(
                    'Created',
                    _formatDate(zone.createdAt),
                  ),
                ]),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
          style: AppTheme.headline3.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: valueColor ?? AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getZoneIcon(ZoneType type) {
    switch (type) {
      case ZoneType.office:
        return Icons.business;
      case ZoneType.mosque:
        return Icons.mosque;
      case ZoneType.hospital:
        return Icons.local_hospital;
      case ZoneType.classroom:
        return Icons.school;
      case ZoneType.library:
        return Icons.library_books;
      case ZoneType.cinema:
        return Icons.movie;
      case ZoneType.other:
        return Icons.location_on;
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
