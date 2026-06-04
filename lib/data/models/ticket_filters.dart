import 'ticket.dart';

/// Filtri applicati alle liste ticket (home e gestione).
class TicketFilters {
  const TicketFilters({
    this.searchQuery = '',
    this.tipologia,
    this.responsabile,
    this.unitaAziendale,
    this.impianto,
    this.cliente,
    this.soloInScadenza = false,
    this.soloGuasti = false,
    this.periodoGiorni,
  });

  final String searchQuery;
  final TicketType? tipologia;
  final String? responsabile;
  final String? unitaAziendale;
  final String? impianto;
  final String? cliente;
  final bool soloInScadenza;
  final bool soloGuasti;

  /// `null` = tutti i periodi; altrimenti ultimi N giorni (da data creazione).
  final int? periodoGiorni;

  TicketFilters copyWith({
    String? searchQuery,
    TicketType? tipologia,
    bool clearTipologia = false,
    String? responsabile,
    bool clearResponsabile = false,
    String? unitaAziendale,
    bool clearUnita = false,
    String? impianto,
    bool clearImpianto = false,
    String? cliente,
    bool clearCliente = false,
    bool? soloInScadenza,
    bool? soloGuasti,
    int? periodoGiorni,
    bool clearPeriodo = false,
  }) {
    return TicketFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      tipologia: clearTipologia ? null : (tipologia ?? this.tipologia),
      responsabile:
          clearResponsabile ? null : (responsabile ?? this.responsabile),
      unitaAziendale: clearUnita ? null : (unitaAziendale ?? this.unitaAziendale),
      impianto: clearImpianto ? null : (impianto ?? this.impianto),
      cliente: clearCliente ? null : (cliente ?? this.cliente),
      soloInScadenza: soloInScadenza ?? this.soloInScadenza,
      soloGuasti: soloGuasti ?? this.soloGuasti,
      periodoGiorni: clearPeriodo ? null : (periodoGiorni ?? this.periodoGiorni),
    );
  }

  TicketFilters cleared() => const TicketFilters();

  int get activeCount {
    var n = 0;
    if (searchQuery.trim().isNotEmpty) n++;
    if (tipologia != null) n++;
    if (responsabile != null) n++;
    if (unitaAziendale != null) n++;
    if (impianto != null) n++;
    if (cliente != null) n++;
    if (soloInScadenza) n++;
    if (soloGuasti) n++;
    if (periodoGiorni != null) n++;
    return n;
  }

  bool get hasActive => activeCount > 0;
}
