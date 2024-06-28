import 'package:chess/components/piece.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget{
  final bool isWhite;
  final ChessPiece? piece;

  const Square({super.key, required this.isWhite, this.piece});
  @override
  Widget build(BuildContext context){
    return Container(
      color: isWhite ? orange : brown,
      child: piece != null ? Image.asset(piece!.imagePath, color: piece!.isWhite ? Colors.white: Colors.black,) : null,
    );
  }

}