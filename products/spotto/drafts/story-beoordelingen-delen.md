# Beoordelingen Delen

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Epic:** Pand Beoordeling v2

## User Story

Als woningzoeker,
wil ik mijn beoordeelde panden kunnen delen met mijn partner of familie,
zodat zij kunnen zien welke panden ik interessant vind en hoe ik ze beoordeel.

## Acceptance Criteria

- [ ] Gebruiker kan een deellink genereren voor Mijn Panden
- [ ] Deellink toont read-only overzicht van beoordeelde panden met scores
- [ ] Ontvanger hoeft geen account te hebben om te bekijken
- [ ] Gebruiker kan de deellink intrekken/deactiveren
- [ ] Deellink bevat geen gevoelige accountgegevens
- [ ] Gedeeld overzicht toont: panden, gemiddelde scores, criteria scores
- [ ] Optioneel: specifieke panden selecteren om te delen (niet alles)

## Notes

- Dit is de "read-only" versie van delen - ontvanger kan alleen bekijken
- Stap 1 richting "samen scoren" - eerst simpel delen valideren
- Privacy belangrijk: gebruiker moet controle hebben over wat gedeeld wordt
- Link-based delen = laagdrempelig, geen account nodig voor ontvanger

## Technical Notes

- Deel token genereren: unieke, niet-raadbare URL
- Token opslaan met: eigenaar_id, created_at, active boolean
- Consider: expiratie datum op deellinks?
- Aparte "shared view" pagina zonder authenticatie vereiste

## Out of Scope

- Real-time sync van wijzigingen naar gedeelde view
- Notificaties wanneer eigenaar scores wijzigt
- Commentaar/reacties van ontvanger
- Account-to-account delen (komt in "samen scoren")
