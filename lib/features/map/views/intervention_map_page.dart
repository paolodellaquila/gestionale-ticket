import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config/mapbox_config.dart';
import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/intervention_area.dart';
import '../../../data/models/ticket.dart';
import '../viewmodels/intervention_map_view_model.dart';
import '../widgets/intervention_area_panel.dart';
import '../widgets/intervention_map_view.dart';

class InterventionMapPage extends StatefulWidget {
  const InterventionMapPage({super.key});

  @override
  State<InterventionMapPage> createState() => _InterventionMapPageState();
}

class _InterventionMapPageState extends State<InterventionMapPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InterventionMapViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InterventionMapViewModel>();
    final isMobile = context.isMobile;

    if (vm.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(child: Text(vm.error!));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MapToolbar(vm: vm),
        if (!MapboxConfig.isConfigured) const _MapboxTokenBanner(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? AppSpacing.sm : AppSpacing.lg,
              AppSpacing.sm,
              isMobile ? AppSpacing.sm : AppSpacing.lg,
              isMobile ? AppSpacing.sm : AppSpacing.lg,
            ),
            child: isMobile ? _MobileLayout(vm: vm) : _DesktopLayout(vm: vm),
          ),
        ),
      ],
    );
  }
}

class _MapToolbar extends StatelessWidget {
  const _MapToolbar({required this.vm});

  final InterventionMapViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Aree di intervento',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  FilterChip(
                    label: Text(
                      'Guasto (${vm.areas.where((a) => a.dominantType == TicketType.guasto).length})',
                    ),
                    selected: vm.showGuasto,
                    onSelected: vm.toggleGuasto,
                  ),
                  FilterChip(
                    label: const Text('Anomalia'),
                    selected: vm.showAnomalia,
                    onSelected: vm.toggleAnomalia,
                  ),
                  FilterChip(
                    label: const Text('Amministrativo'),
                    selected: vm.showAmministrativo,
                    onSelected: vm.toggleAmministrativo,
                  ),
                  FilterChip(
                    avatar: const Icon(Icons.engineering, size: 16),
                    label: const Text('Solo interventi'),
                    selected: vm.onlyInterventi,
                    onSelected: vm.toggleOnlyInterventi,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Aggiorna',
              onPressed: vm.load,
              icon: const Icon(Icons.refresh),
            ),
            const _MapLegend(),
          ],
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'Legenda',
      icon: const Icon(Icons.info_outline),
      itemBuilder: (_) => [
        const PopupMenuItem(
          enabled: false,
          child: _LegendRow(color: AppColors.guasto, label: 'Guasto — area ~10 km'),
        ),
        const PopupMenuItem(
          enabled: false,
          child: _LegendRow(color: AppColors.anomalia, label: 'Anomalia — area ~6.5 km'),
        ),
        const PopupMenuItem(
          enabled: false,
          child: _LegendRow(
            color: AppColors.danger,
            label: 'In scadenza — area estesa',
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _MapboxTokenBanner extends StatelessWidget {
  const _MapboxTokenBanner();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warningBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.map_outlined, size: 18, color: AppColors.warning),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Token Mapbox non configurato: mappa OpenStreetMap. '
                'Imposta MAPBOX_ACCESS_TOKEN nel file .env',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.vm});

  final InterventionMapViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InterventionMapView(
              key: ValueKey(vm.areas.map((a) => a.impianto.codice).join(',')),
              viewModel: vm,
              onAreaTap: vm.selectArea,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 1,
          child: InterventionAreaPanel(
            areas: vm.areas,
            selected: vm.selected,
            onSelect: vm.selectArea,
          ),
        ),
      ],
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.vm});

  final InterventionMapViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: InterventionMapView(
              key: ValueKey(vm.areas.map((a) => a.impianto.codice).join(',')),
              viewModel: vm,
              onAreaTap: (area) {
                vm.selectArea(area);
                _showAreaSheet(context, vm, area);
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: InterventionAreaPanel(
            areas: vm.areas,
            selected: vm.selected,
            onSelect: vm.selectArea,
          ),
        ),
      ],
    );
  }

  void _showAreaSheet(
    BuildContext context,
    InterventionMapViewModel vm,
    InterventionArea area,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              area.impianto.codice,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(area.impianto.cliente),
            Text(area.impianto.indirizzo),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/tickets/${area.primaryTicket.id}');
              },
              child: const Text('Apri ticket principale'),
            ),
          ],
        ),
      ),
    );
  }
}
