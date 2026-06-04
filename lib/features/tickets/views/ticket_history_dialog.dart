import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/ticket.dart';
import '../../../data/repositories/ticket_repository.dart';

class TicketHistoryDialog extends StatefulWidget {
  const TicketHistoryDialog({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<TicketHistoryDialog> createState() => _TicketHistoryDialogState();
}

class _TicketHistoryDialogState extends State<TicketHistoryDialog> {
  bool _loading = true;
  List<TicketHistoryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<TicketRepository>();
    final history = await repo.getHistory(widget.ticketId);
    if (mounted) {
      setState(() {
        _entries = history;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.history, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Storico #${widget.ticketId}'),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : _entries.isEmpty
                ? const Text('Nessuno storico disponibile')
                : SingleChildScrollView(
                    child: Column(
                      children: _entries.map(_HistoryTile.new).toList(),
                    ),
                  ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.entry);

  final TicketHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final inProgress = entry.stato.contains('LAVORAZIONE');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: inProgress ? AppColors.primary : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.stato,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (entry.note.isNotEmpty)
                  Text(
                    entry.note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                Text(
                  formatDateTime(entry.dallaData),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
