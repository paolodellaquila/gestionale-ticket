import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_format.dart';
import '../../data/models/ticket.dart';
import 'ticket_type_chip.dart';

typedef TicketCardCallback = void Function(Ticket ticket, String action);

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    this.onAction,
    this.highlightDeadline = false,
  });

  final Ticket ticket;
  final TicketCardCallback? onAction;
  final bool highlightDeadline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/tickets/${ticket.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${ticket.id}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket.cliente,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TicketTypeChip(ticket: ticket),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ticket.descrizione,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _MetaChip(icon: Icons.precision_manufacturing_outlined, label: ticket.impianto),
                  _MetaChip(icon: Icons.person_outline, label: ticket.responsabile),
                  if (ticket.unitaAziendale != null)
                    _MetaChip(icon: Icons.business_outlined, label: ticket.unitaAziendale!),
                ],
              ),
              if (highlightDeadline && ticket.dataScadenza != null) ...[
                const SizedBox(height: AppSpacing.sm),
                DeadlineBadge(ticket: ticket),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Ultima attività: ${formatDateTime(ticket.ultimaAttivita)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'Dettaglio',
                    onPressed: () => context.go('/tickets/${ticket.id}'),
                  ),
                  _ActionButton(
                    icon: Icons.history,
                    label: 'Storico',
                    onPressed: () => onAction?.call(ticket, 'storico'),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (v) => onAction?.call(ticket, v),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'attivita',
                        child: ListTile(
                          leading: Icon(Icons.play_circle_outline, size: 20),
                          title: Text('Attività'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'chiudi',
                        child: ListTile(
                          leading: Icon(Icons.swap_horiz, size: 20),
                          title: Text('Chiudi / Riassegna'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}

class TicketCardGrid extends StatelessWidget {
  const TicketCardGrid({
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
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 800
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 1 ? 2.15 : 1.72,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: tickets.length,
          itemBuilder: (_, i) => TicketCard(
            ticket: tickets[i],
            onAction: onAction,
            highlightDeadline: highlightDeadline,
          ),
        );
      },
    );
  }
}

class EmptyQueueState extends StatelessWidget {
  const EmptyQueueState({super.key, this.message = 'Nessun ticket in questa coda'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
