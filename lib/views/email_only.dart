import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mid_term_asmnt/views/home_page.dart';

import '../authentication.dart';
import '../driver.dart';

class emailPage extends StatefulWidget {
  const emailPage({Key? key}) : super(key: key);
  @override
  _emailState createState() => _emailState();
}

class _emailState extends State<emailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;

  get model => null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

 String _email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 100.0,
          backgroundColor: Colors.pink[300],
          centerTitle: true,
          title: const Text("Email Only Sign In"),
          titleTextStyle: const TextStyle(color: Colors.black54, fontSize: 40),
        ),
        backgroundColor: Colors.pink[100],
        body: Center(
            key: _formKey,
            child: Column(children: [
              const SizedBox(height: 20.0),
              TextFormField(
                autocorrect: false,
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Email'),
              ),

              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Authentication().signInWithEmail(_emailController.text);
                      Navigator.push(
                          context, MaterialPageRoute(builder: (con) => const HomePage()));
                    }
                  },
                  child: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.pink[300],
                      onPrimary: Colors.black
                  ),
                ),
              ),
            ])));
  }

  Future<void> login() async {
    await Firebase.initializeApp();
    try {
      UserCredential _ = await _auth.signInWithEmailAndPassword(
          email: _email, password: '');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (con) => AppDriver()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found for that email.')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Wrong password provided for that user.')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Something Else")));
      }
    } catch (e) {
      print(e);
    }

  }
}