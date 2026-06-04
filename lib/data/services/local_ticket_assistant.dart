import '../models/impianto.dart';
import '../models/ticket.dart';
import '../repositories/impianto_repository.dart';
import '../repositories/ticket_repository.dart';
import '../../core/utils/date_format.dart';
import 'ticket_context_builder.dart';

/// Fallback locale quando GPT non è disponibile (es. CORS su Web senza proxy).
class LocalTicketAssistant {
  LocalTicketAssistant(this._tickets, this._impianti);

  final TicketRepository _tickets;
  final ImpiantoRepository _impianti;
  List<Ticket>? _cache;
  Map<String, Impianto>? _impiantiByCodice;

  Future<String> reply(String question) async {
    _cache ??= await _tickets.getTickets();
    _impiantiByCodice ??= {
      for (final i in await _impianti.getAll()) i.codice: i,
    };
    final tickets = _cache!;
    final impianti = _impiantiByCodice!;
    final q = question.toLowerCase().trim();

    final idMatch = RegExp(r'\b(\d{6})\b').firstMatch(q);
    if (idMatch != null) {
      return _ticketDetail(tickets, impianti, idMatch.group(1)!);
    }

    if (q.contains('indirizz') ||
        q.contains('ubicaz') ||
        q.contains('dove') ||
        q.contains('sede') ||
        q.contains('localit')) {
      return _addressQuery(tickets, impianti, q);
    }

    if (q.contains('quanti') || q.contains('riepilogo') || q.contains('panoramica')) {
      return _summary(tickets);
    }
    if (q.contains('scaden') || q.contains('scadut')) {
      return _listSection(tickets, impianti, TicketSection.inScadenza, 'In scadenza/scaduti');
    }
    if (q.contains('guast')) {
      return _listByType(tickets, impianti, TicketType.guasto);
    }
    if (q.contains('intervent')) {
      return _listSection(tickets, impianti, TicketSection.interventi, 'Interventi');
    }
    if (q.contains('processare') || q.contains('da lavorare')) {
      return _listSection(tickets, impianti, TicketSection.processare, 'Da processare');
    }
    if (q.contains('offert') || q.contains('oe')) {
      final attesa =
          tickets.where((t) => t.section == TicketSection.offerteInAttesa);
      final inviare =
          tickets.where((t) => t.section == TicketSection.offerteDaInviare);
      return 'Offerte economiche:\n'
          '- In attesa cliente (${attesa.length}): ${attesa.map((t) => t.id).join(', ')}\n'
          '- Da inviare (${inviare.length}): ${inviare.map((t) => t.id).join(', ')}';
    }

    final byCliente = tickets
        .where((t) => q.length >= 3 && t.cliente.toLowerCase().contains(q))
        .toList();
    if (byCliente.isNotEmpty) {
      return 'Ticket per cliente corrispondente:\n'
          '${byCliente.map((t) => '• ${t.id} — ${t.descrizione} (${t.tipologiaLabel}) — ${_sede(t, impianti)}').join('\n')}';
    }

    return 'Posso aiutarti su: riepilogo ticket, ticket in scadenza, guasti, '
        'interventi, offerte economiche, indirizzi impianti, o dettaglio per ID (es. 000664). '
        'Riformula la domanda o configura OPENAI_API_KEY per risposte GPT complete.';
  }

  String _sede(Ticket t, Map<String, Impianto> impianti) =>
      TicketContextBuilder.formatSedeTicket(t.impianto, impianti[t.impianto]);

  String _addressQuery(
    List<Ticket> tickets,
    Map<String, Impianto> impianti,
    String q,
  ) {
    final byComune = impianti.values
        .where((i) => q.length >= 3 && i.comune.toLowerCase().contains(q))
        .toList();
    if (byComune.isNotEmpty) {
      return 'Impianti nel comune cercato:\n'
          '${byComune.map((i) => '• ${i.codice} — ${TicketContextBuilder.formatIndirizzoImpianto(i)}').join('\n')}';
    }

    final byCodice = impianti.values
        .where((i) => q.contains(i.codice.toLowerCase()))
        .toList();
    if (byCodice.isNotEmpty) {
      return byCodice
          .map(
            (i) =>
                '${i.codice}: ${TicketContextBuilder.formatIndirizzoImpianto(i)}',
          )
          .join('\n');
    }

    final open = tickets.take(8);
    return 'Indirizzi impianti con ticket aperti (esempio):\n'
        '${open.map((t) => '• ${t.id} ${t.impianto}: ${_sede(t, impianti)}').join('\n')}';
  }

  String _summary(List<Ticket> tickets) {
    return 'Riepilogo attuale:\n'
        '• Da processare: ${_count(tickets, TicketSection.processare)}\n'
        '• In scadenza: ${_count(tickets, TicketSection.inScadenza)}\n'
        '• Interventi: ${_count(tickets, TicketSection.interventi)}\n'
        '• In lavorazione: ${_count(tickets, TicketSection.inLavorazione)}\n'
        '• Guasti totali: ${tickets.where((t) => t.tipologia == TicketType.guasto).length}';
  }

  String _listSection(
    List<Ticket> tickets,
    Map<String, Impianto> impianti,
    TicketSection section,
    String label,
  ) {
    final list = tickets.where((t) => t.section == section).toList();
    if (list.isEmpty) return 'Nessun ticket in $label.';
    return '$label (${list.length}):\n'
        '${list.map((t) => '• ${t.id} — ${t.cliente} — ${_sede(t, impianti)} — ${t.descrizione}').join('\n')}';
  }

  String _listByType(
    List<Ticket> tickets,
    Map<String, Impianto> impianti,
    TicketType type,
  ) {
    final list = tickets.where((t) => t.tipologia == type).toList();
    if (list.isEmpty) return 'Nessun ticket di tipo ${type.name}.';
    return 'Ticket GUASTO (${list.length}):\n'
        '${list.map((t) => '• ${t.id} — ${t.impianto} — ${_sede(t, impianti)} — ${t.descrizione}').join('\n')}';
  }

  String _ticketDetail(
    List<Ticket> tickets,
    Map<String, Impianto> impianti,
    String id,
  ) {
    final padded = id.padLeft(6, '0');
    try {
      final t = tickets.firstWhere((x) => x.id == padded || x.id == id);
      final imp = impianti[t.impianto];
      final sede = imp != null
          ? TicketContextBuilder.formatIndirizzoImpianto(imp)
          : 'non in anagrafica';
      return 'Ticket #${t.id}\n'
          'Cliente: ${t.cliente}\n'
          'Impianto: ${t.impianto}\n'
          'Indirizzo impianto: $sede\n'
          'Tipologia: ${t.tipologiaLabel}\n'
          'Coda: ${t.section.name}\n'
          'Responsabile: ${t.responsabile}\n'
          'Descrizione: ${t.descrizione}\n'
          'Ultima attività: ${formatDateTime(t.ultimaAttivita)}'
          '${t.dataScadenza != null ? '\nScadenza: ${formatDate(t.dataScadenza!)}' : ''}';
    } catch (_) {
      return 'Ticket $id non trovato nell\'anagrafica demo.';
    }
  }

  int _count(List<Ticket> tickets, TicketSection section) =>
      tickets.where((t) => t.section == section).length;
}
