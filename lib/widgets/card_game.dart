import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:tictactoe_app/database/tictactoe_model.dart';
import 'package:tictactoe_app/database/dblocal.dart';
import 'package:tictactoe_app/widgets/card_game_list.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const String PLAYER_X = "X";
  static const String PLAYER_O = "O";
  String playerNameX = "Player X";
  String playerNameO = "Player 0";

  late String currentPlayer;
  late bool gameEnd;
  late List<String> occupied;
  late bool isGameStarted;
  late DatabaseHandler dbHandler;
  late bool shouldInsertWinner;
  String winnerPlayer = "";
  int rounds = 0;
  int scorePlayerX = 0;
  int scorePlayerO = 0;
  int roundsWonPlayerX = 0;
  int roundsWonPlayerO = 0;
  String playerWithMostRounds = ""; // Jugador con más rondas ganadas
  int highestScore = 0; // Puntaje más alto del jugador con más rondas ganadas
  @override
  void initState() {
    initializeGame();
    dbHandler = DatabaseHandler();
    super.initState();
  }

  void initializeGame() {
    currentPlayer = playerNameX;
    gameEnd = false;
    occupied = List.filled(9, "");
    isGameStarted = false;
    shouldInsertWinner = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (shouldInsertWinner) {
            insertWinnerToDatabase();
            setState(() {});
            dbHandler.printGames();
            initializeGame();
          }
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _headerText(),
            _gameContainer(),
            _buttonsRow(),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    String message = isGameStarted
        ? " Turno de $currentPlayer"
        : "Presione Play para iniciar";
    if (gameEnd) {
      message = "Presione Reiniciar para volver a jugar";
    }

    return Column(
      children: [
        const Text(
          "TicTacToe",
          style: TextStyle(
            color: Colors.green,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (!isGameStarted)
          ElevatedButton(
            onPressed: () => showPlayerNamesDialog(context),
            child: const Text('Configurar Nombres'),
          ),
        Text(
          message,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _gameContainer() {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.height / 2,
      margin: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: 9,
        itemBuilder: (context, int index) {
          return _box(index);
        },
      ),
    );
  }

  Widget _box(int index) {
    String symbol = occupied[index];
    if (symbol == playerNameX) {
      symbol = PLAYER_X;
    } else if (symbol == playerNameO) {
      symbol = PLAYER_O;
    }

    return InkWell(
      onTap: () {
        if (!isGameStarted || gameEnd || occupied[index].isNotEmpty) {
          return;
        }
        setState(() {
          occupied[index] = currentPlayer;
          changeTurn();
          verifyWinner();
          checkForDraw();
        });
      },
      child: Container(
        color: occupied[index].isEmpty
            ? Colors.black26
            : occupied[index] == playerNameX
                ? Colors.blue
                : Colors.orange,
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            symbol,
            style: const TextStyle(fontSize: 50),
          ),
        ),
      ),
    );
  }

  Widget _buttonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              initializeGame();
              isGameStarted = true;
            });
          },
          child: const Text("Play"),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            setState(() {
              initializeGame();
              isGameStarted = true;
            });
          },
          child: const Text("Reiniciar"),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListScreen()),
            );
          },
          child: const Text("Historial"),
        ),
      ],
    );
  }

  void changeTurn() {
    if (currentPlayer == playerNameX) {
      currentPlayer = playerNameO;
    } else {
      currentPlayer = playerNameX;
    }
  }

  void verifyWinner() {
    List<List<int>> winningList = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var winningPos in winningList) {
      String playerPosition0 = occupied[winningPos[0]];
      String playerPosition1 = occupied[winningPos[1]];
      String playerPosition2 = occupied[winningPos[2]];

      if (playerPosition0.isNotEmpty &&
          playerPosition0 == playerPosition1 &&
          playerPosition0 == playerPosition2) {
        winnerPlayer = playerPosition0;
        showGameOverMessage("$playerPosition0 gana!!!");
        gameEnd = true;
        // Game game = Game(
        //     nameGame: "TicTacToe",
        //     namePlayer1: PLAYER_X,
        //     namePlayer2: PLAYER_O,
        //     winner: playerPosition0,
        //     score: 1,
        //     state: "MUY BIEN");
        shouldInsertWinner = true;
        if (winnerPlayer == playerNameX) {
          roundsWonPlayerX++;
        } else if (winnerPlayer == playerNameO) {
          roundsWonPlayerO++;
        }
        return;
      }
    }
  }

  void insertWinnerToDatabase() {
    if (roundsWonPlayerX > roundsWonPlayerO) {
      highestScore = roundsWonPlayerX; // Actualiza el puntaje más alto
      playerWithMostRounds =
          playerNameX; // Actualiza el jugador con más rondas ganadas
    } else if (roundsWonPlayerO > roundsWonPlayerX) {
      highestScore = roundsWonPlayerO; // Actualiza el puntaje más alto
      playerWithMostRounds =
          playerNameO; // Actualiza el jugador con más rondas ganadas
    }

    if (playerWithMostRounds == playerNameX) {
      scorePlayerX += highestScore * 100; // Incrementa el puntaje del jugador X
      scorePlayerO = 0; // Reinicia el puntaje del jugador O
    } else if (playerWithMostRounds == playerNameO) {
      scorePlayerO += highestScore * 100; // Incrementa el puntaje del jugador O
      scorePlayerX = 0; // Reinicia el puntaje del jugador X
    }

    dbHandler.insertGame(
      nameGame: "tictactoe",
      namePlayer1: playerNameX,
      namePlayer2: playerNameO,
      winner: playerWithMostRounds, // Utiliza el jugador con más rondas ganadas
      score: highestScore *
          100, // Utiliza el puntaje del jugador con más rondas ganadas
      state: "NICE",
    );

    roundsWonPlayerX = 0; // Reinicia las rondas ganadas por el jugador X
    roundsWonPlayerO = 0; // Reinicia las rondas ganadas por el jugador O
  }

  void checkForDraw() {
    if (gameEnd) {
      return;
    }

    bool draw = occupied.every((element) => element.isNotEmpty);

    if (draw) {
      showGameOverMessage("Draw");
      gameEnd = true;
    }
  }

  void showGameOverMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Game Over\n$message",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Future<void> showPlayerNamesDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Evita cerrar la ventana emergente haciendo clic fuera de ella
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingrese los nombres de los jugadores'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    setState(() {
                      playerNameX = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "Nombre Jugador X"),
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      playerNameO = value;
                    });
                  },
                  decoration: InputDecoration(labelText: "Nombre Jugador O"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
