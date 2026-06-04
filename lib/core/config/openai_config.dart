import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAiConfig {
  static String get apiKey {
    final fromFile = dotenv.env['OPENAI_API_KEY']?.trim() ?? '';
    if (fromFile.isNotEmpty) return fromFile;
    return const String.fromEnvironment(
      'OPENAI_API_KEY',
      defaultValue: '',
    );
  }

  static String get model {
    final fromFile = dotenv.env['OPENAI_MODEL']?.trim() ?? '';
    if (fromFile.isNotEmpty) return fromFile;
    return const String.fromEnvironment(
      'OPENAI_MODEL',
      defaultValue: 'gpt-4o-mini',
    );
  }

  static bool get isConfigured => apiKey.isNotEmpty;
}
