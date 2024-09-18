import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/extention.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/online_game.dart';
import 'package:uuid/uuid.dart';

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseAuth firebasefir = FirebaseAuth.instance;
  //FirebaseFirestore firebaseFirestore= FirebaseFirestore.instance;
  bool isLoading = false;
  Future logIn(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
    }
  }

  Future declineGame(String pendingId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection("pendingGame")
          .doc(pendingId)
          .update({"status": "declined"});
    } on FirebaseException catch (e) {}
  }

  Future<String?> approvedGame(String pendingId) async {
    setState(() {
      isLoading = true;
    });
    try {
      String gameId = Uuid().v4();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection("pendingGame")
          .doc(pendingId)
          .update(
              {"status": "approved", "approved": gameId});

      await FirebaseFirestore.instance
          .collection("game")
          .doc(gameId)
          .set({
        "gameId": gameId,
        "time": 60,
        "Play1": pendingId,
        "Play2": FirebaseAuth.instance.currentUser?.uid,
        "Play1Winning": 0,
        "Play2Winning": 0,
        "Winner": "",
        "status": "Game Over",
        "board": [0, 0, 0, 0, 0, 0, 0, 0, 0],
        "whoIsPlaying": ""
      });
      setState(() {
        isLoading = false;
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  OnlineGamePage(approvedId: gameId)));
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData) {
            return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(snapshot.data?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  var user = snapshot.data?.data();
                  return Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.green,
                        centerTitle: false,
                        leading: Container(),
                        leadingWidth: 1,
                        title: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return LoginDialog();
                                });
                          },
                          child: Card(
                            child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                        8.0),
                                child: user == null
                                    ? Text("Log In")
                                    : Text(
                                        user["username"])),
                          ),
                        ),
                      ),
                      body: isLoading
                          ? Center(
                              child:
                                  CircularProgressIndicator(),
                            )
                          : StreamBuilder(
                              stream: FirebaseFirestore
                                  .instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance
                                      .currentUser?.uid)
                                  .collection("pendingGame")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data!.docs
                                        .isNotEmpty &&
                                    snapshot.data!.docs
                                        .every((e) =>
                                            e["status"] !=
                                            "declined")) {
                                  return Scaffold(
                                    body: Center(
                                      child:
                                          ListView.builder(
                                              itemCount:
                                                  snapshot
                                                      .data
                                                      ?.docs
                                                      .length,
                                              itemBuilder:
                                                  (context,
                                                      index) {
                                                var pending = snapshot
                                                    .data
                                                    ?.docs[
                                                        index]
                                                    .data();
                                                return ListTile(
                                                  leading:
                                                      CircleAvatar(),
                                                  title: Text(
                                                      "${pending?["name"] ?? "User"} request to play with you"),
                                                  trailing:
                                                      SizedBox(
                                                    width:
                                                        100,
                                                    child:
                                                        Row(
                                                      children: [
                                                        IconButton(
                                                          onPressed: () async {
                                                            await declineGame(pending!["gameId"]);

                                                            // Navigator.push(context, MaterialPageRoute(builder: (_)=>OnlineGamePage(approvedId: approvedId)));
                                                          },
                                                          icon: Icon(
                                                            Icons.delete,
                                                            size: 30,
                                                            color: Colors.red,
                                                          ),
                                                          tooltip: "Decline",
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            approvedGame(pending!["gameId"]);
                                                          },
                                                          icon: Icon(
                                                            Icons.check_box,
                                                            size: 30,
                                                            color: Colors.green,
                                                          ),
                                                          tooltip: "Approved",
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                    ),
                                  );
                                }

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceAround,
                                      children: [
                                        Container(
                                          margin: EdgeInsets
                                              .all(8.0),
                                          height: 180,
                                          width: MediaQuery
                                                      .sizeOf(
                                                          context)
                                                  .width /
                                              2.5,
                                          decoration: BoxDecoration(
                                              color: Colors
                                                  .green,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          10)),
                                        ),
                                        Container(
                                          margin: EdgeInsets
                                              .all(8.0),
                                          height: 180,
                                          width: MediaQuery
                                                      .sizeOf(
                                                          context)
                                                  .width /
                                              2.5,
                                          decoration: BoxDecoration(
                                              color: Colors
                                                  .green,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          10)),
                                          child: Center(
                                              child: Text(
                                            "${user?["coin"] ?? "0"}",
                                            style: TextStyle(
                                                fontSize:
                                                    22,
                                                fontWeight:
                                                    FontWeight
                                                        .bold),
                                          )),
                                        ),
                                      ],
                                    ),
                                    Container(
                                        width:
                                            double.infinity,
                                        margin: EdgeInsets
                                            .symmetric(
                                                horizontal:
                                                    20),
                                        child:
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors
                                                            .green,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(
                                                            9))),
                                                onPressed:
                                                    () {
                                                  showDialog(
                                                      context:
                                                          context,
                                                      builder: (context) =>
                                                          SelectUserWidget());
                                                },
                                                child: Text(
                                                  "Play with others",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ))),
                                    Container(
                                        width:
                                            double.infinity,
                                        margin: EdgeInsets
                                            .symmetric(
                                                horizontal:
                                                    20),
                                        child:
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors
                                                            .green,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(
                                                            9))),
                                                onPressed:
                                                    () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (c) => GamePage()));
                                                },
                                                child: Text(
                                                  "Play with computer",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ))),
                                    Container(
                                      width:
                                          double.infinity,
                                      padding: EdgeInsets
                                          .symmetric(
                                              horizontal:
                                                  20,
                                              vertical: 15),
                                      child: Text(
                                        "Best Players",
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child:
                                            StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection(
                                                        "users")
                                                    .snapshots(),
                                                builder:
                                                    (context,
                                                        snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState
                                                          .waiting) {
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  } else if (snapshot
                                                      .hasData) {
                                                    var data = snapshot
                                                        .data!
                                                        .docs;

                                                    return ListView
                                                        .builder(
                                                      itemCount:
                                                          data.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        var users =
                                                            data[index].data();
                                                        return ListTile(
                                                          leading: CircleAvatar(),
                                                          title: Text(users["username"]),
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    return const Center(
                                                      child:
                                                          Text("Check your internet connection"),
                                                    );
                                                  }
                                                }))
                                  ],
                                );
                              }));
                });
          }
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      "You Don't Have \n Internet Connection",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) =>
                                      GamePage()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius:
                                  BorderRadius.circular(
                                      10)),
                          child: Center(
                              child: Text(
                                  "Play with computer")),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return LoginDialog();
                            });
                      },
                      child: Card(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(8.0),
                          child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                  child: Text("Log In"))),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class SelectUserWidget extends StatefulWidget {
  Future createGame() async {}
  const SelectUserWidget({
    super.key,
  });

  @override
  State<SelectUserWidget> createState() =>
      _SelectUserWidgetState();
}

class _SelectUserWidgetState
    extends State<SelectUserWidget> {
  String sellectedUserId = "";

  Future sendRequestGame(
      {required usersDetail,
      required var currentUserDetail}) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(usersDetail["userId"])
        .collection("pendingGame")
        .doc(currentUserDetail["userId"])
        .set({
      "name": currentUserDetail["username"],
      "status": "waiting",
      "gameId": currentUserDetail["userId"]
    });
  }

  Future endRequestGame() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(sellectedUserId)
        .collection("pendingGame")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .delete();
    setState(() {
      sellectedUserId = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 600,
        padding: EdgeInsets.symmetric(
            horizontal: 20, vertical: 20),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter the name of the user",
                  suffixIcon: Icon(Icons.search_rounded)),
            ),
            Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasData) {
                        var data = snapshot.data!.docs;

                        return sellectedUserId == ""
                            ? ListView.builder(
                                itemCount: data.length,
                                itemBuilder:
                                    (context, index) {
                                  var users =
                                      data[index].data();
                                  Map<String, dynamic>?
                                      currentUser;
                                  try {
                                    currentUser = data
                                        .where((users) =>
                                            users.data()[
                                                "userId"] ==
                                            FirebaseAuth
                                                .instance
                                                .currentUser
                                                ?.uid)
                                        .first
                                        .data();
                                  } catch (e) {
                                    print(e);
                                  }

                                  return Container(
                                    child: ListTile(
                                      onTap: () async {
                                        if (currentUser ==
                                            null) {
                                          ScaffoldMessenger
                                                  .of(
                                                      context)
                                              .showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text("Kindly log in")));
                                        } else if (currentUser[
                                                'userId'] ==
                                            users[
                                                "userId"]) {
                                          ScaffoldMessenger
                                                  .of(
                                                      context)
                                              .showSnackBar(
                                                  const SnackBar(
                                                      content:
                                                          Text('You cant play with yourself')));
                                        } else {
                                          print(
                                              "its working");
                                          await sendRequestGame(
                                              usersDetail:
                                                  users,
                                              currentUserDetail:
                                                  currentUser);
                                          setState(() {
                                            sellectedUserId =
                                                users[
                                                    "userId"];
                                          });
                                        }
                                      },
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.amber,
                                      ),
                                      title: Text(users[
                                          "username"]),
                                    ),
                                  );
                                })
                            : StreamBuilder(
                                stream: FirebaseFirestore
                                    .instance
                                    .collection("users")
                                    .doc(sellectedUserId)
                                    .collection(
                                        "pendingGame")
                                    .doc(FirebaseAuth
                                        .instance
                                        .currentUser
                                        ?.uid)
                                    .snapshots(),
                                builder:
                                    (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var data = snapshot.data
                                        ?.data();

                                    Map<String, dynamic>?
                                        pendingGame = data;

                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .center,
                                        children: [
                                          data!["status"] ==
                                                  "waiting"
                                              ? CircularProgressIndicator()
                                              : Container(),
                                          Text(data["status"] ==
                                                  "approved"
                                              ? "Your Game is Approved"
                                              : "Waiting for user to accept your request"),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (data[
                                                      "status"] ==
                                                  "approved") {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => OnlineGamePage(
                                                              approvedId: data["approvedId"],
                                                            )));
                                              } else {
                                                endRequestGame();
                                                setState(
                                                    () {
                                                  sellectedUserId =
                                                      "";
                                                });
                                              }
                                            },
                                            child: Text(data[
                                                        "status"] ==
                                                    "approved"
                                                ? "Play"
                                                : "Select another user"),
                                          )
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Center(
                                      child: Text(
                                          "Check your network connection"),
                                    );
                                  }
                                });
                      } else {
                        return Center(
                          child: Text(
                              "Check your network connection"),
                        );
                      }
                    })),
          ],
        ),
      ),
    );
  }
}

class LoginDialog extends StatefulWidget {
  const LoginDialog({
    super.key,
  });

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  TextEditingController emailController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();
  bool isObscure = true;
  bool forgotPassword = false;
  bool forgottenPassword = true;
  bool isLogin = true;
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore =
      FirebaseFirestore.instance;

  Future logIn(String email, String password) async {
    try {
      setState(() {
        isLoading = true;
      });
      var cred =
          await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password);
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Login Successful"),
        backgroundColor: Colors.green,
      ));
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.red,
      ));
      print(e.message);
    }
  }

////////////////////////////////////////////////////////////////////
  Future register(String email, String password) async {
    try {
      setState(() {
        isLoading = true;
      });
      var cred =
          await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password);

      var userData = {
        "userId": cred.user?.uid,
        "email": email.trim(),
        "coin": 10,
        "username": email.toUserName()
      };
      firebaseFirestore
          .collection("users")
          .doc(cred.user?.uid)
          .set(userData);

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Register Successful"),
        backgroundColor: Colors.green,
      ));
      setState(() {
        isLogin = true;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message.toString()),
        backgroundColor: Colors.red,
      ));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
          height: 320,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            emailController.clear();
                            passwordController.clear();
                            setState(() {
                              isLogin = true;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20),
                            height: 30,
                            margin:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8),
                            decoration: BoxDecoration(
                                color: isLogin
                                    ? Colors.green
                                    : Colors.white60,
                                borderRadius:
                                    BorderRadius.circular(
                                        10)),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                color: isLogin
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            emailController.clear();
                            passwordController.clear();
                            setState(() {
                              isLogin = false;
                            });
                          },
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20),
                              height: 30,
                              margin: const EdgeInsets
                                  .symmetric(
                                  horizontal: 8,
                                  vertical: 8),
                              decoration: BoxDecoration(
                                  color: isLogin
                                      ? Colors.white60
                                      : Colors.green,
                                  borderRadius:
                                      BorderRadius.circular(
                                          10)),
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isLogin
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              )),
                        ),
                      ],
                    ),
                    //Register

                    forgotPassword
                        ? Container(
                            height: 250,
                            margin: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10),
                            decoration: BoxDecoration(),
                            child: Column(
                              children: [
                                TextField(
                                  controller:
                                      emailController,
                                  decoration: InputDecoration(
                                      hintText:
                                          "Enter your email",
                                      border:
                                          OutlineInputBorder()),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                GestureDetector(
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    12)),
                                    child: GestureDetector(
                                        child: Center(
                                          child:
                                              StreamBuilder(
                                                  stream:
                                                      null,
                                                  builder:
                                                      (context,
                                                          snapshot) {
                                                    return Center(
                                                        child:
                                                            Text(
                                                      "forgotten password",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16),
                                                    ));
                                                  }),
                                        ),
                                        onTap: () {
                                          //forgottenPassword=true?
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          GameHome()));
                                        }),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          )
                        : isLogin
                            ? Container(
                                height: 250,
                                margin:
                                    EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10),
                                decoration: BoxDecoration(),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller:
                                          emailController,
                                      decoration: InputDecoration(
                                          hintText:
                                              "Enter your email",
                                          border:
                                              OutlineInputBorder()),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextField(
                                      controller:
                                          passwordController,
                                      obscureText:
                                          isObscure,
                                      decoration: InputDecoration(
                                          hintText:
                                              "Enter your password",
                                          border:
                                              OutlineInputBorder()),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        logIn(
                                            emailController
                                                .text,
                                            passwordController
                                                .text);
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors
                                                .green,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        12)),
                                        child: Center(
                                            child: Text(
                                          "Login",
                                          style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 16),
                                        )),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Align(
                                      alignment: Alignment
                                          .bottomRight,
                                      child:
                                          GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            forgotPassword =
                                                true;
                                          });
                                        },
                                        child: Text(
                                            'Forgot Password'),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                height: 250,
                                margin:
                                    EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10),
                                decoration: BoxDecoration(),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller:
                                          emailController,
                                      decoration: InputDecoration(
                                          hintText:
                                              "Enter your email",
                                          border:
                                              OutlineInputBorder()),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextField(
                                      controller:
                                          passwordController,
                                      obscureText:
                                          isObscure,
                                      decoration: InputDecoration(
                                          hintText:
                                              "Enter your password",
                                          border:
                                              OutlineInputBorder()),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        register(
                                            emailController
                                                .text
                                                .trim(),
                                            passwordController
                                                .text
                                                .trim());
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: Colors
                                                .green,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        12)),
                                        child: Center(
                                            child: Text(
                                          "Register",
                                          style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 16),
                                        )),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                ),
                              ),
                  ],
                )),
    );
  }
}
