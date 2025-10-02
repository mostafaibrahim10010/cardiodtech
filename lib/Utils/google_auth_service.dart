import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Unified Google Authentication Service
/// This service provides a single, reliable interface for Google Sign-In
class GoogleAuthService {
  static GoogleSignIn? _googleSignIn;
  static bool _isInitialized = false;
  
  /// Initialize Google Sign-In service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('🔧 Initializing Google Auth Service...');
      
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
        // Let Google Services handle the client ID automatically
        // This will use the correct client ID from google-services.json
      );
      
      _isInitialized = true;
      print('✅ Google Auth Service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Google Auth Service: $e');
      rethrow;
    }
  }
  
  /// Get the Google Sign-In instance
  static GoogleSignIn get instance {
    if (!_isInitialized) {
      throw Exception('GoogleAuthService not initialized. Call initialize() first.');
    }
    return _googleSignIn!;
  }
  
  /// Check if Google Sign-In is available
  static Future<bool> isAvailable() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Try to check if Google Play Services is available
      final isSignedIn = await instance.isSignedIn();
      print('📱 Google Sign-In availability check: ${isSignedIn ? "Available" : "Checking..."}');
      return true;
    } catch (e) {
      print('❌ Google Sign-In not available: $e');
      print('🔍 Error type: ${e.runtimeType}');
      
      // Handle specific error types
      if (e.toString().contains('ApiException: 10')) {
        print('💡 Configuration error - check google-services.json');
      } else if (e.toString().contains('ApiException: 7')) {
        print('💡 Network error - check internet connection');
      } else if (e.toString().contains('ApiException: 12500')) {
        print('💡 Google Play Services not available');
      }
      
      return false;
    }
  }
  
  /// Get current Google user (if any)
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final user = await instance.signInSilently();
      if (user != null) {
        print('👤 Current Google user: ${user.email}');
      }
      return user;
    } catch (e) {
      print('❌ Error getting current Google user: $e');
      return null;
    }
  }
  
  /// Sign in with Google
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      print('🚀 Starting Google Sign-In...');
      final user = await instance.signIn();
      
      if (user != null) {
        print('✅ Google Sign-In successful: ${user.email}');
      } else {
        print('⚠️ Google Sign-In was cancelled');
      }
      
      return user;
    } catch (e) {
      print('❌ Google Sign-In failed: $e');
      rethrow;
    }
  }
  
  /// Sign out from Google Sign-In
  static Future<void> signOut() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      await instance.signOut();
      print('✅ Google Sign-In signed out successfully');
    } catch (e) {
      print('❌ Error signing out from Google: $e');
      // Don't rethrow - sign out should be graceful
    }
  }
  
  /// Clear any stuck authentication states
  static Future<void> clearAuthState() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // Force sign out to clear any stuck states
      await instance.signOut();
      
      // Also try to disconnect to clear all cached data
      try {
        await instance.disconnect();
        print('🧹 Disconnected from Google Sign-In');
      } catch (e) {
        print('⚠️ Disconnect failed (this is usually fine): $e');
      }
      
      print('🧹 Cleared Google Sign-In authentication state');
    } catch (e) {
      print('❌ Error clearing Google Sign-In state: $e');
      // Don't rethrow - clearing state should be graceful
    }
  }
  
  /// Check if user is currently signed in to Google
  static Future<bool> isSignedIn() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final isSignedIn = await instance.isSignedIn();
      print('📊 Google Sign-In status: ${isSignedIn ? "Signed In" : "Not Signed In"}');
      return isSignedIn;
    } catch (e) {
      print('❌ Error checking Google Sign-In status: $e');
      return false;
    }
  }
  
  /// Get authentication details for current user
  static Future<GoogleSignInAuthentication?> getAuthentication() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      final user = await getCurrentUser();
      if (user != null) {
        final auth = await user.authentication;
        print('🔑 Got Google authentication tokens');
        return auth;
      }
      return null;
    } catch (e) {
      print('❌ Error getting Google authentication: $e');
      return null;
    }
  }
  
  /// Sign in with Google and return Firebase credential
  static Future<UserCredential?> signInWithFirebase() async {
    try {
      print('🚀 Starting Google Sign-In with Firebase...');
      
      // Check if Google Sign-In is available
      final googleSignInAvailable = await isAvailable();
      if (!googleSignInAvailable) {
        throw 'Google Sign-In is not available on this device.';
      }
      
      // Clear any stuck authentication states first
      await clearAuthState();
      
      // Sign in with Google
      final GoogleSignInAccount? googleUser = await signIn();
      
      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return null;
      }

      print('✅ Google Sign-In successful, getting authentication details...');
      
      // Obtain the auth details from the request with timeout
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏰ Getting authentication tokens timed out');
          throw 'Getting authentication tokens timed out. Please try again.';
        },
      );
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ Failed to get Google authentication tokens');
        throw 'Failed to get Google authentication tokens. Please try again.';
      }

      print('🔑 Got Google authentication tokens, creating Firebase credential...');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔥 Created Firebase credential, signing in to Firebase...');

      // Sign in to Firebase with the Google credential with timeout
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          print('⏰ Firebase sign-in timed out');
          throw 'Firebase sign-in timed out. Please try again.';
        },
      );
      
      print('🎉 Successfully signed in to Firebase with Google');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase Auth Exception: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      print('🔍 Error type: ${e.runtimeType}');
      
      // Handle specific error codes
      if (e.toString().contains('ApiException: 10')) {
        throw 'Google Sign-In configuration error. Please check Firebase Console settings.';
      } else if (e.toString().contains('ApiException: 7')) {
        throw 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('ApiException: 12500')) {
        throw 'Google Sign-In was cancelled.';
      } else if (e.toString().contains('sign_in_failed')) {
        throw 'Google Sign-In failed. Please check your internet connection and try again.';
      } else if (e.toString().contains('network_error')) {
        throw 'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('sign_in_canceled')) {
        throw 'Sign-in was cancelled.';
      } else if (e.toString().contains('timed out')) {
        throw e.toString();
      } else {
        throw 'Google Sign-In error: ${e.toString()}';
      }
    }
  }
  
  /// Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'invalid-credential':
        return 'The credentials provided are invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
  
  /// Get detailed status
  static Future<Map<String, dynamic>> getStatus() async {
    final status = <String, dynamic>{};
    
    try {
      status['initialized'] = _isInitialized;
      status['available'] = await isAvailable();
      status['signed_in'] = await isSignedIn();
      
      final user = await getCurrentUser();
      status['has_user'] = user != null;
      if (user != null) {
        status['user_email'] = user.email;
        status['user_display_name'] = user.displayName;
        status['user_id'] = user.id;
      }
      
      final auth = await getAuthentication();
      status['has_auth'] = auth != null;
      if (auth != null) {
        status['has_access_token'] = auth.accessToken != null;
        status['has_id_token'] = auth.idToken != null;
      }
      
      final firebaseUser = FirebaseAuth.instance.currentUser;
      status['firebase_signed_in'] = firebaseUser != null;
      if (firebaseUser != null) {
        status['firebase_user_email'] = firebaseUser.email;
        status['firebase_user_uid'] = firebaseUser.uid;
      }
      
    } catch (e) {
      status['error'] = e.toString();
    }
    
    return status;
  }
  
  /// Reset service (useful for testing)
  static void reset() {
    _googleSignIn = null;
    _isInitialized = false;
    print('🔄 Google Auth Service reset');
  }
}
