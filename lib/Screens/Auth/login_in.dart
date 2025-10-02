import 'package:cardiodtech/Screens/Auth/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../UI/Components/auth_text_field.dart';
import '../../UI/Components/background_image_widget.dart';
import '../../Utils/firebase_auth_service.dart';
import '../../Utils/main_variables.dart';
import '../home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }


  // Sign in with email and password
  void signUserIn() async {
    // Basic validation
    if (email.text.isEmpty || password.text.isEmpty) {
      return;
    }

    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: HexColor(mainColor),
          ),
        );
      },
    );

    try {
      // Sign in with Firebase
      await FirebaseAuthService.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      
      if (mounted) {
        // Pop the loading circle
        Navigator.pop(context);
        
        // Navigate to home screen
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const HomeScreen())
        );
      }
    } catch (e) {
      if (mounted) {
        // Pop the loading circle
        Navigator.pop(context);
      }
    }
  }

  // Sign in with Google
  void signInWithGoogle() async {
    await _signInWithGoogleWithRetry();
  }

  // Sign in with Google with retry mechanism
  Future<void> _signInWithGoogleWithRetry({int retryCount = 0}) async {
    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: HexColor(mainColor),
          ),
        );
      },
    );

    try {
      // Sign in with Google with timeout
      final userCredential = await FirebaseAuthService.signInWithGoogle().timeout(
        const Duration(seconds: 45), // Total timeout for the entire process
        onTimeout: () {
          throw 'Google Sign-In timed out. Please try again.';
        },
      );
      
      if (mounted) {
        // Pop the loading circle
        Navigator.pop(context);
        
        if (userCredential != null) {
          // Navigate to home screen
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const HomeScreen())
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In was cancelled.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Pop the loading circle
        Navigator.pop(context);
        
        // Check if we should retry
        if (retryCount < 2 && (e.toString().contains('timed out') || e.toString().contains('network'))) {
          print('🔄 Retrying Google Sign-In (attempt ${retryCount + 1}/2)...');
          
          // Wait a bit before retrying
          await Future.delayed(const Duration(seconds: 2));
          
          // Retry
          await _signInWithGoogleWithRetry(retryCount: retryCount + 1);
        } else {
          // Show error message to user with retry option
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google Sign-In failed: $e'),
              backgroundColor: Colors.red,
              action: retryCount < 2 ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _signInWithGoogleWithRetry(retryCount: retryCount + 1),
              ) : null,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  // Forgot Password Dialog
  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Reset Password",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: HexColor(mainColor),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter your email address and we'll send you a link to reset your password.",
              style: GoogleFonts.montserrat(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: GoogleFonts.montserrat(),
            ),
          ),
          FilledButton(
            onPressed: () async {
              if (emailController.text.isEmpty) {
                return;
              }
              
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
                return;
              }
              
              Navigator.of(context).pop();
              
              // Show loading dialog
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
                await FirebaseAuthService.sendPasswordResetEmail(emailController.text);
                
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(
              "Send Reset Link",
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Size screenSize) {
    return SafeArea(
      child: Center(
        child: Container(
          width: 400,
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CachedImageWidget(
                      imagePath: "assets/Images/white_logo.png",
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "CardioDTech",
                      style: GoogleFonts.montserrat(
                          color: HexColor(mainColor),
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Login",
                    style: GoogleFonts.montserrat(
                        color: HexColor(mainColor),
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Email",
                    style: GoogleFonts.montserrat(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  AuthTextField(controller: email, isPassword: false),
                  const SizedBox(height: 25),
                  Text(
                    "Password",
                    style: GoogleFonts.montserrat(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  AuthTextField(controller: password, isPassword: true),
                  const SizedBox(height: 10),
                  // Forgot Password button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordDialog(),
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.montserrat(
                          color: HexColor(mainColor),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: signUserIn,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: HexColor(mainColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          "Login",
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Or another method text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "or another method",
                          style: GoogleFonts.montserrat(
                            color: Colors.grey.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withOpacity(0.3),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Google Sign-In button
                  GestureDetector(
                    onTap: signInWithGoogle,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/Images/google.png',
                            height: 20,
                            width: 20,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.login,
                                color: HexColor(mainColor),
                                size: 20,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Continue with Google",
                            style: GoogleFonts.montserrat(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Debug button (remove in production)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account yet ?",
                          style: GoogleFonts.montserrat(
                              color: Colors.grey.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      TextButton(
                        child: Text(" Sign Up",
                            style: GoogleFonts.montserrat(
                                color: HexColor(mainColor),
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const SignUpScreen()));
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;
    
    return BackgroundImageWidget(
      imagePath: "assets/Images/background.jpg",
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: isDesktop 
            ? _buildDesktopLayout(context, screenSize)
            : SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header section with logo and title
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: CachedImageWidget(
                            imagePath: "assets/Images/white_logo.png",
                            height: isTablet ? 220 : 180,
                            width: isTablet ? 220 : 180,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "CardioDTech",
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: isTablet ? 30 : 25,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 30),
                        // White container with form
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40.0),
                                  topRight: Radius.circular(40.0)),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isTablet ? 30.0 : 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    "Login",
                                    style: GoogleFonts.montserrat(
                                        color: HexColor(mainColor),
                                        fontSize: isTablet ? 40 : 35,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 25),
                                  Text(
                                    "Email",
                                    style: GoogleFonts.montserrat(
                                        color: Colors.grey.withOpacity(0.6),
                                        fontSize: isTablet ? 17 : 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  AuthTextField(controller: email, isPassword: false),
                                  const SizedBox(height: 30),
                                  Text(
                                    "Password",
                                    style: GoogleFonts.montserrat(
                                        color: Colors.grey.withOpacity(0.6),
                                        fontSize: isTablet ? 17 : 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  AuthTextField(controller: password, isPassword: true),
                                  const SizedBox(height: 10),
                                  // Forgot Password button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => _showForgotPasswordDialog(),
                                      child: Text(
                                        "Forgot Password?",
                                        style: GoogleFonts.montserrat(
                                          color: HexColor(mainColor),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: signUserIn,
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      margin:
                                          const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: HexColor(mainColor),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Login",
                                          style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )),
                                  const SizedBox(height: 20),
                                  // Or another method text
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.withOpacity(0.3),
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          "or another method",
                                          style: GoogleFonts.montserrat(
                                            color: Colors.grey.withOpacity(0.6),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.withOpacity(0.3),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Google Sign-In button
                                  GestureDetector(
                                    onTap: signInWithGoogle,
                                    child: Container(
                                      padding: const EdgeInsets.all(15),
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/Images/google.png',
                                            height: 20,
                                            width: 20,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.login,
                                                color: HexColor(mainColor),
                                                size: 20,
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "Continue with Google",
                                            style: GoogleFonts.montserrat(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Don't have an account yet ?",
                                          style: GoogleFonts.montserrat(
                                              color: Colors.grey.withOpacity(0.6),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                      TextButton(
                                        child: Text(" Sign Up",
                                            style: GoogleFonts.montserrat(
                                                color: HexColor(mainColor),
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (BuildContext context) =>
                                                      const SignUpScreen()));
                                        },
                                      )
                                    ],
                                  ),
                                  // Add bottom padding to ensure content doesn't get cut off
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
