import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../Utils/image_preloader.dart';
import '../../Utils/main_variables.dart';

class BackgroundImageWidget extends StatelessWidget {
  final String imagePath;
  final Widget child;
  final BoxFit fit;
  final Color? overlayColor;
  final double? overlayOpacity;

  const BackgroundImageWidget({
    Key? key,
    required this.imagePath,
    required this.child,
    this.fit = BoxFit.cover,
    this.overlayColor,
    this.overlayOpacity = 0.9,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure image is cached immediately
    ImagePreloader.getImage(imagePath);
    
    return Material(
      child: Container(
        // Remove MediaQuery dependency - use full screen without explicit sizing
        decoration: BoxDecoration(
          color: HexColor(mainColor), // Fallback color
          image: DecorationImage(
            image: ImagePreloader.getImage(imagePath),
            fit: fit,
            colorFilter: overlayColor != null
                ? ColorFilter.mode(
                    overlayColor!.withOpacity(overlayOpacity ?? 0.9),
                    BlendMode.darken)
                : ColorFilter.mode(
                    HexColor(mainColor).withOpacity(overlayOpacity ?? 0.9),
                    BlendMode.darken),
          ),
        ),
        child: child,
      ),
    );
  }
}

class CachedImageWidget extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit fit;

  const CachedImageWidget({
    Key? key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image(
      image: ImagePreloader.getImage(imagePath),
      height: height,
      width: width,
      fit: fit,
    );
  }
}
