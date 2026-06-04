import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/intervention_area.dart';
import '../../../shared/widgets/ticket_type_chip.dart';

class InterventionAreaPanel extends StatelessWidget {
  const InterventionAreaPanel({
    super.key,
    required this.areas,
    required this.selected,
    required this.onSelect,
  });

  final List<InterventionArea> areas;
  final InterventionArea? selected;
  final ValueChanged<InterventionArea?> onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Impianti (${areas.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: areas.isEmpty
                ? const Center(
                    child: Text(
                      'Nessuna area con ticket aperti',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    itemCount: areas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final area = areas[index];
                      final isSelected =
                          selected?.impianto.codice == area.impianto.codice;
                      return _AreaListTile(
                        area: area,
                        selected: isSelected,
                        onTap: () => onSelect(isSelected ? null : area),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AreaListTile extends StatelessWidget {
  const _AreaListTile({
    required this.area,
    required this.selected,
    required this.onTap,
  });

  final InterventionArea area;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    area.impianto.codice,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  TicketTypeChip(ticket: area.primaryTicket, compact: true),
                ],
              ),
              Text(
                area.impianto.cliente,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                area.impianto.localita,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${area.openTicketCount} ticket · raggio ${(area.radiusMeters / 1000).toStringAsFixed(1)} km',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              if (selected) ...[
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () =>
                      context.go('/tickets/${area.primaryTicket.id}'),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Apri ticket'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
