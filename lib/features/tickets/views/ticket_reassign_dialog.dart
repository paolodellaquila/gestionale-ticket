import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/ticket.dart';
import '../../../shared/widgets/ticket_type_chip.dart';

class TicketReassignDialog extends StatefulWidget {
  const TicketReassignDialog({super.key, required this.ticket});

  final Ticket ticket;

  @override
  State<TicketReassignDialog> createState() => _TicketReassignDialogState();
}

class _TicketReassignDialogState extends State<TicketReassignDialog> {
  String _azione = 'riassegna';
  String _reparto = 'SERVICE';

  static const _reparti = ['SERVICE', 'PRODUZIONE', 'COMPLIANCE'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chiudi / Riassegna'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#${widget.ticket.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                TicketTypeChip(ticket: widget.ticket, compact: true),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.ticket.cliente,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              widget.ticket.descrizione,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'riassegna', label: Text('Riassegna')),
                ButtonSegment(value: 'chiudi', label: Text('Chiudi')),
              ],
              selected: {_azione},
              onSelectionChanged: (s) => setState(() => _azione = s.first),
            ),
            if (_azione == 'riassegna') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _reparto,
                decoration: const InputDecoration(labelText: 'Unità aziendale'),
                items: _reparti
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _reparto = v);
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _azione == 'chiudi'
                      ? 'Ticket #${widget.ticket.id} chiuso (demo)'
                      : 'Ticket #${widget.ticket.id} riassegnato a $_reparto (demo)',
                ),
              ),
            );
          },
          child: const Text('Conferma'),
        ),
      ],
    );
  }
}
