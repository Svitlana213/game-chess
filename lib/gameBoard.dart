import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';
import 'helper/helper.dart';

class GameBoard extends StatefulWidget{
  const GameBoard({super.key});
  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>{

  late List<List<ChessPiece?>> board;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }
  void _initializeBoard(){
    List<List<ChessPiece?>> newBoard =
      List.generate(8, (index) => List.generate(8, (index) => null));

    // pawns
    for(int i = 0; i < 8; i++){
      newBoard[1][i] = ChessPiece(
          type: PieceType.pawn,
          isWhite: false,
          imagePath: "assets/images/pawn.png"
      );
      newBoard[6][i] = ChessPiece(
          type: PieceType.pawn,
          isWhite: true,
          imagePath: "assets/images/pawn.png"
      );
    }

    // rooks
    newBoard[0][0] = ChessPiece(
        type: PieceType.rook,
        isWhite: false,
        imagePath: "assets/images/rook.png"
    );
    newBoard[0][7] = ChessPiece(
        type: PieceType.rook,
        isWhite: false,
        imagePath: "assets/images/rook.png"
    );
    newBoard[7][0] = ChessPiece(
        type: PieceType.rook,
        isWhite: true,
        imagePath: "assets/images/rook.png"
    );
    newBoard[7][7] = ChessPiece(
        type: PieceType.rook,
        isWhite: true,
        imagePath: "assets/images/rook.png"
    );

    //knignts
    newBoard[0][1] = ChessPiece(
        type: PieceType.knight,
        isWhite: false,
        imagePath: "assets/images/knight.png"
    );
    newBoard[0][6] = ChessPiece(
        type: PieceType.knight,
        isWhite: false,
        imagePath: "assets/images/knight.png"
    );
    newBoard[7][1] = ChessPiece(
        type: PieceType.knight,
        isWhite: true,
        imagePath: "assets/images/knight.png"
    );
    newBoard[7][6] = ChessPiece(
        type: PieceType.knight,
        isWhite: true,
        imagePath: "assets/images/knight.png"
    );

    //bishops
    newBoard[0][2] = ChessPiece(
        type: PieceType.bishop,
        isWhite: false,
        imagePath: "assets/images/bishop.png"
    );
    newBoard[0][5] = ChessPiece(
        type: PieceType.bishop,
        isWhite: false,
        imagePath: "assets/images/bishop.png"
    );
    newBoard[7][2] = ChessPiece(
        type: PieceType.bishop,
        isWhite: true,
        imagePath: "assets/images/bishop.png"
    );
    newBoard[7][5] = ChessPiece(
        type: PieceType.bishop,
        isWhite: true,
        imagePath: "assets/images/bishop.png"
    );

    //queens
    newBoard[0][3] = ChessPiece(
        type: PieceType.queen,
        isWhite: false,
        imagePath: "assets/images/queen.png"
    );
    newBoard[7][3] = ChessPiece(
        type: PieceType.queen,
        isWhite: true,
        imagePath: "assets/images/queen.png"
    );

    // kings
    newBoard[0][4] = ChessPiece(
        type: PieceType.king,
        isWhite: false,
        imagePath: "assets/images/king.png"
    );
    newBoard[7][4] = ChessPiece(
        type: PieceType.king,
        isWhite: true,
        imagePath: "assets/images/king.png"
    );



    board = newBoard;
  }

  @override
  Widget build (BuildContext contex){
    return Scaffold(
      backgroundColor: bg,
      body: GridView.builder(
        itemCount: 8*8,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemBuilder: (context, index){
          int row = index ~/ 8;
          int col = index % 8;

          return Square(
              isWhite: isWhite(index),
            piece: board[row][col],
          );
        }

      ),

    );
  }
}