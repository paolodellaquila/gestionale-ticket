import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/ticket.dart';
import '../../data/models/ticket_ui.dart';

class TicketTypeChip extends StatelessWidget {
  const TicketTypeChip({super.key, required this.ticket, this.compact = false});

  final Ticket ticket;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: ticket.typeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ticket.typeIcon, size: compact ? 12 : 14, color: ticket.typeColor),
          const SizedBox(width: 4),
          Text(
            ticket.tipologiaLabel,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: ticket.typeColor,
            ),
          ),
        ],
      ),
    );
  }
}

class DeadlineBadge extends StatelessWidget {
  const DeadlineBadge({super.key, required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    if (ticket.dataScadenza == null) return const SizedBox.shrink();
    final days = ticket.daysUntilDeadline ?? 0;
    final expired = ticket.isExpired;
    final color = expired ? AppColors.danger : AppColors.warning;
    final bg = expired ? AppColors.dangerBg : AppColors.warningBg;
    final label = expired
        ? 'Scaduto ${(-days)}g fa'
        : days == 0
            ? 'Scade oggi'
            : 'Scade tra ${days}g';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            expired ? Icons.event_busy : Icons.schedule,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
