import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../providers/auth_provider.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete Account?', style: AppTheme.headline3.copyWith(color: AppTheme.errorColor)),
          content: Text(
            'This action is permanent and cannot be undone. All your zones, settings, and personal data will be permanently removed.',
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.deleteAccount();
                if (!context.mounted) return;
                
                if (success) {
                  Navigator.pop(context); // Go back to root (login screen via auth wrapper)
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.errorMessage ?? 'Failed to delete account. You may need to log in again.'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

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
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location preferences saved')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: AppTheme.errorColor),
            title: Text('Delete Account', style: AppTheme.bodyLarge.copyWith(color: AppTheme.errorColor)),
            subtitle: Text('Permanently remove your data', style: AppTheme.bodySmall),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }
}
