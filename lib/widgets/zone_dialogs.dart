import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/zone_model.dart';
import '../providers/zone_provider.dart';
import '../theme.dart';

class ZoneDialogs {
  // Show options sheet (Edit, Delete, Toggle)
  static void showZoneOptionsSheet({
    required BuildContext context,
    required SilentZone zone,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              
              // Zone Header info
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: zone.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        zone.icon,
                        style: const TextStyle(fontSize: 24),
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
                          style: AppTheme.headline3.copyWith(fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '📍 ${zone.radius.toInt()}m radius',
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              
              // 1. Toggle option
              ListTile(
                leading: Icon(
                  zone.isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                  color: zone.isActive ? Colors.orange : Colors.green,
                ),
                title: Text(
                  zone.isActive ? 'Deactivate Zone' : 'Activate Zone',
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Provider.of<ZoneProvider>(context, listen: false).toggleZoneActive(zone.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Zone "${zone.name}" ${zone.isActive ? "deactivated" : "activated"}.'),
                      backgroundColor: AppTheme.textPrimary,
                    ),
                  );
                },
              ),
              
              // 2. Edit option
              ListTile(
                leading: Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                title: Text(
                  'Edit Details',
                  style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  showEditZoneSheet(context: context, zone: zone);
                },
              ),
              
              // 3. Delete option
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
                title: Text(
                  'Delete Zone',
                  style: AppTheme.bodyLarge.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  showDeleteZoneDialog(context: context, zone: zone);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show delete confirmation dialog
  static void showDeleteZoneDialog({
    required BuildContext context,
    required SilentZone zone,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Delete Zone?',
            style: AppTheme.headline3.copyWith(color: AppTheme.errorColor),
          ),
          content: Text(
            'Are you sure you want to delete "${zone.name}"? This action cannot be undone.',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final success = await Provider.of<ZoneProvider>(context, listen: false).deleteZone(zone.id);
                if (context.mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Zone "${zone.name}" deleted successfully.'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Failed to delete zone.'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Show Edit Zone Sheet
  static void showEditZoneSheet({
    required BuildContext context,
    required SilentZone zone,
  }) {
    String editName = zone.name;
    SoundProfile editProfile = zone.soundProfile;
    double editRadius = zone.radius;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (stateContext, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(stateContext).viewInsets.bottom + 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 24),
                  Text(
                    'Edit Silent Zone',
                    style: AppTheme.headline2.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 24),

                  // Zone Name Input
                  TextFormField(
                    initialValue: editName,
                    decoration: InputDecoration(
                      labelText: 'Zone Name',
                      prefixIcon: Icon(Icons.edit_location_alt_rounded, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onChanged: (value) => editName = value,
                  ),
                  const SizedBox(height: 24),

                  // Sound Profile Selection
                  Text(
                    'Sound Profile',
                    style: AppTheme.headline3.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        _buildProfileTab(
                          profile: SoundProfile.silent,
                          label: 'Silent',
                          icon: Icons.volume_off_rounded,
                          color: AppTheme.silentZoneColor,
                          selectedProfile: editProfile,
                          onTap: () => setSheetState(() => editProfile = SoundProfile.silent),
                        ),
                        _buildProfileTab(
                          profile: SoundProfile.vibration,
                          label: 'Vibrate',
                          icon: Icons.vibration_rounded,
                          color: AppTheme.vibrationZoneColor,
                          selectedProfile: editProfile,
                          onTap: () => setSheetState(() => editProfile = SoundProfile.vibration),
                        ),
                        _buildProfileTab(
                          profile: SoundProfile.normal,
                          label: 'Normal',
                          icon: Icons.volume_up_rounded,
                          color: AppTheme.normalZoneColor,
                          selectedProfile: editProfile,
                          onTap: () => setSheetState(() => editProfile = SoundProfile.normal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Coverage Radius Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Coverage Radius',
                        style: AppTheme.headline3.copyWith(fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${editRadius.toInt()} m',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: editRadius,
                    min: 50,
                    max: 500,
                    divisions: 9,
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (value) {
                      setSheetState(() => editRadius = value);
                    },
                  ),
                  const SizedBox(height: 28),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (editName.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please enter a zone name.'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          return;
                        }
                        
                        Navigator.pop(sheetCtx);
                        final updatedZone = SilentZone(
                          id: zone.id,
                          userId: zone.userId,
                          name: editName,
                          type: zone.type,
                          latitude: zone.latitude,
                          longitude: zone.longitude,
                          radius: editRadius,
                          soundProfile: editProfile,
                          isActive: zone.isActive,
                          createdAt: zone.createdAt,
                          updatedAt: DateTime.now(),
                          schedule: zone.schedule,
                          isRepeating: zone.isRepeating,
                        );

                        final success = await Provider.of<ZoneProvider>(context, listen: false).updateZone(updatedZone);
                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Zone "${updatedZone.name}" updated successfully.'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Failed to update zone.'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildProfileTab({
    required SoundProfile profile,
    required String label,
    required IconData icon,
    required Color color,
    required SoundProfile selectedProfile,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedProfile == profile;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade400,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.textPrimary : Colors.grey.shade500,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
