import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'ticket.dart';

extension TicketUi on Ticket {
  Color get typeColor {
    switch (tipologia) {
      case TicketType.guasto:
        return AppColors.guasto;
      case TicketType.anomalia:
        return AppColors.anomalia;
      case TicketType.amministrativo:
        return AppColors.amministrativo;
    }
  }

  Color get typeBackground => typeColor.withValues(alpha: 0.1);

  IconData get typeIcon {
    switch (tipologia) {
      case TicketType.guasto:
        return Icons.warning_amber_rounded;
      case TicketType.anomalia:
        return Icons.info_outline_rounded;
      case TicketType.amministrativo:
        return Icons.description_outlined;
    }
  }

  int? get daysUntilDeadline {
    if (dataScadenza == null) return null;
    return dataScadenza!.difference(DateTime.now()).inDays;
  }
}
