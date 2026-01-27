# Pand Beoordeling v2 - Samen Vergelijken

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Project:** Pand Beoordeling
**Target Quarter:** TBD (na v1 live)

## Problem Statement

Na v1 kunnen gebruikers individueel panden beoordelen. Maar een woningaankoop is vaak een gezamenlijke beslissing. Partners, gezinsleden of vrienden willen samen vergelijken, hun scores naast elkaar leggen, en zien waar ze het eens of oneens zijn.

Daarnaast mist v1 de mogelijkheid om de "verwachting" (online bekeken) te vergelijken met de "realiteit" (na bezichtiging) - een belangrijk reflectiemoment in het aankoopproces.

## Goal

Gebruikers kunnen:
- Hun beoordelingen delen met anderen
- Samen scoren en vergelijken waar ze matchen
- Bezichtigingen tracken en scores bijwerken na bezoek
- Notities toevoegen voor context bij scores

**Primaire doelgroep:** Koppels en gezinnen die samen een woning zoeken

## User Stories

- [ ] Bezichtiging plannen - Bezichtigingsdatum vastleggen bij een pand
- [ ] Verwachting vs realiteit - Aparte scores voor/na bezoek
- [ ] Beoordelingen delen - Panden en scores delen met partner
- [ ] Samen scoren - Beide partners kunnen scoren, scores naast elkaar zien
- [ ] Notities bij scores - Toelichting per criterium toevoegen

## Success Metrics

- **Adoptie delen:** % gebruikers dat beoordelingen deelt
- **Engagement koppels:** Gemiddeld aantal gezamenlijk beoordeelde panden
- **Bezichtiging tracking:** % beoordeelde panden met bezichtigingsdatum
- **Conversie:** Contactaanvragen van gebruikers met gedeelde beoordelingen vs solo

## Dependencies

- Pand Beoordeling v1 moet live zijn
- Account/authenticatie systeem voor delen

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Complexiteit delen onderschat | Medium | High | Simpel starten: read-only delen eerst |
| Privacy zorgen bij delen | Low | Medium | Duidelijke consent flow, makkelijk intrekken |
| Feature creep | High | Medium | Strikte scope per story, geen "nice to haves" |

## Notes

### User journey: Het koppel
> "Mijn partner en ik willen allebei scoren en zien waar we matchen.
> Als we allebei 5 sterren geven voor locatie maar verschillen op prijs,
> weten we waar we over moeten praten."

### Relatie met v1
Deze epic bouwt voort op v1. Stories kunnen pas opgepakt worden nadat de basis (criteria, scores, Mijn Panden) live is.
