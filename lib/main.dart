import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/impianto_repository.dart';
import 'data/repositories/intervention_map_repository.dart';
import 'data/repositories/ticket_repository.dart';
import 'features/auth/viewmodels/auth_view_model.dart';
import 'features/chat/viewmodels/ticket_chat_view_model.dart';
import 'features/map/viewmodels/intervention_map_view_model.dart';
import 'features/tickets/viewmodels/tickets_list_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  runApp(const GestionaleTicketRoot());
}

class GestionaleTicketRoot extends StatelessWidget {
  const GestionaleTicketRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = MockAuthRepository();
    final authViewModel = AuthViewModel(authRepository);
    final ticketRepository = MockTicketRepository();
    final impiantoRepository = MockImpiantoRepository();
    final mapRepository = MockInterventionMapRepository(
      ticketRepository,
      impiantoRepository,
    );
    final router = createAppRouter(authViewModel);

    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        ChangeNotifierProvider<AuthViewModel>.value(value: authViewModel),
        Provider<TicketRepository>.value(value: ticketRepository),
        Provider<ImpiantoRepository>.value(value: impiantoRepository),
        Provider<InterventionMapRepository>.value(value: mapRepository),
        ChangeNotifierProvider(
          create: (ctx) => TicketsListViewModel(ctx.read<TicketRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) =>
              InterventionMapViewModel(ctx.read<InterventionMapRepository>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => TicketChatViewModel(
            ticketRepository: ctx.read<TicketRepository>(),
            impiantoRepository: ctx.read<ImpiantoRepository>(),
          ),
        ),
      ],
      child: GestionaleTicketApp(router: router),
    );
  }
}
