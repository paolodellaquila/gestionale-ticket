import 'impianto.dart';
import 'ticket.dart';

/// Area di intervento derivata da ticket aperti su un impianto.
class InterventionArea {
  const InterventionArea({
    required this.impianto,
    required this.tickets,
  });

  final Impianto impianto;
  final List<Ticket> tickets;

  Ticket get primaryTicket {
    final guasti = tickets.where((t) => t.tipologia == TicketType.guasto);
    if (guasti.isNotEmpty) {
      return guasti.reduce(
        (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
      );
    }
    return tickets.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
  }

  TicketType get dominantType => primaryTicket.tipologia;

  bool get hasExpired =>
      tickets.any((t) => t.isExpired || t.section == TicketSection.inScadenza);

  bool get isIntervento =>
      tickets.any((t) => t.section == TicketSection.interventi);

  /// Raggio area intervento (metri) in base a urgenza/tipologia.
  double get radiusMeters {
    if (hasExpired) return 12000;
    if (dominantType == TicketType.guasto) return 10000;
    if (isIntervento) return 8500;
    return 6500;
  }

  int get openTicketCount => tickets.length;
}
