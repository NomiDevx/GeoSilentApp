import 'package:flutter/material.dart';
import '../../theme.dart';
import 'legal_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Geo Silent', style: AppTheme.headline3),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.location_off, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('Geo Silent', style: AppTheme.headline1),
            const SizedBox(height: 8),
            Text('Version 1.0.0', style: AppTheme.bodyMedium),
            const SizedBox(height: 48),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalScreen(initialTabIndex: 1),
                  ),
                );
              },
              child: const Text('Terms of Service'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LegalScreen(initialTabIndex: 0),
                  ),
                );
              },
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}
