import 'package:flutter/material.dart';
import '../../theme.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  double _defaultRadius = 150;
  String _defaultProfile = 'Silent';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferences', style: AppTheme.headline3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Default Zone Radius', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('${_defaultRadius.toStringAsFixed(0)} meters', style: AppTheme.bodyMedium),
          Slider(
            value: _defaultRadius,
            min: 50,
            max: 500,
            divisions: 9,
            activeColor: AppTheme.primaryColor,
            onChanged: (val) => setState(() => _defaultRadius = val),
          ),
          const Divider(height: 32),
          Text('Default Sound Profile', style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Silent', label: Text('Silent'), icon: Icon(Icons.volume_off)),
              ButtonSegment(value: 'Vibrate', label: Text('Vibrate'), icon: Icon(Icons.vibration)),
              ButtonSegment(value: 'Normal', label: Text('Normal'), icon: Icon(Icons.volume_up)),
            ],
            selected: {_defaultProfile},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() => _defaultProfile = newSelection.first);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.primaryColor.withOpacity(0.2);
                  }
                  return Colors.transparent;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
