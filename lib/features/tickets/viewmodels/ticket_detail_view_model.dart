import 'package:flutter/foundation.dart';

import '../../../data/models/ticket.dart';
import '../../../data/repositories/ticket_repository.dart';

enum TicketDetailTab { attivita, documenti }

class TicketDetailViewModel extends ChangeNotifier {
  TicketDetailViewModel(this._repository, this.ticketId);

  final TicketRepository _repository;
  final String ticketId;

  bool _loading = true;
  Ticket? ticket;
  List<TicketActivity> activities = [];
  List<TicketHistoryEntry> history = [];
  TicketDetailTab _tab = TicketDetailTab.attivita;

  bool get loading => _loading;
  TicketDetailTab get tab => _tab;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    ticket = await _repository.getTicketById(ticketId);
    activities = await _repository.getActivities(ticketId);
    history = await _repository.getHistory(ticketId);
    _loading = false;
    notifyListeners();
  }

  void setTab(TicketDetailTab tab) {
    _tab = tab;
    notifyListeners();
  }

  Future<void> loadHistory() async {
    history = await _repository.getHistory(ticketId);
    notifyListeners();
  }
}
