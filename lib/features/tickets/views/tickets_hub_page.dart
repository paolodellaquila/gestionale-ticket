import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ticket.dart';
import '../../../shared/widgets/queue_stat_card.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../../../shared/widgets/section_panel.dart';
import '../../../shared/widgets/ticket_card.dart';
import '../viewmodels/tickets_list_view_model.dart';
import 'ticket_history_dialog.dart';
import 'ticket_reassign_dialog.dart';

class TicketsHubPage extends StatefulWidget {
  const TicketsHubPage({super.key, this.initialTab = TicketsMainTab.tickets});

  final TicketsMainTab initialTab;

  @override
  State<TicketsHubPage> createState() => _TicketsHubPageState();
}

class _TicketsHubPageState extends State<TicketsHubPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TicketsListViewModel>();
      vm.setMainTab(widget.initialTab);
      vm.load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketsListViewModel>();

    if (vm.loading && vm.counts == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: vm.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(context.isMobile ? AppSpacing.sm : AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QueueOverview(vm: vm),
            const SizedBox(height: AppSpacing.lg),
            SearchFilterBar(
              controller: _searchController,
              onSearch: () => vm.setSearchQuery(_searchController.text),
              onClear: () {
                _searchController.clear();
                vm.clearSearch();
              },
              selectedType: vm.tipologiaFilter,
              onTypeChanged: vm.setTipologiaFilter,
            ),
            const SizedBox(height: AppSpacing.md),
            _MainTabBar(vm: vm),
            const SizedBox(height: AppSpacing.lg),
            switch (vm.mainTab) {
              TicketsMainTab.tickets => _TicketsQueues(
                  vm: vm,
                  onAction: (t, a) => _onTicketAction(context, t, a),
                ),
              TicketsMainTab.ticketsOe => _OeQueues(
                  vm: vm,
                  onAction: (t, a) => _onTicketAction(context, t, a),
                ),
              TicketsMainTab.ticketsInterventi => _InterventiQueue(
                  vm: vm,
                  onAction: (t, a) => _onTicketAction(context, t, a),
                ),
            },
          ],
        ),
      ),
    );
  }

  void _onTicketAction(BuildContext context, Ticket ticket, String action) {
    switch (action) {
      case 'storico':
        showDialog(
          context: context,
          builder: (_) => TicketHistoryDialog(ticketId: ticket.id),
        );
      case 'chiudi':
        showDialog(
          context: context,
          builder: (_) => TicketReassignDialog(ticket: ticket),
        );
      default:
        break;
    }
  }
}

class _QueueOverview extends StatelessWidget {
  const _QueueOverview({required this.vm});

  final TicketsListViewModel vm;

  @override
  Widget build(BuildContext context) {
    final counts = vm.counts;
    final isMobile = context.isMobile;

    final cards = [
      QueueStatCard(
        label: 'Da processare',
        count: vm.processareTickets.length,
        icon: Icons.pending_actions,
        color: AppColors.primary,
        selected: vm.mainTab == TicketsMainTab.tickets,
        onTap: () => _selectTab(context, vm, TicketsMainTab.tickets, ''),
      ),
      QueueStatCard(
        label: 'In scadenza',
        count: vm.scadenzaTickets.length,
        icon: Icons.event_busy,
        color: AppColors.danger,
        onTap: () => _selectTab(context, vm, TicketsMainTab.tickets, ''),
      ),
      QueueStatCard(
        label: 'Offerte economiche',
        count: counts?.ticketsOe ?? 0,
        icon: Icons.request_quote_outlined,
        color: AppColors.anomalia,
        selected: vm.mainTab == TicketsMainTab.ticketsOe,
        onTap: () => _selectTab(context, vm, TicketsMainTab.ticketsOe, '?tab=oe'),
      ),
      QueueStatCard(
        label: 'Interventi',
        count: counts?.ticketsInterventi ?? 0,
        icon: Icons.engineering_outlined,
        color: AppColors.secondary,
        selected: vm.mainTab == TicketsMainTab.ticketsInterventi,
        onTap: () =>
            _selectTab(context, vm, TicketsMainTab.ticketsInterventi, '?tab=interventi'),
      ),
    ];

    if (isMobile) {
      return Column(children: cards.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: c,
          )).toList());
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.4,
      children: cards,
    );
  }

  void _selectTab(
    BuildContext context,
    TicketsListViewModel vm,
    TicketsMainTab tab,
    String query,
  ) {
    vm.setMainTab(tab);
    context.go('/tickets$query');
  }
}

class _MainTabBar extends StatelessWidget {
  const _MainTabBar({required this.vm});

  final TicketsListViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TicketsMainTab>(
      segments: [
        ButtonSegment(
          value: TicketsMainTab.tickets,
          label: Text('Tickets (${vm.processareTickets.length + vm.scadenzaTickets.length})'),
          icon: const Icon(Icons.inbox_outlined, size: 18),
        ),
        ButtonSegment(
          value: TicketsMainTab.ticketsOe,
          label: Text('OE (${vm.offerteInAttesa.length + vm.offerteDaInviare.length})'),
          icon: const Icon(Icons.receipt_long_outlined, size: 18),
        ),
        ButtonSegment(
          value: TicketsMainTab.ticketsInterventi,
          label: Text('Interventi (${vm.interventiTickets.length})'),
          icon: const Icon(Icons.build_outlined, size: 18),
        ),
      ],
      selected: {vm.mainTab},
      onSelectionChanged: (s) {
        final tab = s.first;
        vm.setMainTab(tab);
        final query = switch (tab) {
          TicketsMainTab.tickets => '',
          TicketsMainTab.ticketsOe => '?tab=oe',
          TicketsMainTab.ticketsInterventi => '?tab=interventi',
        };
        context.go('/tickets$query');
      },
    );
  }
}

class _TicketsQueues extends StatelessWidget {
  const _TicketsQueues({required this.vm, required this.onAction});

  final TicketsListViewModel vm;
  final TicketCardCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionPanel(
          title: 'Processare',
          subtitle: 'Ticket da prendere in carico',
          accentColor: AppColors.primary,
          child: TicketCardGrid(
            tickets: vm.processareTickets,
            onAction: onAction,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionPanel(
          title: 'In scadenza o scaduti',
          subtitle: 'Priorità temporale — richiedono attenzione immediata',
          accentColor: AppColors.danger,
          child: TicketCardGrid(
            tickets: vm.scadenzaTickets,
            highlightDeadline: true,
            onAction: onAction,
          ),
        ),
      ],
    );
  }
}

class _OeQueues extends StatelessWidget {
  const _OeQueues({required this.vm, required this.onAction});

  final TicketsListViewModel vm;
  final TicketCardCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionPanel(
          title: 'In attesa del cliente',
          subtitle: 'Offerte economiche in attesa di risconto',
          accentColor: AppColors.anomalia,
          child: TicketCardGrid(
            tickets: vm.offerteInAttesa,
            onAction: onAction,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionPanel(
          title: 'Da inviare',
          subtitle: 'Proposte da inviare al cliente',
          accentColor: AppColors.warning,
          child: TicketCardGrid(
            tickets: vm.offerteDaInviare,
            onAction: onAction,
          ),
        ),
      ],
    );
  }
}

class _InterventiQueue extends StatelessWidget {
  const _InterventiQueue({required this.vm, required this.onAction});

  final TicketsListViewModel vm;
  final TicketCardCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SectionPanel(
      title: 'Interventi da effettuare',
      subtitle: 'Attività tecniche in campo',
      accentColor: AppColors.secondary,
      child: TicketCardGrid(
        tickets: vm.interventiTickets,
        onAction: onAction,
      ),
    );
  }
}
