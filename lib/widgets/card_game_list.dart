import 'package:flutter/material.dart';
import 'package:tictactoe_app/database/dblocal.dart';
import 'package:tictactoe_app/database/tictactoe_model.dart';
import 'package:tictactoe_app/widgets/card_game.dart';

class ListScreen extends StatefulWidget {
  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late DatabaseHandler handler;
  late Future<List<Game>> _game;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    _game = initializeGameList();
  }

  Future<List<Game>> initializeGameList() async {
    await handler.initializeDB();
    return handler.getGames();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _game = initializeGameList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Partidas jugadas'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GamePage()),
          );
        },
        child: Icon(Icons.gamepad),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<Game>>(
        future: _game,
        builder: (BuildContext context, AsyncSnapshot<List<Game>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final games = snapshot.data ?? <Game>[];
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                itemCount: games.length,
                itemBuilder: (BuildContext context, int index) {
                  final game = games[index];
                  return Dismissible(
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: const Icon(Icons.delete_forever),
                    ),
                    key: ValueKey<int>(game.id),
                    onDismissed: (DismissDirection direction) async {
                      await handler.deleteGame(game.id);
                      setState(() {
                        games.removeAt(index);
                      });
                    },
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        title: Text(game.nameGame),
                        subtitle: Text(game.winner),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
