import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/zone_provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../models/zone_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  LatLng? _selectedLocation;
  double _radius = 150.0;
  String _zoneName = '';
  ZoneType _selectedType = ZoneType.office;
  SoundProfile _selectedProfile = SoundProfile.silent;
  bool _isLoadingLocation = false;
  LatLng _initialPosition = const LatLng(33.8938, 72.9346); // Default location
  bool _isMapReady = false;

  final List<ZoneType> _zoneTypes = ZoneType.values;
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _radius = prefs.getDouble('default_radius') ?? 150.0;
      final profileStr = prefs.getString('default_profile') ?? 'Silent';
      switch (profileStr) {
        case 'Vibrate':
          _selectedProfile = SoundProfile.vibration;
          break;
        case 'Normal':
          _selectedProfile = SoundProfile.normal;
          break;
        case 'Silent':
        default:
          _selectedProfile = SoundProfile.silent;
          break;
      }
    });
  }

  @override
  void dispose() {
    if (_isMapReady) {
      _mapController.dispose();
    }
    super.dispose();
  }

  // Get current location for initial map position
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _selectedLocation = _initialPosition;
      });

      // Move camera to current location
      if (_isMapReady) {
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_initialPosition, 14),
        );
      }

      _updateMarkers();
    } catch (e) {
      print('Error getting location: $e');
      // Keep default position
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final zoneProvider = Provider.of<ZoneProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Silent Zone'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _controller.complete(controller);
              setState(() => _isMapReady = true);
            },
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
                _updateMarkers();
              });
            },
            markers: _markers,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            tiltGesturesEnabled: false,
          ),

          // Top instruction banner when no location selected
          if (_selectedLocation == null)
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.touch_app_rounded, color: AppTheme.primaryColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Location',
                              style: AppTheme.headline3.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap anywhere on the map to set a new silent zone.',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Bottom Sheet for Zone Details
          if (_selectedLocation != null)
            DraggableScrollableSheet(
              initialChildSize: 0.55,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return _buildBottomSheetContent(context, authProvider, zoneProvider, scrollController);
              },
            ),

          // Location Button
          Positioned(
            bottom: _selectedLocation != null ? 100 : 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'locationBtn',
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: AppTheme.primaryColor,
              ),
              elevation: 4,
            ),
          ),

          // Cancel/Back Button
          if (_selectedLocation != null)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                heroTag: 'closeBtn',
                onPressed: () {
                  setState(() {
                    _selectedLocation = null;
                    _markers.clear();
                    _circles.clear();
                  });
                },
                backgroundColor: AppTheme.errorColor,
                child: const Icon(Icons.close, color: Colors.white),
                elevation: 4,
              ),
            ),
        ],
      ),
    );
  }

  void _updateMarkers() {
    if (_selectedLocation == null) return;

    _markers.clear();
    _circles.clear();

    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _selectedLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
        infoWindow: const InfoWindow(title: 'Selected Location'),
        draggable: false,
        onDragEnd: (newPosition) {
          setState(() {
            _selectedLocation = newPosition;
            _updateMarkers();
          });
        },
      ),
    );

    _circles.add(
      Circle(
        circleId: const CircleId('zone_circle'),
        center: _selectedLocation!,
        radius: _radius,
        strokeWidth: 2,
        strokeColor: AppTheme.primaryColor,
        fillColor: AppTheme.primaryColor.withOpacity(0.15),
      ),
    );

    // Update map camera to show both marker and circle
    if (_isMapReady) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    }
  }

  Future<void> _saveZone(
    AuthProvider authProvider,
    ZoneProvider zoneProvider,
  ) async {
    if (_selectedLocation == null) {
      _showErrorSnackBar('Please select a location on the map');
      return;
    }

    if (_zoneName.isEmpty) {
      _showErrorSnackBar('Please enter a zone name');
      return;
    }

    final zone = SilentZone(
      id: const Uuid().v4(),
      userId: authProvider.user!.uid,
      name: _zoneName,
      type: _selectedType,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      radius: _radius,
      soundProfile: _selectedProfile,
      createdAt: DateTime.now(),
      isActive: true,
    );

    final success = await zoneProvider.addZone(zone);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Zone "${zone.name}" created! Move to that location to activate.'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 3),
        ),
      );
      // Reset form so user can add another zone (do NOT pop - we're inside IndexedStack)
      setState(() {
        _selectedLocation = null;
        _zoneName = '';
        _markers.clear();
        _circles.clear();
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getTypeLabel(ZoneType type) {
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

  IconData _getTypeIcon(ZoneType type) {
    switch (type) {
      case ZoneType.office:
        return Icons.business_rounded;
      case ZoneType.mosque:
        return Icons.mosque_rounded;
      case ZoneType.hospital:
        return Icons.local_hospital_rounded;
      case ZoneType.classroom:
        return Icons.school_rounded;
      case ZoneType.library:
        return Icons.library_books_rounded;
      case ZoneType.cinema:
        return Icons.movie_creation_rounded;
      case ZoneType.other:
        return Icons.place_rounded;
    }
  }

  Widget _buildBottomSheetContent(
    BuildContext context, 
    AuthProvider authProvider, 
    ZoneProvider zoneProvider,
    ScrollController scrollController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              children: [
                Text(
                  'Create Silent Zone',
                  style: AppTheme.headline2.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 24),

                // Location Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.location_on_rounded, color: AppTheme.primaryColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Location Selected', 
                                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            const SizedBox(height: 4),
                            Text(
                              'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle_rounded, color: AppTheme.successColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Zone Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Zone Name',
                    hintText: 'e.g., Central Office, Grand Mosque',
                    prefixIcon: Icon(Icons.edit_location_alt_rounded, color: AppTheme.primaryColor),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                  ),
                  onChanged: (value) => _zoneName = value,
                ),
                const SizedBox(height: 24),

                // Zone Type
                Text(
                  'Category',
                  style: AppTheme.headline3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: _zoneTypes.map((type) {
                    final isSelected = _selectedType == type;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ChoiceChip(
                        avatar: Icon(
                          _getTypeIcon(type), 
                          size: 18, 
                          color: isSelected ? Colors.white : AppTheme.textSecondary
                        ),
                        label: Text(_getTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedType = type);
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Sound Profile
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
                      _buildProfileOption(SoundProfile.silent, 'Silent', Icons.volume_off_rounded, AppTheme.silentZoneColor),
                      _buildProfileOption(SoundProfile.vibration, 'Vibrate', Icons.vibration_rounded, AppTheme.vibrationZoneColor),
                      _buildProfileOption(SoundProfile.normal, 'Normal', Icons.volume_up_rounded, AppTheme.normalZoneColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Radius
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
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_radius.toInt()} m',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    activeTrackColor: AppTheme.primaryColor,
                    inactiveTrackColor: Colors.grey.shade200,
                    thumbColor: Colors.white,
                    overlayColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14, elevation: 4),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                  ),
                  child: Slider(
                    value: _radius,
                    min: 50,
                    max: 500,
                    divisions: 9,
                    onChanged: (value) {
                      setState(() {
                        _radius = value;
                        _updateMarkers();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('50m', style: AppTheme.bodySmall.copyWith(color: Colors.grey.shade500)),
                      Text('250m', style: AppTheme.bodySmall.copyWith(color: Colors.grey.shade500)),
                      Text('500m', style: AppTheme.bodySmall.copyWith(color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => _saveZone(authProvider, zoneProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: zoneProvider.isLoading
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_location_alt_rounded, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Create Silent Zone',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(SoundProfile profile, String label, IconData icon, Color color) {
    final isSelected = _selectedProfile == profile;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedProfile = profile),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
