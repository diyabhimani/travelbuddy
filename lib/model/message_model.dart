class MessageModel {
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime? timestamp;

  MessageModel({
    required this.text,
    required this.senderId,
    required this.receiverId,
    this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data) {
    return MessageModel(
      text: data['text'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      timestamp: data['timestamp']?.toDate(),
    );
  }
}