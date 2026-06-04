# Gestionale Ticket (Flutter Web)

Nuovo portale ticketing SIEM — UI moderna con UX orientata al lavoro quotidiano degli operatori.

## Stack

- Flutter Web
- **MVVM** con `ChangeNotifier` + `provider`
- **go_router** per navigazione
- Layout **responsive** (drawer mobile / navigation rail desktop)

## Avvio

```bash
flutter pub get
flutter run -d chrome
```

### Mappa Mapbox

L'SDK ufficiale `mapbox_maps_flutter` non supporta Web; la mappa usa **flutter_map** con tile raster Mapbox.

1. Copia `.env.example` in `.env` (se non esiste già)
2. Inserisci il token in `.env`:

```env
MAPBOX_ACCESS_TOKEN=pk.TUO_TOKEN
```

3. Avvia l'app:

```bash
flutter pub get
flutter run -d chrome
```

Alternativa senza file: `flutter run -d chrome --dart-define=MAPBOX_ACCESS_TOKEN=pk.xxx`

Senza token viene usata OpenStreetMap (banner informativo in app). Il file `.env` è in `.gitignore`.

## Funzionalità demo

| Area | Descrizione |
|------|-------------|
| **Centro ticket** | KPI code, filtri per tipologia, tab Tickets/OE/Interventi, card cliccabili |
| **Gestione** | Stati da lavorare / in lavorazione / chiusi, ricerca, paginazione |
| **Nuovo ticket** | Form guidato con validazione |
| **Dettaglio** | Hero card, timeline attività, storico stati, azioni comunicazione |
| **Azioni** | Storico, chiudi/riassegna (dialog demo) |
| **Mappa interventi** | Mapbox (tile) + aree GPS impianti FTV da ticket aperti |

## Struttura

```
lib/
├── core/theme/       # Design system (colori, spacing)
├── data/             # Modelli + repository mock
├── features/
│   ├── shell/        # Header, NavigationRail, layout
│   └── tickets/      # ViewModels + pagine
└── shared/widgets/   # TicketCard, filtri, pannelli
```

## Route

- `/tickets` — Hub code
- `/tickets?tab=oe` — Offerte economiche
- `/tickets?tab=interventi` — Interventi
- `/tickets/gestione` — Gestione con paginazione
- `/tickets/nuovo` — Inserimento
- `/tickets/mappa` — Mappa aree di intervento (GPS impianti)
- `/tickets/:id` — Dettaglio (fuori shell, full page)

## Prossimo step

Integrazione API con il motore dati del gestionale esistente.
