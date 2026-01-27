# Samen Scoren

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Epic:** Pand Beoordeling v2

## User Story

Als woningzoeker met een partner,
wil ik dat we allebei dezelfde panden kunnen beoordelen en onze scores naast elkaar zien,
zodat we kunnen ontdekken waar we het eens zijn en waar we van mening verschillen.

## Acceptance Criteria

- [ ] Gebruiker kan een partner uitnodigen om samen te scoren (via email of link)
- [ ] Partner moet een Spotto account hebben om mee te scoren
- [ ] Beide partners kunnen onafhankelijk scores geven aan dezelfde panden
- [ ] In Mijn Panden zijn beide scores zichtbaar naast elkaar
- [ ] Vergelijkingsview toont: mijn score, partner score, verschil
- [ ] "Match indicator" toont waar jullie het eens zijn (bijv. beide >4 sterren)
- [ ] "Discussiepunten" uitlichten waar scores sterk verschillen (bijv. >2 sterren verschil)
- [ ] Elk partner behoudt eigen criteria (hoeven niet identiek te zijn)
- [ ] Koppeling kan door beide partijen verbroken worden

## Notes

- Dit is de kern van de "koppel journey"
- Maakt het gesprek over woningkeuze concreet en gestructureerd
- Potentieel sterke retentie driver: beiden moeten terugkomen om te scoren
- Privacy: alleen gekoppelde partners zien elkaars scores

## Technical Notes

- Partner relatie: user_id_1 + user_id_2 + status (pending, active, ended)
- Scores blijven per gebruiker, worden samengevoegd in view
- Consider: gedeelde criteria set vs individuele criteria
- Invite flow: email met acceptatie link, of in-app notificatie

## Out of Scope

- Meer dan 2 personen koppelen (groepen/families)
- Gezamenlijke notities of chat functie
- Automatische suggesties voor compromis-panden
- Gewogen gemiddelde van beide scores
