import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

class ConnectGame extends StatefulWidget {
  @override
  _ConnectGameState createState() => _ConnectGameState();
}

class _ConnectGameState extends State<ConnectGame> {
  List<Map<String, String>> games = [];

  void _connectToGame(String gameId) {
    // Implement your logic to connect to the game using the gameId
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to game $gameId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose the game to connect'),
      ),
      body: Container(
        color: bg,
        child: ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                games[index]['name']!,
                style: TextStyle(color: Colors.white),
              ),
              trailing: ElevatedButton(
                onPressed: () => _connectToGame(games[index]['id']!),
                child: Text('Connect'),
              ),
            );
          },
        ),
      ),
    );
  }
}
