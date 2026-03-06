import 'package:flutter/material.dart';

class OverlappingAvatars extends StatelessWidget {
  final List<String> images;

  const OverlappingAvatars({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    const double size = 18;
    const double overlap = 6;

    if (images.isEmpty) return const SizedBox();

    final totalWidth = size + (images.length - 1) * (size - overlap);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: List.generate(images.length, (index) {
          return Positioned(
            left: index * (size - overlap),
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: ClipOval(child: Image.network(images[index], fit: BoxFit.cover)),
            ),
          );
        }),
      ),
    );
  }
}
