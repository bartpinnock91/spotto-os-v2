# Analyse Omnicasa-connecties: Factureerbare vestigingen

## Context

We ontvangen van Omnicasa een lijst van makelaars die via hun platform publiceren naar Spotto. De facturatie gebeurt per **fysieke vestiging van het aangesloten vastgoedkantoor, gebaseerd op hun vestigingen vermeld in KBO** (conform Artikel 6 van het contract, EUR 15,00 excl. BTW per vestiging per maand).

Om te bepalen welke vestigingen effectief factureerbaar zijn, hebben we een grondige analyse uitgevoerd waarbij we elk kantoor kruisen met het Belgisch ondernemingsregister (KBO).

## Aanpak

### Stap 1: Deduplicatie

Vanuit de Omnicasa-export (Q4, 365 rijen) worden dubbele kantoren verwijderd op basis van unieke (BrokerId, OfficeId)-combinaties.

- **365 rijen -> 337 unieke kantoren -> 206 groepen** (1 groep = 1 makelaar)
- Ceusters wordt uitgesloten (apart systeem) -> **205 groepen**

### Stap 2: Filter op publicaties

Een groep is alleen relevant als minstens 1 kantoor actief publiceert naar Spotto.

- **165 groepen** hebben minstens 1 actieve publicatie
- **40 groepen** hebben geen publicaties (inactieve connecties)

### Stap 3: KBO-validatie

Alle unieke KBO-nummers uit de CSV werden gevalideerd via de CBEAPI (Kruispuntbank van Ondernemingen).

Van de 165 publicerende groepen:
- **153** hebben een geldig, bevestigd KBO-nummer
- **5** hebben geen KBO-nummer in het systeem
- **4** hebben een KBO-nummer dat niet gevonden wordt in het register
- **3** staan op de deactivatielijst (Clavis Vastgoed, Depotter, Immo Walbers BV)

### Stap 4: Factureerbare vestigingen bepalen

Per factureerbare groep tellen we:
- Het aantal **publicerende kantoren** in Omnicasa (kantoren met ActivePublications > 0)
- Het aantal **KBO-vestigingseenheden** van die onderneming

Het factureerbare aantal = **min(publicerende kantoren, KBO-vestigingen)**

Dit voorkomt dubbeltelling van fictieve kantoren (bv. Huur/Koop-splits in Omnicasa) en voorkomt dat vestigingen worden aangerekend die niet actief publiceren.

## Resultaat

| Categorie | Groepen | Vestigingen | Toelichting |
|-----------|---------|-------------|-------------|
| **Factureerbaar** | **153** | **172** | Geldig KBO + actieve publicaties |
| Op te volgen | 9 | 11 | Actieve publicaties maar geen geldig KBO |
| Gedeactiveerd | 3 | 3 | Op deactivatielijst |
| Geen publicaties | 40 | - | Inactieve connecties |
| **Totaal** | **205** | | |

### Facturatie Q4

| | |
|---|---|
| Factureerbare vestigingen | **172** |
| Per maand (172 x EUR 15,00) | **EUR 2.580,00** |
| Per trimester (x3) | **EUR 7.740,00** |
| Per jaar (x12) | **EUR 30.960,00** |

### Op te volgen: 9 groepen (11 kantoren)

Deze makelaars publiceren actief maar hebben geen geldig KBO-nummer in het systeem. Bij data-opkuis (correct KBO-nummer invullen) kunnen deze alsnog factureerbaar worden.

| Makelaar | Kantoren | Publicaties | Reden |
|----------|----------|-------------|-------|
| Makelaarskantoor De Smet | 1 | 548 | Geen KBO in systeem |
| Agence Depoorter | 3 | 218 | Geen KBO in systeem |
| Estero | 1 | 127 | Geen KBO in systeem |
| Immo P&A | 1 | 120 | KBO niet gevonden |
| Woonservice | 1 | 82 | KBO niet gevonden |
| Omnia Vastgoed | 1 | 79 | Geen KBO in systeem |
| Vastgoed Vanassche | 1 | 45 | KBO niet gevonden |
| CIK | 1 | 21 | Geen KBO in systeem |
| Diversimmo | 1 | 6 | KBO niet gevonden |

### Gedeactiveerd: 3 groepen

| Makelaar | Publicaties | KBO |
|----------|-------------|-----|
| Immo Walbers BV | 208 | 0428342102 |
| Depotter | 162 | 0845303134 |
| Clavis Vastgoed | 26 | 0651619571 |

## Worst case na opkuis

Als alle 9 op-te-volgen groepen een geldig KBO-nummer blijken te hebben:

- **Maximaal factureerbaar: 183 vestigingen / 162 groepen**
- **Per maand: EUR 2.745,00**
- **Per trimester: EUR 8.235,00**
- **Per jaar: EUR 32.940,00**

## Vergelijking Q3 -> Q4

| | Q3 | Q4 | Delta |
|---|---|---|---|
| Factureerbare groepen | 149 | 153 | +4 |
| Factureerbare vestigingen | 170 | 172 | +2 |
| Per maand | EUR 2.550,00 | EUR 2.580,00 | +EUR 30,00 |
| Per trimester | EUR 7.650,00 | EUR 7.740,00 | +EUR 90,00 |

Nieuw factureerbaar in Q4: Astrid Immobilia, Atrium Vastgoed, Immo Van d'Helsen, PATTYMO bvba, WOWimmo.
Niet meer in Q4: Quares (was 2 vestigingen).
Daling: Vastgoed Chase (2 -> 1 vestiging).

## Voorbeelden billing-logica

| Makelaar | Omnicasa kantoren | Publicerend | KBO-vestigingen | Factureerbaar | Toelichting |
|----------|-------------------|-------------|-----------------|---------------|-------------|
| Coprimmo | 1 | 1 | 5 | **1** | 5 KBO-vestigingen maar slechts 1 publiceert |
| Bolt Real Estate | 3 | 3 | 1 | **1** | 3 kantoren publiceren, afgetopt op 1 KBO-vestiging |
| C&M Vastgoed | 2 | 2 | 2 | **2** | Match: 2 kantoren publiceren, 2 KBO-vestigingen |
| Agence Sissau | 1 | 1 | 2 | **1** | 2 KBO-vestigingen maar slechts 1 publiceert |

## Methode

Volledige analyse beschikbaar in `omnicasa-q4-facturatie.csv`. Script: `python billing-analysis.py Q4`.
