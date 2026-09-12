import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:office_app/theme.dart';
import 'package:office_app/widgets/custom_widgets.dart';

import 'package:office_app/models/user_model.dart';
import 'package:office_app/screens/profile_form_screen.dart';
import 'package:office_app/services/firestore_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showFeatureNotImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout? This will also sign you out of your Google account.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                // Sign out of Google to clear the account picker
                await GoogleSignIn().signOut();
                // Sign out of Firebase
                await FirebaseAuth.instance.signOut();
                
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context, UserProfile? profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileFormScreen(profile: profile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                      ? [AppTheme.backgroundColor, const Color(0xFF1E1B4B)]
                      : [const Color(0xFFFFFFFF), const Color(0xFFEEF2FF)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<UserProfile?>(
              stream: FirestoreService.getUserProfile(),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final name = profile?.displayName.isEmpty ?? true ? 'IT Asset Manager' : profile!.displayName;
                final designation = profile?.designation.isEmpty ?? true ? 'Manage your organization assets' : profile!.designation;
                final photoUrl = profile?.photoUrl.isEmpty ?? true 
                    ? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png' 
                    : profile!.photoUrl;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    children: [
                      // Profile Header
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(photoUrl),
                                backgroundColor: theme.cardColor,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _navigateToEditProfile(context, profile),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name, 
                        style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        designation, 
                        style: const TextStyle(color: AppTheme.primaryColor, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 40),

                      // Profile Sections
                      _ProfileOption(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal Information',
                        subtitle: 'Manage your contact details',
                        onTap: () => _navigateToEditProfile(context, profile),
                      ),
                      _ProfileOption(
                        icon: Icons.security_rounded,
                        title: 'Security & Access',
                        subtitle: 'Password, Biometrics, Permissions',
                        onTap: () => _showFeatureNotImplemented(context, 'Security'),
                      ),
                      _ProfileOption(
                        icon: Icons.notifications_rounded,
                        title: 'Notification Center',
                        subtitle: 'Stay updated on asset alerts',
                        onTap: () => _showFeatureNotImplemented(context, 'Notifications'),
                      ),
                      _ProfileOption(
                        icon: Icons.history_rounded,
                        title: 'Activity Logs',
                        subtitle: 'View your recent actions',
                        onTap: () => _showFeatureNotImplemented(context, 'Activity Logs'),
                      ),
                      
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeManager.themeModeNotifier,
                        builder: (context, mode, child) {
                          final isCurrentlyDark = mode == ThemeMode.dark;
                            return _ProfileOption(
                              icon: isCurrentlyDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              title: 'Appearance',
                              subtitle: isCurrentlyDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                              trailing: Switch(
                                value: isCurrentlyDark,
                                onChanged: (v) => ThemeManager.toggleTheme(v),
                                activeThumbColor: AppTheme.primaryColor,
                                activeTrackColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                              ),
                              onTap: () => ThemeManager.toggleTheme(!isCurrentlyDark),
                            );
                        },
                      ),
                  
                  const SizedBox(height: 32),
                  Divider(color: theme.dividerColor.withValues(alpha: 0.1)),
                  const SizedBox(height: 32),

                  _ProfileOption(
                    icon: Icons.help_outline_rounded,
                    title: 'Support Hub',
                    subtitle: 'Documentation, FAQ, Chat support',
                    onTap: () => _showFeatureNotImplemented(context, 'Support'),
                  ),
                  _ProfileOption(
                    icon: Icons.logout_rounded,
                    title: 'Logout Account',
                    subtitle: 'Securely exit your session',
                    isDestructive: true,
                    onTap: () => _showLogoutDialog(context),
                  ),
                  
                  const SizedBox(height: 40),
                  Text(
                    'VERSION 2.0.4 - STABLE', 
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.15), 
                      fontSize: 10, 
                      letterSpacing: 2, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  ),
);
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.titleLarge?.color ?? (isDark ? Colors.white : Colors.black87);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: ListTile(
          leading: Icon(icon, color: isDestructive ? Colors.redAccent : AppTheme.primaryColor, size: 24),
          title: Text(
            title, 
            style: TextStyle(
              color: isDestructive ? Colors.redAccent : textColor, 
              fontWeight: FontWeight.bold,
            ),
          ),
            subtitle: Text(
            subtitle, 
            style: TextStyle(
              color: textColor.withValues(alpha: 0.4), 
              fontSize: 12,
            ),
          ),
          trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, color: textColor.withValues(alpha: 0.1), size: 14),
          onTap: onTap,
        ),
      ),
    );
  }
}
