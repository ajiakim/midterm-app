import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mid_term_asmnt/ui/loading.dart';
import 'package:mid_term_asmnt/views/phone_login.dart';
import 'package:mid_term_asmnt/views/register_page.dart';
import '../authentication.dart';
import '../driver.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController, _passwordController;

  get model => null;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _loading = false;
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    final emailInput = TextFormField(
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
    );
    final passwordInput = TextFormField(
      autocorrect: false,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter Password';
        }
        return null;
      },
      obscureText: true,
      decoration: const InputDecoration(
        labelText: "password",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        hintText: 'Enter Password',
        suffixIcon: Padding(
          padding: EdgeInsets.all(15), // add padding to adjust icon
          child: Icon(Icons.lock),
        ),
      ),
    );
    final submitButton = ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Processing Data')));
          _email = _emailController.text;
          _password = _passwordController.text;

          // _emailController.clear();
          // _passwordController.clear();

          setState(() {
            _loading = true;
            login();
          });
        }
      },
      child: const Text('Submit'),
      style: ElevatedButton.styleFrom(
          primary: Colors.pink[300], // background
          onPrimary: Colors.black),
    );

    final registerButton = ElevatedButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (con) => const RegisterPage()));
      },
      child: const Text('Register'),
      style: ElevatedButton.styleFrom(
        primary: Colors.pink[300], // background
        onPrimary: Colors.black),
    );

    final google = IconButton(
      icon: Image.asset('allTheThings/Gmail-logo.png'),
      iconSize: 60,
      onPressed: (){
        googleSignIn();
      },
    );



    final phoneNum = ElevatedButton(
        onPressed: () {
          Navigator.push(
            context, MaterialPageRoute(builder: (con) => const PhonePage()));
        },
        child: const Text('SMS Login'),
        style: ElevatedButton.styleFrom(
          primary: Colors.pink[300], // background
          onPrimary: Colors.black,
        ),
    );

    final anony = ElevatedButton(
      onPressed: (){Authentication().signInAnon(context);},
      child: const Text("Anonymous"),
      style: ElevatedButton.styleFrom(
        primary: Colors.pink[300], // background
        onPrimary: Colors.black,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _auth.currentUser != null
                ? Text(_auth.currentUser!.uid)
                : _loading
                ? Loading()
                : Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // Add TextFormFields and ElevatedButton here.
                  anony,
                  registerButton,
                  emailInput,
                  const SizedBox(height:15),
                  passwordInput,
                  submitButton,
                  phoneNum,
                  google
                ],
              ),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> login() async {
    await Firebase.initializeApp();
    try {
      UserCredential _ = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      roleCheck();
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

    setState(() {
      _loading = false;
    });
  }

  void roleCheck() async{
    FirebaseFirestore.instance.collection('user').doc(_auth.currentUser!.uid).get().then((value){
        Navigator.pushReplacement(context,MaterialPageRoute(builder:  (con) => AppDriver()));
    });
  }

  void signOut() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if(_auth.currentUser != null) {
      await _auth.signOut();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Logged out")));
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No user logged in")));
    }
    setState(() {

    });
  }

  void  googleSignIn() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    Navigator.pushReplacement(context,MaterialPageRoute(builder:  (con) => AppDriver()));
  }

}