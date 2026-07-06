

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelbuddy2/utils/app_colors.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverEmail;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;

  /// 🔥 SEND MESSAGE
  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('messages').add({
      "text": _messageController.text.trim(),
      "senderId": currentUser.uid,
      "receiverId": widget.receiverId,
      "participants": [currentUser.uid, widget.receiverId],
      "timestamp": FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  /// 🔥 MESSAGE STREAM (PRIVATE CHAT)
  Stream<QuerySnapshot> getMessages() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where(
      'participants',
      arrayContains: currentUser.uid,
    )
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: kDarkBrown,
        foregroundColor: kWhite,
      ),

      body: Column(
        children: [

          /// 💬 MESSAGES LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getMessages(),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text("No messages"));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {

                    var msg = messages[index];
                    bool isMe = msg['senderId'] == currentUser.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: isMe
                              ? kDarkBrown
                              : kGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            color: isMe ? kWhite : kBlack,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// ✉️ INPUT FIELD
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.send, color: kDarkBrown),
                  onPressed: sendMessage,
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}