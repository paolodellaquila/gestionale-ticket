import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ticket.dart';
import '../../../shared/widgets/search_filter_bar.dart';
import '../../../shared/widgets/ticket_card.dart';
import '../viewmodels/tickets_list_view_model.dart';
import 'ticket_history_dialog.dart';
import 'ticket_reassign_dialog.dart';

class TicketsGestionePage extends StatefulWidget {
  const TicketsGestionePage({super.key});

  @override
  State<TicketsGestionePage> createState() => _TicketsGestionePageState();
}

class _TicketsGestionePageState extends State<TicketsGestionePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<TicketsListViewModel>();
      if (vm.counts == null) vm.load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onAction(Ticket ticket, String action) {
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketsListViewModel>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.isMobile ? AppSpacing.sm : AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<GestioneSubTab>(
            segments: const [
              ButtonSegment(
                value: GestioneSubTab.daLavorare,
                label: Text('Da lavorare'),
                icon: Icon(Icons.schedule, size: 18),
              ),
              ButtonSegment(
                value: GestioneSubTab.inLavorazione,
                label: Text('In lavorazione'),
                icon: Icon(Icons.play_circle_outline, size: 18),
              ),
              ButtonSegment(
                value: GestioneSubTab.chiusi,
                label: Text('Chiusi'),
                icon: Icon(Icons.check_circle_outline, size: 18),
              ),
            ],
            selected: {vm.gestioneTab},
            onSelectionChanged: (s) => vm.setGestioneTab(s.first),
          ),
          const SizedBox(height: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.lg),
          if (vm.loading)
            const Center(child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ))
          else ...[
            TicketCardGrid(
              tickets: vm.gestioneTickets,
              onAction: _onAction,
            ),
            const SizedBox(height: AppSpacing.md),
            _PaginationBar(vm: vm),
          ],
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({required this.vm});

  final TicketsListViewModel vm;

  @override
  Widget build(BuildContext context) {
    final page = vm.currentPage + 1;
    final total = vm.gestioneTotalPages;
    final start = vm.gestioneTotalCount == 0
        ? 0
        : vm.currentPage * TicketsListViewModel.pageSize + 1;
    final end = vm.gestioneTotalCount == 0
        ? 0
        : (start + vm.gestioneTickets.length - 1).clamp(0, vm.gestioneTotalCount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: vm.currentPage > 0 ? vm.firstPage : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: vm.currentPage > 0 ? vm.previousPage : null,
            ),
            Text(
              'Pagina $page di $total',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: vm.currentPage < total - 1 ? vm.nextPage : null,
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: vm.currentPage < total - 1 ? vm.lastPage : null,
            ),
            const SizedBox(width: 16),
            Text(
              'Record $start–$end di ${vm.gestioneTotalCount}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
