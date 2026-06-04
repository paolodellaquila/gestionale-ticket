import '../models/impianto.dart';

abstract class ImpiantoRepository {
  Future<List<Impianto>> getAll();
  Future<Impianto?> getByCodice(String codice);
}

class MockImpiantoRepository implements ImpiantoRepository {
  MockImpiantoRepository() {
    _seed();
  }

  final List<Impianto> _impianti = [];

  void _seed() {
    _impianti.addAll([
      const Impianto(
        codice: 'FTV00327',
        cliente: 'GELARTIGIAN S.R.L.',
        indirizzo: 'Zona Ind.le ASI, lotto 12',
        comune: 'Salerno',
        provincia: 'SA',
        regione: 'Campania',
        latitudine: 40.6822,
        longitudine: 14.7681,
        potenzaKwp: 420,
      ),
      const Impianto(
        codice: 'FTV00143',
        cliente: 'E.P. S.R.L.',
        indirizzo: 'Via delle Energie 8',
        comune: 'Battipaglia',
        provincia: 'SA',
        regione: 'Campania',
        latitudine: 40.6103,
        longitudine: 14.9847,
        potenzaKwp: 990,
      ),
      const Impianto(
        codice: 'FTV00260',
        cliente: 'GEOS ENVIRONMENT S.R.L.',
        indirizzo: 'Contrada Macchia 3',
        comune: 'Eboli',
        provincia: 'SA',
        regione: 'Campania',
        latitudine: 40.6148,
        longitudine: 15.0582,
        potenzaKwp: 750,
      ),
      const Impianto(
        codice: 'FTV00187',
        cliente: 'FARMASOL S.R.L.',
        indirizzo: 'SS18 km 42',
        comune: 'Pontecagnano',
        provincia: 'SA',
        regione: 'Campania',
        latitudine: 40.6511,
        longitudine: 14.8934,
        potenzaKwp: 600,
      ),
      const Impianto(
        codice: 'FTV00120',
        cliente: 'GIOTTO S.C.A.R.A.',
        indirizzo: 'Via Appia 220',
        comune: 'Caserta',
        provincia: 'CE',
        regione: 'Campania',
        latitudine: 41.0732,
        longitudine: 14.3329,
        potenzaKwp: 500,
      ),
      const Impianto(
        codice: 'FTV00210',
        cliente: 'NEW DIMENSION PLASTIC S.R.L.',
        indirizzo: 'Zona PIP lotto 7',
        comune: 'Nocera Inferiore',
        provincia: 'SA',
        regione: 'Campania',
        latitudine: 40.7412,
        longitudine: 14.6453,
        potenzaKwp: 320,
      ),
      const Impianto(
        codice: 'FTV00089',
        cliente: 'SOLAR TECH S.P.A.',
        indirizzo: 'Contrada San Marco',
        comune: 'Benevento',
        provincia: 'BN',
        regione: 'Campania',
        latitudine: 41.1297,
        longitudine: 14.7827,
        potenzaKwp: 1100,
      ),
      const Impianto(
        codice: 'FTV00110',
        cliente: 'ENERGIA VERDE S.R.L.',
        indirizzo: 'Via del Sole 15',
        comune: 'Avellino',
        provincia: 'AV',
        regione: 'Campania',
        latitudine: 40.9142,
        longitudine: 14.7901,
        potenzaKwp: 480,
      ),
      const Impianto(
        codice: 'FTV00301',
        cliente: 'BIOMED S.R.L.',
        indirizzo: 'Area produttiva nord',
        comune: 'Fisciano',
        provincia: 'SA',
        regione: 'Campania',
        latitudine: 40.7721,
        longitudine: 14.8012,
        potenzaKwp: 280,
      ),
    ]);
  }

  @override
  Future<List<Impianto>> getAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return List.unmodifiable(_impianti);
  }

  @override
  Future<Impianto?> getByCodice(String codice) async {
    try {
      return _impianti.firstWhere((i) => i.codice == codice);
    } catch (_) {
      return null;
    }
  }
}
