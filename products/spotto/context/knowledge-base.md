# Spotto Knowledge Base

## Product Overview

Spotto is a B2C Belgian real estate platform for property search - buying and renting residential and commercial properties.

- **Website:** [spotto.be](https://www.spotto.be)
- **Backoffice:** backoffice.spotto.be
- **Jira Project:** SPOTTO
- **Linear Workspace:** Eikhart (Team: Spotto)

## Key Team Members

- **Ramon Eijkemans** - SEO Lead, manages most technical SEO and authority projects
- **Spotto team** - Product team handling implementation and product initiatives

## Core Features

- **Property listings** - Residential & commercial, buy & rent
- **Advanced search** - Filters, saved searches, notifications
- **Travel-time search** - Find properties based on commute time to locations
- **Real estate professional directory** - Agent/agency pages
- **Spotto Assistance** - Insurance product offering
- **Market insights blog** - Content marketing

## Target Users

- Homebuyers and renters (primary)
- Property owners
- Real estate professionals (makelaars)

## Technical Landscape

### CRM Integrations
Properties flow into Spotto from various real estate CRM systems:
- **Omnicasa** - Major integration, includes cache busting logic
- **Sweepbright** - Webhook-based integration
- **Dewaele** - Custom import monitoring
- **RealSmart** - Linked via Oris ecosystem
- Other CRMs via standard feeds

### Key Technical Components
- Publication management (online/offline states, archiving)
- Image hosting via ImageKit
- SEO infrastructure (alternate pages, structured data, deduplication)
- Customer tracking & analytics
- Email notification system
- Webshop for paid services

### Infrastructure
- .NET backend (currently .NET 8)
- Uses Oris shared services (EventBus, COMAN content management)
- Azure-hosted (Application Insights for monitoring)

## Data Model Concepts

### Publications vs Addresses
Currently property-centric ("publicaties"), with consideration for moving to address-centric model to handle:
- Same property listed by multiple agents
- Online/offline lifecycle per publication
- URL structure optimization

### Property Lifecycle
Properties go through states: import -> online -> sold/rented -> archived (with configurable days online after sale)

## Key Stakeholders

Part of Oris NV / Immo United ecosystem, with VLAIO partnership for public/professional real estate pricing strategy.

## Domain Terminology

| Term | Meaning |
|------|---------|
| **WeGov** | Government system for CIB (real estate professional) recognitions |
| **IC** | Immo Connect - related system with customer profiles |
| **CX** | Customer Experience team (backoffice users) |

## Story Writing Guidelines

- **Human beneficiary** - User stories must always have a human beneficiary, never "Als systeem"
- **Avoid blame culture** - Don't track "who changed it" in audit trails, only track what changed and when
- **Split by beneficiary** - Create separate stories when there are different beneficiaries or different UX flows (e.g., manual vs automatic)
- **Keep features minimal** - Separate things like filtering, history logs into their own stories

## Jira Workflow

- Stories are linked to epics via the `parent` field
- New stories land in "Functional Analysis" status
- Issue types: Epic, Story, Bug, Task, Subtask

## Related Products

- **Vergelijkingspanden (TRANSDATA)** - B2B comparable properties tool, shares team resources
- **Markttendensen** - B2B market insights dashboard

## Current Strategic Focus Areas (2025-2026)

### SEO & Technical Optimization
- **Hygiëne (Deduplication):** Fixing duplicate content issues across 100k+ pages
- **Structured Data:** Implementing schema.org for rich results
- **Pagerank Flow:** Optimizing internal linking structure
- **Warm welkom:** Personalized landing page content for locations

### AI & Future Search
- **LLM/GEO/AI SEO:** Preparing for AI-powered search engines
- **ChatGPT Integration:** MCP-based property search integration planned

### Authority Building
- **Wikipedia presence:** Building brand authority through Wikipedia
- **EPC Authority:** Data journalism around energy performance certificates
- **Content clusters:** Niche landing pages for EPC, renovatie, budget, buurt topics

### Future Initiatives (2026)
- **Location pages:** SEO pages for gemeenten, deelgemeenten, wijken, buurten
- **Address pages:** "Huispedia-style" permanent property insight pages
- **Woninginzicht-pagina:** Property insights for owners (market position, EPC, etc.)

## SEO Key Metrics

| Metric | Purpose |
|--------|---------|
| GSC "Duplicate canonical" | Track duplicate content issues |
| Indexed pages | Monitor index coverage |
| URL positions | Track ranking improvements |
| Rich results | Measure structured data success |
| AI visibility | Track mentions in ChatGPT/LLMs |

## Geographic Hierarchy (Belgium)

Spotto content can be structured at different NIS levels:
1. **Gemeenten** (municipalities): e.g., 9000 Gent
2. **Deelgemeenten** (sub-municipalities): e.g., 9032 Wondelgem
3. **Wijken** (neighborhoods): e.g., 9000 Gent Zuid
4. **Sectoren/buurten** (sectors): e.g., 9000 Gent Zuid - Sint-Anna

## External Context Documents

- [SEO Strategy](seo-strategy.md) - Detailed SEO initiatives and technical approach
- [Linear Projects](linear-projects.md) - All active projects from Linear
- [Strategy 2026](strategy-2026.md) - Board-approved strategic initiatives
- [Strategy 2026 Initiative Details](strategy-2026-initiatives-details.md) - Detailed initiative breakdown
