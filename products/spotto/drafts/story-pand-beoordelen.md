# Pand Beoordelen

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Epic:** Pand Beoordeling

## User Story

Als woningzoeker,
wil ik een pand kunnen beoordelen op mijn criteria,
zodat ik later kan vergelijken hoe verschillende panden scoren.

## Acceptance Criteria

- [ ] Op de pand detail pagina is een beoordeling widget zichtbaar
- [ ] Widget toont alle criteria van de gebruiker met sterren (1-5) per criterium
- [ ] Gebruiker kan per criterium een score geven door op sterren te klikken
- [ ] Door op dezelfde score te klikken als de reeds ingedrukte score, wordt de score voor dat criterium gereset.
- [ ] Score wordt direct opgeslagen na selectie (geen save knop nodig)
- [ ] Widget toont het gemiddelde van alle gegeven scores (berekend over ingevulde criteria)
- [ ] Niet-ingevulde criteria tellen niet mee in het gemiddelde
- [ ] Widget toont link naar "Criteria beheren"
- [ ] Widget toont link naar "Mijn Panden" onderaan
- [ ] Bij eerste beoordeling wordt het pand automatisch toegevoegd aan favorieten/Mijn Panden
- [ ] Gebruiker moet ingelogd zijn om te beoordelen
- [ ] Niet-ingelogde gebruiker ziet prompt om in te loggen

## Notes

- Scores kunnen altijd aangepast worden door opnieuw te klikken
- Een score kan ook verwijderd worden (terugzetten naar 0/geen score)

## Technical Notes

- Consider: check of pand al favoriet is om duplicaten te voorkomen

## Out of Scope

- Notities toevoegen aan individuele scores
- Bezichtigingsdatum koppelen aan beoordeling
- Foto's toevoegen aan beoordeling
- Onderscheid "verwachting" vs "na bezoek" scores
