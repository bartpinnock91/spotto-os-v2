# Criteria Beheer

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Epic:** Pand Beoordeling

## User Story

Als woningzoeker,
wil ik mijn eigen beoordelingscriteria kunnen instellen,
zodat ik panden kan scoren op wat voor mij persoonlijk belangrijk is.

## Acceptance Criteria

- [ ] Nieuwe gebruikers krijgen 4 standaard criteria: Prijs, Bereikbaarheid, Omgeving, Energiescore
- [ ] Gebruiker kan een nieuw criterium toevoegen (vrije tekst)
- [ ] Gebruiker kan een criterium verwijderen
- [ ] Gebruiker kan de naam van een criterium wijzigen
- [ ] Maximum van 15 criteria per account
- [ ] Bij bereiken maximum krijgt gebruiker feedback dat limiet bereikt is
- [ ] Verwijderen van een criterium verwijdert ook alle bijbehorende scores
- [ ] Criteria zijn gekoppeld aan het account
- [ ] Criteria beheer is toegankelijk via het profielmenu

## Notes

- Gebruikers kunnen alle prefill criteria verwijderen als ze volledig eigen lijst willen
- Volgorde van criteria is voorlopig niet aanpasbaar

## Technical Notes

- Criteria worden opgeslagen op account niveau
- Bij eerste login/registratie worden de 4 default criteria aangemaakt
- Geen migratie nodig voor bestaande accounts - criteria worden lazy aangemaakt bij eerste interactie

## Out of Scope

- Criteria volgorde aanpassen
- Criteria categoriseren of groeperen
- Gedeelde/voorgestelde criteria van andere gebruikers
- Criteria templates per type woning
