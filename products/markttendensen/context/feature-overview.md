# Markttendensen - Feature Overview

> Based on Figma designs (2026-01-13)

## Product Overview

**Markttendensen** is a B2B market insights dashboard for real estate professionals. It provides comprehensive analytics on property markets across Belgium, enabling agents to understand pricing trends, supply/demand dynamics, competition, and demographics for specific regions.

**Figma Section:** [Markttendensen Overview](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1840-15473)

---

## Core Concepts

### Market Types
Users can analyze four distinct market segments:
| Market | Description |
|--------|-------------|
| **Koopmarkt** | Purchase/sales market for residential properties |
| **Huurmarkt** | Rental market |
| **Nieuwbouwvergunningen** | New construction permits |
| **Studentenkamers** | Student housing market |

### Geographic Hierarchy
Data is organized in a hierarchical structure:
- **België** (Country)
  - **Gewesten** (Regions): Vlaanderen, Wallonië, Brussels
    - **Provincies** (Provinces)
      - **Gemeentes** (Municipalities): e.g., Gent
        - **Wijken** (Neighborhoods): e.g., Bloemekenswijk, Mariakerke, Wondelgem

### Property Types
Filters available for property types:
- Huizen (Houses)
- Appartementen (Apartments)
- More TBD based on market type

### Time Periods
Data can be filtered by year (e.g., 2025, 2024)

---

## Main Features

### 1. Homepage / Dashboard Selection

**Figma:**
- [Nieuwe zoekopdrachten (empty state)](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1618-16876)
- [Nieuwe zoekopdrachten (with onboarding)](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1822-9187)
- [Opgeslagen dashboards](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1816-8889)

**Two modes:**
- **Nieuwe zoekopdrachten** - Start a new market analysis
- **Opgeslagen dashboards** - View saved/pinned dashboards

**Market category cards** showing:
- Icon per market type
- Short description
- CTA: "Ontdek de koopmarkt/huurmarkt/..."

**Onboarding:** Tooltip explaining users can pin charts and track market evolution.

---

### 2. Vraag & Aanbod (Supply & Demand)

**Figma:** [Vraag & Aanbod tab](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1615-7394)

**Purpose:** Compare pricing and supply across regions with geographic context.

**Components:**

#### Interactive Map
- Colored regions showing price variations
- Labels with neighborhood names and % change indicators
- Toggle: Vraagprijzen / Aanbod view

#### Vraagprijzen Huizen (Asking Prices) Table
| Column | Description |
|--------|-------------|
| Gemeente/Wijk | Location name |
| Gemiddelde prijs | Average asking price |
| Verschil | % difference vs selected area |

**Comparison rows:**
- Selected neighborhood (highlighted)
- Surrounding neighborhoods (Wondelgem, Mariakerke)
- Regional benchmarks (Vlaanderen, België)

#### Aanbod Huizen (Supply) Table
Same structure, showing supply volumes and changes.

---

### 3. Trends & Inzichten (Trends & Insights)

**Figma:**
- [Trends & Inzichten (empty dashboard)](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1618-8815)
- [Trends & Inzichten (with chart)](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1838-14258)
- [Trends & Inzichten (auto-save tooltip)](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1839-14795)

**Purpose:** Deep-dive into market indicators with customizable dashboards.

#### KPI Indicator Cards (6 cards)
| Indicator | Example | Description |
|-----------|---------|-------------|
| Prijs per m² | €1145 | Average price per square meter |
| Panden online | 20 | Properties currently listed |
| Opzoekingen per maand | 20.000 | Monthly search volume |
| Aanvragen per pand | 6.3 | Contact requests per property |
| Doorlooptijd | 63 dagen | Average time on market |
| Makelaars actief | 15 | Active agents in area |

Each card shows:
- Value
- Unit/label
- YoY change (+ or - %)

#### Prijsindicatoren Table
| Column | Description |
|--------|-------------|
| Gemeente/Wijk | Location |
| Gem. Vraagprijs | Average asking price |
| Prijs per m² | Price per square meter |

Eye icon to toggle column visibility (for dashboard pinning).

#### Aanbodindicatoren Table
| Column | Description |
|--------|-------------|
| Aanbod | Number of properties |
| Aanbodgroei | Supply growth |
| Doorlooptijd | Time on market (days) |

#### Vraagindicatoren Table
Same structure for demand-side metrics.

#### Custom Dashboard Builder
- Right panel: "Jouw dashboards"
- Select metrics from tables to visualize
- Line chart showing evolution over time (Q1 2024 - Q2 2025)
- Multiple series: Compare neighborhoods (Bloemekenswijk, Wondelgem, Mariakerke)
- "Grafiek toevoegen" button to add more charts
- "Opslaan als dashboard" to save configuration
- Auto-save tooltip when pinning/unpinning charts

---

### 4. Concurrenten & Kansen (Competitors & Opportunities)

**Figma:** [Concurrenten & Kansen tab](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1602-13119)

**Purpose:** Analyze competitive landscape and identify market opportunities.

#### Grootste Kantoren (Top Agencies)
Ranking table by properties sold (last 12 months):
| Rank | Agency/Area | Count |
|------|-------------|-------|
| 1 | Bloemekenswijk | 20 |
| 2 | Wondelgem | 19 |
| 3 | Mariakerke | 16 |

#### Market Analysis Sliders

**Marktconcentratie (Market Concentration)**
- Scale: Weinig geconcentreerd ↔ Sterk geconcentreerd
- Shows if market is dominated by few large players or distributed

**Marktevenwicht (Market Balance)**
- Scale: Vraag groter dan aanbod ↔ Aanbod groter dan vraag
- Supply vs demand balance indicator

**Vraagdruk (Demand Pressure)**
- Scale: Hoge druk ↔ Lage druk
- Contact requests per property relative to neighboring areas

#### Map Visualization
- Same map component as Vraag & Aanbod
- Colored overlays showing competitive zones

---

### 5. Demografie (Demographics)

**Figma:** [Demografie tab](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1602-14864)

**Purpose:** Understand the population characteristics of an area.

#### Leeftijdsklasse (Age Distribution)
- Bar chart showing population by age bracket
- Age ranges: 18-25, 26-30, 31-35, 36-40, 41-45, 46-50, 51-55, 56-60, 61-65, 66-70, 71-75, 76-80, 81+

#### Verhouding Eigenaar/Huurder (Owner vs Renter)
- Side-by-side bar comparison
- "Eigenaars" vs "Huurders" count

#### Gemiddeld Fiscaal Inkomen (Average Taxable Income)
- Bar chart by age group
- Shows income distribution across demographics
- Percentage scale (10-30%)

---

## UI Patterns

### Navigation
- **Breadcrumbs:** België > Gent > Bloemekenswijk
- **Tab bar:** Vraag & aanbod | Trends & inzichten | Concurrenten & kansen | Demografie
- **Dynamic title:** "Koopmarkt van Huizen in Gent voor 2025" with dropdown selectors

### Filter Controls
- Dropdown selectors for: Market type, Property type, Location, Year
- Each with chevron-down icon
- Styled as inline text with underline highlight

### Data Tables
- White background with subtle borders
- Row highlighting for selected area
- Eye icons to toggle visibility
- Percentage indicators colored: green (positive), red (negative)

### Charts
- Line charts for evolution over time
- Bar charts for distributions
- Legend with color-coded series
- Toggleable series visibility

### Dashboard Panel
- Right-side panel for saved dashboards
- "Opslaan als dashboard" primary button
- "Verwijder dashboard" secondary action
- Dashboard title editable

### Map Component
- Shared component with Vraag & Aanbod and Concurrenten tabs
- Colored regions with opacity variations
- Tooltips showing area name and key metric
- Legend: Vraagprijzen / Aanbod toggle

---

## Data Displayed

### Price Data
- Gemiddelde vraagprijs (Average asking price)
- Prijs per m² (Price per square meter)
- Geïndexeerde prijs (Indexed price)

### Supply Data
- Aantal panden online (Properties listed)
- Aanbodgroei (Supply growth %)
- Doorlooptijd (Time on market in days)

### Demand Data
- Opzoekingen per maand (Monthly searches)
- Aanvragen per pand (Requests per property)
- Vraagdruk (Demand pressure)

### Market Structure
- Marktconcentratie (Market concentration)
- Marktevenwicht (Supply/demand balance)
- Actieve makelaars (Active agents)

### Demographics
- Leeftijdsverdeling (Age distribution)
- Eigenaar/huurder ratio (Owner/renter split)
- Inkomensverdeling (Income distribution)

---

## Comparison Context

All metrics are shown in comparison to:
1. **Selected area** (e.g., Bloemekenswijk) - highlighted row
2. **Surrounding neighborhoods** (e.g., Wondelgem, Mariakerke)
3. **Regional average** (Vlaanderen)
4. **National average** (België)

Percentage differences shown as:
- `+3%` (green) - higher than reference
- `-5%` (red) - lower than reference

---

## Figma Reference

All screens in Section 1 (node-id=1840-15473):

| Screen | Node ID | Link |
|--------|---------|------|
| Vraag & Aanbod | 1615:7394 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1615-7394) |
| Homepage (empty) | 1618:16876 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1618-16876) |
| Opgeslagen dashboards | 1816:8889 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1816-8889) |
| Homepage (onboarding) | 1822:9187 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1822-9187) |
| Trends & Inzichten (empty) | 1618:8815 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1618-8815) |
| Trends & Inzichten (empty dashboard) | 1839:15164 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1839-15164) |
| Trends & Inzichten (with chart) | 1838:14258 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1838-14258) |
| Trends & Inzichten (auto-save) | 1839:14795 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1839-14795) |
| Concurrenten & Kansen | 1602:13119 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1602-13119) |
| Demografie | 1602:14864 | [Open](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto?node-id=1602-14864) |

---

*Last updated: 2026-01-13*
