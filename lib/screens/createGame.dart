import 'package:chess/values/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreateGame extends StatefulWidget {
  @override
  _CreateGameState createState() => _CreateGameState();
}

class _CreateGameState extends State<CreateGame> {
  bool _isLoading = false;

  void _createGame() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate waiting for another user to connect
    await Future.delayed(Duration(seconds: 5));

    setState(() {
      _isLoading = false;
    });

    // Show a message or proceed with the game setup
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Other user connected!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Game'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : AlertDialog(
                backgroundColor: bg,
                title: Text("Enter game name"),
                content: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter game name',
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: _createGame,
                    child: Text('Create'),
                  ),
                ],
              ),
      ),
    );
  }
}