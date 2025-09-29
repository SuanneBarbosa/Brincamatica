import 'package:flutter/material.dart';

class HoleClipper extends CustomClipper<Path> {
  final Rect? holeRect;

  HoleClipper(this.holeRect);

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    if (holeRect != null) {
      final holePath = Path()
        ..addRRect(RRect.fromRectAndRadius(
            holeRect!.inflate(8), const Radius.circular(12)));
      return Path.combine(PathOperation.difference, path, holePath);
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}