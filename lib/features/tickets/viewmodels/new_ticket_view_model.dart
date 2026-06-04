import 'package:flutter/foundation.dart';

import '../../../data/models/ticket.dart';
import '../../../data/repositories/ticket_repository.dart';

class NewTicketViewModel extends ChangeNotifier {
  NewTicketViewModel(this._repository);

  final TicketRepository _repository;

  String cliente = '';
  String impianto = 'FTV00120';
  TicketType tipologia = TicketType.anomalia;
  String descrizione = '';
  String noteInterne = '';
  bool _saving = false;
  String? _error;
  bool _saved = false;

  bool get saving => _saving;
  String? get error => _error;
  bool get saved => _saved;

  static const impianti = [
    'FTV00120',
    'FTV00143',
    'FTV00260',
    'FTV00327',
  ];

  void updateCliente(String value) {
    cliente = value;
    notifyListeners();
  }

  void updateImpianto(String value) {
    impianto = value;
    notifyListeners();
  }

  void updateTipologia(TicketType value) {
    tipologia = value;
    notifyListeners();
  }

  void updateDescrizione(String value) {
    descrizione = value;
    notifyListeners();
  }

  void updateNoteInterne(String value) {
    noteInterne = value;
    notifyListeners();
  }

  Future<bool> save() async {
    if (cliente.trim().isEmpty || descrizione.trim().isEmpty) {
      _error = 'Compila cliente e descrizione';
      notifyListeners();
      return false;
    }
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createTicket(
        cliente: cliente.trim(),
        impianto: impianto,
        tipologia: tipologia,
        descrizione: descrizione.trim(),
        noteInterne: noteInterne.trim().isEmpty ? null : noteInterne.trim(),
      );
      _saved = true;
      return true;
    } catch (e) {
      _error = 'Errore durante il salvataggio';
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  void reset() {
    cliente = '';
    impianto = 'FTV00120';
    tipologia = TicketType.anomalia;
    descrizione = '';
    noteInterne = '';
    _saved = false;
    _error = null;
    notifyListeners();
  }
}
