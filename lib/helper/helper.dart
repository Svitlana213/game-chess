bool isWhite (int index){
  int x = index ~/ 8; // for rows
  int y = index  % 8; // for cols
  bool isWhite = (x + y) % 2 == 0;

  return isWhite;
}

bool isInBoard(int row, int col){
  return row >= 0 && row < 8 && col >= 0 && col < 8;
}