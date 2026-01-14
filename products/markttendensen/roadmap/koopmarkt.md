# Roadmap: Koopmarkt

De eerste dataset die we ontsluiten in Markttendensen. Dit document geeft een high-level overzicht van de epics en hun doel. Voor details en actuele status: zie Jira project [RSMMT](https://orisnv.atlassian.net/browse/RSMMT).

## Release: Accelerating Alpaca (RSMMT-6)

### Epic 0: Technical setup (RSMMT-8)

**Doel:** Technische basis leggen voor de module.

---

### Epic 1: MVP Koopmarkt (RSMMT-9)

**Doel:** Proof-of-concept voor de volledige flow - van GeoData API tot werkende UI.

**Strategie:** Start smal, breid uit
- Data diepte: één indicator → alle indicatoren
- Data breedte: Gent → andere gemeentes → buurtgemeenten

**Hardcoded in MVP:**
- Locatie: Gent
- Jaar: 2025

**Levert op:**
- 6 indicatoren (prijs/m², panden online, opzoekingen, aanvragen, doorlooptijd, makelaars)
- Gemeente selector
- Buurtgemeenten automatisch
- Vastgoedtype filter (residentieel)

---

### Epic 2: Slimmere filters (RSMMT-25)

**Doel:** De hardcoded defaults uit MVP vervangen door dynamische, slimme opties.

**Levert op:**
- Standaardlocatie op basis van kantooradres
- Jaar/periode filter
- Commerciële vastgoed indicatoren

**Afhankelijk van:** MVP epic afgerond

---

## Toekomstige datasets (nog geen epics)

- Huurmarkt
- Nieuwbouwvergunningen
- Studentenkamers

---

## Links

- [Jira Project RSMMT](https://orisnv.atlassian.net/browse/RSMMT)
- [Figma Designs](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-%7C-Spotto?node-id=1840-15473)
- [Confluence: Technische Analyse Koopmarkt](https://orisnv.atlassian.net/wiki/spaces/IMMOX/pages/3267100673)
