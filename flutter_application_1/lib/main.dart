import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_application_1/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  String status = "Your turn";
  int player = 1;
  int computer = 2;
  List<int> board = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  int time = 60;
  int winning = 0;
  Timer? timer;
  int computerWinning = 0;
  int coin = 0;

  startTiming() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (time > 0) {
        setState(() {
          time--;
        });
      } else {
        t.cancel();
        timer?.cancel();

        if (winning != 5) {
          showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.red.withOpacity(0.4),
              builder: (c) {
                return AlertDialog(
                  title: Text(
                    "You Lose",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber),
                        onPressed: () {
                          setState(() {
                            board = List.filled(9, 0);
                            winning = 0;
                            time = 60;
                            computerWinning = 0;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Restart",
                          style: TextStyle(
                              color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        GameHome()));
                          },
                          child: Text(
                            "End Game",
                            style: TextStyle(
                                color: Colors.amber),
                          )),
                    )
                  ],
                );
              });
        } else {
          showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.green.withOpacity(0.4),
              builder: (c) {
                return AlertDialog(
                  title: Text(
                    "You Won",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber),
                        onPressed: () {
                          setState(() {
                            board = List.filled(9, 0);
                            winning = 0;
                            time = 60;
                            computerWinning = 0;
                            coin += 30;
                          });
                          startTiming();
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Play Again",
                          style: TextStyle(
                              color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        GameHome()));
                          },
                          child: Text(
                            "End Game",
                            style: TextStyle(
                                color: Colors.amber),
                          )),
                    )
                  ],
                );
              });
        }
      }
    });
  }

  Future runComputer() async {
    Future.delayed(Duration(milliseconds: 300), () {
      if (board.every((one) => one != 0) && time > 2) {
        setState(() {
          board = List.filled(9, 0);
        });
      }
    });

    if (isWinner(player, board)) {
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          winning++;
          board = List.filled(9, 0);
          coin += 30;
        });
      });
    }

    if (winning == 5) {
      showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.green.withOpacity(0.4),
          builder: (c) {
            return AlertDialog(
              title: Text(
                "You Won",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber),
                    onPressed: () {
                      setState(() {
                        board = List.filled(9, 0);
                        winning = 0;
                        time = 60;
                        computerWinning = 0;
                      });
                      startTiming();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Play Again",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GameHome()));
                      },
                      child: Text(
                        "End Game",
                        style:
                            TextStyle(color: Colors.amber),
                      )),
                )
              ],
            );
          });
    } else {
      print("hello");
      Future.delayed(Duration(milliseconds: 300), () {
        int? blockingMove;
        int? winningMove;
        List<int> availableMove = [];

        for (int i = 0; i < board.length; i++) {
          if (board[i] != 0) {
            continue;
          }
          List<int> demoBoard = List.from(board);
          demoBoard[i] = player;
          if (isWinner(player, demoBoard)) {
            blockingMove = i;
          }

          demoBoard[i] = computer;
          if (isWinner(computer, demoBoard)) {
            winningMove = i;
          }
          availableMove.add(i);
        }

        if (winningMove != null) {
          makeMove(winningMove);
        } else if (blockingMove != null) {
          makeMove(blockingMove);
        } else {
          print("Gift");

          if (availableMove.isNotEmpty) {
            var random = Random();
            var randomIndex =
                random.nextInt(availableMove.length);
            var randomMove = availableMove[randomIndex];

            makeMove(randomMove);
          }
        }
      });
    }
  }

  makeMove(int move) {
    setState(() {
      board[move] = computer;
    });
    if (isWinner(computer, board)) {
      Future.delayed(Duration(milliseconds: 200), () {
        setState(() {
          computerWinning++;
          board = List.filled(9, 0);
        });
      });

      if (computerWinning >= 5) {
        showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.red.withOpacity(0.4),
            builder: (c) {
              return AlertDialog(
                title: Text(
                  "You Lose",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                actions: [
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber),
                      onPressed: () {
                        setState(() {
                          board = List.filled(9, 0);
                          winning = 0;
                          time = 60;
                          computerWinning = 0;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Restart",
                        style:
                            TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const GameHome()));
                        },
                        child: Text(
                          "End Game",
                          style: TextStyle(
                              color: Colors.amber),
                        )),
                  )
                ],
              );
            });
      }
    }

    if (board.every((element) => element != 0) &&
        time > 2) {
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          board = List.filled(9, 0);
        });
      });
    }
  }

  bool isWinner(int who, List<int> board) {
    //012
    //345
    //678
    //036
    //147
    //258
    //048
    //246
    return board[0] == who &&
            board[1] == who &&
            board[2] == who ||
        board[3] == who &&
            board[4] == who &&
            board[5] == who ||
        board[6] == who &&
            board[7] == who &&
            board[8] == who ||
        board[0] == who &&
            board[3] == who &&
            board[6] == who ||
        board[1] == who &&
            board[4] == who &&
            board[7] == who ||
        board[2] == who &&
            board[5] == who &&
            board[8] == who ||
        board[0] == who &&
            board[4] == who &&
            board[8] == who ||
        board[2] == who &&
            board[4] == who &&
            board[6] == who;
  }

  @override
  void initState() {
    startTiming();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Row(
          children: [
            Text(time.toString()),
            SizedBox(
              width: 10,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                text: "P  $winning",
                style: TextStyle(
                    color: Colors.black, fontSize: 16),
              ),
              TextSpan(
                  text: " /",
                  style: TextStyle(
                      fontSize: 16, color: Colors.black)),
              TextSpan(
                  text: "C $computerWinning",
                  style: TextStyle(
                      color: Colors.black, fontSize: 16))
            ]))
          ],
        ),
        actions: [
          Image(
            image: AssetImage("asset/images/coin.png"),
            height: 50,
            width: 70,
          ),
          Text(
            "$coin",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  board = List.filled(9, 0);
                  status = "Play";
                  time:
                  60;
                  winning = 0;
                  computerWinning = 0;
                });
                startTiming();
              },
              icon: Icon(
                Icons.restart_alt_rounded,
                size: 30,
              )),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 400,
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                for (int i = 0; i < board.length; i++)
                  GestureDetector(
                    onTap: () async {
                      if (board[i] != 0) {
                        setState(() {
                          board[i] == player
                              ? status =
                                  "You have already played here"
                              : status =
                                  "Opponent has played here already";
                        });
                      } else {
                        setState(() {
                          board[i] = player;
                          status = "Computer Turn";
                        });
                        await runComputer();
                        setState(() {
                          status = "Your Turn";
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: board[i] == player
                              ? Colors.green
                              : board[i] == computer
                                  ? Colors.red
                                  : Colors.amber),
                      child: Text(
                        board[i] == player
                            ? "X"
                            : board[i] == computer
                                ? "O"
                                : "",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
              ],
            ),
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            status,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
