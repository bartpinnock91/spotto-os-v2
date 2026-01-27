# Bezichtiging Plannen

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Epic:** Pand Beoordeling v2

## User Story

Als woningzoeker,
wil ik kunnen vastleggen wanneer ik een pand ga bezichtigen,
zodat ik een overzicht heb van mijn geplande en voltooide bezichtigingen.

## Acceptance Criteria

- [ ] Gebruiker kan een bezichtigingsdatum toevoegen aan een pand
- [ ] Datum en tijd kunnen worden ingesteld
- [ ] Bezichtiging kan gemarkeerd worden als "gepland" of "voltooid"
- [ ] In Mijn Panden is zichtbaar welke panden een bezichtiging hebben
- [ ] Panden kunnen gefilterd worden op bezichtigingsstatus
- [ ] Gebruiker kan bezichtiging verwijderen of aanpassen
- [ ] Optioneel: notitie toevoegen aan bezichtiging (adresdetails, contactpersoon)

## Notes

- Dit is de basis voor "verwachting vs realiteit" - je moet weten wanneer het bezoek was
- Geen kalender-integratie in v2 (te complex)
- Focus op simpele datum tracking, niet op scheduling

## Technical Notes

- Bezichtiging als aparte entiteit: gebruiker_id + publicatie_id + datum + status + notitie
- Status enum: planned, completed, cancelled
- Relatie met beoordelingen: bezichtiging kan trigger zijn voor "na bezoek" score

## Out of Scope

- Kalender sync (Google Calendar, Outlook)
- Herinneringen/notificaties
- Route planning naar bezichtiging
- Contact met makelaar vanuit bezichtiging
