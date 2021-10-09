import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../authentication.dart';
import '../driver.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  File? _image;

  late TextEditingController _emailController,
      _reemailController,
      _passwordController,
      _repasswordController,
      _firstnameController,
      _lastnameController,
      _phonenumberController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _reemailController = TextEditingController();
    _passwordController = TextEditingController();
    _repasswordController = TextEditingController();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _phonenumberController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _reemailController.dispose();
    _passwordController.dispose();
    _repasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phonenumberController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        backgroundColor: Colors.pink[100],
        body: Form(
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
              const SizedBox(height: 20.0),
              TextFormField(
                autocorrect: false,
                controller: _reemailController,
                validator: (value) {
                  if (value == null || value != _reemailController.text) {
                    return 'Email addresses do not match';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "re-enter email",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Re-Enter Email'),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                autocorrect: false,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Password'),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                autocorrect: false,
                controller: _repasswordController,
                validator: (value) {
                  if (value == null || value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "re-enter password",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Verify Password'),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                autocorrect: false,
                controller: _firstnameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "firstname",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Firstname'),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                autocorrect: false,
                controller: _lastnameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lastname cannot be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "lastname",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter Lastname'),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                autocorrect: false,
                controller: _phonenumberController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number cannot be empty';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    labelText: "phone number",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    hintText: 'Enter phone number'),
              ),

              ElevatedButton(
                  onPressed: (){
                    getImage(true);
                  },
                  child: const Text("What do you look like?",
                  style: TextStyle(
                    color: Colors.amberAccent
                  ))),
              const SizedBox(height: 30.0),
              OutlinedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')));

                    setState(() {
                      register();
                    });
                  }
                },
                child: const Text('Submit'),
              )
            ])));
  }

  Future getImage(bool gallery) async {
    ImagePicker imagePicker = ImagePicker();
    XFile image;
    // Let user select photo from gallery
    if(gallery) {
      image = (await imagePicker.pickImage(
          source: ImageSource.gallery,imageQuality: 50))!;
    }
    // Otherwise open camera to get new photo
    else{
      image = (await imagePicker.pickImage(
          source: ImageSource.camera,imageQuality: 50))!;
    }
    setState(() {
      _image = File(image.path); // Use if you only need a single picture\

    });
  }

  Future<void> signUp() async {
    try {
      var auth = Authentication().getAuth();
      UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      var now =  DateTime.now();
      var formatter = DateFormat('dd/MM/yyyy');
      String formattedDate = formatter.format(now);

      _db
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "first_name": _firstnameController.text,
        "last_name": _lastnameController.text,
        "phone_number": _phonenumberController.text,
        "role" : 'customer',
        "uid" : userCredential.user!.uid,
        "time" : formattedDate,
      })
          .then((value) => null)
          .onError((error, stackTrace) => null);
      addImage();

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error")));
    } catch (e) {
      print(e);
    }

    setState(() {

    });
  }

  Future<void> addImage() async {
    String id =Authentication().getUserId();

    var storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child(id)
        .putFile(_image!);
    if (snapshot.state == TaskState.success) {
      final String downloadUrl =
      await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(id)
          .update({"url": downloadUrl});
    }
    Navigator.pushReplacement(context,MaterialPageRoute(builder:  (con) => AppDriver()));
  }

  Future<void> register() async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      _db
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "first_name": _firstnameController.text,
        "last_name": _lastnameController.text,
        "phone": _phonenumberController.text,
      })
          .then((value) => null)
          .onError((error, stackTrace) => null);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Something Else")));
    } catch (e) {
      print(e);
    }

    setState(() {});
  }
}