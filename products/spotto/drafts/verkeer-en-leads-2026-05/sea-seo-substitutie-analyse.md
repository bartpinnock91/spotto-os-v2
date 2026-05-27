# SEA → SEO substitutie analyse

**Periode:** jan 2025 – apr 2026 (16 maanden)
**Vraag:** als SEA spend verder verlaagd wordt, welk deel van het verloren betaald verkeer komt terug via SEO?
**Data:** Google Ads CSV, GA4, Google Search Console (16 maanden dagelijkse organic data)
**Aanvullende context:** rapporteringspresentaties feb/mrt/Q1+april 2026, seo-strategy doc

## Conclusie

**Substitutie-ratio voor verdere SEA-cuts: 10%.**

Voor elke 100 paid sessies die verloren gaan door verdere SEA-bezuiniging, mag worden gerekend op ~10 sessies die via SEO terugkomen. De overige 90 zijn netto verkeersverlies.

## Onderbouwing

### De historische periode (sept 2025 – apr 2026)

| Metric | Nov 2025 (peak) | Apr 2026 (trough) | Δ |
|---|---:|---:|---:|
| SEA spend | €12.279 | €5.114 | −58% |
| GA4 Paid sessies | 90.738 | 50.986 | −44% |
| GSC Organic clicks | 168.559 | 199.708 | +18% |

### Waarom 10% en niet hoger

Met de volledige 16-maands GSC historie blijkt:
- **Organic groeide al sterk vóór de cut:** +2,6%/maand gemiddeld over jan–nov 2025
- **YoY apr 2025 → apr 2026: +50%** — dat is Spotto's natuurlijke SEO groeitempo
- **Op die groeisnelheid alleen** zou apr 2026 al ~200k organic clicks zijn — wat we ook werkelijk zagen
- **De gedocumenteerde SEO-investeringen** (Warm Welkom pilot, Hygiëne project, structured data, GEO/AI SEO) verklaren deze structurele groei zonder dat substitutie nodig is

Met andere woorden: het grootste deel van de organic groei zou ook zonder SEA-cut zijn gebeurd.

### Waarom 10% en niet 0%

- **Branded substitutie is bewezen:** branded query CTR sprong van ~65% → ~83% direct na de branded exclusion van 21 januari 2026 — dat is een schoolvoorbeeld van substitutie, maar op een klein volume (~2,6% van organic)
- **Sommige overlap-effecten op long-tail commerciële queries** zijn plausibel ook al kunnen we ze niet direct meten via CTR

### Het tegenbewijs dat hogere getallen ontkracht

- **Non-branded CTR bleef vlak** (3,06% → 3,02%) ondanks +20% impressies — gebruikers klikten niet vaker organic
- **April-reversie:** toen SEA verder daalde van mrt naar apr, daalde organic óók (van 240k naar 200k clicks) — niet wat substitutie zou voorspellen
- **De maartelijkse cuts werden door het team stopgezet** wegens reële lead-daling — empirisch bewijs dat verdere cuts NIET door SEO worden opgevangen

## Wat betekent dit voor budgetplanning

| Verdere SEA-cut | Verwacht paid sessie-verlies | Verwacht SEO-herstel (10%) | Netto verlies |
|---|---:|---:|---:|
| €500/mnd minder | ~5.000 sessies | ~500 sessies | **~4.500/mnd** |
| €1.000/mnd minder | ~10.000 sessies | ~1.000 sessies | **~9.000/mnd** |
| €2.000/mnd minder | ~20.000 sessies | ~2.000 sessies | **~18.000/mnd** |

*Berekend op basis van Apr 2026 ratio: €5.114 spend → 50.986 paid sessies = ~10 sessies per €*

## Belangrijke kanttekeningen

1. **De goedkope substitutie zit op.** De 100%-substitutie effect uit branded exclusion is een eenmalig effect dat al is gerealiseerd. Verdere cuts zitten op campagnes waar dit effect niet meer geldt.
2. **De organic groei blijft komen** — gedreven door SEO-roadmap, niet door SEA-keuzes. Dat is een onafhankelijk traject, niet een compensatiemechanisme.
3. **Het team observeerde zelf reëel lead-verlies** na de maartelijkse cuts (vandaar de twee geannuleerde extra cuts). Consistent met lage substitutie.

## Aanbeveling

- **Plan met 10% substitutie.** Bij €1.000 verdere maandelijkse SEA-bezuiniging: reken op ~9.000 sessies minder per maand netto.
- **Verdere bezuinigingen rechtvaardigen via efficiency**, niet via "SEO compenseert". De huidige CPA-trend is positief (van €3,07 → €1,83 per conversie); dat is het juiste verhaal.
- **Investeer in SEO als eigen kanaal**, niet als SEA-vervanger. De Warm Welkom pilot opschalen naar meer postcodes zal naar verwachting meer organic verkeer opleveren dan welke SEA-bezuiniging dan ook kan compenseren.

## Data sources

- `campaigns_monthly.csv` — Google Ads export, sep 2025 – mei 2026
- GA4 property **Spotto - V2** (491908260)
- Google Search Console `sc-domain:spotto.be`, dagelijkse data jan 2025 – mei 2026
- Spotto reporting decks februari / maart / Q1+april 2026
- `seo-strategy.md` — actieve SEO-projecten Q1 2026
- Berekeningen in `_analysis.py` + `_analysis_long.py`
