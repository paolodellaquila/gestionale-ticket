import 'package:flutter/foundation.dart';

import '../../../data/models/ticket.dart';
import '../../../data/repositories/ticket_repository.dart';

enum TicketsMainTab { tickets, ticketsOe, ticketsInterventi }

enum GestioneSubTab { daLavorare, inLavorazione, chiusi }

class TicketsListViewModel extends ChangeNotifier {
  TicketsListViewModel(this._repository);

  final TicketRepository _repository;

  bool _loading = true;
  String _searchQuery = '';
  TicketType? _tipologiaFilter;
  TicketsMainTab _mainTab = TicketsMainTab.tickets;
  GestioneSubTab _gestioneTab = GestioneSubTab.inLavorazione;
  int _currentPage = 0;
  static const int pageSize = 15;

  TicketTabCounts? counts;
  List<Ticket> _allTickets = [];

  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  TicketType? get tipologiaFilter => _tipologiaFilter;
  TicketsMainTab get mainTab => _mainTab;
  GestioneSubTab get gestioneTab => _gestioneTab;
  int get currentPage => _currentPage;

  List<Ticket> get processareTickets => _filter(
    _allTickets.where((t) => t.section == TicketSection.processare),
  );

  List<Ticket> get scadenzaTickets => _filter(
    _allTickets.where((t) => t.section == TicketSection.inScadenza),
  );

  List<Ticket> get offerteInAttesa => _filter(
    _allTickets.where((t) => t.section == TicketSection.offerteInAttesa),
  );

  List<Ticket> get offerteDaInviare => _filter(
    _allTickets.where((t) => t.section == TicketSection.offerteDaInviare),
  );

  List<Ticket> get interventiTickets => _filter(
    _allTickets.where((t) => t.section == TicketSection.interventi),
  );

  List<Ticket> get gestioneTickets {
    final filtered = _filter(_allTickets.where((t) {
      switch (_gestioneTab) {
        case GestioneSubTab.daLavorare:
          return t.section == TicketSection.processare;
        case GestioneSubTab.inLavorazione:
          return t.section == TicketSection.inLavorazione;
        case GestioneSubTab.chiusi:
          return false;
      }
    }));
    final start = _currentPage * pageSize;
    if (start >= filtered.length) return [];
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get gestioneTotalPages {
    final total = _filter(_allTickets.where((t) {
      switch (_gestioneTab) {
        case GestioneSubTab.daLavorare:
          return t.section == TicketSection.processare;
        case GestioneSubTab.inLavorazione:
          return t.section == TicketSection.inLavorazione;
        case GestioneSubTab.chiusi:
          return false;
      }
    })).length;
    return total == 0 ? 1 : (total / pageSize).ceil();
  }

  int get gestioneTotalCount {
    return _filter(_allTickets.where((t) {
      switch (_gestioneTab) {
        case GestioneSubTab.daLavorare:
          return t.section == TicketSection.processare;
        case GestioneSubTab.inLavorazione:
          return t.section == TicketSection.inLavorazione;
        case GestioneSubTab.chiusi:
          return false;
      }
    })).length;
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    counts = await _repository.getTabCounts();
    _allTickets = await _repository.getTickets();
    _loading = false;
    notifyListeners();
  }

  void setMainTab(TicketsMainTab tab) {
    _mainTab = tab;
    notifyListeners();
  }

  void setGestioneTab(GestioneSubTab tab) {
    _gestioneTab = tab;
    _currentPage = 0;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 0;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _currentPage = 0;
    notifyListeners();
  }

  void setTipologiaFilter(TicketType? type) {
    _tipologiaFilter = type;
    _currentPage = 0;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < gestioneTotalPages - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void firstPage() {
    _currentPage = 0;
    notifyListeners();
  }

  void lastPage() {
    _currentPage = gestioneTotalPages - 1;
    notifyListeners();
  }

  List<Ticket> _filter(Iterable<Ticket> items) {
    var list = items.toList();
    if (_tipologiaFilter != null) {
      list = list.where((t) => t.tipologia == _tipologiaFilter).toList();
    }
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where(
          (t) =>
              t.id.contains(q) ||
              t.cliente.toLowerCase().contains(q) ||
              t.impianto.toLowerCase().contains(q) ||
              t.descrizione.toLowerCase().contains(q) ||
              t.responsabile.toLowerCase().contains(q),
        )
        .toList();
  }
}
