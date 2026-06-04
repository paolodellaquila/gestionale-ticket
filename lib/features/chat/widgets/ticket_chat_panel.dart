import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/openai_config.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../models/chat_message.dart';
import '../viewmodels/ticket_chat_view_model.dart';

class TicketChatPanel extends StatefulWidget {
  const TicketChatPanel({
    super.key,
    required this.width,
    required this.onClose,
  });

  final double width;
  final VoidCallback onClose;

  @override
  State<TicketChatPanel> createState() => _TicketChatPanelState();
}

class _TicketChatPanelState extends State<TicketChatPanel> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketChatViewModel>();
    final isMobile = context.isMobile;

    _scrollToBottom();

    return Material(
      elevation: 12,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: widget.width,
        height: isMobile ? 420 : 520,
        color: AppColors.surfaceCard,
        child: Column(
          children: [
            _ChatHeader(onClose: widget.onClose),
            if (!OpenAiConfig.isConfigured)
              const _ApiKeyBanner()
            else
              const _GptStatusBanner(),
            Expanded(child: _MessageList(controller: _scrollController)),
            if (vm.isLoading) const LinearProgressIndicator(minHeight: 2),
            _InputBar(
              controller: _controller,
              enabled: !vm.isLoading,
              onSend: () {
                vm.sendMessage(_controller.text);
                _controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: AppColors.primary,
      child: Row(
        children: [
          const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistente Ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'GPT + dati ticket SIEM',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 20),
            tooltip: 'Nuova conversazione',
            onPressed: context.read<TicketChatViewModel>().clearConversation,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Chiudi',
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _ApiKeyBanner extends StatelessWidget {
  const _ApiKeyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: AppColors.warningBg,
      child: const Text(
        'OPENAI_API_KEY assente: risposte assistente locale sui dati demo.',
        style: TextStyle(fontSize: 10, color: AppColors.warning),
      ),
    );
  }
}

class _GptStatusBanner extends StatelessWidget {
  const _GptStatusBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Text(
        'Modello: ${OpenAiConfig.model}',
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<TicketChatViewModel>().messages;

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) => _MessageBubble(message: messages[index]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isUser
        ? AppColors.primary
        : message.isError
            ? AppColors.dangerBg
            : AppColors.surface;
    final fg = isUser
        ? Colors.white
        : message.isError
            ? AppColors.danger
            : AppColors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: align,
          children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12).copyWith(
                bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
              ),
              border: isUser ? null : Border.all(color: AppColors.border),
            ),
            child: Text(message.content, style: TextStyle(color: fg, fontSize: 13)),
          ),
          if (message.usedLocalFallback)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                'Risposta locale (GPT non raggiungibile)',
                style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Chiedi sui ticket...',
                isDense: true,
              ),
              onSubmitted: enabled ? (_) => onSend() : null,
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: enabled ? onSend : null,
            child: const Icon(Icons.send, size: 20),
          ),
        ],
      ),
    );
  }
}
