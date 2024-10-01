
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final  _messageController = TextEditingController();

  void _sendMessage () async {
    final enteredMessage = _messageController.text;
    if (enteredMessage
        .trim()
        .isEmpty) {
      return;
    }
    //send message
    _messageController.clear();
    FocusScope.of(context).unfocus();

    User user = FirebaseAuth.instance.currentUser!; // to get current userid

    // to get current user data
    final userData = await FirebaseFirestore.instance
        .collection('users') //The collection name of the data
        .doc(user.uid) // the document name to save data in
        .get();

    await FirebaseFirestore.instance
        .collection('chat') //The collection name of the data
        .add({ // .add create the document name to save data in automatically
      'createdAt': Timestamp.now(),
      'userId':user.uid,
      'email': userData.data()!['email'],
      'message': enteredMessage,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['userImage'],

    });
  }
  @override
  void dispose() {
     _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
             Expanded(
            child: TextField(
              controller: _messageController,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'send message...'),

            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon:  Icon(Icons.send,color: Theme.of(context).colorScheme.primary,),
          ),
        ],
      ),
    );
  }
}
