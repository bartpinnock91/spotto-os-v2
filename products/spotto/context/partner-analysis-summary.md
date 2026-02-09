# Partner Analyse: Samenvatting

**Datum:** 2026-02-06
**Periode:** januari 2025 - december 2025
**Partners geanalyseerd:** Zabun, Whise, Omnicasa
**Totaal partner tickets:** 242 (van 844 totaal = **29% van alle support**)

---

## Overzicht per partner

| Partner | Tickets | % van totaal | Hoofdprobleem | Automatiseerbaarheid |
|---------|---------|-------------|---------------|---------------------|
| **Zabun** | 108 | 13% | Activaties/deactivaties via email | 70% (76 tickets) |
| **Whise** | 73 | 9% | Geautomatiseerde activatie-emails | 84% (61 tickets) |
| **Omnicasa** | 61 | 7% | Handmatige activaties + sync issues | 80-98% (50-60 tickets) |
| **Totaal** | **242** | **29%** | | **77% (~187 tickets)** |

---

## Gemeenschappelijke patronen

### 1. Activaties domineren het volume (~70% van partner tickets)

Alle drie de partners genereren het meeste ticketvolume voor dezelfde reden: **het aan- of uitzetten van een koppeling voor een vastgoedkantoor**. Dit is bij elke partner een manueel email-gebaseerd proces:

| Partner | Activatie-tickets | % van partner tickets | Proces |
|---------|-------------------|----------------------|--------|
| Zabun | 76 (incl. migraties + deactivaties) | 70% | Gestandaardiseerd formulier via email |
| Whise | 61 | 84% | Volledig geautomatiseerde email van noreply@whise.eu |
| Omnicasa | 25-30 | 45% | Email met API-link voor configuratie |

### 2. Het support-team volgt steeds hetzelfde afhandelingsproces

Bij alle partners is de afhandeling identiek:
1. Email ontvangen van partner
2. Back Office account aanmaken
3. Welkomstmail sturen naar kantoor
4. Ticket sluiten

Dit is een **volledig standaardiseerbaar proces** zonder inhoudelijke beoordeling.

### 3. Partners zijn het primaire contactpunt (niet eindklanten)

| Partner | % tickets via partner support | % via eindklant |
|---------|------------------------------|-----------------|
| Zabun | 90% (support@zabun.be) | 2% |
| Whise | 84% (noreply@whise.eu) | 8% |
| Omnicasa | 70% (Asia, Anne, Farah) | 20% |

Eindklanten contacteren Spotto zelden rechtstreeks voor partner-gerelateerde zaken. De partners fungeren als tussenpersoon.

### 4. Duplicaat-tickets blazen volume op

Alle partners genereren duplicaten:
- **Whise:** Oreon Properties stuurde 7 identieke activaties in 2 dagen
- **Zabun:** 6 activaties binnen 10 minuten op 7 april 2025 (batch)
- **Omnicasa:** Dezelfde conversatie genereert meerdere Freshdesk-tickets

### 5. Technische problemen zijn relatief zeldzaam

| Partner | Technische issues | % van tickets | Type |
|---------|-------------------|---------------|------|
| Zabun | 8 | 7% | Ontbrekende panden, veldfouten |
| Whise | 5 | 7% | Sync-fouten, Office ID problemen |
| Omnicasa | 16-20 | 30% | Status mismatch, foto-sync, depublicatie |

Omnicasa heeft relatief meer technische issues, voornamelijk door status-mapping en foto-caching problemen.

---

## Impactanalyse

### Huidige situatie (2025)

| Metriek | Waarde |
|---------|--------|
| Partner tickets per jaar | 242 |
| Geschatte afhandeltijd per ticket | 10-15 min |
| Totale support-uren partner tickets | **40-60 uur/jaar** |
| Percentage van alle tickets | 29% |

### Na automatisering (geschat)

| Partner | Nu | Na automatisering | Besparing |
|---------|-----|-------------------|-----------|
| Zabun | 108 | 32 | -76 (-70%) |
| Whise | 73 | 12 | -61 (-84%) |
| Omnicasa | 61 | 10 | -51 (-84%) |
| **Totaal** | **242** | **54** | **-188 (-78%)** |

**Geschatte besparing: ~188 tickets/jaar = ~30-45 support-uren/jaar**

---

## Aanbevelingen (geprioriteerd)

### Prioriteit 1: Partner Self-Service API/Portaal

**Impact: -188 tickets/jaar (78% reductie)**
**Effort: Medium-Hoog**

Bouw een Partner API of self-service portaal waarmee partners zelf:
- Koppelingen activeren (account aanmaken + welkomstmail triggeren)
- Koppelingen deactiveren
- Migraties uitvoeren (CRM-switch)
- Status van koppelingen inzien

Dit lost het kernprobleem op dat bij alle drie partners identiek is. De API kan gefaseerd uitgerold worden:

| Fase | Scope | Impact |
|------|-------|--------|
| **Fase 1:** Webhook voor Whise activaties | Whise noreply@whise.eu emails automatisch verwerken | -61 tickets |
| **Fase 2:** Activatieformulier voor Zabun | Zabun kan koppelingen zelf activeren/deactiveren | -76 tickets |
| **Fase 3:** Omnicasa API-integratie | Omnicasa API-links automatisch verwerken | -30 tickets |

### Prioriteit 2: Freshdesk automatie (quick win)

**Impact: duplicaten voorkomen + auto-tagging**
**Effort: Laag**

Zonder code-wijzigingen aan het Spotto-platform:
- **Duplicaat-detectie:** Als binnen 48 uur een tweede email binnenkomt van dezelfde partner over hetzelfde kantoor, toevoegen als notitie aan bestaand ticket
- **Auto-categorisering:** Whise noreply-emails automatisch taggen als `spotto_whise_activatie_auto`
- **Auto-reply:** Standaard welkomstmail automatisch sturen bij ontvangst activatie-email

### Prioriteit 3: Automatische depublicatie

**Impact: -5-7 tickets/jaar bij Omnicasa**
**Effort: Laag**

Wanneer een partner een pand niet meer doorstuurt, na X dagen automatisch depubliceren. Voorkomt handmatige "haal dit pand offline" verzoeken.

### Prioriteit 4: Verbeterde sync-monitoring

**Impact: proactieve detectie van ~20 issues/jaar**
**Effort: Medium**

- Status-mapping validatie bij import (vlag onbekende statussen)
- Foto-hash vergelijking i.p.v. URL-vergelijking (lost Omnicasa cache-probleem op)
- Monitoring dashboard voor sync-fouten per partner

### Prioriteit 5: Verfijning ticket-tagging

**Impact: betere rapportage en triage**
**Effort: Laag**

Splits de generieke partner-tags op in sub-tags:

| Huidige tag | Nieuwe sub-tags |
|-------------|-----------------|
| `spotto_partner_whise` | `whise_activatie_auto`, `whise_helpdesk`, `whise_api`, `whise_koppeling` |
| `spotto_partner_zabun` | `zabun_activatie`, `zabun_deactivatie`, `zabun_migratie`, `zabun_technisch` |
| `spotto_partner_omnicasa` | `omnicasa_activatie`, `omnicasa_sync`, `omnicasa_foto`, `omnicasa_depublicatie` |

---

## Conclusie

De drie grootste partners (Zabun, Whise, Omnicasa) genereren samen **29% van alle support tickets**, maar het overgrote deel (78%) is **operationeel en gestandaardiseerd**. Het kernprobleem is identiek bij alle partners: het activeren en deactiveren van koppelingen verloopt via email in plaats van via een technische integratie.

Een Partner API of self-service portaal zou het meest impactvolle initiatief zijn om het supportvolume structureel te verlagen. Als quick win kan Freshdesk-automatie al een groot deel van de manuele afhandeling elimineren, zonder wijzigingen aan het platform zelf.

---

## Detailrapporten

- [Partner Analyse: Zabun](partner-analysis-zabun.md) — 108 tickets, 70% automatiseerbaar
- [Partner Analyse: Whise](partner-analysis-whise.md) — 73 tickets, 84% automatiseerbaar
- [Partner Analyse: Omnicasa](partner-analysis-omnicasa.md) — 61 tickets, 80-98% automatiseerbaar
