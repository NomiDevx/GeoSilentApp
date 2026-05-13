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

    // Initialize providers after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final zoneProvider = Provider.of<ZoneProvider>(context, listen: false);
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);

      if (authProvider.user != null) {
        zoneProvider.initializeZones(authProvider.user!.uid);
        locationProvider.startTracking();
      }

      // React to location updates AFTER the frame is done, not during build
      locationProvider.addListener(() {
        if (!mounted) return;
        final pos = locationProvider.currentPosition;
        if (pos != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            zoneProvider.checkCurrentLocation(pos.latitude, pos.longitude);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // ── IndexedStack keeps all tabs alive, no push/pop needed ──
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(
            onNavigateToMap: () {
              setState(() => _selectedIndex = 1);
            },
          ),
          const MapScreen(),
          const ActiveZonesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: CustomCurvedNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (_selectedIndex == index) return; // already on this tab
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home tab content (extracted from old HomeScreen.build)
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final VoidCallback onNavigateToMap;

  const _HomeTab({required this.onNavigateToMap});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _scale = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final zoneProvider = Provider.of<ZoneProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    return ScaleTransition(
      scale: _scale,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
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

              // ── Animated banner ──────────────────────────────────────
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Lottie.asset(
                        'assets/animation/sound_waves.json',
                        width: 300,
                        height: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
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

              // ── Quick info buttons ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildInfoButton(
                      icon: Icons.pin_drop_outlined,
                      label: 'Current Location',
                      value: locationProvider.locationName,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoButton(
                      icon: Icons.phone_android_rounded,
                      label: 'Active Zones',
                      value: '${zoneProvider.activeZonesCount}',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoButton(
                      icon: Icons.add_location_alt_rounded,
                      label: 'Add Zone',
                      value: 'Use Map tab',
                      onTap: widget.onNavigateToMap,
                      isAddButton: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Status bars ──────────────────────────────────────────
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

              // ── Zones section ────────────────────────────────────────
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

              zoneProvider.isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )
                  : zoneProvider.zones.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
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
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                              isActive: zoneProvider.currentZone?.id == zone.id,
                              onTap: () {},
                            );
                          },
                        ),

              // Bottom padding so content clears the floating nav bar
              const SizedBox(height: 16),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        constraints: const BoxConstraints(minHeight: 140),
        decoration: BoxDecoration(
          color: isAddButton ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isAddButton
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: isAddButton
              ? null
              : Border.all(color: Colors.grey.shade100, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isAddButton
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isAddButton ? Colors.white : AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: isAddButton ? Colors.white70 : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: isAddButton ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
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
