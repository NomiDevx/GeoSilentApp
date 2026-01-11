import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: Icon(Icons.logout, color: AppTheme.errorColor),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Avatar with Animation
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: user?.profileImage != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user!.profileImage!),
                            radius: 65,
                          )
                        : Center(
                            child: Text(
                              user?.name?.substring(0, 2).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // User Name
              Text(
                user?.name ?? 'User Name',
                style: AppTheme.headline1.copyWith(
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: 8),

              // User Email
              Text(
                user?.email ?? 'user@example.com',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 40),

              // Stats Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    icon: Icons.location_on,
                    value: '12',
                    label: 'Zones',
                  ),
                  _buildStatCard(
                    icon: Icons.timer,
                    value: '24h',
                    label: 'Active',
                  ),
                  _buildStatCard(
                    icon: Icons.notifications,
                    value: '98%',
                    label: 'Accuracy',
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Settings List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingItem(
                      icon: Icons.person,
                      title: 'Edit Profile',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.security,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.info,
                      title: 'About Geo Silent',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // App Version
              Text(
                'Geo Silent v1.0.0',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.headline3.copyWith(
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: AppTheme.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textHint),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        color: Colors.grey[200],
        height: 1,
      ),
    );
  }
}
