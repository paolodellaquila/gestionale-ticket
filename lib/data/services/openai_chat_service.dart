import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/openai_config.dart';
import '../../features/chat/models/chat_message.dart';

class OpenAiChatService {
  OpenAiChatService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  Future<String> complete({
    required String systemPrompt,
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    if (!OpenAiConfig.isConfigured) {
      throw OpenAiChatException(
        'OPENAI_API_KEY non configurata nel file .env',
      );
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ...history
          .where((m) => m.role != ChatRole.system)
          .map(
            (m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            },
          ),
      {'role': 'user', 'content': userMessage},
    ];

    final response = await _client.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${OpenAiConfig.apiKey}',
      },
      body: jsonEncode({
        'model': OpenAiConfig.model,
        'messages': messages,
        'temperature': 0.25,
        'max_tokens': 900,
      }),
    );

    if (response.statusCode != 200) {
      throw OpenAiChatException(
        'OpenAI API errore ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw OpenAiChatException('Risposta OpenAI vuota');
    }

    final message = choices.first['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.trim().isEmpty) {
      throw OpenAiChatException('Contenuto risposta mancante');
    }

    return content.trim();
  }

  void dispose() => _client.close();
}

class OpenAiChatException implements Exception {
  OpenAiChatException(this.message);
  final String message;

  @override
  String toString() => message;
}
