import 'package:flutter/material.dart';

class ImagePreloader {
  static final Map<String, ImageProvider> _cachedImages = {};
  static final Map<String, bool> _preloadingStatus = {};
  static bool _isPreloading = false;
  static bool _isContextReady = false;

  /// Preloads all background images used in the app
  static Future<void> preloadImages(BuildContext context) async {
    if (_isPreloading) return;
    _isPreloading = true;
    _isContextReady = true;

    try {
      // List of background images to preload - prioritize background.jpg
      final imagePaths = [
        'assets/Images/background.jpg', // Most important - used in all screens
        'assets/Images/white_logo.png',
        'assets/Images/main_logo.png',
        'assets/person.png',
      ];

      // Preload each image with proper error handling
      for (final path in imagePaths) {
        try {
          final imageProvider = AssetImage(path);
          // Check if context is still mounted before precaching
          if (context.mounted) {
            await precacheImage(imageProvider, context);
            _cachedImages[path] = imageProvider;
            _preloadingStatus[path] = true;
            debugPrint(' Preloaded image: $path');
          } else {
            // Context is unmounted, just cache the provider
            _cachedImages[path] = imageProvider;
            _preloadingStatus[path] = false;
            debugPrint(' Context unmounted, cached image provider: $path');
          }
        } catch (e) {
          debugPrint(' Failed to preload image $path: $e');
          _preloadingStatus[path] = false;
          // Still cache the image provider even if precache fails
          _cachedImages[path] = AssetImage(path);
        }
      }

      debugPrint(' All images preloaded successfully');
    } catch (e) {
      debugPrint(' Error preloading images: $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// Preloads only the background image (most critical)
  static Future<void> preloadBackgroundImage(BuildContext context) async {
    const backgroundPath = 'assets/Images/background.jpg';
    
    if (_cachedImages.containsKey(backgroundPath)) return;
    
    try {
      final imageProvider = AssetImage(backgroundPath);
      // Check if context is still mounted before precaching
      if (context.mounted) {
        await precacheImage(imageProvider, context);
        _cachedImages[backgroundPath] = imageProvider;
        _preloadingStatus[backgroundPath] = true;
        debugPrint(' Preloaded background image: $backgroundPath');
      } else {
        // Context is unmounted, just cache the provider
        _cachedImages[backgroundPath] = imageProvider;
        _preloadingStatus[backgroundPath] = false;
        debugPrint(' Context unmounted, cached background image provider: $backgroundPath');
      }
    } catch (e) {
      debugPrint(' Failed to preload background image $backgroundPath: $e');
      _preloadingStatus[backgroundPath] = false;
      // Still cache the image provider even if precache fails
      _cachedImages[backgroundPath] = AssetImage(backgroundPath);
    }
  }

  /// Gets a cached image provider or creates a new one
  static ImageProvider getImage(String path) {
    // Always ensure the image is cached, even if not preloaded
    if (!_cachedImages.containsKey(path)) {
      _cachedImages[path] = AssetImage(path);
      _preloadingStatus[path] = false;
      debugPrint(' Auto-cached image provider: $path');
    }
    return _cachedImages[path]!;
  }

  /// Checks if an image is already cached
  static bool isImageCached(String path) {
    return _cachedImages.containsKey(path);
  }

  /// Checks if an image is currently being preloaded
  static bool isImagePreloading(String path) {
    return _preloadingStatus[path] == true;
  }

  /// Clears the image cache (useful for memory management)
  static void clearCache() {
    _cachedImages.clear();
    _preloadingStatus.clear();
  }

  /// Preloads a specific image
  static Future<void> preloadSingleImage(BuildContext context, String path) async {
    if (_cachedImages.containsKey(path)) return;
    
    try {
      final imageProvider = AssetImage(path);
      // Check if context is still mounted before precaching
      if (context.mounted) {
        await precacheImage(imageProvider, context);
        _cachedImages[path] = imageProvider;
        _preloadingStatus[path] = true;
        debugPrint(' Preloaded single image: $path');
      } else {
        // Context is unmounted, just cache the provider
        _cachedImages[path] = imageProvider;
        _preloadingStatus[path] = false;
        debugPrint(' Context unmounted, cached single image provider: $path');
      }
    } catch (e) {
      debugPrint(' Failed to preload single image $path: $e');
      _preloadingStatus[path] = false;
      // Still cache the image provider even if precache fails
      _cachedImages[path] = AssetImage(path);
    }
  }

  /// Checks if the context is ready for preloading
  static bool isContextReady() {
    return _isContextReady;
  }

  /// Preloads critical images globally at app startup
  static Future<void> preloadCriticalImages() async {
    const criticalImages = [
      'assets/Images/background.jpg',
      'assets/Images/white_logo.png',
      'assets/Images/main_logo.png',
    ];

    for (final path in criticalImages) {
      _cachedImages[path] = AssetImage(path);
      _preloadingStatus[path] = false; // Will be properly preloaded when context is available
      debugPrint(' Cached critical image provider: $path');
    }
  }
}

/// Navigation service to access navigator context
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
