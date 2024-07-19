import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/screens/startScreen.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'components/takenPieces.dart';
import 'helper/helper.dart';

class GameBoard extends StatefulWidget {
  final HubConnection hubConnection;
  final String gameId;
  final bool isWhitePlayer;

  const GameBoard({super.key, required this.hubConnection, required this.gameId, required this.isWhitePlayer});

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

  //lists of pieces that was taken
  List<ChessPiece> whiteTaken = [];
  List<ChessPiece> blackTaken = [];

  bool isWhiteTurn = true;

  //initial kings positions
  List<int> whiteKing = [7,4];
  List<int> blackKing = [0,4];

  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _setupHubConnection();
  }

  void _setupHubConnection() {
    // Reconnect if disconnected
    widget.hubConnection.onclose((error) async {
      print("Connection closed: $error");
      await _reconnect();
    });

    // Start the connection if it's not already started
    if (widget.hubConnection.state != HubConnectionState.connected) {
      _startConnection();
    }

    widget.hubConnection.on('ReceiveMove', _handleOpponentMove);
  }

  Future<void> _startConnection() async {
    try {
      await widget.hubConnection.start();
      print("Connection started");
    } catch (e) {
      print("Error starting connection: $e");
    }
  }

  Future<void> _reconnect() async {
    while (widget.hubConnection.state != HubConnectionState.connected) {
      try {
        await widget.hubConnection.start();
        print("Reconnected");
      } catch (e) {
        print("Reconnection attempt failed: $e");
        await Future.delayed(Duration(seconds: 5));
      }
    }
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

  void _handleOpponentMove(List<dynamic>? args) {
    if (args != null && args.length == 5) {
      int startRow = args[0] as int;
      int startCol = args[1] as int;
      int endRow = args[2] as int;
      int endCol = args[3] as int;
      String cId = args[4] as String;

      setState(() {
        movePiece(startRow, startCol, endRow, endCol, widget.hubConnection.connectionId == cId);
      });
    }
  }

  void sendMove(int startRow, int startCol, int endRow, int endCol) {
    if (widget.hubConnection.state == HubConnectionState.connected) {
      widget.hubConnection.invoke('SendMove', args: [widget.gameId, startRow, startCol, endRow, endCol,widget.hubConnection.connectionId]).catchError((error) {
        print("SendMove error: $error");
      });
    } else {
      print("Connection is not in the 'Connected' state");
      _reconnect().then((_) {
        sendMove(startRow, startCol, endRow, endCol);
      });
    }
  }

  void selected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == widget.isWhitePlayer && board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
          validMoves = calculateValidMoves(selectedRow, selectedCol, selectedPiece, true);
        }
      } else if (board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
        validMoves = calculateValidMoves(selectedRow, selectedCol, selectedPiece, true);
      } else if (selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col)) {
        sendMove(selectedRow, selectedCol, row, col);
      }
    });
  }

  void movePiece(int startRow, int startCol, int endRow, int endCol, bool isLocalMove) {
    selectedPiece ??= board[startRow][startCol];

    if (board[endRow][endCol] != null) {
      var capturedPiece = board[endRow][endCol];
      if (capturedPiece!.isWhite) {
        whiteTaken.add(capturedPiece);
      } else {
        blackTaken.add(capturedPiece);
      }
    }

    if (selectedPiece!.type == PieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKing = [endRow, endCol];
      } else {
        blackKing = [endRow, endCol];
      }
    }

    board[endRow][endCol] = selectedPiece;
    board[startRow][startCol] = null;

    if (kingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Checkmate"),
          content: Text(
            isWhiteTurn ? "Black won!" : "White won!",
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => StartScreen()),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text("Back to menu"),
            ),
          ],
        ),
      );
    }

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
      isWhiteTurn = !isWhiteTurn;
    });
  }

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
            && board[row + direction][col - 1]!.isWhite != piece.isWhite
        ){
          possibleMoves.add([row + direction, col - 1]);
        }
        if(isInBoard(row + direction, col + 1)
            && board[row + direction][col + 1] != null
            && board[row + direction][col + 1]!.isWhite != piece.isWhite
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

  //calc valid moves
  List<List<int>> calculateValidMoves(int row, int col, ChessPiece? piece, bool possibleCheck){
    List<List<int>> validMoves = [];
    List<List<int>> possibleMoves = calculatePossibleValidMoves(row, col, piece);

    //filter out that would result a check
    if(possibleCheck){
      for(var move in possibleMoves){
        int endRow = move[0];
        int endCol = move[1];

        //check if future move is safe
        if(possibleMoveSafe(piece!, row, col, endRow, endCol)){
          validMoves.add(move);
        }
      }
    } else {
      validMoves = possibleMoves;
    }
    return validMoves;
  }

  bool kingInCheck(bool isWhiteKing) {
    List<int> kingPosition = isWhiteKing ? whiteKing : blackKing;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Пропускаємо порожні клітинки та фігури того ж кольору
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves = calculateValidMoves(i, j, board[i][j], false);
        // Перевіряємо, чи король знаходиться в можливих ходах фігури
        if (pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool isCheckMate(bool isWhiteKing) {
    // Якщо король не під шахом, то не шах і мат
    if (!kingInCheck(isWhiteKing)) {
      return false;
    }

    // Перевіряємо, чи є хоча б один валідний хід для будь-якої фігури гравця
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // Пропускаємо порожні клітинки та фігури іншого кольору
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = calculateValidMoves(i, j, board[i][j], true);
        // Якщо є хоча б один валідний хід, то це не шах і мат
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // Якщо немає валідних ходів, це шах і мат
    return true;
  }

  bool possibleMoveSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol){
    //save the current board state
    ChessPiece? originalDestinationPiece = board [endRow][endCol];

    //if it's the king, save current position and update the new one
    List<int>? originalKingPosition;
    if(piece.type == PieceType.king){
      originalKingPosition = piece.isWhite ? whiteKing : blackKing;

      //update the king position
      if(piece.isWhite){
        whiteKing = [endRow, endCol];
      } else{
        blackKing = [endRow, endCol];
      }
    }

    //simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    //check if our king is under attack
    bool kingCheck = kingInCheck(piece.isWhite);

    //restore board to the original state
    board[startRow][startCol] = piece;
    board [endRow][endCol] = originalDestinationPiece;

    //if king restore its original position
    if(piece.type == PieceType.king){
      if(piece.isWhite){
        whiteKing = originalKingPosition??[];
      }else{
        blackKing = originalKingPosition??[];
      }
    }
    return !kingCheck;
  }

  void resetGame(){
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whiteTaken.clear();
    blackTaken.clear();
    whiteKing = [7,4];
    blackKing = [0,4];
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // white taken
          Expanded(
            child: GridView.builder(
              itemCount: whiteTaken.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) => TakenPieces(
                imagePath: whiteTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.isWhitePlayer ? "You are playing as White" : "You are playing as Black",
              style: TextStyle(
                color: White,
                fontSize: 18,
              ),
            ),
          ),

          Text(
            checkStatus ? "Check" : "",
            style: TextStyle(
              color: White,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          // board
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;

                bool isSelected = selectedRow == row && selectedCol == col;
                bool isValidMove = validMoves.any((position) => position[0] == row && position[1] == col);

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => selected(row, col),
                );
              },
            ),
          ),

          if (isWhiteTurn == widget.isWhitePlayer)
            Text(
              "Your move",
              style: TextStyle(
                color: White,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

          // black taken
          Expanded(
            child: GridView.builder(
              itemCount: blackTaken.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) => TakenPieces(
                imagePath: blackTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}