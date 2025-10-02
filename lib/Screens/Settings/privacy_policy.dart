import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../Utils/main_variables.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: HexColor(mainColor),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Last updated: ${DateTime.now().year}',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 24),
              
              _buildSection(
                '1. Information We Collect',
                'We collect information you provide directly to us, such as when you create an account, use our health tracking features, or contact us for support.',
              ),
              
              _buildSection(
                '2. How We Use Your Information',
                'We use the information we collect to provide, maintain, and improve our services, including health monitoring, medication reminders, and personalized recommendations.',
              ),
              
              _buildSection(
                '3. Health Data Privacy',
                'Your health data is encrypted and stored securely. We do not share your personal health information with third parties without your explicit consent.',
              ),
              
              _buildSection(
                '4. Data Security',
                'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
              ),
              
              _buildSection(
                '5. Your Rights',
                'You have the right to access, update, or delete your personal information. You can also opt out of certain data collection practices.',
              ),
              
              _buildSection(
                '6. Contact Us',
                'If you have any questions about this Privacy Policy, please contact us at privacy@cardiodtech.com.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: HexColor(mainColor),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            content,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
