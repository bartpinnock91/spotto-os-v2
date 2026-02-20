# Toegangscontrole Vergelijkingspanden - Analyse

**Status:** Draft
**Datum:** 2026-02-05
**Doel:** Technische analyse voor feature-based toegangscontrole

---

## Context

De tool Vergelijkingspanden moet toegankelijk zijn voor exploratie (lead generation), maar bepaalde functionaliteiten worden afgeschermd achter CIB-lidmaatschap of een betaald abonnement.

### Achtergrond RealSmart Feature System

RealSmart werkt toe naar een **feature-set based** systeem waarbij de check op "heeft die feature" centraal gebeurt. In afwachting van dit centrale systeem moet de Vergelijkingspanden-module zelf de controle uitvoeren en knoppen disablen op basis van rechten.

---

## Toegangsmodel

### Twee manieren om volledige toegang te krijgen

Er zijn twee onafhankelijke manieren om volledige toegang te krijgen tot Vergelijkingspanden:

**1. CIB-lidmaatschap (gratis)**

CIB-leden krijgen automatisch gratis toegang tot Vergelijkingspanden. Dit is een extra voordeel van het CIB-lidmaatschap.

**2. Betaald abonnement**

Makelaars die geen CIB-lid zijn kunnen een standalone abonnement afsluiten. Hiermee krijgen ze volledige toegang. Dit is bedoeld voor kantoren die geen CIB-lid zijn maar wel de vergelijkingsdata willen gebruiken.

---

## Toegangsniveaus

### Niveau 1: Exploratie (geen login / geen toegang)

**Wat je ziet:** Volledige kaart met alle property markers

| Functionaliteit  | Gedrag                                                  |
| ---------------- | ------------------------------------------------------- |
| Kaart bekijken   | Volledig zichtbaar met alle markers                     |
| Zoomen           | Tot **zoom level 14** (wijk/buurt niveau, ~500m schaal) |
| Aantal panden    | Getoond in zijbalk: "135.000 vergelijkingspanden"       |
| Property markers | Zichtbaar als gekleurde dots                            |
| Filters          | Niet zichtbaar                                          |
| Property preview | **Geblokkeerd**                                         |
| Vergelijkingen   | **Geblokkeerd**                                         |

**Zoom level referentie:**

- Level 12: Stad overzicht (hele Gent/Antwerpen zichtbaar)
- Level 14: Wijk niveau (~500m) - **voorgestelde grens**
- Level 16: Straatniveau (individuele huizen zichtbaar)
- Level 18: Gebouw niveau

**Doel:** Gebruiker ziet de rijkdom aan data, kan inschatten of de tool waardevol is, maar kan geen concreet werk doen.

### Niveau 2: Volledige toegang

**Voorwaarde:** CIB-lid **OF** betaald abonnement

| Functionaliteit           | Toegang |
| ------------------------- | ------- |
| Alle niveau 1 features    | ✓       |
| Zoomen tot straatniveau   | ✓       |
| Alle filters              | ✓       |
| Property details bekijken | ✓       |
| Vergelijkingen maken      | ✓       |
| Vergelijkingen opslaan    | ✓       |
| Export PDF                | ✓       |
| Huuranalyse preview       | ✓       |

---

## Toegangsvoorwaarden

### Optie A: CIB-lid (gratis)

| Vereiste         | Details             |
| ---------------- | ------------------- |
| CIB-lidmaatschap | Actief lidmaatschap |
| EULA             | Geldige acceptatie  |

**Geldt voor:** Alle CIB-leden

### Optie B: Betaald abonnement (€1.500/jaar)

| Vereiste   | Details            |
| ---------- | ------------------ |
| Abonnement | Actieve betaling   |
| EULA       | Geldige acceptatie |

**Geldt voor:** Makelaars die geen CIB-lid zijn maar wel Vergelijkingspanden willen

## Controle Mechanisme

### Bij elke aanmelding (niet alleen eerste keer)

Per sessie wordt gecontroleerd:

1. Heeft gebruiker geldige EULA geaccepteerd?
2. Is gebruiker CIB-lid? → Volledige toegang
3. Heeft gebruiker betaalde licentie? → Volledige toegang
4. Geen van beide? → Beperkte exploratie modus

### Frontend gedrag

**Exploratie modus (geen toegang):**

- Kaart volledig zichtbaar met alle markers
- Zoom geblokkeerd voorbij level 14
- Filters disabled met lock icon
- Bij klikken op property/filter → upsell panel

## Open vragen

1. **EULA juridische uitwerking**

   - Wordt apart opgepakt, maar moet klaar zijn voor go-live

2. **Migratie bestaande gebruikers**

   - Hebben huidige beta-gebruikers automatisch toegang?

3. **Zoom level 14 - akkoord?**
   - Dit is wijk/buurt niveau (~500m schaal)
   - Gebruiker ziet dat er panden zijn in een gebied, maar kan niet zien welke huizen exact

## Gerelateerde Jira tickets

- TRANSDATA-153: Free tier browsing
- TRANSDATA-156: Subscription access

---
