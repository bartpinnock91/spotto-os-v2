# Van Publicatie naar Adres

**Status:** Onderzoek & Conceptfase
**Jira:** [SPOTTO-1171](https://orisnv.atlassian.net/browse/SPOTTO-1171)
**Laatste update:** 2026-01-16

---

## 1. Samenvatting

Dit document beschrijft de strategische verschuiving van een **publicatie-centrisch** naar een **adres-centrisch** datamodel voor Spotto. Deze transitie lost fundamentele problemen op rond URL-structuur, duplicatie en offline panden, en legt de basis voor toekomstige features zoals prijsgeschiedenis en woningclaiming.

De sleutel tot succes is een **geleidelijke migratie** waarbij de gebruikerservaring voor kopers en makelaars ongewijzigd blijft tijdens de verkoopfase, terwijl de technische architectuur fundamenteel verbetert.

---

## 2. Probleemstelling

### Huidige situatie (publicatie-centrisch)

Spotto is vandaag georganiseerd rond **publicaties** - elke listing van een makelaar is een aparte entiteit:

| Probleem | Impact |
|----------|--------|
| **Meerdere URLs per adres** | Hetzelfde fysieke adres kan meerdere URLs hebben (verschillende makelaars, herlijstingen over tijd) |
| **Offline = verdwenen** | Wanneer een pand offline gaat, verdwijnt de URL/pagina volledig |
| **Duplicatie over gemeenten** | Panden in meerdere gemeenten creëren separate publicaties |
| **Geen historiek** | Geen prijsgeschiedenis, geen evolutie over tijd |
| **SEO-fragmentatie** | Autoriteit verspreid over meerdere URLs voor hetzelfde adres |

### Gewenste situatie (adres-centrisch)

Een model waarbij het **fysieke adres** de primaire entiteit is:

| Voordeel | Beschrijving |
|----------|--------------|
| **Eén canonieke URL** | `/postcode/gemeente/straatnaam/huisnummer` (à la Huispedia) |
| **Persistente pagina** | Adrespagina blijft bestaan, ongeacht lijststatus |
| **Consolidatie** | Meerdere publicaties voor hetzelfde adres onder één pagina |
| **Historiek mogelijk** | Basis voor prijsevolutie, vorige verkopen, etc. |
| **Betere SEO** | Eén autoritatieve URL per adres |

---

## 3. Strategische Context

### Relatie met Vergelijkingspanden

Het adres-centrische model is **reeds geïmplementeerd in Vergelijkingspanden** (B2B product). De data-laag en matching-logica kunnen hergebruikt worden. De uitdaging voor Spotto ligt primair in:

1. **UX-implicaties** op de consumentenwebsite
2. **Makelaarscommunicatie** en perceptie
3. **Migratiestrategie** zonder bestaande SEO en bookmarks te breken

### Positionering t.o.v. Concurrenten

| Platform | Model | Implicatie |
|----------|-------|------------|
| **Immoweb** | Publicatie-centrisch | Traditioneel aggregator-model |
| **Huispedia** | Adres-centrisch | Consumenten kunnen hun huis "claimen" en volgen |
| **Realo** | Hybride | Schatting + listings gecombineerd |
| **Spotto (toekomst)** | Adres-centrisch | Differentiatie via unieke features (reistijd, EPC-data) |

---

## 4. Kritieke Ontwerpbeslissing

> **De pagina moet aanvoelen als een listing tijdens het verkoopproces.**

Dit is de kernconstraint. Wanneer een pand actief te koop staat, moet de ervaring voor kopers én makelaars **ononderscheidbaar** zijn van het huidige publicatiemodel:

- Makelaarsdashboard toont nog steeds "mijn listings"
- Gedeelde links blijven werken
- De pagina ziet eruit als een listing wanneer actief
- Makelaars hoeven niet te begrijpen dat het model anders is

Het adres-centrische model is een **implementatiedetail** dat toekomstige features mogelijk maakt, geen zichtbare verandering voor eindgebruikers.

---

## 5. Risico-analyse (Premortem)

### 5.1 SEO-risico's (Hoog)

| Risico | Waarschijnlijkheid | Impact | Mitigatie |
|--------|-------------------|--------|-----------|
| Massale URL-wijzigingen breken rankings | Hoog | Kritiek | Waterdichte 301-redirects, gefaseerde uitrol |
| Duplicate content tijdens transitie | Middel | Hoog | Canonical tags, duidelijke oude→nieuw mapping |
| Verlies van page authority | Middel | Hoog | Redirect chains vermijden, monitoring |

**Monitoring vereist:**
- Rankings voor top-100 zoekwoorden
- Crawl errors in Search Console
- Indexatiestatus nieuwe URLs
- 404-errors op oude URLs

### 5.2 Datakwaliteitsrisico's (Middel)

| Risico | Waarschijnlijkheid | Impact | Mitigatie |
|--------|-------------------|--------|-----------|
| Incorrecte adres-matching (merge fouten) | Middel | Hoog | Validatie-dashboard, handmatige review edge cases |
| Incorrecte splits (één adres → meerdere) | Laag | Middel | Strikte matching-regels, monitoring |
| Edge cases: appartementen zonder busnummer | Hoog | Middel | Fallback-logica, graceful degradation |
| Nieuwbouw zonder officieel adres | Middel | Middel | Tijdelijke publicatie-modus behouden |

**Data-kwaliteit checkpoints:**
- % publicaties dat succesvol matcht naar adres
- False positive rate (incorrecte merges)
- False negative rate (gemiste matches)

### 5.3 Makelaar-relatie risico's (Middel-Hoog)

| Risico | Waarschijnlijkheid | Impact | Mitigatie |
|--------|-------------------|--------|-----------|
| Gedeelde links breken | Hoog | Hoog | Perfecte redirects, geen grace period |
| "Waar is MIJN listing?" verwarring | Middel | Middel | Actieve listing prominent, identieke look |
| Weerstand tegen zichtbare historiek | Laag (bij goede design) | Middel | Historiek verbergen tijdens actieve verkoop |
| Klachten via community manager | Middel | Laag | Interne FAQ voor support, geen proactieve communicatie |

**Kritiek inzicht:** Makelaars betalen voor community-lidmaatschap, niet specifiek voor "een listingpagina." Dit geeft ruimte voor modelwijzigingen zolang hun ervaring ongewijzigd blijft.

### 5.4 Technische risico's (Middel)

| Risico | Waarschijnlijkheid | Impact | Mitigatie |
|--------|-------------------|--------|-----------|
| Performance adrespagina's (aggregatie) | Middel | Middel | Caching, lazy loading historiek |
| Cache invalidatie complexiteit | Middel | Laag | Event-driven updates |
| Rollback complexiteit | Laag | Hoog | Feature flags, dual-write periode |

### 5.5 UX-risico's (Laag-Middel)

| Risico | Waarschijnlijkheid | Impact | Mitigatie |
|--------|-------------------|--------|-----------|
| Gebroken bookmarks van gebruikers | Hoog | Laag | Redirects |
| Verwarrende ervaring tijdens transitie | Middel | Middel | Property type slice, geen mix op zoekpagina |
| Conflict bij meerdere actieve listings | Laag | Middel | Design voor "primaire listing" + alternatieven |

---

## 6. Migratiestrategie

### Aanbevolen aanpak: Property Type Slice + Dual Display

Combineer twee strategieën:

1. **Property Type Slice**: Begin met één vastgoedtype in één regio
2. **Dual Display**: Oude URLs blijven werken via redirect naar adrespagina

```
┌─────────────────────────────────────────────────────────────┐
│                    MIGRATIEFASEN                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  FASE 0: Voorbereiding                                      │
│  ├─ Adres-matching valideren (hergebruik VP)                │
│  ├─ Redirect-infrastructuur bouwen                          │
│  ├─ Monitoring & rollback opzetten                          │
│  └─ Interne FAQ voor support                                │
│                                                             │
│  FASE 1: Shadow Mode (2-4 weken)                            │
│  ├─ Adrespagina's genereren (niet publiek)                  │
│  ├─ Data-kwaliteit valideren                                │
│  ├─ A/B test met interne gebruikers                         │
│  └─ SEO-impact simuleren                                    │
│                                                             │
│  FASE 2: Pilot Segment (4-8 weken)                          │
│  ├─ Selectie: [bijv. huizen, niet-nieuwbouw, Oost-Vlaanderen]│
│  ├─ Nieuwe URLs actief voor dit segment                     │
│  ├─ Oude URLs → 301 redirect naar adres                     │
│  ├─ Monitoring: SEO, errors, klachten                       │
│  └─ Go/no-go beslissing voor uitbreiding                    │
│                                                             │
│  FASE 3: Uitbreiding (per segment, 2-4 weken elk)           │
│  ├─ Volgend vastgoedtype of regio                           │
│  ├─ Iteratieve verbeteringen                                │
│  └─ Herhaal tot volledig platform                           │
│                                                             │
│  FASE 4: Nieuwe features (optioneel, later)                 │
│  ├─ Prijsgeschiedenis tonen                                 │
│  ├─ "Claim je woning" feature                               │
│  └─ Eigenaarsdashboard                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Segmentkeuze voor Pilot

**Aanbevolen startsegment: Huizen (niet-nieuwbouw) in één provincie**

| Criterium | Huizen, niet-nieuwbouw | Waarom geschikt |
|-----------|------------------------|-----------------|
| Adres-kwaliteit | Hoog | Bestaande adressen, goede data |
| Volume | Middel | Genoeg voor statistisch significante test |
| Edge cases | Laag | Geen busnummer-complexiteit |
| Nieuwbouw-issues | Geen | Adressen bestaan al |
| Makelaar-diversiteit | Hoog | Representatief voor totaal |

**Niet geschikt voor pilot:**
- Nieuwbouw (vaak geen officieel adres)
- Appartementen (busnummer-complexiteit)
- Bedrijfsvastgoed (andere URL-verwachtingen)

---

## 7. URL-structuur

### Voorstel nieuwe URL-structuur

```
https://www.spotto.be/nl/pand/{postcode}/{gemeente}/{straatnaam}/{huisnummer}[/{busnummer}]
```

**Voorbeelden:**
- `https://www.spotto.be/nl/pand/9000/gent/veldstraat/15`
- `https://www.spotto.be/nl/pand/2000/antwerpen/meir/50/3`

**Voordelen:**
- Human-readable
- SEO-vriendelijk (locatie in URL)
- Consistent met Huispedia-model
- Schaalbaar voor alle adrestypes

### Redirect-strategie

```
Oude URL                                    → Nieuwe URL
─────────────────────────────────────────────────────────────
/nl/te-koop/huis/gent/{slug}-{id}           → /nl/pand/9000/gent/veldstraat/15
/nl/te-huur/appartement/antwerpen/{slug}-{id} → /nl/pand/2000/antwerpen/meir/50/3
```

**Regels:**
- Alle oude URLs krijgen permanente 301-redirects
- Redirects blijven minimaal 2 jaar actief
- Monitoring op 404's voor gemiste mappings

---

## 8. Adrespagina Design-principes

### Actieve Listing Modus

Wanneer een pand actief te koop/huur staat:

```
┌─────────────────────────────────────────────────────────────┐
│  [Foto carrousel - identiek aan huidige listing]            │
├─────────────────────────────────────────────────────────────┤
│  € 349.000                           [Contact makelaar] CTA │
│  Veldstraat 15, 9000 Gent                                   │
│  3 slpk · 2 badk · 145 m² · EPC C                          │
├─────────────────────────────────────────────────────────────┤
│  [Beschrijving van de makelaar]                             │
│  [Kenmerken]                                                │
│  [Locatie & reistijd]                                       │
│  [Makelaarsprofiel]                                         │
├─────────────────────────────────────────────────────────────┤
│  [Gelijkaardige panden - aanbevelingen]                     │
└─────────────────────────────────────────────────────────────┘

→ Historiek en prijsevolutie NIET zichtbaar tijdens actieve verkoop
→ Look & feel identiek aan huidige publicatiepagina
```

### Inactieve/Historische Modus (toekomst)

Wanneer geen actieve listing:

```
┌─────────────────────────────────────────────────────────────┐
│  [Laatste beschikbare foto / streetview]                    │
├─────────────────────────────────────────────────────────────┤
│  Veldstraat 15, 9000 Gent                                   │
│  Laatst te koop: maart 2025 voor € 349.000                  │
├─────────────────────────────────────────────────────────────┤
│  Woninggegevens                                             │
│  ├─ Type: Rijwoning                                         │
│  ├─ Bouwjaar: 1965                                          │
│  ├─ EPC: C (286 kWh/m²)                                     │
│  └─ Kadastraal inkomen: € 1.250                             │
├─────────────────────────────────────────────────────────────┤
│  Prijsgeschiedenis (indien beschikbaar)                     │
│  ├─ 2025: € 349.000 (verkocht)                              │
│  ├─ 2019: € 275.000 (verkocht)                              │
│  └─ 2012: € 195.000 (verkocht)                              │
├─────────────────────────────────────────────────────────────┤
│  Buurtinformatie                                            │
│  [Gemiddelde prijzen] [Voorzieningen] [Reistijden]          │
├─────────────────────────────────────────────────────────────┤
│  [Is dit jouw woning? Claim en volg.]  ← Toekomstige feature│
└─────────────────────────────────────────────────────────────┘
```

---

## 9. Relatie met andere initiatieven

Dit initiatief versterkt en wordt versterkt door andere roadmap-items:

| Initiatief | Relatie |
|------------|---------|
| **Woninginzicht-pagina** | Adres-centrisch model is fundament; woninginzicht wordt onderdeel van adrespagina voor eigenaars |
| **Niche SEO-pagina's** | Adrespagina's linken naar relevante niche-content (EPC, buurt, renovatie) |
| **ChatGPT-integratie** | API kan adres-gebaseerde queries beter beantwoorden |
| **Gepersonaliseerde e-mails** | "Updates voor dit adres" notificaties mogelijk |
| **Aanbevelingen** | Betere "vergelijkbare panden" door adres-data |

---

## 10. Technische afhankelijkheden

### Hergebruik van Vergelijkingspanden

| Component | Beschikbaarheid | Aanpassingen nodig |
|-----------|-----------------|-------------------|
| Adres-matching service | Beschikbaar | Minimal (performance tuning) |
| Adres-normalisatie | Beschikbaar | Geen |
| Publicatie → Adres linking | Beschikbaar | Integratie in Spotto |

### Nieuwe componenten voor Spotto

| Component | Complexiteit | Prioriteit |
|-----------|--------------|------------|
| URL-router voor adrespagina's | Middel | Kritiek |
| Redirect-service oude URLs | Middel | Kritiek |
| Adrespagina template (actief) | Laag | Kritiek |
| Adrespagina template (inactief) | Middel | Fase 4 |
| Monitoring dashboard | Laag | Hoog |

---

## 11. Succes-criteria

### Fase 1-2 (Pilot)

| Metric | Target | Minimum |
|--------|--------|---------|
| SEO rankings behouden | 95% | 90% |
| Redirect success rate | 99.9% | 99% |
| Makelaar-klachten | < 5 | < 20 |
| Data-matching accuracy | 98% | 95% |
| Page load time | < 2s | < 3s |

### Lange termijn

| Metric | Target |
|--------|--------|
| Organisch verkeer groei | +10% YoY |
| Unieke adressen met historiek | 50% binnen 2 jaar |
| User engagement op inactieve pagina's | > 30 sec gemiddeld |

---

## 12. Open vragen

Onderstaande vragen vereisen verder onderzoek of beslissing:

1. **Meerdere actieve listings op één adres**
   - Hoe tonen we dit? Tabs? Primair + alternatieven?
   - Hoe bepalen we "primaire" listing?

2. **Prijsgeschiedenis privacyaspecten**
   - GDPR-implicaties van historische prijzen tonen?
   - Opt-out mogelijkheid voor eigenaars?

3. **Timing t.o.v. andere initiatieven**
   - Prioriteit versus SEO-niche pagina's?
   - Afhankelijkheid van Woninginzicht-pagina?

4. **Nieuwbouw-handling**
   - Blijft dit publicatie-centrisch tot oplevering?
   - Wanneer converteren naar adres?

---

## 13. Volgende stappen

### Korte termijn (Q1 2026)

- [ ] Valideer adres-matching kwaliteit voor pilot-segment
- [ ] Technisch ontwerp redirect-infrastructuur
- [ ] UX-mockups actieve adrespagina
- [ ] Go/no-go meeting met stakeholders

### Middellange termijn (Q2-Q3 2026)

- [ ] Shadow mode implementatie
- [ ] Pilot uitrol voor geselecteerd segment
- [ ] Monitoring & iteratie
- [ ] Beslissing over uitbreiding

---

## Appendix A: Referenties

- Huispedia URL-structuur: `https://huispedia.nl/{gemeente}/{postcode}/{straatnaam}/{huisnummer}`
- SPOTTO-1171: Jira ticket voor technisch onderzoek
- Vergelijkingspanden documentatie: [intern]

## Appendix B: Glossary

| Term | Definitie |
|------|-----------|
| **Publicatie** | Eén listing van een makelaar op Spotto |
| **Adres** | Fysiek adres (straat + huisnummer + eventueel busnummer) |
| **Adrespagina** | Pagina georganiseerd rond een fysiek adres, niet een listing |
| **Dual Display** | Strategie waarbij oude en nieuwe URLs tijdelijk coëxisteren |
| **Property Type Slice** | Migratiestrategie per vastgoedtype |
