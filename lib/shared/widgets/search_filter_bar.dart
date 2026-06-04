import 'package:flutter/material.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/ticket.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
    this.selectedType,
    this.onTypeChanged,
    this.hint = 'Cerca per ID, cliente, impianto, descrizione...',
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final TicketType? selectedType;
  final ValueChanged<TicketType?>? onTypeChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(Icons.search, size: 22),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: onClear,
                        )
                      : null,
                ),
                onSubmitted: (_) => onSearch(),
                onChanged: (_) => (context as Element).markNeedsBuild(),
              ),
            ),
            const SizedBox(width: 8),
            if (!context.isMobile) ...[
              FilledButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Cerca'),
              ),
            ] else
              FilledButton(
                onPressed: onSearch,
                child: const Icon(Icons.search),
              ),
          ],
        ),
        if (onTypeChanged != null) ...[
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tutti'),
                  selected: selectedType == null,
                  onSelected: (_) => onTypeChanged!(null),
                ),
                const SizedBox(width: 6),
                ...TicketType.values.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(_typeLabel(t)),
                      selected: selectedType == t,
                      onSelected: (_) => onTypeChanged!(t),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _typeLabel(TicketType t) {
    switch (t) {
      case TicketType.guasto:
        return 'Guasto';
      case TicketType.anomalia:
        return 'Anomalia';
      case TicketType.amministrativo:
        return 'Amministrativo';
    }
  }
}
