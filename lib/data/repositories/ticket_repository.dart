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
      // —— Da processare ——
      Ticket(
        id: '000666',
        createdAt: DateTime(2026, 6, 2, 7, 45),
        cliente: 'GELARTIGIAN S.R.L.',
        impianto: 'FTV00327',
        tipologia: TicketType.guasto,
        descrizione: 'PERDITA ISOLAMENTO STRINGA 12 — ALLARME DC',
        responsabile: 'Da assegnare',
        ultimaAttivita: DateTime(2026, 6, 2, 7, 45),
        section: TicketSection.processare,
      ),
      Ticket(
        id: '000667',
        createdAt: DateTime(2026, 6, 1, 16, 30),
        cliente: 'E.P. S.R.L.',
        impianto: 'FTV00143',
        tipologia: TicketType.anomalia,
        descrizione: 'SCOSTAMENTO PRODUZIONE ATTESA > 15%',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 6, 3, 9, 10),
        section: TicketSection.processare,
      ),
      Ticket(
        id: '000668',
        createdAt: DateTime(2026, 5, 28, 11, 20),
        cliente: 'GIOTTO S.C.A.R.A.',
        impianto: 'FTV00120',
        tipologia: TicketType.amministrativo,
        descrizione: 'RICHIESTA DUPLICATO FATTURA MANUTENZIONE',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 6, 1, 14, 0),
        unitaAziendale: 'COMPLIANCE',
        section: TicketSection.processare,
      ),
      Ticket(
        id: '000669',
        createdAt: DateTime(2026, 6, 3, 8, 0),
        cliente: 'BIOMED S.R.L.',
        impianto: 'FTV00301',
        tipologia: TicketType.guasto,
        descrizione: 'COMBINATORE AC IN ERRORE — IMPIANTO FERMO',
        responsabile: 'Mario Rossi',
        ultimaAttivita: DateTime(2026, 6, 3, 10, 25),
        section: TicketSection.processare,
      ),
      Ticket(
        id: '000670',
        createdAt: DateTime(2026, 5, 27, 13, 0),
        cliente: 'SOLAR TECH S.P.A.',
        impianto: 'FTV00089',
        tipologia: TicketType.anomalia,
        descrizione: 'AGGIORNAMENTO FIRMWARE INVERTER SUNGROW',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 5, 30, 17, 40),
        section: TicketSection.processare,
      ),
      // —— In scadenza ——
      Ticket(
        id: '000452',
        createdAt: DateTime(2026, 1, 10, 9, 0),
        cliente: 'FARMASOL S.R.L.',
        impianto: 'FTV00187',
        tipologia: TicketType.anomalia,
        descrizione: 'REVISIONE ANNUALE IMPIANTO',
        responsabile: 'Mario Rossi',
        ultimaAttivita: DateTime(2026, 5, 15, 11, 30),
        dataScadenza: DateTime(2026, 6, 5),
        section: TicketSection.inScadenza,
      ),
      Ticket(
        id: '000453',
        createdAt: DateTime(2025, 10, 5, 8, 30),
        cliente: 'NEW DIMENSION PLASTIC S.R.L.',
        impianto: 'FTV00210',
        tipologia: TicketType.guasto,
        descrizione: 'SOSTITUZIONE FUSIBILI DC BOX',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 4, 22, 9, 0),
        dataScadenza: DateTime(2026, 6, 1),
        section: TicketSection.inScadenza,
      ),
      Ticket(
        id: '000454',
        createdAt: DateTime(2026, 2, 20, 14, 0),
        cliente: 'GEOS ENVIRONMENT S.R.L.',
        impianto: 'FTV00260',
        tipologia: TicketType.amministrativo,
        descrizione: 'RINNOVO POLIZZA ALL RISK',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 5, 10, 16, 0),
        dataScadenza: DateTime(2026, 5, 28),
        unitaAziendale: 'COMPLIANCE',
        section: TicketSection.inScadenza,
      ),
      Ticket(
        id: '000455',
        createdAt: DateTime(2025, 9, 12, 10, 0),
        cliente: 'GELARTIGIAN S.R.L.',
        impianto: 'FTV00327',
        tipologia: TicketType.anomalia,
        descrizione: 'PULIZIA MODULI FTV — PROGRAMMATA',
        responsabile: 'Mario Rossi',
        ultimaAttivita: DateTime(2026, 3, 18, 8, 45),
        dataScadenza: DateTime(2026, 6, 10),
        section: TicketSection.inScadenza,
      ),
      // —— Offerte economiche ——
      Ticket(
        id: '001363',
        createdAt: DateTime(2024, 8, 15, 9, 0),
        cliente: 'SOLAR TECH S.P.A.',
        impianto: 'FTV00089',
        tipologia: TicketType.anomalia,
        descrizione: 'Attesa firma cliente OE sostituzione inverter',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 5, 22, 11, 0),
        section: TicketSection.offerteInAttesa,
      ),
      Ticket(
        id: '001364',
        createdAt: DateTime(2025, 3, 8, 10, 30),
        cliente: 'ENERGIA VERDE S.R.L.',
        impianto: 'FTV00110',
        tipologia: TicketType.anomalia,
        descrizione: 'In attesa approvazione preventivo cabina MT',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 4, 30, 15, 20),
        section: TicketSection.offerteInAttesa,
      ),
      Ticket(
        id: '001365',
        createdAt: DateTime(2023, 11, 2, 8, 0),
        cliente: 'NEW DIMENSION PLASTIC S.R.L.',
        impianto: 'FTV00210',
        tipologia: TicketType.anomalia,
        descrizione: 'Cliente richiede revisione importi OE 2024',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 2, 14, 9, 45),
        section: TicketSection.offerteInAttesa,
      ),
      Ticket(
        id: '001501',
        createdAt: DateTime(2026, 5, 15, 12, 0),
        cliente: 'GELARTIGIAN S.R.L.',
        impianto: 'FTV00327',
        tipologia: TicketType.anomalia,
        descrizione: 'PREVENTIVO SOSTITUZIONE TRASFORMATORE MT',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 6, 2, 10, 0),
        section: TicketSection.offerteDaInviare,
      ),
      Ticket(
        id: '001502',
        createdAt: DateTime(2026, 5, 18, 9, 30),
        cliente: 'GIOTTO S.C.A.R.A.',
        impianto: 'FTV00120',
        tipologia: TicketType.anomalia,
        descrizione: 'OE LAVORI STRAORDINARI CABINA DI CONSEGNA',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 6, 1, 8, 15),
        section: TicketSection.offerteDaInviare,
      ),
      Ticket(
        id: '001503',
        createdAt: DateTime(2026, 4, 8, 14, 0),
        cliente: 'FARMASOL S.R.L.',
        impianto: 'FTV00187',
        tipologia: TicketType.anomalia,
        descrizione: 'OFFERTA RIFACIMENTO IMPIANTO DI TERRA',
        responsabile: 'Mario Rossi',
        ultimaAttivita: DateTime(2026, 5, 29, 13, 50),
        section: TicketSection.offerteDaInviare,
      ),
      // —— Interventi ——
      Ticket(
        id: '002249',
        createdAt: DateTime(2026, 3, 22, 7, 0),
        cliente: 'NEW DIMENSION PLASTIC S.R.L.',
        impianto: 'FTV00210',
        tipologia: TicketType.guasto,
        descrizione: 'INTERVENTO ON SITE — RIPRISTINO PRODUZIONE',
        responsabile: 'Mario Rossi',
        ultimaAttivita: DateTime(2026, 6, 2, 18, 0),
        unitaAziendale: 'SERVICE',
        section: TicketSection.interventi,
      ),
      Ticket(
        id: '002250',
        createdAt: DateTime(2026, 4, 5, 11, 30),
        cliente: 'FARMASOL S.R.L.',
        impianto: 'FTV00187',
        tipologia: TicketType.guasto,
        descrizione: 'SOSTITUZIONE MODULO DANNEGGIATO DA GRANDINE',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 6, 3, 7, 30),
        section: TicketSection.interventi,
      ),
      Ticket(
        id: '002251',
        createdAt: DateTime(2026, 2, 28, 9, 0),
        cliente: 'ENERGIA VERDE S.R.L.',
        impianto: 'FTV00110',
        tipologia: TicketType.anomalia,
        descrizione: 'TARATURA CONTATORE DI SCAMBIO',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 5, 27, 14, 15),
        section: TicketSection.interventi,
      ),
      Ticket(
        id: '002252',
        createdAt: DateTime(2026, 5, 10, 8, 45),
        cliente: 'BIOMED S.R.L.',
        impianto: 'FTV00301',
        tipologia: TicketType.guasto,
        descrizione: 'VERIFICA STRINGHE BASSA PRODUZIONE',
        responsabile: 'Mario Rossi',
        ultimaAttivita: DateTime(2026, 6, 1, 11, 40),
        section: TicketSection.interventi,
      ),
      Ticket(
        id: '002253',
        createdAt: DateTime(2026, 1, 18, 10, 0),
        cliente: 'SOLAR TECH S.P.A.',
        impianto: 'FTV00089',
        tipologia: TicketType.guasto,
        descrizione: 'RIPARAZIONE TRACKER ASSE 4',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 5, 24, 16, 30),
        unitaAziendale: 'SERVICE',
        section: TicketSection.interventi,
      ),
      Ticket(
        id: '002254',
        createdAt: DateTime(2026, 5, 5, 13, 20),
        cliente: 'E.P. S.R.L.',
        impianto: 'FTV00143',
        tipologia: TicketType.anomalia,
        descrizione: 'ALLINEAMENTO PARAMETRI MONITORAGGIO',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 6, 2, 12, 0),
        section: TicketSection.interventi,
      ),
      // —— In lavorazione ——
      Ticket(
        id: '001201',
        createdAt: DateTime(2026, 4, 2, 9, 0),
        cliente: 'E.P. S.R.L.',
        impianto: 'FTV00143',
        tipologia: TicketType.guasto,
        descrizione: 'DIAGNOSI INVERTER 2 — COMUNICAZIONE RS485',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 6, 3, 8, 50),
        unitaAziendale: 'SERVICE',
        section: TicketSection.inLavorazione,
      ),
      Ticket(
        id: '001202',
        createdAt: DateTime(2026, 3, 15, 14, 30),
        cliente: 'GEOS ENVIRONMENT S.R.L.',
        impianto: 'FTV00260',
        tipologia: TicketType.anomalia,
        descrizione: 'INTEGRAZIONE TELELETTURA GSE',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 6, 2, 15, 10),
        section: TicketSection.inLavorazione,
      ),
      Ticket(
        id: '001203',
        createdAt: DateTime(2026, 2, 8, 8, 0),
        cliente: 'SOLAR TECH S.P.A.',
        impianto: 'FTV00089',
        tipologia: TicketType.amministrativo,
        descrizione: 'AGGIORNAMENTO ANAGRAFICA CLIENTE',
        responsabile: 'Mario Rossi',
        ultimaAttivita: DateTime(2026, 5, 31, 10, 20),
        unitaAziendale: 'COMPLIANCE',
        section: TicketSection.inLavorazione,
      ),
      Ticket(
        id: '001204',
        createdAt: DateTime(2026, 5, 20, 11, 0),
        cliente: 'ENERGIA VERDE S.R.L.',
        impianto: 'FTV00110',
        tipologia: TicketType.guasto,
        descrizione: 'RESET ALLARME SOVRATENSIONE AC',
        responsabile: 'Stefano Ianuale',
        ultimaAttivita: DateTime(2026, 6, 3, 9, 35),
        unitaAziendale: 'SERVICE',
        section: TicketSection.inLavorazione,
      ),
      Ticket(
        id: '001205',
        createdAt: DateTime(2026, 4, 28, 16, 0),
        cliente: 'BIOMED S.R.L.',
        impianto: 'FTV00301',
        tipologia: TicketType.anomalia,
        descrizione: 'REPORT MENSILE PRODUZIONE — VALIDAZIONE',
        responsabile: 'Elpidio Vendemia',
        ultimaAttivita: DateTime(2026, 6, 1, 17, 0),
        section: TicketSection.inLavorazione,
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

    _activities['000666'] = [
      TicketActivity(
        titolo: 'Apertura ticket da allarme SCADA',
        descrizioneOperatore: 'Allarme isolamento stringa 12 rilevato in notturna',
        esito: 'Ticket creato',
        dataOra: DateTime(2026, 6, 2, 7, 45),
        eseguitaDa: 'Sistema SCADA',
      ),
      TicketActivity(
        titolo: 'Assegnazione priorità alta',
        descrizioneOperatore: 'Guasto con impianto in derating',
        esito: 'In attesa assegnazione operatore',
        dataOra: DateTime(2026, 6, 2, 8, 10),
        eseguitaDa: 'Stefano Ianuale',
      ),
    ];

    _activities['001363'] = [
      TicketActivity(
        titolo: 'Invio preventivo aggiornato al cliente',
        descrizioneOperatore: 'Revisione importi a seguito sopralluogo',
        esito: 'Mail inviata',
        dataOra: DateTime(2026, 5, 12, 10, 30),
        eseguitaDa: 'Elpidio Vendemia',
        hasAttachment: true,
      ),
      TicketActivity(
        titolo: 'Sollecito telefonico cliente',
        descrizioneOperatore: 'Nessuna risposta — lasciato messaggio',
        esito: 'Da richiamare',
        dataOra: DateTime(2026, 5, 22, 11, 0),
        eseguitaDa: 'Elpidio Vendemia',
      ),
    ];

    _activities['002249'] = [
      TicketActivity(
        titolo: 'Intervento programmato in campo',
        descrizioneOperatore: 'Squadra SERVICE in partenza ore 07:00',
        esito: 'In corso',
        dataOra: DateTime(2026, 6, 2, 6, 30),
        eseguitaDa: 'Mario Rossi',
      ),
      TicketActivity(
        titolo: 'Ripristino parziale produzione',
        descrizioneOperatore: 'Sostituito fusibile DC box 3',
        esito: 'Problematica non risolta',
        dataOra: DateTime(2026, 6, 2, 18, 0),
        eseguitaDa: 'Mario Rossi',
      ),
    ];

    _history['000666'] = [
      TicketHistoryEntry(
        stato: 'DA LAVORARE',
        note: 'Ticket generato da allarme',
        dallaData: DateTime(2026, 6, 2, 7, 45),
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
