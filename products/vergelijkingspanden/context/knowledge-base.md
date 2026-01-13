# Vergelijkingspanden (TRANSDATA) - Knowledge Base

> Auto-generated from Jira project TRANSDATA on 2026-01-13

## Project Overview

The **Dataplatform (TRANSDATA)** project is a B2B tool for real estate agents to find and compare reference properties ("vergelijkingspanden") for property valuations. It integrates with **RealSmart** and pulls data from **Spotto** publications.

**Project Start:** October 2024
**Total Issues:** ~288

---

## Architecture

### Data Pipeline (Databricks)
- **Bronze Layer:** Raw data ingestion from Spotto, external sources
- **Silver Layer:** Cleaned/matched data, address normalization
- **Gold Layer:** Aggregated data models ready for consumption
- **DBT:** Data transformation orchestration

### Backend
- **RealEstateComparison-API:** .NET 8 API with WeGov security
- **GeoServer:** WMS/WFS for map visualization
- **ImageKit:** Image hosting with watermarks

### Frontend
- **RealSmart Module:** Angular-based UI integrated into RealSmart platform

---

## Completed Features (Done/Closed/Resolved)

### 1. Data Pipeline & Infrastructure
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-9 | Data pipeline setup | Closed |
| TRANSDATA-10 | Spotto publication ingestion | Closed |
| TRANSDATA-28 | Production-ready pipelines | Closed |
| TRANSDATA-29 | Git version control | Closed |
| TRANSDATA-36 | Incremental data processing (Databricks) | Resolved |
| TRANSDATA-37 | Incremental data processing (DBT) | Resolved |
| TRANSDATA-41 | API project setup | Done |
| TRANSDATA-45 | Data sync to operational database | Done |
| TRANSDATA-75-77 | DBT model tagging & scheduling | Closed |
| TRANSDATA-245 | Environment setup (test/prod) | Closed |
| TRANSDATA-246 | Daily data ingestion fixes | Closed |

### 2. Address Matching & Geocoding
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-11 | Address cleaning (bus numbers, spaces, etc.) | Closed |
| TRANSDATA-12 | Address existence flag | Closed |
| TRANSDATA-13 | Address matching (primary/secondary rules) | Closed |
| TRANSDATA-26 | Address normalization | Closed |
| TRANSDATA-27 | BEST street & municipality matching | Closed |
| TRANSDATA-31 | BEST house number matching | Closed |
| TRANSDATA-32 | Geocoding | Closed |
| TRANSDATA-35 | Private address fallback | Resolved |

### 3. Map & Visualization
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-33 | Properties on map | Closed |
| TRANSDATA-46 | Basic map with WMS layer | Done |
| TRANSDATA-48 | Property preview popup | Done |
| TRANSDATA-93-94 | WMS query & proxy | Closed |
| TRANSDATA-101-105 | WFS markers & preview | Closed |
| TRANSDATA-179 | WFS markers (real markers vs dots) | Closed |

### 4. Filtering & Search
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-47 | Property filters (status, type, year, transaction) | QA Testing |
| TRANSDATA-97-100 | Filter UI, WMS query filters, result count | Closed/Resolved |
| TRANSDATA-257 | Search by postal code | Resolved |
| TRANSDATA-271 | Filter bug fixes | Closed |

### 5. Property Details & Data
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-17 | Core property attributes | Closed |
| TRANSDATA-20 | Flex properties | Closed |
| TRANSDATA-44 | Gold model (asking price, EPC, rooms, etc.) | Done |
| TRANSDATA-50 | Property detail page | Closed |
| TRANSDATA-69 | Indexed asking price | Done |
| TRANSDATA-74 | Gold model per address | Closed |
| TRANSDATA-183 | Indexed price in reference properties | Closed |
| TRANSDATA-184 | Price history in Databricks | Closed |

### 6. Comparison Workflow
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-49 | Select/deselect property on map | Closed |
| TRANSDATA-51 | Comparison preview panel | Resolved |
| TRANSDATA-52 | Side-by-side comparison view | Resolved |
| TRANSDATA-53 | Remove comparison property | Resolved |
| TRANSDATA-165 | Link comparison to dossier | Closed |
| TRANSDATA-174 | Saved comparisons overview | Resolved |
| TRANSDATA-177 | Comparison naming | Resolved |
| TRANSDATA-178 | Historical comparisons | Resolved |
| TRANSDATA-192 | New tab doesn't create new comparison | Closed |
| TRANSDATA-199 | Assignment ID in URL | Closed |

### 7. Export & Documents
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-186 | Document metadata sync | Resolved |
| TRANSDATA-249 | French translation of export | Ready for Test |
| TRANSDATA-250 | Show only existing documents | Resolved |
| TRANSDATA-251 | Download previous exports | Resolved |

### 8. External Data Sources (Cadastral/Geodata)
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-54 | Cadastral parcels import (VL/BRU/WAL) | Resolved |
| TRANSDATA-55 | Transformation pipeline for matching | Resolved |
| TRANSDATA-56 | Shapefile creation | Resolved |
| TRANSDATA-57 | GRB - Built/unbuilt parcels | Resolved |
| TRANSDATA-58 | Zoning (Gewestplan) | Resolved |
| TRANSDATA-59 | Building type calculation | Closed |
| TRANSDATA-60-62 | Housing quality (CA, Herstelvordering, OO) | Resolved |
| TRANSDATA-63-64 | Flood risk (P-score, G-score) | Resolved |
| TRANSDATA-65 | Housing typology | Resolved |
| TRANSDATA-66 | Neglected business buildings | Resolved |
| TRANSDATA-198 | DSI - Urban planning info | Resolved |

### 9. UI/UX Features
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-158 | Pinned properties (organization level) | Closed |
| TRANSDATA-159 | Highlight property attributes | Closed |
| TRANSDATA-164 | Show/hide attributes for export | Closed |
| TRANSDATA-169-170 | Exit surveys | Closed/Resolved |
| TRANSDATA-171 | Quarterly data consent recheck | Closed |
| TRANSDATA-172 | Pinned properties (assignment level) | Closed |
| TRANSDATA-176 | Scrambled private addresses | Closed |
| TRANSDATA-180 | Animated drawer | Closed |
| TRANSDATA-181 | Watermark logo on photos | Closed |
| TRANSDATA-182 | Layout redesign (2 columns) | Resolved |

### 10. Location Analysis
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-161 | Location analysis (mobiscore) | Closed |
| TRANSDATA-173 | Location analysis review | Closed |
| TRANSDATA-267 | Mobiscore v2 | Ready for Test |
| TRANSDATA-268 | Mobiscore averages per municipality/district | Resolved |

### 11. Integrations
| Issue | Feature | Status |
|-------|---------|--------|
| TRANSDATA-265 | Bizlocator provider mapping | Ready for Test |
| TRANSDATA-266 | Bizlocator pictures hosting | Ready for Test |
| TRANSDATA-280 | ImageKit optimizations | Closed |

---

## In Progress

| Issue | Feature | Assignee |
|-------|---------|----------|
| TRANSDATA-16 | Spotto property database | - |
| TRANSDATA-25 | Analysis | - |
| TRANSDATA-47 | Property filters | QA Testing |
| TRANSDATA-72 | Analytical Ant (V1 release) | - |
| TRANSDATA-78 | General tasks (Referentiepanden) | - |
| TRANSDATA-157 | Personalization | - |
| TRANSDATA-160 | Level 3 info | - |
| TRANSDATA-187 | Suggestions | - |
| TRANSDATA-273 | Duplicate/incorrect price history | - |
| TRANSDATA-286 | Filter state persistence bug | Laura V. |

---

## Backlog / To Do (Notable)

| Issue | Feature | Priority |
|-------|---------|----------|
| TRANSDATA-19 | Sequence publication data | FA |
| TRANSDATA-22 | Most recent property in sequence | FA |
| TRANSDATA-38 | Business testing spike | Ready for Dev |
| TRANSDATA-153 | Free tier browsing | FA |
| TRANSDATA-155 | Export only for Spotto users | FA |
| TRANSDATA-156 | Subscription access | FA |
| TRANSDATA-162 | Rent analysis preview | FA |
| TRANSDATA-163 | Price history chart | FA |
| TRANSDATA-188 | HQ read-only access | FA |
| TRANSDATA-189 | Rent analysis upgrade | FA |
| TRANSDATA-241 | .NET 10 upgrade | FA |
| TRANSDATA-255 | Tech analysis: rent preview redux | To Do |
| TRANSDATA-262 | Export custom visibilities | FA |
| TRANSDATA-285 | EventBus v2 upgrade | TA |
| TRANSDATA-287 | Reference property marker | Ready for Dev |
| TRANSDATA-288 | Mobiscore feedback states | FA |

---

## UI/UX Design

### Main Screens

**1. Map View (Primary Interface)**
- Full-width map with property markers (WFS layer)
- Collapsible filter panel on the left
- Property count indicator showing results
- Click marker → preview popup with key details
- Select properties to add to comparison

**2. Filter Panel**
- Property type selector (residential, commercial, etc.)
- Status filter (for sale, sold, rented, etc.)
- Transaction type (sale, rent)
- Year range (construction/renovation)
- Price range slider
- Postal code search
- Clear filters / Apply buttons

**3. Property Detail View**
- Two-column layout
- Left: Photo gallery with thumbnails
- Right: Property attributes in structured sections
- Address (scrambled for private listings)
- Key metrics: price, surface, EPC, rooms
- Location analysis (Mobiscore with breakdown)
- Action buttons: Add to comparison, Pin

**4. Comparison Panel (Drawer)**
- Animated slide-in drawer from right
- Selected properties as cards
- Remove button per property
- "Compare" button to open full comparison
- Save comparison with custom name

**5. Side-by-Side Comparison**
- Properties in columns
- Attribute rows for easy comparison
- Highlight differences between properties
- Toggle attribute visibility for export
- Export button (PDF generation)

**6. Saved Comparisons Overview**
- List of previously saved comparisons
- Link to dossier/assignment
- Date created
- Quick actions: Open, Delete

### Design Patterns
- **Primary action color:** Yellow/Gold buttons
- **Header:** Blue accent bar
- **Cards:** White with subtle shadows
- **Data tables:** Zebra striping for readability
- **Icons:** Consistent iconography for property types

---

## Key Data Models

### Property Attributes (Gold Model)
- Asking price (+ indexed)
- Duration on market
- Price change count
- Plot surface / Built surface
- EPC rating
- Number of rooms
- Building type (based on facades)
- Construction year / Renovation year
- Garden surface / Terrace
- Documents
- Online status
- Property type
- is_private / is_official flags

### Matching Logic
**Primary matching:**
1. Full address
2. Coordinates
3. EPC number

**Secondary matching (combination of):**
- Built surface
- Construction/renovation year
- Plot surface
- Number of bedrooms
- Broker reference

---

## External Data Sources

| Source | Data | Region |
|--------|------|--------|
| BEST | Address validation | Belgium |
| GRB/Kadaster | Parcels, building contours | VL/BRU/WAL |
| Gewestplan | Zoning/destination | VL/BRU/WAL |
| POI Vlaanderen | Housing quality (CA, OO, Herstelvordering) | VL |
| Waterinfo | Flood risk | VL/BRU/WAL |
| Gezondheidsindex | Price indexation | Belgium |
| DSI | Urban planning | VL |
| Bizlocator | Commercial property data | Belgium |

---

## Team Members (from issues)

- Bart Pinnock (Reporter/PM)
- Laura Vastesaeger (Developer)
- Jelle Vandendriessche (Developer)
- Arno Dhondt (DevOps)
- Admir Radaj (Testing)

---

## Key URLs & Resources

- **Confluence:** https://orisnv.atlassian.net/wiki/spaces/IMMOX/
- **Miro:** https://miro.com/app/board/uXjVINsMYXo=/
- **Figma:** https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-|-Spotto
- **Azure DevOps:** https://dev.azure.com/build-orisnv/Dataplatform
- **Databricks:** https://adb-697404674670473.13.azuredatabricks.net/
- **GeoServer:** https://geoserver.orisnv.be/

---

## Release History

| Date | Release | Key Features |
|------|---------|--------------|
| 2025-12-01 | TRANSDATA-248 | Major release with data sync |
| 2025-07-01 | Bridging Beaver | API setup, WMS/WFS integration |
| 2025-06-19 | Analytical Ant | Initial map and comparison features |

---

*Last updated: 2026-01-13*
