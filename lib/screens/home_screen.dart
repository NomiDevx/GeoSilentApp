import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';
import '../providers/zone_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/animated_zone_card.dart';
import '../widgets/status_bar.dart';
import '../widgets/curved_nav_bar.dart';
import '../theme.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'active_zones_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final zoneProvider = Provider.of<ZoneProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        zoneProvider.initializeZones(authProvider.user!.uid);
        locationProvider.startTracking();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MapScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ActiveZonesScreen()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final zoneProvider = Provider.of<ZoneProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    // Check zones when location updates
    if (locationProvider.currentPosition != null) {
      zoneProvider.checkCurrentLocation(
        locationProvider.currentPosition!.latitude,
        locationProvider.currentPosition!.longitude,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: ScaleTransition(
        scale: _scaleAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome beck!',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          authProvider.user?.name?.split(' ').first ?? 'User',
                          style: AppTheme.headline2.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        authProvider.user?.name?.substring(0, 1) ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Animated GIF Square
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Animated Lottie
                      Center(
                        child: Lottie.asset(
                          'assets/animation/sound_waves.json',
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Overlay Text
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Geo Silent Active',
                              style: AppTheme.headline3.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${zoneProvider.activeZonesCount} zones monitoring',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Horizontal Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildInfoButton(
                        icon: Icons.location_on,
                        label: 'Current Location',
                        value: locationProvider.locationName,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoButton(
                        icon: Icons.place,
                        label: 'Active Zones',
                        value: '${zoneProvider.activeZonesCount}',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoButton(
                        icon: Icons.add_location_alt,
                        label: 'Add Zone',
                        value: 'Tap to add',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapScreen(),
                            ),
                          );
                        },
                        isAddButton: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Status Bars
                Column(
                  children: [
                    StatusBar(
                      title: 'Normal Zone',
                      subtitle: 'Your phone is in normal mode',
                      color: AppTheme.normalZoneColor,
                      icon: Icons.volume_up,
                      isActive: zoneProvider.currentZone == null,
                    ),
                    const SizedBox(height: 16),
                    StatusBar(
                      title: 'Silent Zone',
                      subtitle: zoneProvider.currentZone?.name ??
                          'Not in any silent zone',
                      color: AppTheme.silentZoneColor,
                      icon: Icons.volume_off,
                      isActive: zoneProvider.currentZone != null,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Active Zones Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Silent Zones', style: AppTheme.headline3),
                    Text(
                      '${zoneProvider.zones.length} total',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Zones Grid
                Expanded(
                  child: zoneProvider.isLoading
                      ? Center(
                          child: Lottie.asset(
                            'assets/animations/loading.json',
                            width: 100,
                            height: 100,
                          ),
                        )
                      : zoneProvider.zones.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 16),
                                  Text(
                                    'No silent zones added yet',
                                    style: AppTheme.bodyLarge.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap "Add Zone" to create your first zone',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: zoneProvider.zones.length,
                              itemBuilder: (context, index) {
                                final zone = zoneProvider.zones[index];
                                return AnimatedZoneCard(
                                  zone: zone,
                                  isActive:
                                      zoneProvider.currentZone?.id == zone.id,
                                  onTap: () {
                                    // Show zone details
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: CustomCurvedNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildInfoButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isAddButton = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 140),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isAddButton
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  isAddButton ? AppTheme.primaryColor : AppTheme.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color:
                    isAddButton ? AppTheme.primaryColor : AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
