enum TicketType { guasto, anomalia, amministrativo }

enum TicketSection {
  processare,
  inScadenza,
  offerteInAttesa,
  offerteDaInviare,
  interventi,
  inLavorazione,
}

class Ticket {
  const Ticket({
    required this.id,
    required this.createdAt,
    required this.cliente,
    required this.impianto,
    required this.tipologia,
    required this.descrizione,
    required this.responsabile,
    required this.ultimaAttivita,
    this.unitaAziendale,
    this.dataScadenza,
    this.section = TicketSection.processare,
  });

  final String id;
  final DateTime createdAt;
  final String cliente;
  final String impianto;
  final TicketType tipologia;
  final String descrizione;
  final String responsabile;
  final DateTime ultimaAttivita;
  final String? unitaAziendale;
  final DateTime? dataScadenza;
  final TicketSection section;

  String get tipologiaLabel {
    switch (tipologia) {
      case TicketType.guasto:
        return 'GUASTO';
      case TicketType.anomalia:
        return 'ANOMALIA';
      case TicketType.amministrativo:
        return 'AMMINISTRATIVO';
    }
  }

  bool get isExpired =>
      dataScadenza != null && dataScadenza!.isBefore(DateTime.now());
}

class TicketActivity {
  const TicketActivity({
    required this.titolo,
    required this.descrizioneOperatore,
    required this.esito,
    required this.dataOra,
    required this.eseguitaDa,
    this.hasAttachment = false,
  });

  final String titolo;
  final String descrizioneOperatore;
  final String esito;
  final DateTime dataOra;
  final String eseguitaDa;
  final bool hasAttachment;
}

class TicketHistoryEntry {
  const TicketHistoryEntry({
    required this.stato,
    required this.note,
    required this.dallaData,
  });

  final String stato;
  final String note;
  final DateTime dallaData;
}

class TicketTabCounts {
  const TicketTabCounts({
    required this.tickets,
    required this.ticketsOe,
    required this.ticketsInterventi,
    required this.dashboard,
  });

  final int tickets;
  final int ticketsOe;
  final int ticketsInterventi;
  final int dashboard;
}
