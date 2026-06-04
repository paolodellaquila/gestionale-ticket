import 'package:flutter/foundation.dart';

import '../../../data/repositories/impianto_repository.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../../../data/services/local_ticket_assistant.dart';
import '../../../data/services/openai_chat_service.dart';
import '../../../data/services/ticket_context_builder.dart';
import '../models/chat_message.dart';

class TicketChatViewModel extends ChangeNotifier {
  TicketChatViewModel({
    required TicketRepository ticketRepository,
    required ImpiantoRepository impiantoRepository,
    OpenAiChatService? openAiService,
  })  : _contextBuilder =
            TicketContextBuilder(ticketRepository, impiantoRepository),
        _openAi = openAiService ?? OpenAiChatService(),
        _localAssistant =
            LocalTicketAssistant(ticketRepository, impiantoRepository);

  final TicketContextBuilder _contextBuilder;
  final OpenAiChatService _openAi;
  final LocalTicketAssistant _localAssistant;

  bool _isOpen = false;
  bool _isLoading = false;
  String? _systemPrompt;
  final List<ChatMessage> _messages = [];

  bool get isOpen => _isOpen;
  bool get isLoading => _isLoading;
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  static const _welcome =
      'Ciao! Sono l\'assistente ticket SIEM. Chiedimi informazioni su code, '
      'scadenze, guasti, interventi o un ID ticket (es. 000664).';

  void toggleOpen() {
    _isOpen = !_isOpen;
    if (_isOpen && _messages.isEmpty) {
      _messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          content: _welcome,
          timestamp: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _messages.add(
      ChatMessage(
        role: ChatRole.user,
        content: trimmed,
        timestamp: DateTime.now(),
      ),
    );
    _isLoading = true;
    notifyListeners();

    try {
      _systemPrompt ??= await _buildSystemPrompt();
      final history = _messages.where((m) => !m.isError).toList();

      String reply;
      var usedFallback = false;

      try {
        reply = await _openAi.complete(
          systemPrompt: _systemPrompt!,
          history: history,
          userMessage: trimmed,
        );
      } catch (_) {
        reply = await _localAssistant.reply(trimmed);
        usedFallback = true;
      }

      _messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          content: reply,
          timestamp: DateTime.now(),
          usedLocalFallback: usedFallback,
        ),
      );
    } catch (e) {
      _messages.add(
        ChatMessage(
          role: ChatRole.assistant,
          content: 'Errore: $e',
          timestamp: DateTime.now(),
          isError: true,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearConversation() {
    _systemPrompt = null;
    _messages.clear();
    _messages.add(
      ChatMessage(
        role: ChatRole.assistant,
        content: _welcome,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  Future<String> _buildSystemPrompt() async {
    final context = await _contextBuilder.build();
    return '''
Sei l'assistente del portale gestione ticket SIEM (energia/impianti fotovoltaici).
Rispondi sempre in italiano, in modo conciso e operativo.
Usa SOLO i dati nel contesto seguente. Se un'informazione non c'è, dillo chiaramente.
Non inventare ticket o clienti. Per ID ticket cita sempre numero, cliente, codice impianto, indirizzo/sede e coda.
Per domande su ubicazione, indirizzo o dove si trova un impianto usa i campi "sede" e l'anagrafica impianti.

CONTESTO TICKET:
$context
''';
  }

  @override
  void dispose() {
    _openAi.dispose();
    super.dispose();
  }
}
