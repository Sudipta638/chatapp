import 'dart:io';
import 'package:chat_app/widgets/userimage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _credentails = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _islogin = true;
  var _enteredpassword = "";
  var _enteredemail = "";
  final _formkey = GlobalKey<FormState>();
  var _enteredusername = '';
  File? _selectedimage;
  var _isaunthecating = false;
  void _onsubmit() async {
    final isvalid = _formkey.currentState!.validate();

    if (!isvalid || !_islogin && _selectedimage == null) {
      return;
    }

    _formkey.currentState!.save();
    try {
      setState(() {
        _isaunthecating = true;
      });
      if (_islogin) {
        final _usercredentails = await _credentails.signInWithEmailAndPassword(
            email: _enteredemail, password: _enteredpassword);
      } else {
        final _usercredentails =
            await _credentails.createUserWithEmailAndPassword(
                email: _enteredemail, password: _enteredpassword);

        final storageref = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child('${_usercredentails.user!.uid}.jpg');
        await storageref.putFile(_selectedimage!);
        final imageurl = await storageref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection("users")
            .doc(_usercredentails.user!.uid)
            .set({
          "username": _enteredusername,
          "email": _enteredemail,
          "useriamge": imageurl
        });
      }
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "Wrong user credentials")));
      setState(() {
        _isaunthecating = false;
      });
      // print("jjjj");
      // print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                width: 200,
                child: Image.asset("assests/chat.png"),
              ),
              Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                              key: _formkey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!_islogin)
                                    UserImage(
                                      onpickedimage: (selectediamge) {
                                        _selectedimage = selectediamge;
                                      },
                                    ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "Email adress"),
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                    textCapitalization: TextCapitalization.none,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          !value.contains("@")) {
                                        return "Enter email address correctly ";
                                      }
                                    },
                                    onSaved: (newValue) {
                                      _enteredemail = newValue!;
                                    },
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "password"),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          value.length < 6) {
                                        return "Paasword should be greate than or equality 6 characters ";
                                      }
                                    },
                                    onSaved: (newValue) {
                                      _enteredpassword = newValue!;
                                    },
                                  ),
                                  if(!_islogin)
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: "username"),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          value.length < 4) {
                                        return "Username should be greate than or equality 4 characters ";
                                      }
                                    },
                                    onSaved: (newValue) {
                                      _enteredusername = newValue!;
                                    },
                                  ),
                                  if (_isaunthecating)
                                    const CircularProgressIndicator(),
                                  if (!_isaunthecating)
                                    ElevatedButton(
                                        onPressed: _onsubmit,
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer),
                                        child: Text(
                                            _islogin ? "login" : "signin")),
                                  if (!_isaunthecating)
                                    TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _islogin = !_islogin;
                                          });
                                        },
                                        child: Text(_islogin
                                            ? "Dont have account"
                                            : "I already have an account"))
                                ],
                              )))))
            ]),
          ),
        ),
      ),
    );
  }
}
