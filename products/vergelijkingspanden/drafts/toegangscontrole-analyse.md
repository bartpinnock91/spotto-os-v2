# Toegangscontrole Vergelijkingspanden - Analyse

**Status:** Draft
**Datum:** 2026-02-25
**Doel:** Functionele analyse voor toegangscontrole met twee niveaus

---

## Context

Vergelijkingspanden moet publiek toegankelijk zijn als trigger om met Spotto te werken of een abonnement te kopen. De publieke versie toont de rijkdom aan data, maar geeft niet genoeg weg om op straatniveau individuele panden te bekijken.

---

## Toegangsmodel

### Twee niveaus

| Niveau                | Wie                                            | Doel                                             |
| --------------------- | ---------------------------------------------- | ------------------------------------------------ |
| **Publiek**           | Elke ingelogde gebruiker                       | Lead generation - tonen dat de data waardevol is |
| **Volledige toegang** | Actieve Spotto-gebruikers OF abonnementhouders | Dagelijks gebruik voor vergelijkingen            |

### Hoe krijg je volledige toegang?

Er zijn twee onafhankelijke manieren:

**1. Actief gebruik van Spotto**
Kantoren die actief publiceren via Spotto krijgen automatisch toegang. Het exacte tijdsvenster en de drempel worden nog bepaald (zie [Definitie "actief Spotto-gebruik"](#definitie-actief-spotto-gebruik)).

**2. Betaald abonnement**
Makelaars die geen actieve Spotto-gebruiker zijn kunnen een standalone abonnement afsluiten. Pricing is nog te bepalen.

---

## Niveau 1: Publiek gebruik

**Voorwaarde:** Ingelogd in RealSmart

### Wat je ziet en kan doen

| Functionaliteit   | Gedrag                                                    |
| ----------------- | --------------------------------------------------------- |
| Kaart bekijken    | Volledig zichtbaar met alle property markers              |
| Zoomen            | Tot **zoom level 12** (stadsniveau - hele stad zichtbaar) |
| Aantal panden     | Getoond in zijbalk (bv. "5.756 panden")                   |
| Property markers  | Zichtbaar als gekleurde dots                              |
| Filters           | Zichtbaar maar disabled                                   |
| Klikken op marker | Geen actie - preview opent niet                           |
| Vergelijkingen    | Volledig geblokkeerd                                      |

### Zoom level referentie

- **Level 12: Stadsniveau** - hele stad zichtbaar (Gent, Antwerpen) → **grens voor publiek**
- Level 14: Wijk/buurt (~500m)
- Level 16: Straatniveau (individuele huizen)
- Level 18: Gebouwniveau

### Waarom level 12?

Op stadsniveau ziet een gebruiker dat er veel data beschikbaar is in een bepaalde regio, maar kan niet inzoomen tot op het niveau waar individuele panden herkenbaar zijn. Dit voorkomt dat iemand gratis kan checken of een specifiek buurhuis in de dataset zit.

---

## Niveau 2: Volledige toegang

**Voorwaarde:** Actieve Spotto-gebruiker OF betaald abonnement

| Functionaliteit                   | Toegang |
| --------------------------------- | ------- |
| Alle niveau 1 features            | ✓       |
| Zoomen tot straatniveau           | ✓       |
| Alle filters                      | ✓       |
| Property preview (klik op marker) | ✓       |
| Property details bekijken         | ✓       |
| Vergelijkingen maken              | ✓       |
| Vergelijkingen opslaan            | ✓       |
| Export PDF                        | ✓       |
| Huuranalyse preview               | ✓       |

---

## Definitie "actief Spotto-gebruik"

Criterium: kantoor heeft ≥1 publicatie op spotto.be binnen een bepaald tijdsvenster. Welk venster?

| Optie | Regel | Pro | Contra |
|---|---|---|---|
| **A: 30 dagen** | ≥1 publicatie in laatste maand | Strakste koppeling met actief gebruik | Lastig voor zeer kleine kantoren |
| **B: 12 maanden** | ≥1 publicatie in laatste jaar | Stabiel, geen verrassingen | Bijna iedereen kwalificeert, zwakke prikkel |
| **C: 3 maanden** | ≥1 publicatie in laatste 90 dagen | Balans: overbrugt rustige periodes, filtert inactieven | Kleine kantoren kunnen nog wegvallen |
| **D: Nu online** | ≥1 pand staat nu op spotto | Simpelste logica, realtime | Makelaar die net alles verkocht verliest toegang |


---

## Open vragen

1. **Tijdsvenster actief gebruik** - Welke optie kiezen we? (zie boven)

2. **Pricing abonnement** - Nog te bepalen

3. **Upsell ervaring** - Wanneer een publieke gebruiker op een disabled filter of marker klikt: tonen we een boodschap? Zo ja, wat is de CTA? (bv. "Neem contact op", "Activeer Spotto", directe aankoop)

---
