# Project: Pand Beoordeling

**Status:** Draft
**Linear Project:** <!-- Add after pushing -->
**Target:** 2026

## Visie

Woningzoekers een gestructureerde manier geven om panden te vergelijken op wat voor hen persoonlijk belangrijk is - van solo zoeken tot samen beslissen met een partner.

## Problem Space

Een woning kopen is een van de grootste beslissingen in iemands leven. Toch ontbreekt er tooling om deze keuze gestructureerd te maken:

- **Informatie overload:** Tientallen panden bekeken, details vergeten
- **Subjectieve vergelijking:** "Gevoel" in plaats van criteria
- **Gezamenlijke beslissing:** Partner/familie betrekken is lastig
- **Verwachting vs realiteit:** Online ziet alles er mooi uit

## Oplossing

Een beoordelingssysteem waarbij gebruikers:
1. Eigen criteria definiëren (wat vind ik belangrijk?)
2. Panden scoren op die criteria
3. Scores vergelijken in een overzicht
4. (Later) Samen scoren met partner

## Epics

### v1 - Individueel Beoordelen
**Focus:** De dromer - solo zoeken en vergelijken

| Story | Beschrijving |
|-------|--------------|
| Criteria beheer | CRUD voor persoonlijke criteria |
| Pand beoordelen | Score widget op pand detail |
| Rename Favorieten | "Favorieten" → "Mijn Panden" |
| Gemiddelde score overzicht | Scores zichtbaar in Mijn Panden |
| Onboarding feedback | Toast bij eerste beoordeling |

### v2 - Samen Vergelijken
**Focus:** Het koppel - samen beslissen

| Story | Beschrijving |
|-------|--------------|
| Bezichtiging plannen | Datum/tijd vastleggen |
| Verwachting vs realiteit | Scores voor/na bezoek |
| Beoordelingen delen | Read-only deellink |
| Samen scoren | Partner koppelen |
| Notities bij scores | Toelichting per criterium |

## Strategische Fit

Dit project ondersteunt de 2026 doelen:

| Doel | Bijdrage |
|------|----------|
| **Activatie** | Reden om account aan te maken |
| **Retentie** | Terugkeren om scores bij te werken |
| **Personalisatie** | Data over gebruikersvoorkeuren |
| **Differentiatie** | Unieke feature vs concurrenten |

## Success Metrics

### v1
- % accounts met minstens 1 criterium
- Gemiddeld aantal beoordeelde panden per actieve gebruiker
- Terugkeerfrequentie beoordelende gebruikers vs niet-beoordelend

### v2
- % gebruikers dat beoordelingen deelt
- Gemiddeld aantal gezamenlijk beoordeelde panden
- Contactaanvragen van koppels vs solo gebruikers

## Doelgroep

**Primair:** Kopers
- Huurmarkt is te snel/oververhit voor dit type reflectie
- Aankoop rechtvaardigt de investering in vergelijken

**Toegang:** Gratis, account vereist

## Dependencies

- Account/authenticatie systeem
- Bestaande favorieten functionaliteit
- Pand detail pagina (voor widget plaatsing)

## Risico's

| Risico | Mitigatie |
|--------|-----------|
| Feature niet gevonden | Onboarding toast, link in widget |
| Te complex voor gebruiker | Start simpel (v1), itereer op feedback |
| Geen adoptie bij koppels | v1 valideert solo use case eerst |

## Open Vragen

- [ ] Exacte plaatsing widget op pand detail pagina (design)
- [ ] Vertalingen NL/FR nodig?
- [ ] Integratie met bestaande notificatie systeem?

## Referenties

- Competitor screenshot (in conversatie)
- [Strategy 2026](../context/strategy-2026.md) - Activatie & Retentie doelen
