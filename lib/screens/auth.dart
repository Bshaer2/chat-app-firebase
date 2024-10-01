import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../widgets/user_image.dart';

final FirebaseAuth _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;

  bool _isUploading = false;

  void _submit() async {
    var valid = _formKey.currentState!.validate();

    if (!valid || (!_isLogin && _selectedImage == null)) {
      return;
    }
    try {
      setState(() {
        _isUploading = true;
      });
      if (_isLogin) {
        final userCredential = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        final userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
          //save data as collection in database of firebase cloud
       await FirebaseFirestore.instance
            .collection('users')//The collection name of the data
            .doc(userCredential.user!.uid)// the document name to save data in
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'password': _enteredPassword,
         'userImage':imageUrl,
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication failed')));
    }

    setState(() {
      _isUploading = false;
    });

    _formKey.currentState!.save();
    log(_enteredEmail);
    log(_enteredPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.only(
                      top: 30, bottom: 20, left: 20, right: 20),
                  padding: const EdgeInsets.all(16),
                  width: 200,
                  child: Image.asset('assets/images/chat.png')),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onPickedImage: (File pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            //Email Field
                            TextFormField(
                              onSaved: (value) {
                                setState(() {
                                  _enteredEmail = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                              ),
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                            ),
                            //Username Field
                            if (!_isLogin)
                              TextFormField(
                              onSaved: (value) {
                                setState(() {
                                  _enteredUsername = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length<4) {
                                  return 'Please enter at least 4 character';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                            ),

                            //password field
                            TextFormField(
                              onSaved: (value) {
                                setState(() {
                                  _enteredPassword = value!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Please enter password at least 6 character long';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              autocorrect: false,
                              obscureText: true,
                            ),
                            const SizedBox(
                              height: 10,
                            ),

                            if (_isUploading) const CircularProgressIndicator(),
                            if (!_isUploading)
                              ElevatedButton(
                                  onPressed: _submit,
                                  style: TextButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer),
                                  child: Text(_isLogin ? 'Login' : 'Signup')),

                            if (!_isUploading)
                              TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLogin = !_isLogin;
                                    });
                                  },
                                  child: Text(_isLogin
                                      ? 'Create an account'
                                      : 'I already have an account')),
                          ],
                        )),
                  ),
                ),
              ),
              //email field
            ],
          ),
        ),
      ),
    );
  }
}
