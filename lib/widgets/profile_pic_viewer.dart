import 'package:flutter/material.dart';

class ProfilePictureViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ProfilePictureViewer(
      {super.key, required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showImageViewer(context, imageUrl, heroTag);
      },
      child: Hero(
        tag: heroTag,
        child: CircleAvatar(
          radius: 23,
          backgroundImage: NetworkImage(
            imageUrl,
          ),
        ),
      ),
    );
  }
}

class ImageHeroViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const ImageHeroViewer(
      {super.key, required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.5), // Dimmed background
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: GestureDetector(
            onTap: () {},
            child: Center(
              child: Hero(
                transitionOnUserGestures: true,
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Function to show the image viewer with a smooth Hero transition
void showImageViewer(BuildContext context, String imageUrl, String heroTag) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false, // Keeps the background visible
      pageBuilder: (context, animation, secondaryAnimation) {
        return ImageHeroViewer(imageUrl: imageUrl, heroTag: heroTag);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation, // Smooth fade-in transition
          child: child,
        );
      },
    ),
  );
}
