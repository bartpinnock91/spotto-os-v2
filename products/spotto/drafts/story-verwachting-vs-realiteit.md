# Verwachting vs Realiteit Scores

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Epic:** Pand Beoordeling v2

## User Story

Als woningzoeker,
wil ik aparte scores kunnen geven voor mijn verwachting (online) en mijn ervaring (na bezoek),
zodat ik kan reflecteren op hoe een pand in het echt vergelijkt met de online presentatie.

## Acceptance Criteria

- [ ] Gebruiker kan een "verwachting" score geven (voor bezichtiging)
- [ ] Gebruiker kan een "realiteit" score geven (na bezichtiging)
- [ ] Beide scores zijn zichtbaar in de beoordeling widget
- [ ] Verschil tussen verwachting en realiteit wordt visueel getoond
- [ ] In Mijn Panden overzicht is zichtbaar of er een verschil is
- [ ] Grote verschillen (bijv. >1 ster gemiddeld) worden uitgelicht
- [ ] Gebruiker kan kiezen welke score te tonen in vergelijkingen (verwachting/realiteit/beide)

## Notes

- "Verwachting" = de v1 score (wat je denkt op basis van de listing)
- "Realiteit" wordt ontgrendeld na een bezichtiging markeren als voltooid
- Dit helpt gebruikers kritischer kijken naar listings vs werkelijkheid
- Interessante data voor Spotto: welke type panden/makelaars hebben grootste gaps?

## Technical Notes

- Uitbreiding score model: type enum (expectation, reality)
- Backward compatible: bestaande v1 scores worden "expectation"
- Gemiddelde berekening moet rekening houden met welk type getoond wordt
- Consider: aparte gemiddeldes tonen of gecombineerd?

## Out of Scope

- Automatische suggestie om realiteit score te geven na bezichtiging
- Analyse/insights over verwachting vs realiteit trends
- Delen van deze gap-data met andere gebruikers
