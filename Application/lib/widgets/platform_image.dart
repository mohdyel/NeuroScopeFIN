import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';

class PlatformImage extends StatelessWidget {
  final String imagePath;
  final Uint8List? webImageData;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PlatformImage({
    Key? key,
    required this.imagePath,
    this.webImageData,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb && webImageData != null) {
      return Image.memory(
        webImageData!,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
    );
  }
}
