import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_format.dart';
import '../../data/models/ticket.dart';
import 'ticket_card.dart';
import 'ticket_type_chip.dart';

class TicketTableView extends StatelessWidget {
  const TicketTableView({
    super.key,
    required this.tickets,
    this.onAction,
    this.highlightDeadline = false,
  });

  final List<Ticket> tickets;
  final TicketCardCallback? onAction;
  final bool highlightDeadline;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const EmptyQueueState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableMinWidth = constraints.maxWidth < 720 ? 880.0 : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: tableMinWidth),
            child: DataTable(
              headingRowHeight: 44,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 72,
              columnSpacing: 16,
              horizontalMargin: 12,
              headingRowColor: WidgetStateProperty.all(AppColors.surface),
              columns: const [
                DataColumn(label: Text('ID', style: _headerStyle)),
                DataColumn(label: Text('Cliente', style: _headerStyle)),
                DataColumn(label: Text('Impianto', style: _headerStyle)),
                DataColumn(label: Text('Tipologia', style: _headerStyle)),
                DataColumn(label: Text('Descrizione', style: _headerStyle)),
                DataColumn(label: Text('Responsabile', style: _headerStyle)),
                DataColumn(label: Text('Ultima att.', style: _headerStyle)),
                DataColumn(label: Text('Scadenza', style: _headerStyle)),
                DataColumn(label: Text('Azioni', style: _headerStyle)),
              ],
              rows: tickets.map((t) => _buildRow(context, t)).toList(),
            ),
          ),
        );
      },
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  DataRow _buildRow(BuildContext context, Ticket ticket) {
    return DataRow(
      onSelectChanged: (_) => context.go('/tickets/${ticket.id}'),
      cells: [
        DataCell(
          Text(
            '#${ticket.id}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        DataCell(
          Text(
            ticket.cliente,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(Text(ticket.impianto)),
        DataCell(TicketTypeChip(ticket: ticket, compact: true)),
        DataCell(
          Text(
            ticket.descrizione,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(Text(ticket.responsabile)),
        DataCell(Text(formatDateTime(ticket.ultimaAttivita))),
        DataCell(
          highlightDeadline && ticket.dataScadenza != null
              ? DeadlineBadge(ticket: ticket)
              : Text(
                  ticket.dataScadenza != null
                      ? formatDate(ticket.dataScadenza!)
                      : '—',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Dettaglio',
                icon: const Icon(Icons.open_in_new, size: 20),
                onPressed: () => context.go('/tickets/${ticket.id}'),
              ),
              PopupMenuButton<String>(
                tooltip: 'Altre azioni',
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (v) => onAction?.call(ticket, v),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'storico',
                    child: Text('Storico'),
                  ),
                  PopupMenuItem(
                    value: 'chiudi',
                    child: Text('Chiudi / Riassegna'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
