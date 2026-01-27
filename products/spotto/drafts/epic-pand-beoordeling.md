# Pand Beoordeling

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Project:** Pand Beoordeling
**Target Quarter:** Q1 2026

## Problem Statement

Woningzoekers bekijken vaak meerdere panden en verliezen het overzicht. Na een paar bezichtigingen wordt het moeilijk om te onthouden welk pand goed scoorde op welke aspecten. Er is geen gestructureerde manier om panden te vergelijken op persoonlijke criteria.

Huidige situatie:
- Gebruikers kunnen panden alleen als favoriet markeren (ja/nee)
- Geen manier om eigen prioriteiten vast te leggen
- Vergelijken gebeurt in het hoofd of op papier

## Goal

Gebruikers kunnen panden beoordelen op zelfgekozen criteria en deze beoordelingen terugvinden in een overzicht om panden te vergelijken.

**Primaire doelgroep:** Kopers (huurmarkt is te snel/oververhit voor dit type reflectie)

## User Stories

- [ ] Criteria beheer - Gebruiker kan beoordelingscriteria instellen
- [ ] Pand beoordelen - Gebruiker kan een pand scoren op criteria
- [ ] Rename Favorieten - "Favorieten" wordt "Mijn Panden"
- [ ] Gemiddelde score in overzicht - Scores zichtbaar in Mijn Panden overzicht
- [ ] Onboarding feedback - Eerste beoordeling krijgt begeleiding

## Success Metrics

- **Activatie:** % accounts dat minstens 1 criterium aanmaakt
- **Engagement:** Gemiddeld aantal beoordeelde panden per actieve gebruiker
- **Retentie:** Terugkeerfrequentie van gebruikers met beoordelingen vs zonder

## Dependencies

- Account systeem (inloggen vereist voor opslaan)
- Bestaande favorieten functionaliteit

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Gebruikers vinden de feature niet | Medium | High | Duidelijke CTA op pand detail, onboarding toast |
| Te veel criteria maakt vergelijken onoverzichtelijk | Low | Medium | Maximum van 15 criteria |
| Verwarring over waar beoordelingen staan | Medium | Medium | Rename naar "Mijn Panden", directe link in widget |

## Notes

### Inspiratie
Competitor screenshot toont vergelijkbare aanpak met:
- Criteria lijst met sterren (1-5)
- Gemiddelde score prominent
- "Criteria beheren" link

### Geparkeerd voor v2
- Bezichtiging plannen/tracken
- Verwachting vs realiteit (voor/na bezoek)
- Delen met partner
- Notities aan scores koppelen

### Design beslissingen
- **Scoreschaal:** 5 sterren (genoeg nuance voor grote beslissing, herkenbaar patroon)
- **Prefill criteria:** Prijs, Bereikbaarheid, Omgeving, Energiescore
- **Max criteria:** 15
- **Gemiddelde:** Server-side berekenen bij ophalen (geen sync issues)
- **Auto-favoriet:** Beoordelen maakt pand automatisch favoriet
