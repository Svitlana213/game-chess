import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import '../gameBoard.dart';

class ConnectGame extends StatefulWidget {
  @override
  _ConnectGameState createState() => _ConnectGameState();
}

class _ConnectGameState extends State<ConnectGame> {
  // The location of the SignalR Server.
  final serverUrl = "http://192.168.0.104:5249/chessHub";
  HubConnection? hubConnection;
  bool isConnected = false;
  List<dynamic> games = [];

  @override
  void initState() {
    super.initState();
    _startConnection();
  }

  Future<void> _startConnection() async {
    // Creates the connection by using the HubConnectionBuilder.
    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();

    try {
      await hubConnection!.start();
      setState(() {
        isConnected = true;
      });
      print("Connection Started");

      var gameList = await _getGameList();
      setState(() {
        games = gameList;
      });
    } catch (e) {
      print("Error starting connection: $e");
    }
  }

  void _connectToGame(String gameId) {
    if (isConnected) {
      // Implement your logic to connect to the game using SignalR.
      hubConnection!.invoke("ConnectGame", args: <Object>[gameId]).then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameBoard(hubConnection: hubConnection!,
            gameId: gameId,
            isWhitePlayer: false,)),
        );
      }).catchError((error) {
        print("Error invoking method: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error connecting to game')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not connected to the server')),
      );
    }
  }

  Future<List<dynamic>> _getGameList() async {
    if (isConnected) {
      try {
        var games = await hubConnection!.invoke("GetGameList");
        return games?.map((game) => game.toString()).toList() ?? [];
      } catch (e) {
        print("Error fetching game list: $e");
        return [];
      }
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose the game to connect'),
      ),
      body: isConnected
          ? Container(
        color: bg,
        child: ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                games[index],
                style: TextStyle(color: White),
              ),
              trailing: ElevatedButton(
                onPressed: () => _connectToGame(games[index]),
                child: Text('Connect'),
              ),
            );
          },
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    hubConnection?.stop();
    super.dispose();
  }
}
