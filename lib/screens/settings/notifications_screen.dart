import 'package:flutter/material.dart';
import '../../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushEnabled = true;
  bool _zoneAlerts = true;
  bool _emailUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTheme.headline3),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Enable all notifications from Geo Silent',
            value: _pushEnabled,
            onChanged: (val) => setState(() => _pushEnabled = val),
          ),
          _buildSwitchTile(
            title: 'Zone Entry/Exit Alerts',
            subtitle: 'Get notified when your ringer mode changes',
            value: _zoneAlerts,
            onChanged: _pushEnabled ? (val) => setState(() => _zoneAlerts = val) : null,
          ),
          _buildSwitchTile(
            title: 'Email Updates',
            subtitle: 'Receive tips and product updates via email',
            value: _emailUpdates,
            onChanged: (val) => setState(() => _emailUpdates = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool)? onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTheme.bodyLarge),
      subtitle: Text(subtitle, style: AppTheme.bodySmall),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryColor,
    );
  }
}
