import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/ticket_repository.dart';
import '../../features/shell/widgets/app_shell_layout.dart';
import '../../features/tickets/viewmodels/new_ticket_view_model.dart';
import '../../features/tickets/viewmodels/ticket_detail_view_model.dart';
import '../../features/tickets/viewmodels/tickets_list_view_model.dart';
import '../../features/tickets/views/new_ticket_page.dart';
import '../../features/tickets/views/ticket_detail_page.dart';
import '../../features/tickets/views/tickets_gestione_page.dart';
import '../../features/map/views/intervention_map_page.dart';
import '../../features/tickets/views/tickets_hub_page.dart';
import 'page_transitions.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/tickets',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShellLayout(child: child),
        routes: [
          GoRoute(
            path: '/tickets',
            pageBuilder: (context, state) {
              final tabParam = state.uri.queryParameters['tab'];
              final initialTab = switch (tabParam) {
                'oe' => TicketsMainTab.ticketsOe,
                'interventi' => TicketsMainTab.ticketsInterventi,
                _ => TicketsMainTab.tickets,
              };
              return shellTransitionPage(
                state: state,
                child: TicketsHubPage(initialTab: initialTab),
              );
            },
          ),
          GoRoute(
            path: '/tickets/mappa',
            pageBuilder: (context, state) => shellTransitionPage(
              state: state,
              child: const InterventionMapPage(),
            ),
          ),
          GoRoute(
            path: '/tickets/gestione',
            pageBuilder: (context, state) => shellTransitionPage(
              state: state,
              child: const TicketsGestionePage(),
            ),
          ),
          GoRoute(
            path: '/tickets/nuovo',
            pageBuilder: (context, state) => shellTransitionPage(
              state: state,
              child: ChangeNotifierProvider(
                create: (_) => NewTicketViewModel(
                  context.read<TicketRepository>(),
                ),
                child: const NewTicketPage(),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/tickets/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return detailTransitionPage(
            state: state,
            child: ChangeNotifierProvider(
              create: (_) => TicketDetailViewModel(
                context.read<TicketRepository>(),
                id,
              )..load(),
              child: TicketDetailPage(ticketId: id),
            ),
          );
        },
      ),
    ],
    redirect: (context, state) {
      if (state.matchedLocation == '/') return '/tickets';
      return null;
    },
  );
}
