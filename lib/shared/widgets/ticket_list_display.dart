import 'package:flutter/material.dart';

import '../../data/models/ticket.dart';
import '../../features/tickets/viewmodels/tickets_list_view_model.dart';
import 'ticket_card.dart';
import 'ticket_table.dart';

/// Mostra i ticket come griglia card o tabella in base al layout hub.
class TicketListDisplay extends StatelessWidget {
  const TicketListDisplay({
    super.key,
    required this.tickets,
    required this.layout,
    this.onAction,
    this.highlightDeadline = false,
  });

  final List<Ticket> tickets;
  final TicketHubLayout layout;
  final TicketCardCallback? onAction;
  final bool highlightDeadline;

  @override
  Widget build(BuildContext context) {
    return switch (layout) {
      TicketHubLayout.cards => TicketCardGrid(
          tickets: tickets,
          onAction: onAction,
          highlightDeadline: highlightDeadline,
        ),
      TicketHubLayout.table => TicketTableView(
          tickets: tickets,
          onAction: onAction,
          highlightDeadline: highlightDeadline,
        ),
    };
  }
}
