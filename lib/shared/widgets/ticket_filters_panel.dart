import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/ticket.dart';
import '../../data/models/ticket_filters.dart';
import '../../features/tickets/viewmodels/tickets_list_view_model.dart';

/// Pannello filtri rapidi per la home ticket.
class TicketFiltersPanel extends StatefulWidget {
  const TicketFiltersPanel({
    super.key,
    required this.searchController,
    this.visibleCount,
  });

  final TextEditingController searchController;
  final int? visibleCount;

  @override
  State<TicketFiltersPanel> createState() => _TicketFiltersPanelState();
}

class _TicketFiltersPanelState extends State<TicketFiltersPanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketsListViewModel>();
    final f = vm.filters;
    final isMobile = context.isMobile;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Filtri',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  if (vm.activeFilterCount > 0) ...[
                    const SizedBox(width: 8),
                    Badge(
                      label: Text('${vm.activeFilterCount}'),
                      backgroundColor: AppColors.primary,
                    ),
                  ],
                  const Spacer(),
                  if (widget.visibleCount != null)
                    Text(
                      '${widget.visibleCount} risultati',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SearchRow(
                    controller: widget.searchController,
                    onSearch: () =>
                        vm.setSearchQuery(widget.searchController.text),
                    onClear: () {
                      widget.searchController.clear();
                      vm.clearSearch();
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _QuickToggles(vm: vm, filters: f),
                  const SizedBox(height: AppSpacing.md),
                  isMobile
                      ? _MobileFilters(vm: vm, filters: f)
                      : _DesktopFilters(vm: vm, filters: f),
                  if (vm.hasActiveFilters) ...[
                    const SizedBox(height: AppSpacing.md),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          widget.searchController.clear();
                          vm.clearAllFilters();
                        },
                        icon: const Icon(Icons.filter_alt_off, size: 18),
                        label: const Text('Azzera tutti i filtri'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchRow extends StatefulWidget {
  const _SearchRow({
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  State<_SearchRow> createState() => _SearchRowState();
}

class _SearchRowState extends State<_SearchRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: 'Ricerca rapida',
              hintText: 'ID, cliente, impianto, descrizione...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.onClear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) => widget.onSearch(),
            onChanged: (_) {
              widget.onSearch();
              setState(() {});
            },
          ),
        ),
        if (!context.isMobile) ...[
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: widget.onSearch,
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Applica'),
          ),
        ],
      ],
    );
  }
}

class _QuickToggles extends StatelessWidget {
  const _QuickToggles({required this.vm, required this.filters});

  final TicketsListViewModel vm;
  final TicketFilters filters;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Tipologia:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        FilterChip(
          label: const Text('Tutte'),
          selected: filters.tipologia == null,
          onSelected: (_) => vm.setTipologiaFilter(null),
        ),
        ...TicketType.values.map((t) {
          return FilterChip(
            label: Text(_tipologiaLabel(t)),
            selected: filters.tipologia == t,
            onSelected: (_) => vm.setTipologiaFilter(
              filters.tipologia == t ? null : t,
            ),
          );
        }),
        const SizedBox(width: 8),
        FilterChip(
          avatar: Icon(
            Icons.event_busy,
            size: 16,
            color: filters.soloInScadenza ? AppColors.danger : null,
          ),
          label: const Text('In scadenza'),
          selected: filters.soloInScadenza,
          onSelected: (v) => vm.updateFilters(
            filters.copyWith(soloInScadenza: v),
          ),
        ),
        FilterChip(
          avatar: Icon(
            Icons.warning_amber,
            size: 16,
            color: filters.soloGuasti ? AppColors.guasto : null,
          ),
          label: const Text('Solo guasti'),
          selected: filters.soloGuasti,
          onSelected: (v) =>
              vm.updateFilters(filters.copyWith(soloGuasti: v)),
        ),
      ],
    );
  }

  String _tipologiaLabel(TicketType t) {
    return switch (t) {
      TicketType.guasto => 'Guasto',
      TicketType.anomalia => 'Anomalia',
      TicketType.amministrativo => 'Amministrativo',
    };
  }
}

class _PeriodoRow extends StatelessWidget {
  const _PeriodoRow({required this.vm, required this.filters});

  final TicketsListViewModel vm;
  final TicketFilters filters;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Periodo:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        FilterChip(
          label: const Text('Tutti'),
          selected: filters.periodoGiorni == null,
          onSelected: (_) => vm.updateFilters(filters.copyWith(clearPeriodo: true)),
        ),
        FilterChip(
          label: const Text('7 giorni'),
          selected: filters.periodoGiorni == 7,
          onSelected: (_) => vm.updateFilters(
            filters.periodoGiorni == 7
                ? filters.copyWith(clearPeriodo: true)
                : filters.copyWith(periodoGiorni: 7),
          ),
        ),
        FilterChip(
          label: const Text('30 giorni'),
          selected: filters.periodoGiorni == 30,
          onSelected: (_) => vm.updateFilters(
            filters.periodoGiorni == 30
                ? filters.copyWith(clearPeriodo: true)
                : filters.copyWith(periodoGiorni: 30),
          ),
        ),
        FilterChip(
          label: const Text('90 giorni'),
          selected: filters.periodoGiorni == 90,
          onSelected: (_) => vm.updateFilters(
            filters.periodoGiorni == 90
                ? filters.copyWith(clearPeriodo: true)
                : filters.copyWith(periodoGiorni: 90),
          ),
        ),
      ],
    );
  }
}

class _DesktopFilters extends StatelessWidget {
  const _DesktopFilters({required this.vm, required this.filters});

  final TicketsListViewModel vm;
  final TicketFilters filters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FilterDropdown(
                label: 'Cliente',
                value: filters.cliente,
                options: vm.clientiOptions,
                onChanged: (v) => vm.updateFilters(
                  v == null
                      ? filters.copyWith(clearCliente: true)
                      : filters.copyWith(cliente: v),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Impianto',
                value: filters.impianto,
                options: vm.impiantiOptions,
                onChanged: (v) => vm.updateFilters(
                  v == null
                      ? filters.copyWith(clearImpianto: true)
                      : filters.copyWith(impianto: v),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Responsabile',
                value: filters.responsabile,
                options: vm.responsabiliOptions,
                onChanged: (v) => vm.updateFilters(
                  v == null
                      ? filters.copyWith(clearResponsabile: true)
                      : filters.copyWith(responsabile: v),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterDropdown(
                label: 'Unità aziendale',
                value: filters.unitaAziendale,
                options: vm.unitaOptions,
                onChanged: (v) => vm.updateFilters(
                  v == null
                      ? filters.copyWith(clearUnita: true)
                      : filters.copyWith(unitaAziendale: v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _PeriodoRow(vm: vm, filters: filters),
      ],
    );
  }
}

class _MobileFilters extends StatelessWidget {
  const _MobileFilters({required this.vm, required this.filters});

  final TicketsListViewModel vm;
  final TicketFilters filters;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilterDropdown(
          label: 'Cliente',
          value: filters.cliente,
          options: vm.clientiOptions,
          onChanged: (v) => vm.updateFilters(
            v == null
                ? filters.copyWith(clearCliente: true)
                : filters.copyWith(cliente: v),
          ),
        ),
        const SizedBox(height: 10),
        _FilterDropdown(
          label: 'Impianto',
          value: filters.impianto,
          options: vm.impiantiOptions,
          onChanged: (v) => vm.updateFilters(
            v == null
                ? filters.copyWith(clearImpianto: true)
                : filters.copyWith(impianto: v),
          ),
        ),
        const SizedBox(height: 10),
        _FilterDropdown(
          label: 'Responsabile',
          value: filters.responsabile,
          options: vm.responsabiliOptions,
          onChanged: (v) => vm.updateFilters(
            v == null
                ? filters.copyWith(clearResponsabile: true)
                : filters.copyWith(responsabile: v),
          ),
        ),
        const SizedBox(height: 10),
        _FilterDropdown(
          label: 'Unità aziendale',
          value: filters.unitaAziendale,
          options: vm.unitaOptions,
          onChanged: (v) => vm.updateFilters(
            v == null
                ? filters.copyWith(clearUnita: true)
                : filters.copyWith(unitaAziendale: v),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _PeriodoRow(vm: vm, filters: filters),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      key: ValueKey('$label-${value ?? 'tutti'}'),
      value: value,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Tutti'),
        ),
        ...options.map(
          (o) => DropdownMenuItem<String?>(value: o, child: Text(o)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
