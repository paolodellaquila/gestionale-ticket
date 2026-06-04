import '../models/impianto.dart';
import '../models/ticket.dart';
import '../repositories/impianto_repository.dart';
import '../repositories/ticket_repository.dart';
import '../../core/utils/date_format.dart';

/// Costruisce il contesto ticket da inviare a GPT (o all'assistente locale).
class TicketContextBuilder {
  TicketContextBuilder(this._tickets, this._impianti);

  final TicketRepository _tickets;
  final ImpiantoRepository _impianti;

  Future<String> build() async {
    final tickets = await _tickets.getTickets();
    final counts = await _tickets.getTabCounts();
    final impiantiList = await _impianti.getAll();
    final byCodice = {for (final i in impiantiList) i.codice: i};

    final buffer = StringBuffer()
      ..writeln('RIEPILOGO TICKET SIEM (${tickets.length} totali in anagrafica demo)')
      ..writeln('- Da processare: ${_count(tickets, TicketSection.processare)}')
      ..writeln('- In scadenza/scaduti: ${_count(tickets, TicketSection.inScadenza)}')
      ..writeln('- Offerte in attesa cliente: ${_count(tickets, TicketSection.offerteInAttesa)}')
      ..writeln('- Offerte da inviare: ${_count(tickets, TicketSection.offerteDaInviare)}')
      ..writeln('- Interventi: ${_count(tickets, TicketSection.interventi)}')
      ..writeln('- In lavorazione: ${_count(tickets, TicketSection.inLavorazione)}')
      ..writeln('- Badge dashboard: ${counts.dashboard}')
      ..writeln()
      ..writeln('ANAGRAFICA IMPIANTI (${impiantiList.length}):');

    for (final i in impiantiList) {
      buffer.writeln(_impiantoLine(i));
    }

    buffer
      ..writeln()
      ..writeln('ELENCO TICKET (max 40):');

    final sorted = List<Ticket>.from(tickets)
      ..sort((a, b) => b.ultimaAttivita.compareTo(a.ultimaAttivita));

    for (final t in sorted.take(40)) {
      buffer.writeln(_line(t, byCodice[t.impianto]));
    }

    return buffer.toString();
  }

  int _count(List<Ticket> tickets, TicketSection section) =>
      tickets.where((t) => t.section == section).length;

  static String formatIndirizzoImpianto(Impianto i) =>
      '${i.indirizzo}, ${i.comune} (${i.provincia})';

  static String formatSedeTicket(String codiceImpianto, Impianto? impianto) {
    if (impianto == null) {
      return 'sede: codice $codiceImpianto (indirizzo non in anagrafica)';
    }
    final gps =
        'GPS ${impianto.latitudine.toStringAsFixed(4)}, ${impianto.longitudine.toStringAsFixed(4)}';
    return 'sede: ${formatIndirizzoImpianto(impianto)} | $gps';
  }

  String _impiantoLine(Impianto i) {
    final potenza =
        i.potenzaKwp != null ? ' | ${i.potenzaKwp!.toStringAsFixed(0)} kWp' : '';
    final gps =
        'GPS ${i.latitudine.toStringAsFixed(4)}, ${i.longitudine.toStringAsFixed(4)}';
    return '${i.codice} | ${i.cliente} | ${formatIndirizzoImpianto(i)} | $gps$potenza';
  }

  String _line(Ticket t, Impianto? impianto) {
    final scadenza = t.dataScadenza != null
        ? ' | scadenza ${formatDate(t.dataScadenza!)}'
        : '';
    final unita = t.unitaAziendale != null ? ' | ${t.unitaAziendale}' : '';
    final sede = formatSedeTicket(t.impianto, impianto);
    return 'ID ${t.id} | ${t.tipologiaLabel} | ${t.section.name} | '
        '${t.cliente} | impianto ${t.impianto} | $sede | ${t.responsabile}$unita | '
        '${t.descrizione} | ultima att. ${formatDateTime(t.ultimaAttivita)}$scadenza';
  }
}
