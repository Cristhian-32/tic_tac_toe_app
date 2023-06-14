import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tictactoe_model.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'games.db'),
      onCreate: (database, version) async {
        await database.execute('''CREATE TABLE games (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            nameGame TEXT NOT NULL, 
            namePlayer1 TEXT NOT NULL, 
            namePlayer2 TEXT NOT NULL, 
            winner TEXT NOT NULL, 
            score INTEGER NOT NULL, 
            state TEXT NOT NULL
          )''');
      },
      version: 1,
    );
  }

  Future<void> printGames() async {
    final db = await initializeDB();
    final games = await db.query('games');

    print('Games in database:');
    for (final game in games) {
      print('ID: ${game['id']}');
      print('Name: ${game['nameGame']}');
      print('Winner: ${game['winner']}');
      print('Score: ${game['score']}');
      // Imprime otros campos según la estructura de tu tabla
      print('------------');
    }
  }

  // Future<void> insertGame(Game game) async {
  //   final db = await initializeDB();
  //   await db.insert('games', game.toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace);
  // }

  Future<void> insertGame(
      {nameGame, namePlayer1, namePlayer2, winner, score, state}) async {
    final db = await initializeDB();
    await db.insert('games', {
      'nameGame': nameGame,
      'namePlayer1': namePlayer1,
      'namePlayer2': namePlayer2,
      'winner': winner,
      'score': score,
      'state': state
    });
  }

  Future<List<Game>> getGames() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query('games');
    return queryResult.map((e) => Game.fromMap(e)).toList();
  }

  Future<void> deleteGame(int id) async {
    final db = await initializeDB();
    await db.delete(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void updateScore(int score, int roundsPlayed) {
    score += roundsPlayed * 100;
  }
}
