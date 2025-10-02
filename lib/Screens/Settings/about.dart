import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../Utils/main_variables.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      setState(() {
        _version = '1.0.0';
        _buildNumber = '1';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: HexColor(mainColor)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'About',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: HexColor(mainColor),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: HexColor(mainColor),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: HexColor(mainColor).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // App Name
              Text(
                'CardioDTech',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: HexColor(mainColor),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Version
              Text(
                'Version $_version (Build $_buildNumber)',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Description
              Text(
                'CardioDTech is a comprehensive health monitoring app designed to help you track your cardiovascular health, manage medications, and connect with healthcare professionals.',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Features
              _buildFeatureItem(
                Icons.favorite,
                'Heart Health Monitoring',
                'Track your heart rate, blood pressure, and other vital signs',
              ),
              
              _buildFeatureItem(
                Icons.medication,
                'Medicine Reminders',
                'Never miss a dose with smart medication reminders',
              ),
              
              _buildFeatureItem(
                Icons.medical_services,
                'Doctor Connection',
                'Find and connect with qualified healthcare professionals',
              ),
              
              _buildFeatureItem(
                Icons.psychology,
                'AI Assistant',
                'Get personalized health insights and recommendations',
              ),
              
              const SizedBox(height: 32),
              
              // Copyright
              Text(
                '© ${DateTime.now().year} CardioDTech. All rights reserved.',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: HexColor(mainColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: HexColor(mainColor),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HexColor(mainColor),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
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
