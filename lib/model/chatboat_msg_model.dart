class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isTyping = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toApiFormat() => {
    'role': isUser ? 'user' : 'assistant',
    'content': text,
  };
}