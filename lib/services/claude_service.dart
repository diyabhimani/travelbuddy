import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:travelbuddy2/model/chatboat_msg_model.dart';


class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-20250514';

  static const String _systemPrompt = '''
You are TravelBuddy, an enthusiastic and knowledgeable AI travel assistant for the TravelBuddy app. Your personality is warm, adventurous, and practical.

You help users with:
- Trip planning and itineraries
- Destination recommendations and hidden gems
- Packing lists tailored to destination and season
- Visa, passport, and entry requirements
- Budget travel tips and cost estimates
- Local culture, food, and customs
- Safety tips and travel insurance
- Flight, hotel, and transport advice

Keep responses conversational, helpful, and concise (2-4 short paragraphs max). Use occasional travel emojis to keep it lively. Always stay focused on travel topics. If asked about unrelated topics, gently redirect to travel. Never mention being Claude or Anthropic — you are TravelBuddy.
''';

  Future<String> sendMessage(List<ChatMessage> history) async {
    final apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
    if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
      throw Exception('Please set your ANTHROPIC_API_KEY in the .env file');
    }

    // Build message list — exclude typing indicators
    final messages = history
        .where((m) => !m.isTyping)
        .map((m) => m.toApiFormat())
        .toList();

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'system': _systemPrompt,
        'messages': messages,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['content'] as List;
      return content
          .where((block) => block['type'] == 'text')
          .map((block) => block['text'] as String)
          .join('');
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error']?['message'] ?? 'API error ${response.statusCode}');
    }
  }
}