import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'data/repositories/ticket_repository.dart';
import 'features/tickets/viewmodels/tickets_list_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GestionaleTicketRoot());
}

class GestionaleTicketRoot extends StatelessWidget {
  const GestionaleTicketRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = MockTicketRepository();

    return MultiProvider(
      providers: [
        Provider<TicketRepository>.value(value: repository),
        ChangeNotifierProvider(
          create: (ctx) => TicketsListViewModel(ctx.read<TicketRepository>()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = createAppRouter();
          return GestionaleTicketApp(router: router);
        },
      ),
    );
  }
}
