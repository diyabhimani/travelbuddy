import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:travelbuddy2/utils/app_colors.dart';

class GroupChatScreen extends StatefulWidget {
  final String tripId;
  final String tripName;

  const GroupChatScreen({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  // 💬 SEND MESSAGE
  Future<void> sendMessage() async {
    String text = messageController.text.trim();

    if (text.isEmpty) return;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('messages').add({
      'tripId': widget.tripId,
      'text': text,
      'senderId': user!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // 💬 CHAT LIST
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .where('tripId', isEqualTo: widget.tripId)
                .snapshots(),

            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No messages yet 💬"));
              }

              final messages = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];

                  final isMe = msg['senderId'] == user?.uid;

                  return Align(
                    alignment:
                    isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? kDarkBrown : kGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text'] ?? '',
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

        // ✏️ INPUT BOX
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          color: kWhite,
          child: Row(
            children: [

              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
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
    );
  }
}