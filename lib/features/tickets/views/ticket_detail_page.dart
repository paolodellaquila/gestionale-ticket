import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format.dart';
import '../../../data/models/ticket.dart';
import '../../../shared/widgets/ticket_type_chip.dart';
import '../viewmodels/ticket_detail_view_model.dart';
import 'ticket_history_dialog.dart';

class TicketDetailPage extends StatelessWidget {
  const TicketDetailPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketDetailViewModel>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/tickets'),
        ),
        title: Text('Ticket #$ticketId'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mail_outline, size: 18),
            label: const Text('Cliente'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.business_outlined, size: 18),
            label: const Text('EPS'),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Storico stati',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => TicketHistoryDialog(ticketId: ticketId),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : vm.ticket == null
              ? const Center(child: Text('Ticket non trovato'))
              : _DetailBody(vm: vm),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.vm});

  final TicketDetailViewModel vm;

  @override
  Widget build(BuildContext context) {
    final ticket = vm.ticket!;
    final isMobile = context.isMobile;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroCard(ticket: ticket),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<TicketDetailTab>(
                segments: const [
                  ButtonSegment(
                    value: TicketDetailTab.attivita,
                    label: Text('Attività'),
                    icon: Icon(Icons.timeline, size: 18),
                  ),
                  ButtonSegment(
                    value: TicketDetailTab.documenti,
                    label: Text('Documenti'),
                    icon: Icon(Icons.folder_outlined, size: 18),
                  ),
                ],
                selected: {vm.tab},
                onSelectionChanged: (s) => vm.setTab(s.first),
              ),
              const SizedBox(height: AppSpacing.md),
              if (vm.tab == TicketDetailTab.attivita)
                _ActivityTimeline(activities: vm.activities)
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'Nessun documento allegato',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TicketTypeChip(ticket: ticket),
                const Spacer(),
                Text(
                  formatDateTime(ticket.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.descrizione,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _InfoItem(label: 'Cliente', value: ticket.cliente),
                _InfoItem(label: 'Impianto', value: ticket.impianto),
                _InfoItem(label: 'Responsabile', value: ticket.responsabile),
                if (ticket.unitaAziendale != null)
                  _InfoItem(label: 'Unità', value: ticket.unitaAziendale!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline({required this.activities});

  final List<TicketActivity> activities;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: activities.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value;
            final isLast = i == activities.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: AppColors.border,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  a.titolo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (a.hasAttachment)
                                const Icon(Icons.attach_file, size: 18),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.descrizioneOperatore,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              a.esito,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${formatDateTime(a.dataOra)} · ${a.eseguitaDa}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
