class Game {
  final int id;
  final String nameGame;
  final String namePlayer1;
  final String namePlayer2;
  final String winner;
  final int score;
  final String state;

  Game({
    this.id = 0,
    required this.nameGame,
    required this.namePlayer1,
    required this.namePlayer2,
    required this.winner,
    required this.score,
    required this.state,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameGame': nameGame,
      'namePlayer1': namePlayer1,
      'namePlayer2': namePlayer2,
      'winner': winner,
      'score': score,
      'state': state
    };
  }

  Game.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        nameGame = res["nameGame"],
        namePlayer1 = res["namePlayer1"],
        namePlayer2 = res["namePlayer2"],
        winner = res["winner"],
        score = res["score"],
        state = res["state"];
}
