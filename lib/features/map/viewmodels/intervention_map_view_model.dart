import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/intervention_area.dart';
import '../../../data/models/ticket.dart';
import '../../../data/repositories/intervention_map_repository.dart';

class InterventionMapViewModel extends ChangeNotifier {
  InterventionMapViewModel(this._repository);

  final InterventionMapRepository _repository;

  bool _loading = true;
  String? _error;
  List<InterventionArea> _areas = [];
  InterventionArea? _selected;
  bool _showGuasto = true;
  bool _showAnomalia = true;
  bool _showAmministrativo = true;
  bool _onlyInterventi = false;

  bool get loading => _loading;
  String? get error => _error;
  List<InterventionArea> get areas => _filteredAreas;
  InterventionArea? get selected => _selected;
  bool get showGuasto => _showGuasto;
  bool get showAnomalia => _showAnomalia;
  bool get showAmministrativo => _showAmministrativo;
  bool get onlyInterventi => _onlyInterventi;

  List<InterventionArea> get _filteredAreas {
    return _areas.where((a) {
      if (_onlyInterventi && !a.isIntervento) return false;
      return switch (a.dominantType) {
        TicketType.guasto => _showGuasto,
        TicketType.anomalia => _showAnomalia,
        TicketType.amministrativo => _showAmministrativo,
      };
    }).toList();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _areas = await _repository.getInterventionAreas();
      if (_selected != null &&
          !_filteredAreas.any((a) => a.impianto.codice == _selected!.impianto.codice)) {
        _selected = null;
      }
    } catch (e) {
      _error = 'Impossibile caricare le aree di intervento';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void selectArea(InterventionArea? area) {
    _selected = area;
    notifyListeners();
  }

  void toggleGuasto(bool value) {
    _showGuasto = value;
    notifyListeners();
  }

  void toggleAnomalia(bool value) {
    _showAnomalia = value;
    notifyListeners();
  }

  void toggleAmministrativo(bool value) {
    _showAmministrativo = value;
    notifyListeners();
  }

  void toggleOnlyInterventi(bool value) {
    _onlyInterventi = value;
    notifyListeners();
  }

  LatLng? get center {
    if (_filteredAreas.isEmpty) return const LatLng(40.72, 14.85);
    final lat =
        _filteredAreas.map((a) => a.impianto.latitudine).reduce((a, b) => a + b) /
            _filteredAreas.length;
    final lng =
        _filteredAreas.map((a) => a.impianto.longitudine).reduce((a, b) => a + b) /
            _filteredAreas.length;
    return LatLng(lat, lng);
  }

  List<LatLng> get visiblePoints =>
      _filteredAreas.map((a) => a.impianto.coordinate).toList();
}
