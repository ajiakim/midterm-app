import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../authentication.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({Key? key}) : super(key: key);

  @override
  _SignInPhoneState createState() => _SignInPhoneState();
}
class _SignInPhoneState extends State<PhonePage> {

  //final _formKey = GlobalKey<FormState>();
  final SmsAutoFill _autoFill = SmsAutoFill();
  late TextEditingController
  _phoneController,
      _smsController;

  @override
  void initState(){
    super.initState();
    _phoneController = TextEditingController();
    _smsController = TextEditingController();
  }
  void dipose(){
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  String _phone = '';
  String _sms = '';
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 300.0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pink[300],
        title: Text("Sign in with phone number"),
        titleTextStyle: const TextStyle(color: Colors.black54, fontSize: 40),
      ),
      backgroundColor: Colors.pink[100],
      body: Padding(padding: const EdgeInsets.all(6),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone number (+1 xxx-xxx-xxxx)'),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    child: const Text("Verify Number"),
                    onPressed: () async {
                      Authentication().verifyPhone(_phoneController.text, context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.pink[300],
                      onPrimary: Colors.black
                    ),
                  ),
                ),
                TextFormField(
                  controller: _smsController,
                  decoration: const InputDecoration(labelText: 'Verification code'),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10.0),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      onPressed: () async {
                        Authentication().signInWithPhone(_smsController.text, context);
                      },
                      child: const Text("Sign in"),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.pink[300],
                        onPrimary: Colors.black
                    ),
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}