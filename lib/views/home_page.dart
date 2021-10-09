import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../driver.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _db = FirebaseFirestore.instance;

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        centerTitle: true,
        title: const Text("HomePage"),
          titleTextStyle: const TextStyle(color: Colors.black54, fontSize: 40),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.black,
            ),
              onPressed: (){},
              child: const Icon(Icons.add),
          )
        ]
      ),
      body: Container(),
      backgroundColor: Colors.pink[100],
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.pink[300], // background
          onPrimary: Colors.black, // foreground
        ),
        onPressed: () {
          _signOut(context);
        },
        child: const Icon(Icons.logout),
      ),
    );
  }

  void _signOut(BuildContext context) async {
    return showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.pink[50],
            title: const Text("Log Out"),
            content: const Text("Are you sure you want to log out?", textAlign: TextAlign.center,),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                      const SnackBar(content: Text('User logged out.')));
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (con) => AppDriver()));
                  ScaffoldMessenger.of(context).clearSnackBars();
                },
                child: const Text("YES"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink[300], // background
                  onPrimary: Colors.black, // foreground
                ),
              ),
            ],
          );
        });
  }
}