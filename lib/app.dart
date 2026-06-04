import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';

class GestionaleTicketApp extends StatelessWidget {
  const GestionaleTicketApp({super.key, required this.router});

  final dynamic router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gestionale Ticket - SIEM',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
      locale: const Locale('it', 'IT'),
      supportedLocales: const [Locale('it', 'IT')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
