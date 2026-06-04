import 'package:flutter/foundation.dart';

import '../../../data/models/ticket.dart';
import '../../../data/models/ticket_filters.dart';
import '../../../data/repositories/ticket_repository.dart';

enum TicketsMainTab { tickets, ticketsOe, ticketsInterventi }

enum GestioneSubTab { daLavorare, inLavorazione, chiusi }

class TicketsListViewModel extends ChangeNotifier {
  TicketsListViewModel(this._repository);

  final TicketRepository _repository;

  bool _loading = true;
  TicketFilters _filters = const TicketFilters();
  TicketsMainTab _mainTab = TicketsMainTab.tickets;
  GestioneSubTab _gestioneTab = GestioneSubTab.inLavorazione;
  int _currentPage = 0;
  static const int pageSize = 15;

  TicketTabCounts? counts;
  List<Ticket> _allTickets = [];

  bool get loading => _loading;
  TicketFilters get filters => _filters;
  String get searchQuery => _filters.searchQuery;
  TicketType? get tipologiaFilter => _filters.tipologia;
  TicketsMainTab get mainTab => _mainTab;
  GestioneSubTab get gestioneTab => _gestioneTab;
  int get currentPage => _currentPage;
  int get activeFilterCount => _filters.activeCount;
  bool get hasActiveFilters => _filters.hasActive;

  List<String> get clientiOptions => _uniqueSorted((t) => t.cliente);
  List<String> get impiantiOptions => _uniqueSorted((t) => t.impianto);
  List<String> get responsabiliOptions => _uniqueSorted((t) => t.responsabile);
  List<String> get unitaOptions => _uniqueSorted(
        (t) => t.unitaAziendale ?? '',
      ).where((s) => s.isNotEmpty).toList();

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

  int get visibleCountCurrentTab => switch (_mainTab) {
        TicketsMainTab.tickets =>
          processareTickets.length + scadenzaTickets.length,
        TicketsMainTab.ticketsOe =>
          offerteInAttesa.length + offerteDaInviare.length,
        TicketsMainTab.ticketsInterventi => interventiTickets.length,
      };

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

  void updateFilters(TicketFilters filters) {
    _filters = filters;
    _currentPage = 0;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    updateFilters(_filters.copyWith(searchQuery: query));
  }

  void clearSearch() {
    updateFilters(_filters.copyWith(searchQuery: ''));
  }

  void setTipologiaFilter(TicketType? type) {
    updateFilters(
      type == null
          ? _filters.copyWith(clearTipologia: true)
          : _filters.copyWith(tipologia: type),
    );
  }

  void clearAllFilters() {
    _filters = const TicketFilters();
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

  List<String> _uniqueSorted(String Function(Ticket) pick) {
    return _allTickets.map(pick).toSet().toList()..sort();
  }

  List<Ticket> _filter(Iterable<Ticket> items) {
    var list = items.toList();
    final f = _filters;

    if (f.tipologia != null) {
      list = list.where((t) => t.tipologia == f.tipologia).toList();
    }
    if (f.responsabile != null) {
      list = list.where((t) => t.responsabile == f.responsabile).toList();
    }
    if (f.unitaAziendale != null) {
      list =
          list.where((t) => t.unitaAziendale == f.unitaAziendale).toList();
    }
    if (f.impianto != null) {
      list = list.where((t) => t.impianto == f.impianto).toList();
    }
    if (f.cliente != null) {
      list = list.where((t) => t.cliente == f.cliente).toList();
    }
    if (f.soloInScadenza) {
      list = list
          .where(
            (t) =>
                t.section == TicketSection.inScadenza || t.isExpired,
          )
          .toList();
    }
    if (f.soloGuasti) {
      list = list.where((t) => t.tipologia == TicketType.guasto).toList();
    }
    if (f.periodoGiorni != null) {
      final cutoff = DateTime.now().subtract(Duration(days: f.periodoGiorni!));
      list = list.where((t) => t.createdAt.isAfter(cutoff)).toList();
    }
    if (f.searchQuery.trim().isNotEmpty) {
      final q = f.searchQuery.toLowerCase().trim();
      list = list
          .where(
            (t) =>
                t.id.contains(q) ||
                t.cliente.toLowerCase().contains(q) ||
                t.impianto.toLowerCase().contains(q) ||
                t.descrizione.toLowerCase().contains(q) ||
                t.responsabile.toLowerCase().contains(q) ||
                (t.unitaAziendale?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    return list;
  }
}
