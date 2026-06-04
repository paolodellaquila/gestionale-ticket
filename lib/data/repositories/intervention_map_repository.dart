import '../models/intervention_area.dart';
import '../models/ticket.dart';
import 'impianto_repository.dart';
import 'ticket_repository.dart';

abstract class InterventionMapRepository {
  /// Ticket aperti recenti raggruppati per impianto (con coordinate GPS).
  Future<List<InterventionArea>> getInterventionAreas({
    Duration maxAge = const Duration(days: 90),
  });
}

class MockInterventionMapRepository implements InterventionMapRepository {
  MockInterventionMapRepository(this._tickets, this._impianti);

  final TicketRepository _tickets;
  final ImpiantoRepository _impianti;

  static const _openSections = {
    TicketSection.processare,
    TicketSection.inScadenza,
    TicketSection.offerteInAttesa,
    TicketSection.offerteDaInviare,
    TicketSection.interventi,
    TicketSection.inLavorazione,
  };

  @override
  Future<List<InterventionArea>> getInterventionAreas({
    Duration maxAge = const Duration(days: 90),
  }) async {
    final cutoff = DateTime.now().subtract(maxAge);
    final allTickets = await _tickets.getTickets();
    final impianti = await _impianti.getAll();
    final byCodice = {for (final i in impianti) i.codice: i};

    final openRecent = allTickets.where(
      (t) =>
          _openSections.contains(t.section) &&
          t.createdAt.isAfter(cutoff),
    );

    final grouped = <String, List<Ticket>>{};
    for (final ticket in openRecent) {
      grouped.putIfAbsent(ticket.impianto, () => []).add(ticket);
    }

    final areas = <InterventionArea>[];
    for (final entry in grouped.entries) {
      final impianto = byCodice[entry.key];
      if (impianto == null) continue;
      areas.add(InterventionArea(impianto: impianto, tickets: entry.value));
    }

    areas.sort((a, b) {
      if (a.hasExpired != b.hasExpired) return a.hasExpired ? -1 : 1;
      if (a.dominantType == TicketType.guasto &&
          b.dominantType != TicketType.guasto) {
        return -1;
      }
      return b.openTicketCount.compareTo(a.openTicketCount);
    });

    return areas;
  }
}
