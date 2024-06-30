import 'package:flutter/material.dart';

class TakenPieces extends StatelessWidget{
  final String imagePath;
  final bool isWhite;

  const TakenPieces ({
    super.key,
    required this.imagePath,
    required this.isWhite
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      color: isWhite ? Colors.grey[400] : Colors.grey[800],
    );
  }
}