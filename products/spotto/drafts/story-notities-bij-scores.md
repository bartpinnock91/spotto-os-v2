# Notities bij Scores

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Epic:** Pand Beoordeling v2

## User Story

Als woningzoeker,
wil ik een notitie kunnen toevoegen bij mijn score voor een criterium,
zodat ik later weet waarom ik die score heb gegeven.

## Acceptance Criteria

- [ ] Gebruiker kan per criterium een tekstnotitie toevoegen
- [ ] Notitie icoon/indicator is zichtbaar bij criteria met notities
- [ ] Notitie kan bekeken worden door op het criterium te klikken/tappen
- [ ] Notitie kan bewerkt en verwijderd worden
- [ ] Notities zijn zichtbaar in de pand detail beoordeling widget
- [ ] In Mijn Panden kan gebruiker notities terugzien (uitklapbaar of hover)
- [ ] Notities hebben een maximale lengte (bijv. 500 karakters)

## Notes

- Voorbeelden van nuttige notities:
  - "Tuin is klein maar op het zuiden" (bij Omgeving: 4 sterren)
  - "Keuken moet volledig vernieuwd" (bij Prijs: 2 sterren)
  - "10 min fietsen naar station" (bij Bereikbaarheid: 5 sterren)
- Helpt bij herinneren na meerdere bezichtigingen
- Bij "samen scoren": notities helpen de discussie

## Technical Notes

- Uitbreiding score model: optioneel note veld (text, max 500 chars)
- Notities worden mee opgeslagen bij score update
- Consider: aparte notities tabel vs veld op score record
- UI: inline editing of modal/popup voor notitie

## Out of Scope

- Foto's toevoegen aan notities
- Voice notities
- Rich text formatting in notities
- Notities doorzoeken
