import '../models/ticket.dart';

abstract class TicketRepository {
  Future<List<Ticket>> getTickets({TicketSection? section});
  Future<Ticket?> getTicketById(String id);
  Future<List<TicketActivity>> getActivities(String ticketId);
  Future<List<TicketHistoryEntry>> getHistory(String ticketId);
  Future<TicketTabCounts> getTabCounts();
  Future<void> createTicket({
    required String cliente,
    required String impianto,
    required TicketType tipologia,
    required String descrizione,
    String? noteInterne,
  });
}

class MockTicketRepository implements TicketRepository {
  MockTicketRepository() {
    _seed();
  }

  final List<Ticket> _tickets = [];
  final Map<String, List<TicketActivity>> _activities = {};
  final Map<String, List<TicketHistoryEntry>> _history = {};

  void _seed() {
    _tickets.addAll([
      Ticket(
        id: '000664',
        createdAt: DateTime(2026, 5, 30, 9, 15),
        cliente: 'GELARTIGIAN S.R.L.',
        impianto: 'FTV00327',
        tipologia: TicketType.anomalia,
        descrizione: 'RILIEVO SCHEMA CABLAGGIO STRINGHE',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 6, 1, 8, 30),
        section: TicketSection.processare,
      ),
      Ticket(
        id: '000665',
        createdAt: DateTime(2026, 5, 29, 14, 20),
        cliente: 'PLASTIC SYSTEM S.R.L.',
        impianto: 'FTV00143',
        tipologia: TicketType.guasto,
        descrizione: 'INVERTER HUAWEI IN STOP',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 5, 31, 16, 45),
        section: TicketSection.processare,
      ),
      Ticket(
        id: '001362',
        createdAt: DateTime(2022, 5, 3, 12, 54),
        cliente: 'E.P. S.R.L.',
        impianto: 'FTV00143',
        tipologia: TicketType.anomalia,
        descrizione: 'Attesa accordo economico MS',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 1, 15, 10, 0),
        section: TicketSection.offerteInAttesa,
      ),
      Ticket(
        id: '002248',
        createdAt: DateTime(2025, 11, 10, 11, 0),
        cliente: 'GEOS ENVIRONMENT S.R.L.',
        impianto: 'FTV00260',
        tipologia: TicketType.anomalia,
        descrizione: 'TARATURA FISCALE MISURATORE',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 5, 28, 9, 0),
        section: TicketSection.interventi,
      ),
      Ticket(
        id: '003070',
        createdAt: DateTime(2026, 4, 12, 8, 0),
        cliente: 'FARMASOL S.R.L.',
        impianto: 'FTV00187',
        tipologia: TicketType.guasto,
        descrizione: 'SOSTITUZIONE MODULO STRINGA',
        responsabile: 'Mario Rossi',
        ultimaAttivita: DateTime(2026, 5, 30, 14, 20),
        section: TicketSection.interventi,
      ),
      Ticket(
        id: '001200',
        createdAt: DateTime(2026, 3, 1, 10, 0),
        cliente: 'GIOTTO S.C.A.R.A.',
        impianto: 'FTV00120',
        tipologia: TicketType.guasto,
        descrizione: 'ALLARME IMPIANTO',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 5, 29, 11, 0),
        unitaAziendale: 'SERVICE',
        section: TicketSection.inLavorazione,
      ),
      Ticket(
        id: '000890',
        createdAt: DateTime(2026, 2, 15, 9, 0),
        cliente: 'NEW DIMENSION PLASTIC S.R.L.',
        impianto: 'FTV00210',
        tipologia: TicketType.amministrativo,
        descrizione: 'AGGIORNAMENTO CONTRATTO',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 5, 20, 15, 0),
        unitaAziendale: 'COMPLIANCE',
        section: TicketSection.inLavorazione,
      ),
      Ticket(
        id: '000450',
        createdAt: DateTime(2025, 12, 1, 8, 0),
        cliente: 'SOLAR TECH S.P.A.',
        impianto: 'FTV00089',
        tipologia: TicketType.anomalia,
        descrizione: 'VERIFICA PRODUZIONE',
        responsabile: 'Mario Rossi',
        ultimaAttivita: DateTime(2026, 4, 10, 9, 0),
        dataScadenza: DateTime(2026, 5, 25),
        section: TicketSection.inScadenza,
      ),
      Ticket(
        id: '000451',
        createdAt: DateTime(2025, 11, 20, 10, 0),
        cliente: 'ENERGIA VERDE S.R.L.',
        impianto: 'FTV00110',
        tipologia: TicketType.guasto,
        descrizione: 'MANUTENZIONE PROGRAMMATA',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 3, 5, 14, 0),
        dataScadenza: DateTime(2026, 5, 20),
        section: TicketSection.inScadenza,
      ),
      Ticket(
        id: '001500',
        createdAt: DateTime(2026, 4, 20, 11, 0),
        cliente: 'BIOMED S.R.L.',
        impianto: 'FTV00301',
        tipologia: TicketType.anomalia,
        descrizione: 'OFFERTA ECONOMICA DA INVIARE',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 5, 31, 9, 0),
        section: TicketSection.offerteDaInviare,
      ),
    ]);

    _activities['001362'] = [
      TicketActivity(
        titolo: 'Attesa dal cliente riscontro accordo economico per MS',
        descrizioneOperatore: 'Attendere il riscontro dal cliente...',
        esito: 'Sollecitare riscontro al cliente',
        dataOra: DateTime(2025, 12, 10, 14, 30),
        eseguitaDa: 'Elpidio Vendemia',
      ),
      TicketActivity(
        titolo: 'Invio mail al cliente - Sollecito richiesta accordo economico',
        descrizioneOperatore: 'Allegare proposta economica...',
        esito: 'Mail inviata',
        dataOra: DateTime(2026, 1, 8, 9, 15),
        eseguitaDa: 'Stefano Ianuale',
        hasAttachment: true,
      ),
    ];

    _activities['002248'] = [
      TicketActivity(
        titolo: 'Invio mail al cliente',
        descrizioneOperatore: 'Comunicazione stato intervento',
        esito: 'Mail inviata',
        dataOra: DateTime(2026, 5, 15, 10, 0),
        eseguitaDa: 'Stefano Ianuale',
        hasAttachment: true,
      ),
      TicketActivity(
        titolo: 'Verifica risoluzione problematica',
        descrizioneOperatore: 'Controllo remoto impianto',
        esito: 'Problematica non risolta',
        dataOra: DateTime(2026, 5, 28, 9, 0),
        eseguitaDa: 'SIEM',
      ),
    ];

    _history['001362'] = [
      TicketHistoryEntry(
        stato: 'DA LAVORARE',
        note: '',
        dallaData: DateTime(2022, 5, 3, 12, 54),
      ),
      TicketHistoryEntry(
        stato: 'IN LAVORAZIONE',
        note: 'Preso in carico da Stefano Ianuale',
        dallaData: DateTime(2022, 5, 3, 12, 56),
      ),
      TicketHistoryEntry(
        stato: 'DA LAVORARE',
        note: 'Riassegnato a COMPLIANCE',
        dallaData: DateTime(2025, 11, 19, 13, 15),
      ),
      TicketHistoryEntry(
        stato: 'IN LAVORAZIONE',
        note: 'Preso in carico da Stefano Ianuale',
        dallaData: DateTime(2025, 11, 19, 13, 16),
      ),
    ];
  }

  @override
  Future<List<Ticket>> getTickets({TicketSection? section}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (section == null) return List.unmodifiable(_tickets);
    return _tickets.where((t) => t.section == section).toList();
  }

  @override
  Future<Ticket?> getTicketById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TicketActivity>> getActivities(String ticketId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(
      _activities[ticketId] ??
          [
            TicketActivity(
              titolo: 'Apertura ticket',
              descrizioneOperatore: 'Ticket registrato nel sistema',
              esito: 'Creato',
              dataOra: DateTime.now(),
              eseguitaDa: 'Sistema',
            ),
          ],
    );
  }

  @override
  Future<List<TicketHistoryEntry>> getHistory(String ticketId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(
      _history[ticketId] ??
          [
            TicketHistoryEntry(
              stato: 'DA LAVORARE',
              note: 'Ticket creato',
              dallaData: DateTime.now(),
            ),
          ],
    );
  }

  @override
  Future<TicketTabCounts> getTabCounts() async {
    final processare =
        _tickets.where((t) => t.section == TicketSection.processare).length;
    final scadenza =
        _tickets.where((t) => t.section == TicketSection.inScadenza).length;
    final oe = _tickets
        .where(
          (t) =>
              t.section == TicketSection.offerteInAttesa ||
              t.section == TicketSection.offerteDaInviare,
        )
        .length;
    final interventi =
        _tickets.where((t) => t.section == TicketSection.interventi).length;
    return TicketTabCounts(
      tickets: processare + scadenza,
      ticketsOe: oe,
      ticketsInterventi: interventi,
      dashboard: 643,
    );
  }

  @override
  Future<void> createTicket({
    required String cliente,
    required String impianto,
    required TicketType tipologia,
    required String descrizione,
    String? noteInterne,
  }) async {
    final id = (_tickets.length + 1).toString().padLeft(6, '0');
    _tickets.insert(
      0,
      Ticket(
        id: id,
        createdAt: DateTime.now(),
        cliente: cliente,
        impianto: impianto,
        tipologia: tipologia,
        descrizione: descrizione,
        responsabile: 'Da assegnare',
        ultimaAttivita: DateTime.now(),
        section: TicketSection.processare,
      ),
    );
  }
}
