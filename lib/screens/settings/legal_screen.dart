import 'package:flutter/material.dart';
import '../../theme.dart';

class LegalScreen extends StatelessWidget {
  final int initialTabIndex;

  const LegalScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text('Legal Documents', style: AppTheme.headline3),
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textHint,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Privacy Policy'),
              Tab(text: 'Terms of Service'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPrivacyPolicy(),
            _buildTermsOfService(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Privacy Policy'),
          _buildSubHeader('Last updated: June 19, 2026'),
          const SizedBox(height: 16),
          _buildParagraph(
            'Geo Silent is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.',
          ),
          _buildSectionTitle('1. Information We Collect'),
          _buildParagraph(
            '• **Location Data:** We collect precise real-time location data (latitude and longitude) to monitor your distance from your defined silent zones.\n'
            '• **Background Location:** To enable the core geofencing features (automatically silencing your phone when you arrive at a designated area), the app collects location data in the background even when the app is closed, not in use, or running in the background.\n'
            '• **Account Details:** When you create an account, we collect your name, email address, and authentication credentials.',
          ),
          _buildSectionTitle('2. How We Use Your Information'),
          _buildParagraph(
            'We use the collected information solely to:\n'
            '• Register and authenticate your user account.\n'
            '• Save and synchronize your custom silent zones to Firestore.\n'
            '• Trigger the ringer mode modifications (silent, vibrate, normal) using native Android APIs when you cross zone boundaries.',
          ),
          _buildSectionTitle('3. Data Sharing & Third Parties'),
          _buildParagraph(
            'We do NOT sell, rent, trade, or share your location or personal data with any third-party advertisers, marketers, or external entities. Your data is stored securely in Firebase (Google Cloud Platform) and cached locally on your device.',
          ),
          _buildSectionTitle('4. Data Deletion & Rights'),
          _buildParagraph(
            'You have full control over your data. You can delete your custom silent zones or permanently delete your account and all associated data at any time via the "Privacy & Security" settings inside the app.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTermsOfService() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Terms of Service'),
          _buildSubHeader('Last updated: June 19, 2026'),
          const SizedBox(height: 16),
          _buildParagraph(
            'By downloading or using the Geo Silent application, you agree to comply with and be bound by the following Terms of Service.',
          ),
          _buildSectionTitle('1. Permitted Use'),
          _buildParagraph(
            'You may use Geo Silent for your personal, non-commercial convenience to manage your phone\'s sound profiles based on location boundaries.',
          ),
          _buildSectionTitle('2. Permissions Required'),
          _buildParagraph(
            'For the app to function properly, you must grant:\n'
            '• **Location Permissions:** Must be set to "Allow all the time" for reliable background zone triggers.\n'
            '• **Do Not Disturb (DND) Access:** Required to change ringer mode to "Silent". Without this access, the app will fallback to "Vibrate".',
          ),
          _buildSectionTitle('3. Disclaimers & Limits of Liability'),
          _buildParagraph(
            '• **OS Restrictions:** Android aggressively manages battery saver settings and background services. While our service runs in the foreground with a visible notification, delays in location updates from the operating system may occasionally occur. We are not responsible for ringers not silenced due to native OS throttling or delays.\n'
            '• **Accuracy:** Geofence triggers rely on GPS/Wi-Fi positioning, which may vary in accuracy depending on environmental factors.',
          ),
          _buildSectionTitle('4. Modifications to Service'),
          _buildParagraph(
            'We reserve the right to modify, suspend, or discontinue the application or its features at any time without notice.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(
      title,
      style: AppTheme.headline2.copyWith(color: AppTheme.primaryColor),
    );
  }

  Widget _buildSubHeader(String text) {
    return Text(
      text,
      style: AppTheme.bodySmall.copyWith(color: AppTheme.textHint, fontStyle: FontStyle.italic),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: AppTheme.headline3.copyWith(fontSize: 16),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: AppTheme.bodyMedium.copyWith(height: 1.6, color: AppTheme.textSecondary),
    );
  }
}
