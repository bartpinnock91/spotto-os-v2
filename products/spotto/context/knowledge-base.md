# Spotto Knowledge Base

## Product Overview

Spotto is a B2C Belgian real estate platform for property search - buying and renting residential and commercial properties.

- **Website:** [spotto.be](https://www.spotto.be)
- **Backoffice:** backoffice.spotto.be
- **Jira Project:** SPOTTO

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
