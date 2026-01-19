# Spotto SEO Strategy

This document captures the SEO strategy and ongoing initiatives as tracked in Linear (Eikhart workspace).

## Core SEO Challenges

### 1. Duplicate Content (Hygiëne Project)

**Problem:** Large sites (100k+ pages) with minimal content differences between pages face "duplicate content by URL" issues. This is particularly relevant for marketplaces with listing pages (PLP) and pagination like Spotto.

**Goals:**
1. Build Google's trust that Spotto always sends users to the right page → more traffic
2. When users land on the correct page → higher conversion rate

**Key Issues Being Addressed:**
- **By postcode** (SPO-5): Duplicate content issues with postcode-based URLs
- **By type** (SPO-6): Property type URL deduplication
- **Uppercase/lowercase/CamelCase** (SPO-9): URL case inconsistencies
- **Soft-404s in smaller municipalities** (SPO-10): Pages with no listings showing as soft-404s
- **Pagination** (SPO-7): Pagination SEO issues including title tags, h2, rel=next/prev

**Measurement:**
- GSC report: "Duplicate, Google chose different canonical than user"
- Baseline April 2025: 357k duplicate pages

**Technical Solutions:**
- All links and canonicals standardized to lowercase (SPO-16)
- All redirects & canonicals pointing to `/immo/overzicht` (SPO-17)
- Expand search area when no listings exist in a location (SPO-20)

---

## SEO Projects Overview

### Project: Hygiëne (In Progress)
**Lead:** Ramon Eijkemans
**Priority:** Medium
**Focus:** Technical SEO hygiene, especially for larger cities with content split by postcode, type, and overview pages.

**Active Issues:**
| ID | Title | Status |
|----|-------|--------|
| SPO-5 | By postcode | To Refine |
| SPO-6 | By type | To Monitor |
| SPO-9 | Uppercase/lowercase/CamelCase | To Monitor |
| SPO-10 | Soft-404s in smaller municipalities | To Monitor |
| SPO-16 | All links and canonicals lowercase | Waiting |
| SPO-33 | Pagination makelaars | Waiting |
| SPO-65 | EPC filters PLP indexable | To Refine |

---

### Project: Pagerank Flow (To Monitor)
**Lead:** Ramon Eijkemans
**Focus:** Internal link optimization and monitoring search position improvements.

**Key Issue:**
- SPO-22: Track history of URL positions in link list (In Progress)

---

### Project: Warm Welkom (In Progress)
**Lead:** Spotto team
**Priority:** High
**Focus:** Improving landing page quality with localized "warm welcome" content.

**Goal:** Create welcoming, location-specific content for property listing pages with:
- Location-specific quotes and descriptions
- UGC analysis from Typeform responses
- Monitoring results across 20 pilot postcodes

**Pilot Postcodes:**
2000, 2018, 2100, 2300, 3000, 3150, 3200, 3290, 3500, 3550,
8000, 8200, 8370, 8400, 8800, 8870, 9000, 9120, 9160, 9200

**Active Issues:**
| ID | Title | Status |
|----|-------|--------|
| SPO-49 | Monitor results 20 pages warm welkom | In Progress |
| SPO-45 | Collect quotes by transaction type & property type | Done |

---

### Project: Structured Data (In Progress)
**Lead:** Ramon Eijkemans
**Focus:** Implementing structured data for property pages to improve rich results in search.

**Key Issues:**
| ID | Title | Status |
|----|-------|--------|
| SPO-47 | Implement Structured Data for property pages | Todo |
| SPO-60 | DataLayer JSON in HTML | To Refine |

**Implementation Notes:**
- Need JSON datalayer in HTML with property data (house properties, location, offer properties, provider info including coordinates)

---

### Project: Autometas (Canceled)
**Focus:** Automatic meta description/title generation based on property data.

**Remaining Issue:**
- SPO-58: Autometas (title algorithm) - Todo

**Concept:**
Replace generic meta descriptions like:
```html
<meta name="description" content="Appartement in MOERBEKE-WAAS. Bekijk de foto's...">
```
With data-rich descriptions including property type, transaction type, location, price, bedrooms, EPC, etc.

---

## Meta & Title Optimization

### Current Problem (SPO-50, SPO-51)
Google often chooses its own descriptions instead of using the provided meta descriptions. The current descriptions are generic and marketing-focused rather than informative.

### Proposed Solution
Change meta descriptions to be more content-focused:
> {property_type} {transaction} in {location} {postal_code}. Vraag/huurprijs: {amount}. {bedrooms} {EPC label}. Bouwjaar...

---

## GEO / LLM / AI SEO (New Initiative)

### Project: LLM / GEO / AI SEO (In Progress)
**Lead:** Ramon Eijkemans
**Start:** January 2026
**Focus:** Optimizing for AI search engines and LLMs.

**Key Issues:**
| ID | Title | Status |
|----|-------|--------|
| SPO-43 | GEO-tracking | In Progress |
| SPO-66 | Expand About section Spotto | To Refine |

**Tools Being Evaluated:**
- peec.ai (German, 3x cheaper than Meridian)
- Profound (US-based)
- trackerly.ai

**Market Context:**
- ChatGPT handles ~4% of Google's daily search volume
- AI search visibility tracking is becoming essential

---

## Wikipedia & Authority Building

### Project: Wikipedia lemma Spotto (Waiting)
**Lead:** Ramon Eijkemans
**Focus:** Creating Wikipedia presence for brand authority.

**Strategy:**
1. Create CIB (real estate professional federation) Wikipedia page first (SPO-25)
2. Build sources and references (SPO-53)
3. Propose text for review (SPO-54)
4. Search for Spotto-relevant Wikipedia opportunities (SPO-64)

---

## Future Initiatives

### Location Pages Research (2026)
**Project:** Research traject 2026: uitzoeken benodigdheden & effort locatiepagina's
**Status:** Backlog
**Start:** April 2026

**Concept:** Create SEO pages for different NIS levels in Belgium:
- Gemeenten (municipalities): 9000 Gent
- Deelgemeenten (sub-municipalities): 9032 Wondelgem
- Wijken (neighborhoods): 9000 Gent Zuid
- Sectoren/buurten (sectors/quarters): 9000 Gent Zuid - Sint-Anna

**Open Question (SPO-63):** Is neighborhood/sector level SEO valuable?

### Address Pages (Requirements)
**Project:** Requirements adrespagina's
**Status:** Backlog
**Concept:** "A la Huispedia" - permanent property insight pages per address

---

## Key Metrics to Track

1. **Duplicate content:** GSC "Duplicate, Google chose different canonical than user"
2. **Index coverage:** Total indexed pages vs. submitted
3. **Position tracking:** Monitor URL positions over time (SPO-22)
4. **Warm welkom results:** 20 pilot postcodes performance
5. **Structured data:** Rich results appearance in SERPs
6. **AI visibility:** ChatGPT/LLM mention tracking
