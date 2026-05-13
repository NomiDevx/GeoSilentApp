import 'package:flutter/material.dart';
import '../../theme.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy & Security', style: AppTheme.headline3),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text('Change Password', style: AppTheme.bodyLarge),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset email sent')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_off_outlined),
            title: Text('Location Data', style: AppTheme.bodyLarge),
            subtitle: Text('Manage how your location is used', style: AppTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: AppTheme.errorColor),
            title: Text('Delete Account', style: AppTheme.bodyLarge.copyWith(color: AppTheme.errorColor)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Account deletion requested'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
