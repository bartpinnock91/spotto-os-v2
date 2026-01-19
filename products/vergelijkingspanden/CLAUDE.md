# Vergelijkingspanden

**Type:** B2B Tool
**Jira Project:** TRANSDATA
**Status:** Active Development (since Oct 2024)

## Overview

Comparable properties search tool for real estate agents. Helps agents find similar properties to generate a pricing basis for properties they're acquiring for inventory. Integrated into the RealSmart platform.

## Key Features

### Map-Based Property Search
- Interactive map with WMS/WFS layers showing property markers
- Filter by property type, status, year, transaction type
- Search by postal code or draw on map
- Property preview popup on hover/click

### Property Comparison Workflow
- Select multiple properties for side-by-side comparison
- Pin properties at organization or assignment level
- Save and name comparisons for future reference
- Link comparisons to dossiers in RealSmart

### Property Details
- Core attributes: price, EPC, rooms, surface, construction year
- Indexed asking price (adjusted for inflation)
- Price history and duration on market
- Photo gallery with watermarked images
- Location analysis (Mobiscore)

### Data & Export
- Export comparison reports (NL/FR)
- Download previous exports
- Show/hide specific attributes in export
- Document metadata from Spotto

### External Data Integration
- Cadastral parcels (VL/BRU/WAL)
- Flood risk scores (P-score, G-score)
- Housing quality indicators
- Zoning/urban planning info (DSI)

## Target Users

- Real estate agents (primary)
- Property appraisers

## Links

- **Jira Project:** [TRANSDATA](https://orisnv.atlassian.net/jira/software/projects/TRANSDATA)
- **Figma Designs:** [RS | Spotto](https://www.figma.com/design/D88mnHjMhaqL2mVFSTSEck/RS-%7C-Spotto)
- **Confluence:** [IMMOX Wiki](https://orisnv.atlassian.net/wiki/spaces/IMMOX/)
- **Codebase:** [Dataplatform](https://dev.azure.com/build-orisnv/_git/Dataplatform) (Azure DevOps)

---

## Folders

- `context/` - Personas, competitors, feature details
- `roadmap/` - Product roadmap
- `drafts/` - WIP user stories
- `archive/` - Completed stories from Jira
