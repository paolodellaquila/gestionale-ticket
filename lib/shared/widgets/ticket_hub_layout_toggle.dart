import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../features/tickets/viewmodels/tickets_list_view_model.dart';

/// Switch card / tabella per la home ticket.
class TicketHubLayoutToggle extends StatelessWidget {
  const TicketHubLayoutToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TicketsListViewModel>();
    final isMobile = context.isMobile;

    return Row(
      children: [
        if (!isMobile) ...[
          const Icon(
            Icons.view_module_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          const Text(
            'Visualizzazione',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
        ],
        Expanded(
          child: Align(
            alignment: isMobile ? Alignment.centerRight : Alignment.centerRight,
            child: SegmentedButton<TicketHubLayout>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: TicketHubLayout.cards,
                  icon: const Icon(Icons.grid_view_rounded, size: 18),
                  label: isMobile ? null : const Text('Card'),
                ),
                ButtonSegment(
                  value: TicketHubLayout.table,
                  icon: const Icon(Icons.table_rows_outlined, size: 18),
                  label: isMobile ? null : const Text('Tabella'),
                ),
              ],
              selected: {vm.hubLayout},
              onSelectionChanged: (s) => vm.setHubLayout(s.first),
            ),
          ),
        ),
      ],
    );
  }
}
