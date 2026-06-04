import 'package:latlong2/latlong.dart';

/// Anagrafica impianto fotovoltaico con coordinate GPS.
class Impianto {
  const Impianto({
    required this.codice,
    required this.cliente,
    required this.indirizzo,
    required this.comune,
    required this.provincia,
    required this.latitudine,
    required this.longitudine,
    this.potenzaKwp,
    this.regione,
  });

  final String codice;
  final String cliente;
  final String indirizzo;
  final String comune;
  final String provincia;
  final double latitudine;
  final double longitudine;
  final double? potenzaKwp;
  final String? regione;

  LatLng get coordinate => LatLng(latitudine, longitudine);

  String get localita => '$comune ($provincia)';
}
