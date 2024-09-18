import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';

class OnlineGamePage extends StatefulWidget {
  final String approvedId;
  const OnlineGamePage(
      {super.key, required this.approvedId});

  @override
  State<OnlineGamePage> createState() =>
      _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> {
  String status = "Your turn";
  String? player = FirebaseAuth.instance.currentUser?.uid;
  int computer = 2;

  int winning = 0;
  Timer? timer;
  int computerWinning = 0;
  int coin = 0;

  String getOpponent(Map<String, dynamic> data) {
    return data["Play1"] == player
        ? data["Play2"]
        : data["Play1"];
  }

  int getWinningCount(
      Map<String, dynamic> data, String pl) {
    return pl == data["Play1"]
        ? data["Play1Winning"]
        : data["Play2Winning"];
  }

  play(List board, String whoIsPlaying,
      Map<String, dynamic> data) async {
    bool amWon = isWinner(player, board);

    if (amWon) {
      if (getWinningCount(data, player!) >= 4) {
        int winningCount =
            getWinningCount(data, player!) + 1;
        await FirebaseFirestore.instance
            .collection("game")
            .doc(widget.approvedId)
            .update({
          "board": List.filled(9, 0),
          "whoIsPlaying": whoIsPlaying,
          getPlayer(data["Play1"])
              ? "Play1Winning"
              : "Play2Winning": winningCount,
          "status": "Game over"
        });
      } else {
        int winningCount =
            getWinningCount(data, player!) + 1;
        await FirebaseFirestore.instance
            .collection("game")
            .doc(widget.approvedId)
            .update({
          "board": List.filled(9, 0),
          "whoIsPlaying": whoIsPlaying,
          getPlayer(data["Play1"])
              ? "Play1Winning"
              : "Play2Winning": winningCount,
          "status": "Game over"
        });
      }
    } else if (board.every((element) => element != 0) &&
        data["time"] > 2) {
      await FirebaseFirestore.instance
          .collection("game")
          .doc(widget.approvedId)
          .update({
        "board": List.filled(9, 0),
        "whoIsPlaying": whoIsPlaying,
      });
    } else {
      print(widget.approvedId);
      await FirebaseFirestore.instance
          .collection("game")
          .doc(widget.approvedId)
          .update({
        "board": board,
        "whoIsPlaying": whoIsPlaying
      });
    }
  }

  bool getPlayer(
    String check,
  ) {
    return check == player;
  }

  bool isWinner(who, List board) {
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
    // startTiming();
    player = FirebaseAuth.instance.currentUser?.uid;
    print(widget.approvedId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("game")
            .doc(widget.approvedId)
            .snapshots(),
        builder: (context, snapshot) {
          var data = snapshot.data?.data();
          String opponent = getOpponent(data!);

          List boards = data!["board"];
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Row(
                children: [
                  Text(data["time"].toString()),
                  SizedBox(
                    width: 10,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text:
                          "M ${getPlayer(data["Play1"]) ? data["Play1Winning"] : data["Play2Winning"]}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16),
                    ),
                    TextSpan(
                        text: " /",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black)),
                    TextSpan(
                        text:
                            "O ${opponent == data["Play2"] ? data["Play2Winning"] : data["Play1Winning"]}",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16))
                  ]))
                ],
              ),
              actions: [
                Image(
                  image:
                      AssetImage("asset/images/coin.png"),
                  height: 50,
                  width: 70,
                ),
                Text(
                  "$coin",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                IconButton(
                    onPressed: () async {
                      setState(() {
                        status = "Play";

                        winning = 0;
                        computerWinning = 0;
                      });
                      await FirebaseFirestore.instance
                          .collection("game")
                          .doc(widget.approvedId)
                          .update({
                        "board": List.filled(9, 0),
                        "whoIsPlaying": opponent
                      });
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
                      for (int i = 0;
                          i < boards.length;
                          i++)
                        GestureDetector(
                          onTap: () async {
                            print(boards);
                            if (data["whoIsPlaying"] !=
                                player) {
                              setState(() {
                                status =
                                    "It is your opponent turn";
                              });
                            } else if (boards[i] != 0) {
                              setState(() {
                                boards[i] == player
                                    ? status =
                                        "You have already played here"
                                    : status =
                                        "Opponent has played here already";
                              });
                            } else {
                              setState(() {
                                boards[i] = player;
                                status = "Opp Turn";
                              });
                              print(
                                  "After Played : $boards");
                              await play(
                                  boards, opponent, data);
                              setState(() {
                                status = "Your Turn";
                              });
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.all(8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: boards[i] == player
                                    ? Colors.green
                                    : boards[i] == opponent
                                        ? Colors.red
                                        : Colors.amber),
                            child: Text(
                              boards[i] == player
                                  ? "X"
                                  : boards[i] == opponent
                                      ? "O"
                                      : "",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight:
                                      FontWeight.bold),
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          );
        });
  }
}
