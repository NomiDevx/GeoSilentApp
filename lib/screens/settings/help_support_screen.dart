import 'package:flutter/material.dart';
import '../../theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Support', style: AppTheme.headline3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildFaqItem('How do I add a new zone?', 'Go to the Map tab, tap on your desired location, adjust the radius, and save.'),
          _buildFaqItem('Why isn\'t my phone silencing?', 'Ensure you have granted the "Do Not Disturb" permission in your Android settings, and that the zone is Active.'),
          _buildFaqItem('Does it drain my battery?', 'Geo Silent uses efficient background location tracking to minimize battery impact, but keeping GPS on does consume some power.'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.email),
              label: const Text('Contact Support'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(question, style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer, style: AppTheme.bodyMedium),
          )
        ],
      ),
    );
  }
}
