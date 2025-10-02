import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../Utils/firebase_auth_service.dart';
import '../Utils/main_variables.dart';
import 'Auth/login_in.dart';
import 'Settings/about.dart';
import 'Settings/privacy_policy.dart';
import 'Settings/profile_settings.dart';
import 'Settings/terms_of_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _userEmail;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userEmail = FirebaseAuthService.userEmail;
      _userName = FirebaseAuthService.userDisplayName;
    });
  }

  void _logout(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Log out', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
          content: Text('Are you sure you want to log out?', style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(
                      color: HexColor(mainColor),
                    ),
                  ),
                );
                
                try {
                  // Sign out from Firebase
                  await FirebaseAuthService.signOut();
                  
                  if (mounted) {
                    // Close loading dialog
                    Navigator.of(context).pop();
                    
                    // Navigate to login screen
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    // Close loading dialog
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Text('Log out', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: HexColor(mainColor)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            color: HexColor(mainColor),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  // Medical Card Section
                  _MedicalCard(
                    userName: _userName ?? 'User',
                    userEmail: _userEmail ?? 'user@example.com',
                  ),

                  const SizedBox(height: 24),

                  // Account Section
                  _SectionHeader(title: 'Account'),
                  _SettingTile(
                    icon: Icons.person_outline,
                    title: 'Profile Settings',
                    description: 'Manage your personal information',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
                    ),
                  ),

                  const SizedBox(height: 24),


                  // Privacy & Data Section
                  _SectionHeader(title: 'Privacy & Data'),
                  _SettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    description: 'Learn how we protect and handle your data',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SettingTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    description: 'Read our terms and conditions for using the app',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // App Information Section
                  _SectionHeader(title: 'App Information'),
                  _SettingTile(
                    icon: Icons.info_outline,
                    title: 'About',
                    description: 'Learn more about the app and its version details',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Session Section
                  _SectionHeader(title: 'Session'),
                  _SettingTile(
                    icon: Icons.logout_rounded,
                    title: 'Log out',
                    description: 'Sign out of your account securely',
                    isDestructive: true,
                    onTap: () => _logout(context),
                  ),

                  const SizedBox(height: 24),

                ],
              ),
      ),
    );
  }

}

class _MedicalCard extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _MedicalCard({
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    // Generate initials from user name
    final initials = userName.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').take(2).join('');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HexColor(mainColor),
            HexColor(mainColor).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Text(
              initials.isNotEmpty ? initials : 'U',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: HexColor(mainColor),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.grey[700],
          letterSpacing: 0.5,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.description,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = HexColor(mainColor);
    final iconSize = 22.0;

    final iconColor = isDestructive ? Colors.red : primary;
    final titleColor = isDestructive ? Colors.red : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: titleColor ?? Colors.grey[800],
          ),
        ),
        subtitle: description != null ? Text(
          description!,
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ) : null,
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
