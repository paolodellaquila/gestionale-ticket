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

## Funzionalità demo

| Area | Descrizione |
|------|-------------|
| **Centro ticket** | KPI code, filtri per tipologia, tab Tickets/OE/Interventi, card cliccabili |
| **Gestione** | Stati da lavorare / in lavorazione / chiusi, ricerca, paginazione |
| **Nuovo ticket** | Form guidato con validazione |
| **Dettaglio** | Hero card, timeline attività, storico stati, azioni comunicazione |
| **Azioni** | Storico, chiudi/riassegna (dialog demo) |

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
- `/tickets/:id` — Dettaglio (fuori shell, full page)

## Prossimo step

Integrazione API con il motore dati del gestionale esistente.
