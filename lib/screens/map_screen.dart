import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
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
  double _radius = 100.0;
  String _zoneName = '';
  ZoneType _selectedType = ZoneType.office;
  bool _isLoadingLocation = false;
  LatLng _initialPosition = const LatLng(33.8938, 72.9346); // Default location
  bool _isMapReady = false;

  final List<ZoneType> _zoneTypes = ZoneType.values;
  final Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
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

          // Center indicator for map
          if (_selectedLocation == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 48,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap on map to select location',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Sheet for Zone Details
          if (_selectedLocation != null)
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.3,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 60,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Create Silent Zone',
                            style: AppTheme.headline2,
                          ),
                          const SizedBox(height: 24),

                          // Selected Coordinates
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedLocation != null
                                        ? 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                                            'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                                        : 'No location selected',
                                    style: AppTheme.bodySmall.copyWith(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Zone Name
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Zone Name',
                              hintText: 'e.g., Office, Mosque, Hospital',
                              prefixIcon: Icon(
                                Icons.location_on,
                                color: AppTheme.primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            onChanged: (value) => _zoneName = value,
                          ),

                          const SizedBox(height: 20),

                          // Zone Type Selection
                          Text(
                            'Zone Type',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _zoneTypes.map((type) {
                              final isSelected = _selectedType == type;
                              return ChoiceChip(
                                label: Text(_getTypeLabel(type)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedType = type;
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: AppTheme.primaryColor,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppTheme.primaryColor
                                        : Colors.grey[300]!,
                                    width: isSelected ? 0 : 1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 20),

                          // Radius Slider
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Radius: ${_radius.toStringAsFixed(0)} meters',
                                style: AppTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Slider(
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
                                activeColor: AppTheme.primaryColor,
                                inactiveColor: Colors.grey[300],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('50m', style: AppTheme.bodySmall),
                                  Text('250m', style: AppTheme.bodySmall),
                                  Text('500m', style: AppTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _saveZone(authProvider, zoneProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: zoneProvider.isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.save,
                                            color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Save Silent Zone',
                                          style: AppTheme.button,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Location Button
          Positioned(
            bottom: _selectedLocation != null ? 100 : 24,
            right: 24,
            child: FloatingActionButton(
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
      soundProfile: SoundProfile.silent,
      createdAt: DateTime.now(),
      isActive: true,
    );

    final success = await zoneProvider.addZone(zone);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Zone "${zone.name}" created successfully'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
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
}

