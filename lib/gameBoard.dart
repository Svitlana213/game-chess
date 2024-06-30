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

  ChessPiece? selectedPiece;

  // nothing is selected
  int selectedRow = -1;
  int selectedCol = -1;

  // check if the move is valid. each move is a list of rows and cols
  List<List<int>> validMoves = [];



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
    newBoard[7][4] = ChessPiece(
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
    newBoard[7][3] = ChessPiece(
        type: PieceType.king,
        isWhite: true,
        imagePath: "assets/images/king.png"
    );
    board = newBoard;
  }

  void selected(int row, int col){
    setState(() {
      //no piece selected, first selection
      if(selectedPiece == null && board[row][col] != null){
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
      // change selected piece
      else if (board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite){
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }
      //selected piece and square is a valid move, move
      else if(selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col)){
        movePiece(row, col);
      }

      // if piece is selected calc its valid move
      validMoves = calculatePossibleValidMoves(selectedRow, selectedCol, selectedPiece);
    });
  }

  // calc possible valid moves
  List<List<int>> calculatePossibleValidMoves(int row, int col, ChessPiece? piece){
    List<List<int>> possibleMoves = [];

    if(piece == null){
      return [];
    }

    int direction = piece!.isWhite ? -1 : 1;

    switch(piece.type){
      case PieceType.pawn:
        // move forward 1 square
        if(isInBoard(row + direction, col) && board[row + direction][col] == null){
          possibleMoves.add([row + direction, col]);
        }

        // move forward 2 sq if its first move
        if((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)){
          if(isInBoard(row + 2 * direction, col)
              && board[row + 2 * direction][col] == null
              && board[row + direction][col] == null
          ){
            possibleMoves.add([row + 2 * direction, col]);
          }
        }

        // capture diagonally
        if(isInBoard(row + direction, col - 1)
            && board[row + direction][col - 1] != null
            && board[row + direction][col - 1]!.isWhite
        ){
          possibleMoves.add([row + direction, col - 1]);
        }
        if(isInBoard(row + direction, col + 1)
            && board[row + direction][col + 1] != null
            && board[row + direction][col + 1]!.isWhite
        ){
          possibleMoves.add([row + direction, col + 1]);
        }
      break;


      case PieceType.rook:
        // horizontal and vertical moves
        var rookMoves = [
          [-1, 0], //up
          [1,0], // down
          [0, -1], // left
          [0, 1], //right
        ];

        for (var move in rookMoves){
          var i = 1;
          while(true){
            var newRow = row + i * move[0];
            var newCol = col + i * move[1];

            if(!isInBoard(newRow, newCol)){
              break;
            }

            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                possibleMoves.add([newRow, newCol]);
              }
              break;
            }
            possibleMoves.add([newRow, newCol]);
            i++;
          }
        }
      break;


      case PieceType.bishop:
        var bishopMoves = [
          [-1,-1], // up left
          [-1,1], //upright
          [1,-1], //down left
          [1,1], //down right
        ];
        for ( var move in bishopMoves){
          var i = 1;
          while(true){
            var newRow = row + i * move[0];
            var newCol = col + i * move[1];

            if(!isInBoard(newRow, newCol)){
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                possibleMoves.add([newRow,newCol]);
              }
              break;
            }
            possibleMoves.add([newRow, newCol]);
            i++;
          }
        }
      break;


      case PieceType.king:
        var kingMoves = [
          [-1,0], //up
          [1,0],//down
          [0,-1],//l
          [0,1], //r
          [-1,-1], //up l
          [-1,1],//upr
          [1,-1],//d l
          [1,1],//dr
        ];
        for(var move in kingMoves){
            var newRow = row + move[0];
            var newCol = col + move[1];

            if(!isInBoard(newRow, newCol)){
              continue;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                possibleMoves.add([newRow,newCol]);
              }
              continue;
            }
            possibleMoves.add([newRow,newCol]);
        }
      break;


      case PieceType.knight:
        var knightMoves = [
          [-2,-1], // up 2 left 1
          [-2, 1], // up2 right1
          [-1,-2], //up1 left2
          [-1,2], //up1 right2
          [1,-2], //down1 left2
          [1,2], //down1 right2
          [2,-1], //down 2 left 1
          [2,1], //down 2 right1
        ];

        for(var move in knightMoves){
          var newRow = row + move[0];
          var newCol = col + move[1];

          if(!isInBoard(newRow, newCol)){
            continue;
          }

          if(board[newRow][newCol] != null){
            if(board[newRow][newCol]!.isWhite != piece.isWhite){
              possibleMoves.add([newRow,newCol]);
            }
            continue;
          }
          possibleMoves.add([newRow,newCol]);
        }
      break;


      case PieceType.queen:
        var queenMoves = [
          [-1,0], //up
          [1,0],//down
          [0,-1],//l
          [0,1], //r
          [-1,-1], //up l
          [-1,1],//upr
          [1,-1],//d l
          [1,1],//dr
        ];

        for(var move in queenMoves){
          var i = 1;
          while(true){
            var newRow = row + i * move[0];
            var newCol = col + i * move[1];

            if(!isInBoard(newRow, newCol)){
              break;
            }
            if(board[newRow][newCol] != null){
              if(board[newRow][newCol]!.isWhite != piece.isWhite){
                possibleMoves.add([newRow,newCol]);
              }
              break;
            }
            possibleMoves.add([newRow,newCol]);
            i++;
          }
        }
      break;

    }
      return possibleMoves;
  }


  //move piece
  void movePiece(int newRow, int newCol){
    //move and clear prev spot
     board[newRow][newCol] = selectedPiece;
     board[selectedRow][selectedCol] = null;
    //clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });
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

          // check if sq is selected
          bool isSelected = selectedRow == row && selectedCol == col;

          //check if valid move
          bool isValidMove = false;
          for(var position in validMoves){
            if(position[0] == row && position[1] == col){
              isValidMove = true;
            }
          }

          return Square(
              isWhite: isWhite(index),
            piece: board[row][col],
            isSelected: isSelected,
            isValidMove: isValidMove,
            onTap: () => selected(row, col),
          );
        }

      ),

    );
  }
}