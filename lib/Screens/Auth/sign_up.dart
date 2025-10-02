import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../UI/Components/auth_text_field.dart';
import '../../UI/Components/background_image_widget.dart';
import '../../Utils/firebase_auth_service.dart';
import '../../Utils/google_auth_service.dart';
import '../../Utils/main_variables.dart';
import 'login_in.dart';
import '../home.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize Google Auth Service if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await GoogleAuthService.initialize();
        print('✅ Google Auth Service ready for sign-up');
      } catch (e) {
        print('❌ Failed to initialize Google Auth Service: $e');
      }
    });
  }


  // Sign up with email and password
  void signUserUp() async {
    if (!_formKey.currentState!.validate()) return;

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
      // Create user with Firebase
      await FirebaseAuthService.createUserWithEmailAndPassword(
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

  // Sign up with Google with retry mechanism
  void signUpWithGoogle({int retryCount = 0}) async {
    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: HexColor(mainColor),
              ),
              const SizedBox(height: 16),
              Text(
                retryCount > 0 ? 'Retrying Google Sign-Up...' : 'Signing up with Google...',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );

    try {
      // Sign up with Google with timeout
      final userCredential = await FirebaseAuthService.signInWithGoogle().timeout(
        const Duration(seconds: 45), // Total timeout for the entire process
        onTimeout: () {
          throw 'Google Sign-Up timed out. Please try again.';
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
              content: Text('Google Sign-Up was cancelled.'),
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
        if (retryCount < 2 && e.toString().contains('network')) {
          // Retry for network errors
          await Future.delayed(const Duration(seconds: 2));
          signUpWithGoogle(retryCount: retryCount + 1);
          return;
        }
        
        // Show error message to user with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-Up failed: $e'),
            backgroundColor: Colors.red,
            action: retryCount < 2 ? SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => signUpWithGoogle(retryCount: retryCount + 1),
            ) : null,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
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
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      "Sign Up",
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
                                    AuthTextField(
                                      controller: email, 
                                      isPassword: false,
                                      inputType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 30),
                                    Text(
                                      "Password",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.grey.withOpacity(0.6),
                                          fontSize: isTablet ? 17 : 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    AuthTextField(controller: password, isPassword: true),
                                    const SizedBox(height: 30),
                                    Text(
                                      "Confirm Password",
                                      style: GoogleFonts.montserrat(
                                          color: Colors.grey.withOpacity(0.6),
                                          fontSize: isTablet ? 17 : 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    AuthTextField(controller: confirmPassword, isPassword: true),
                                    const SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: signUserUp,
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
                                            "Sign Up",
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
                                    // Google Sign-Up button
                                    GestureDetector(
                                      onTap: signUpWithGoogle,
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
                                        Text("Already have an account?",
                                            style: GoogleFonts.montserrat(
                                                color: Colors.grey.withOpacity(0.6),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                        TextButton(
                                          child: Text(" Sign In",
                                              style: GoogleFonts.montserrat(
                                                  color: HexColor(mainColor),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold)),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext context) =>
                                                        const LoginScreen()));
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

  Widget _buildDesktopLayout(BuildContext context, Size screenSize) {
    return SafeArea(
      child: Center(
        child: Container(
          width: 400,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
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
                      "Sign Up",
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
                    AuthTextField(
                      controller: email, 
                      isPassword: false,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Password",
                      style: GoogleFonts.montserrat(
                          color: Colors.grey.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    AuthTextField(controller: password, isPassword: true),
                    const SizedBox(height: 25),
                    Text(
                      "Confirm Password",
                      style: GoogleFonts.montserrat(
                          color: Colors.grey.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    AuthTextField(controller: confirmPassword, isPassword: true),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: signUserUp,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: HexColor(mainColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "Sign Up",
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
                    // Google Sign-Up button
                    GestureDetector(
                      onTap: signUpWithGoogle,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?",
                            style: GoogleFonts.montserrat(
                                color: Colors.grey.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        TextButton(
                          child: Text(" Sign In",
                              style: GoogleFonts.montserrat(
                                  color: HexColor(mainColor),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const LoginScreen()));
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
      ),
    );
  }
}
