# Gemiddelde Score in Mijn Panden Overzicht

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Epic:** Pand Beoordeling

## User Story

Als woningzoeker,
wil ik de gemiddelde beoordeling zien in mijn panden overzicht,
zodat ik snel kan vergelijken welke panden het beste scoren op mijn criteria.

## Acceptance Criteria

- [ ] Elk pand in "Mijn Panden" toont de gemiddelde score (indien beoordeeld)
- [ ] Score wordt getoond als getal met 1 decimaal (bijv. 3.8)
- [ ] Score wordt visueel ondersteund met sterren
- [ ] Panden zonder beoordeling tonen geen score (niet "0.0")
- [ ] Gemiddelde wordt berekend over alle ingevulde criteria (lege criteria niet meegeteld)

## Notes

- Dit maakt "Mijn Panden" de centrale vergelijkingsplek
- Sortering op score helpt bij het maken van een shortlist
- Later kan hier een uitgebreidere vergelijkingstabel komen (v2)

## Technical Notes

- Consider: Gemiddelde score wordt server-side berekend bij ophalen van de lijst
- Consider: batch berekening bij veel panden vs individuele berekening

## Out of Scope

- Gedetailleerde vergelijkingstabel met alle criteria naast elkaar
- Filteren op minimum score
- Score breakdown zichtbaar in het overzicht (alleen gemiddelde)
- Export functionaliteit
