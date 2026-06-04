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

### Login

All’avvio compare la pagina di accesso. Le route dell’app sono protette: senza sessione si viene reindirizzati a `/login`.

| Ruolo | Username | Password |
|--------|----------|----------|
| Operatore | `arduino.esposito` | `demo123` |
| Amministratore | `admin.siem` | `admin123` |

Logout dal menu utente in alto a destra. La sessione resta attiva fino al logout o al refresh (demo in memoria; in produzione collegare API auth).

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

### Assistente GPT (chatbot)

Pulsante **Assistente** in basso a destra su tutte le pagine. Interroga i dati ticket (mock) via OpenAI Chat Completions.

```env
OPENAI_API_KEY=sk.TUO_TOKEN
OPENAI_MODEL=gpt-4o-mini
```

Se la chiave manca o la chiamata fallisce (es. CORS su Web senza proxy backend), risponde un **assistente locale** sui dati demo.

## Funzionalità demo

| Area | Descrizione |
|------|-------------|
| **Centro ticket** | KPI code, filtri per tipologia, tab Tickets/OE/Interventi, card cliccabili |
| **Gestione** | Stati da lavorare / in lavorazione / chiusi, ricerca, paginazione |
| **Nuovo ticket** | Form guidato con validazione |
| **Dettaglio** | Hero card, timeline attività, storico stati, azioni comunicazione |
| **Azioni** | Storico, chiudi/riassegna (dialog demo) |
| **Mappa interventi** | Mapbox (tile) + aree GPS impianti FTV da ticket aperti |
| **Assistente GPT** | Chat floating con contesto ticket |

## Struttura

```
lib/
├── core/theme/       # Design system (colori, spacing)
├── data/             # Modelli + repository mock
├── features/
│   ├── shell/        # Header, NavigationRail, layout
│   ├── auth/         # Login e sessione
│   ├── tickets/      # ViewModels + pagine
│   └── chat/         # Assistente GPT
└── shared/widgets/   # TicketCard, filtri, pannelli
```

## Route

- `/login` — Accesso
- `/tickets` — Hub code
- `/tickets?tab=oe` — Offerte economiche
- `/tickets?tab=interventi` — Interventi
- `/tickets/gestione` — Gestione con paginazione
- `/tickets/nuovo` — Inserimento
- `/tickets/mappa` — Mappa aree di intervento (GPS impianti)
- `/tickets/:id` — Dettaglio (fuori shell, full page)

## Prossimo step

Integrazione API con il motore dati del gestionale esistente.
