import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../Utils/main_variables.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
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
                'Terms of Service',
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
                '1. Acceptance of Terms',
                'By accessing and using CardioDTech, you accept and agree to be bound by the terms and provision of this agreement.',
              ),
              
              _buildSection(
                '2. Use License',
                'Permission is granted to temporarily download one copy of CardioDTech for personal, non-commercial transitory viewing only.',
              ),
              
              _buildSection(
                '3. Medical Disclaimer',
                'CardioDTech is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider.',
              ),
              
              _buildSection(
                '4. User Responsibilities',
                'You are responsible for maintaining the confidentiality of your account and password and for restricting access to your computer.',
              ),
              
              _buildSection(
                '5. Prohibited Uses',
                'You may not use our app for any unlawful purpose or to solicit others to perform unlawful acts.',
              ),
              
              _buildSection(
                '6. Privacy Policy',
                'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the app.',
              ),
              
              _buildSection(
                '7. Contact Information',
                'If you have any questions about these Terms of Service, please contact us at support@cardiodtech.com.',
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
