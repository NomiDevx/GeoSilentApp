import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  double _defaultRadius = 150;
  String _defaultProfile = 'Silent';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _defaultRadius = prefs.getDouble('default_radius') ?? 150.0;
      _defaultProfile = prefs.getString('default_profile') ?? 'Silent';
      _isLoading = false;
    });
  }

  Future<void> _saveRadius(double val) async {
    setState(() => _defaultRadius = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('default_radius', val);
  }

  Future<void> _saveProfile(String val) async {
    setState(() => _defaultProfile = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_profile', val);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Preferences', style: AppTheme.headline3)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
            onChanged: _saveRadius,
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
              _saveProfile(newSelection.first);
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
