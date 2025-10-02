import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Screens/Auth/login_in.dart';
import '../Screens/home.dart';
import '../Screens/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash screen while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        // If user is signed in, show home screen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        
        // If user is not signed in, show splash screen which will navigate to login
        return const SplashScreen();
      },
    );
  }
}
