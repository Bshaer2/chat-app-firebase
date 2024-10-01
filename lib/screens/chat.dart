import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_test_last/widgets/chat_messages.dart';
import 'package:firebase_test_last/widgets/new_message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Chat'), actions: [
        IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
            color: Theme.of(context).colorScheme.primary),
      ]),
      body: const Center(
       child: Column(
         children: [
           Expanded(child: ChatMessages()),
           NewMessage(),
         ],
       ),
      ),
    );
  }
}