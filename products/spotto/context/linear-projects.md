# Spotto Linear Projects Overview

This document provides an overview of all active projects tracked in Linear (Eikhart workspace, Spotto team).

## Project Summary

| Project | Status | Priority | Lead | Focus Area |
|---------|--------|----------|------|------------|
| LLM / GEO / AI SEO | In Progress | - | Ramon | AI Search Visibility |
| Wikipedia lemma Spotto | Waiting | - | Ramon | Authority Building |
| Pagerank Flow | To Monitor | - | Ramon | Internal Linking |
| Structured Data | In Progress | - | Ramon | Rich Results |
| Warm welkom | In Progress | High | Spotto team | Landing Page Quality |
| Hygiëne | In Progress | Medium | Ramon | Technical SEO |
| Autoriteit | In Progress | High | Ramon | Brand Authority |
| Research locatiepagina's 2026 | Backlog | - | Spotto team | Future SEO |
| Requirements adrespagina's | Backlog | - | - | Future Product |
| Autometas | Canceled | - | Ramon | Meta Generation |

---

## Active Projects Detail

### LLM / GEO / AI SEO
**Status:** In Progress | **Start:** January 2026

Preparing Spotto for the AI search era. Focuses on:
- Tracking visibility in LLM-based search (ChatGPT, Perplexity, etc.)
- Expanding "About" content for better AI understanding
- Evaluating GEO tracking tools (peec.ai, Profound, trackerly.ai)

**Key Issues:**
- SPO-43: GEO-tracking implementation
- SPO-66: About-sectie Spotto uitbreiden

---

### Wikipedia lemma Spotto
**Status:** Waiting | **Start:** June 2025

Building Wikipedia presence for brand authority and SEO benefits.

**Strategy:**
1. First create CIB (industry federation) Wikipedia page
2. Build credible source base
3. Eventually create Spotto lemma with proper references

**Key Issues:**
- SPO-25: Wikipedia - CIB-pagina (To Monitor)
- SPO-53: Bronnen (Sources) (To Monitor)
- SPO-54: Voorstel tekst (Proposed text) (To Monitor)
- SPO-64: Search Wikipedia opportunities for Spotto (Todo)

---

### Pagerank Flow
**Status:** To Monitor | **Start:** May 2025

Optimizing internal link structure to improve page authority flow.

**Key Issues:**
- SPO-22: Historie bijhouden -> Monitoring instellen linklijst URLs (In Progress)
- SPO-24: Implementatie ranking (Done)

---

### Structured Data
**Status:** In Progress | **Start:** November 2025

Implementing schema.org structured data for property pages to enable rich results.

**Key Issues:**
- SPO-47: Implementeer Structured Data voor woningpagina's (Todo)
- SPO-60: DataLayer json in HTML (To Refine)

**Technical Approach:**
- Add JSON datalayer to HTML with:
  - House properties
  - Location data
  - Offer properties (price, transaction type)
  - Provider info (including coordinates)

---

### Warm welkom
**Status:** In Progress | **Priority:** High | **Start:** September 2025

Creating welcoming, personalized landing page content for property listing pages.

**Pilot:** Testing on 20 postcodes with:
- Location-specific quotes
- Property type specific messaging
- UGC analysis from user surveys

**Key Issues:**
- SPO-49: Monitoren resultaten 20 pagina's (In Progress)
- SPO-45: Quotes verzamelen per transactie/property type (Done)
- SPO-44: Ingeven van de 20 (Done)
- SPO-32: Implementatie nakijken (Done)

---

### Hygiëne (Deduplication)
**Status:** In Progress | **Priority:** Medium | **Start:** April 2025

Addressing duplicate content issues that affect large real estate sites.

**Problem Areas:**
- Postcode-based URL duplicates
- Property type URL duplicates
- Case sensitivity issues
- Pagination problems
- Soft-404s in low-inventory areas

**Key Issues:**
- SPO-5: By postcode (To Refine)
- SPO-6: By type (To Monitor)
- SPO-9: Uppercase/lowercase/CamelCase (To Monitor)
- SPO-10: Soft-404s in kleinere gemeenten (To Monitor)
- SPO-16: Alle links en canonicals lowercase (Waiting)
- SPO-33: Paginatie makelaars (Waiting)
- SPO-65: EPC filters PLP indexeerbaar (To Refine)

---

### Autoriteit
**Status:** In Progress | **Priority:** High | **Start:** April 2025

Building Spotto's authority through data-driven content and EPC analysis.

**Focus Areas:**
1. **ROI-calculator:** Show price differences between EPC labels
2. **Koopsnelheid:** How much faster do sustainable homes sell?
3. **Regional highlights:** Identify sustainable municipalities for stories
4. **Policy analysis:** Compare regional sustainability with government targets

**Key Issues:**
- SPO-1: EPC analyse - inspiratiesessie met stakeholders (In Progress)
- SPO-14: Beleid versus regio: regio's highlighten (Done)
- SPO-56: EPC poc bekijken (Done)

---

## Backlog Projects

### Research traject 2026: locatiepagina's
**Planned Start:** April 2026

Research for creating location-based SEO pages at various geographic levels:
- Gemeenten (municipalities)
- Deelgemeenten (sub-municipalities)
- Wijken (neighborhoods)
- Sectoren/buurten (sectors)

**Open Question:** SPO-63 - Is neighborhood-level SEO valuable?

### Requirements adrespagina's
Concept: "A la Huispedia" - permanent insight pages per property address.

---

## Canceled/Archived Projects

### Autometas
**Status:** Canceled

Automatic generation of meta titles/descriptions. Project deprioritized but concept may be revisited (SPO-58 remains in Todo).

### Blog next steps
**Status:** Archived (Done)

Content pruning analysis completed (SPO-12).

---

## Issue Status Legend

| Status | Meaning |
|--------|---------|
| Todo | Ready to start |
| In Progress | Currently being worked on |
| To Refine | Needs more definition/research |
| Waiting | Blocked or waiting for external input |
| To Monitor | Implemented, monitoring results |
| Done | Completed |
| Canceled | Will not be done |
| Duplicate | Merged with another issue |
