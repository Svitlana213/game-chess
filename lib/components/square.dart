import 'package:chess/components/piece.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget{
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.onTap
  });

  @override
  Widget build(BuildContext context){
    Color? squareColor;

    if(isSelected){
      squareColor = Colors.green[300];
    } else if(isValidMove){
      squareColor = Colors.green[200];
    }else{
      squareColor = isWhite ? orange : brown;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove ? 2 : 0),
        child: piece != null ? Image.asset(piece!.imagePath, color: piece!.isWhite ? Colors.white: Colors.black,) : null,
      ),
    );
  }

}