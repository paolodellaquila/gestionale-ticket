import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ticket.dart';
import '../viewmodels/new_ticket_view_model.dart';
import '../viewmodels/tickets_list_view_model.dart';

class NewTicketPage extends StatelessWidget {
  const NewTicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NewTicketViewModel>();
    final isMobile = context.isMobile;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? AppSpacing.sm : AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add_task,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nuovo ticket',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Compila i campi per aprire una segnalazione',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (vm.error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Material(
                      color: AppColors.dangerBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          vm.error!,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _Field(
                    label: 'Cliente',
                    child: TextField(
                      onChanged: vm.updateCliente,
                      decoration: const InputDecoration(
                        hintText: 'Cerca cliente...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  _Field(
                    label: 'Impianto',
                    child: DropdownButtonFormField<String>(
                      value: vm.impianto,
                      items: NewTicketViewModel.impianti
                          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) vm.updateImpianto(v);
                      },
                    ),
                  ),
                  _Field(
                    label: 'Tipologia',
                    child: DropdownButtonFormField<TicketType>(
                      value: vm.tipologia,
                      items: TicketType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_typeLabel(t)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) vm.updateTipologia(v);
                      },
                    ),
                  ),
                  _Field(
                    label: 'Descrizione',
                    child: TextField(
                      onChanged: vm.updateDescrizione,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Descrivi il problema o la richiesta',
                      ),
                    ),
                  ),
                  _Field(
                    label: 'Note interne',
                    child: TextField(
                      onChanged: vm.updateNoteInterne,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Visibili solo agli operatori',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: vm.saving ? null : vm.reset,
                        child: const Text('Annulla'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: vm.saving
                              ? null
                              : () => _save(context, vm),
                          icon: vm.saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 18),
                          label: const Text('Salva ticket'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

  Future<void> _save(BuildContext context, NewTicketViewModel vm) async {
    final ok = await vm.save();
    if (ok && context.mounted) {
      await context.read<TicketsListViewModel>().load();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket creato con successo')),
        );
        context.go('/tickets');
      }
    }
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
