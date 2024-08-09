import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/extention.dart';
import 'package:flutter_application_1/main.dart';

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //FirebaseFirestore firebaseFirestore= FirebaseFirestore.instance;

  Future logIn(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.all(8.0),
                child: Text("Log In"),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                Container(
                  margin: EdgeInsets.all(8.0),
                  height: 180,
                  width: MediaQuery.sizeOf(context).width /
                      2.5,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius:
                          BorderRadius.circular(10)),
                ),
                Container(
                  margin: EdgeInsets.all(8.0),
                  height: 180,
                  width: MediaQuery.sizeOf(context).width /
                      2.5,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius:
                          BorderRadius.circular(10)),
                  child: Center(
                      child: Text(
                    "1000",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ],
            ),
            Container(
                width: double.infinity,
                margin:
                    EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(9))),
                    onPressed: () {
                      showDialog(context: context, builder: (context)=> Dialog(

                        child: Container(height: 600,

                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(children: [
                          SizedBox(height: 10,),
                          TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Enter the name of the user",
                          suffixIcon: Icon(Icons.search_rounded)),),
                          Expanded(child: StreamBuilder(stream: FirebaseFirestore.instance.collection("users").snapshots(), builder: (context, snapshot){
                            if(snapshot.connectionState== ConnectionState.waiting){
                              return Center( child: CircularProgressIndicator(),);
                            }
                            else if(snapshot.hasData){

                                   var  data= snapshot.data!.docs;

                              return ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index){
                                    var users= data[index].data();
                                  
                                  return Container(child: ListTile(leading: CircleAvatar(backgroundColor: Colors.amber,
                                  ),
                                  
                                   title: Text(users["username"]),
                                  ),);
                                });
                            }else{
                              return Center(child: Text("Check your network connection"),);
                            }
                          })),
                 
                          
                        ],),),

                      ));
                    },
                    child: Text(
                      "Play with others",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ))),
            Container(
                width: double.infinity,
                margin:
                    EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(9))),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c)=> GamePage()));
                    },
                    child: Text(
                      "Play with computer",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ))),
                    
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              child: Text(
                "Best Players",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Expanded(child: StreamBuilder(stream: FirebaseFirestore.instance.collection("users").snapshots(), builder: (context, snapshot){
              if(snapshot.connectionState== ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }
              else if(snapshot.hasData){
                var data= snapshot.data!.docs;

                return ListView.builder(itemCount: data.length,
                  itemBuilder: (context, index) {
                    var users= data[index].data();
                    return ListTile(
                    leading: CircleAvatar(),
                    title: Text(users["username"]),
                  );},);
              }
              else{
                return const Center(child: Text("Check your internet connection"),);
              }
            }))
            // Expanded(
            //   child: ListView.builder(
            //       itemCount: 10,
            //       itemBuilder: (context, index) {
            //         return ListTile(
            //           leading: CircleAvatar(
            //             radius: 25,
            //           ),
            //           title: Text(
            //             "Ademola",
            //             style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 18),
            //           ),
            //           trailing: Text(
            //             "1000 Coin",
            //             style: TextStyle(fontSize: 14),
            //           ),
            //         );
            //       }),
            // )
          ],
        ));
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
  bool isLogin = true;
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore= FirebaseFirestore. instance;

  Future logIn(String email, String password) async {
    try {
      setState(() {
        isLoading = true;
      });
     var cred = await firebaseAuth.signInWithEmailAndPassword(
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
       var cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);




          var userData= {
        "email": email.trim(),
        "coin":10,
        "username": email.toUserName()
      };
      firebaseFirestore.collection("users").doc(cred.user?.uid).set(userData);

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

                   forgotPassword?  Container(
                    
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
                                  child: Center(
                                      child: Text(
                                    "forgotten password",
                                    style: TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        fontSize: 16),
                                  )),
                                ),

                                onTap: () {
                                  setState(() {
                                    
                                  });
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ) : isLogin
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
                                  height: 20,
                                ),
                                TextField(
                                  controller:
                                      passwordController,
                                  obscureText: isObscure,
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
                                        color: Colors.green,
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
                                  alignment:
                                      Alignment.bottomRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        forgotPassword= true;
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
                                height: 20,
                              ),
                              TextField(
                                controller:
                                    passwordController,
                                obscureText: isObscure,
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
                                  register(emailController.text.trim(), passwordController.text.trim());
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
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
