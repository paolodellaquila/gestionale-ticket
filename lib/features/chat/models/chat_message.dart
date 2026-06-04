enum ChatRole { user, assistant, system }

class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.isError = false,
    this.usedLocalFallback = false,
  });

  final ChatRole role;
  final String content;
  final DateTime timestamp;
  final bool isError;
  final bool usedLocalFallback;

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;
}
