import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/zone_provider.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Logout confirmation sheet ────────────────────────────────────────
  void _showLogoutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogoutSheet(
        onConfirm: () {
          Navigator.pop(context);
          Provider.of<AuthProvider>(context, listen: false).signOut();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final zoneProvider = Provider.of<ZoneProvider>(context);
    final user = authProvider.user;

    final initials = (user?.name?.isNotEmpty == true ? user!.name! : 'U')
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    final activeCount = zoneProvider.zones.where((z) => z.isActive).length;
    final totalCount = zoneProvider.zones.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── Hero Header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildHeroHeader(
                  context,
                  user?.name ?? 'User Name',
                  user?.email ?? 'user@example.com',
                  initials,
                  user?.profileImage,
                ),
              ),

              // ── Stats Row ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _buildStatsRow(
                    totalZones: totalCount,
                    activeZones: activeCount,
                  ),
                ),
              ),

              // ── Section: Account ─────────────────────────────────────
              _buildSectionHeader('Account'),
              SliverToBoxAdapter(
                child: _buildSettingsGroup([
                  _SettingTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: 'Edit Profile',
                    subtitle: 'Update your name and photo',
                    onTap: () {},
                  ),
                  _SettingTile(
                    icon: Icons.notifications_outlined,
                    iconColor: AppTheme.infoColor,
                    title: 'Notifications',
                    subtitle: 'Manage alert preferences',
                    onTap: () {},
                  ),
                  _SettingTile(
                    icon: Icons.security_rounded,
                    iconColor: AppTheme.successColor,
                    title: 'Privacy & Security',
                    subtitle: 'Password and data settings',
                    onTap: () {},
                  ),
                ]),
              ),

              // ── Section: App ──────────────────────────────────────────
              _buildSectionHeader('App'),
              SliverToBoxAdapter(
                child: _buildSettingsGroup([
                  _SettingTile(
                    icon: Icons.tune_rounded,
                    iconColor: AppTheme.warningColor,
                    title: 'Preferences',
                    subtitle: 'Zone defaults and behavior',
                    onTap: () {},
                  ),
                  _SettingTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppTheme.secondaryColor,
                    title: 'Help & Support',
                    subtitle: 'FAQs and contact us',
                    onTap: () {},
                  ),
                  _SettingTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.primaryLight,
                    title: 'About Geo Silent',
                    subtitle: 'Version 1.0.0',
                    onTap: () {},
                  ),
                ]),
              ),

              // ── Logout Button ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: _buildLogoutButton(),
                ),
              ),

              // ── Footer ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Center(
                    child: Text(
                      'Geo Silent · v1.0.0',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textHint,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Hero Header
  // ────────────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(
    BuildContext context,
    String name,
    String email,
    String initials,
    String? photoUrl,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient background
        Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Page title
                  const Text(
                    ' ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  // Sign-out shortcut
                ],
              ),
            ),
          ),
        ),

        // Avatar + name card — overlaps gradient and white body
        Positioned(
          top: 140,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Avatar
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: photoUrl != null
                    ? ClipOval(
                        child: Image.network(photoUrl, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              Text(
                name,
                style: AppTheme.headline2.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email_outlined,
                      size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    email,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),

        // White body behind card
        Positioned(
          top: 200,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            height: 20,
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Stats Row
  // ────────────────────────────────────────────────────────────────────
  Widget _buildStatsRow({
    required int totalZones,
    required int activeZones,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 160),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStat(
            value: '$totalZones',
            label: 'Total Zones',
            icon: Icons.location_on_rounded,
            color: AppTheme.primaryColor,
          ),
          _buildVertDivider(),
          _buildStat(
            value: '$activeZones',
            label: 'Active Now',
            icon: Icons.volume_off_rounded,
            color: AppTheme.successColor,
          ),
          _buildVertDivider(),
          _buildStat(
            value: '98%',
            label: 'Accuracy',
            icon: Icons.gps_fixed_rounded,
            color: AppTheme.infoColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headline3.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVertDivider() {
    return Container(
      width: 1,
      height: 56,
      color: AppTheme.surfaceColor,
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Section header
  // ────────────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
        child: Text(
          title.toUpperCase(),
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textHint,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Settings card group
  // ────────────────────────────────────────────────────────────────────
  Widget _buildSettingsGroup(List<_SettingTile> tiles) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: List.generate(tiles.length, (i) {
            final tile = tiles[i];
            final isLast = i == tiles.length - 1;
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: tile.onTap,
                    borderRadius: BorderRadius.vertical(
                      top: i == 0 ? const Radius.circular(20) : Radius.zero,
                      bottom: isLast ? const Radius.circular(20) : Radius.zero,
                    ),
                    splashColor: tile.iconColor.withOpacity(0.06),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          // Colored icon box
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: tile.iconColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(tile.icon,
                                color: tile.iconColor, size: 20),
                          ),
                          const SizedBox(width: 14),
                          // Title + subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tile.title,
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (tile.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    tile.subtitle!,
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.textHint,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppTheme.textHint,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 72, right: 16),
                    child: Divider(
                      color: AppTheme.surfaceColor,
                      height: 1,
                      thickness: 1,
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────
  // Logout button
  // ────────────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Material(
      color: AppTheme.errorColor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _showLogoutSheet,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.errorColor.withOpacity(0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.logout_rounded,
                    color: AppTheme.errorColor, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                'Sign Out',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.errorColor.withOpacity(0.5), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data class for settings tiles ────────────────────────────────────────
class _SettingTile {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}

// ── Logout bottom sheet ──────────────────────────────────────────────────
class _LogoutSheet extends StatelessWidget {
  final VoidCallback onConfirm;

  const _LogoutSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.logout_rounded,
                color: AppTheme.errorColor, size: 28),
          ),
          const SizedBox(height: 16),

          Text('Sign Out?', style: AppTheme.headline3),
          const SizedBox(height: 8),
          Text(
            'You will be returned to the login screen.\nYour zones and data will be saved.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Confirm
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Yes, Sign Out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),

          // Cancel
          SizedBox(
            width: double.infinity,
            height: 52,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
