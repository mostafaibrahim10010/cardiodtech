import 'dart:async';
import 'package:flutter/material.dart';
import '../UI/Components/background_image_widget.dart';
import '../Utils/image_preloader.dart';
import 'Auth/login_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _imagesPreloaded = false;
  bool _showContent = false;
  bool _hasStartedPreloading = false;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasStartedPreloading) {
      _hasStartedPreloading = true;
      // Use a microtask to ensure the widget tree is fully built
      Future.microtask(() => _preloadImages());
    }
  }

  Future<void> _preloadImages() async {
    try {
      // Images are already cached from startup, mark as loaded immediately
      if (mounted) {
        setState(() {
          _imagesPreloaded = true;
        });
      }

      // Try to preload in background for better performance
      if (ImagePreloader.isContextReady()) {
        await ImagePreloader.preloadBackgroundImage(context);
        await ImagePreloader.preloadImages(context);
      }
    } catch (e) {
      debugPrint('Error preloading images: $e');
      // Continue even if preload fails - images are already cached
    }
  }

  void _startSplashTimer() {
    // Show content after 1 second
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });

    // Navigate after 3 seconds total - always go to login screen for UI-only auth
    Timer(const Duration(seconds: 3), () async {
      if (mounted) {
        // Navigate to login screen (UI-only)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWidget(
      imagePath: "assets/Images/background.jpg",
      child: Center(
        child: AnimatedOpacity(
          opacity: _showContent ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animation
              AnimatedScale(
                scale: _showContent ? 1.0 : 0.8,
                duration: const Duration(milliseconds: 800),
                child: CachedImageWidget(
                  imagePath: "assets/Images/white_logo.png",
                  height: 200,
                  width: 200,
                ),
              ),
              const SizedBox(height: 30),
              
              // App name with animation
              AnimatedSlide(
                offset: _showContent ? Offset.zero : const Offset(0, 0.5),
                duration: const Duration(milliseconds: 600),
                child: Text(
                  "CardioDTech",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Loading indicator
              if (_imagesPreloaded)
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
