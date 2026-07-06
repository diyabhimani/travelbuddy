import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendRequestButton extends StatelessWidget {
  final String currentUserId;
  final String targetUserId;

  const SendRequestButton({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
  });

  Future<void> sendRequest() async {
    await FirebaseFirestore.instance.collection('friend_requests').add({
      "fromUid": currentUserId,
      "toUid": targetUserId,
      "status": "pending",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await sendRequest();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request Sent")),
        );
      },
      child: const Text("Add Friend"),
    );
  }
}