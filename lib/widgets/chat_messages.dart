
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final userAuth = FirebaseAuth.instance.currentUser!;
    final Stream<QuerySnapshot<Map<String, dynamic>>> chatMessages =
        FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots();
    return StreamBuilder(
        stream: chatMessages,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('There is no Messages!'),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong...'),
            );
          }
          final loadMessages = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: loadMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadMessages[index].data();
              final nexMessage = index + 1 < loadMessages.length
                  ? loadMessages[index + 1].data()
                  : null;
              final currentUserId = chatMessage['userId'];
              final nextUserId =
                  nexMessage != null ? nexMessage['userId'] : null;

              final bool nextUserIsSame = currentUserId == nextUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: chatMessage['message'],
                  isMe: userAuth.uid == currentUserId,
                );
              } else {
                return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['message'],
                  isMe: userAuth.uid == currentUserId,
                );
              }
            },
          );
        });
  }
}
