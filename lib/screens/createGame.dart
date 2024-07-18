import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

import '../gameBoard.dart';


class CreateGame extends StatefulWidget {
  @override
  _CreateGameState createState() => _CreateGameState();
}

class _CreateGameState extends State<CreateGame> {
  final serverUrl = "http://192.168.0.104:5249/chessHub";
  HubConnection? hubConnection;
  bool isConnected = false;
  TextEditingController _gameNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startConnection();
  }

  Future<void> _startConnection() async {
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();

    try {
      await hubConnection!.start();
      setState(() {
        isConnected = true;
      });
      print("Connection Started");
    } catch (e) {
      print("Error starting connection: $e");
    }
  }

  Future<void> _createGame() async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not connected to the server')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String gameName = _gameNameController.text;
      await hubConnection!.invoke("CreateGame", args: <Object>[gameName]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game "$gameName" created successfully')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GameBoard(hubConnection: hubConnection!,
          gameId: gameName,
          isWhitePlayer: true,)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating game: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    hubConnection?.stop();
    _gameNameController.dispose();
    super.dispose();
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
          backgroundColor: Colors.white,
          title: Text("Enter game name"),
          content: TextField(
            controller: _gameNameController,
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
