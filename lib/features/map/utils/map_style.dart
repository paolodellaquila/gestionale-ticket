import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/intervention_area.dart';
import '../../../data/models/ticket.dart';

class MapStyle {
  static Color areaFill(InterventionArea area) {
    if (area.hasExpired) {
      return AppColors.danger.withValues(alpha: 0.18);
    }
    return switch (area.dominantType) {
      TicketType.guasto => AppColors.guasto.withValues(alpha: 0.2),
      TicketType.anomalia => AppColors.anomalia.withValues(alpha: 0.18),
      TicketType.amministrativo =>
        AppColors.amministrativo.withValues(alpha: 0.16),
    };
  }

  static Color areaBorder(InterventionArea area) {
    if (area.hasExpired) return AppColors.danger;
    return switch (area.dominantType) {
      TicketType.guasto => AppColors.guasto,
      TicketType.anomalia => AppColors.anomalia,
      TicketType.amministrativo => AppColors.amministrativo,
    };
  }

  static IconData markerIcon(InterventionArea area) {
    return switch (area.dominantType) {
      TicketType.guasto => Icons.warning_amber_rounded,
      TicketType.anomalia => Icons.solar_power_outlined,
      TicketType.amministrativo => Icons.description_outlined,
    };
  }
}
