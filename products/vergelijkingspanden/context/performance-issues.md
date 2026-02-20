# Onderzoeksrapport: Performantie-optimalisaties

> **Status:** Ready for Deployment

De focus lag op het wegnemen van de "blokkades" en het versnellen van de data-ophaling. De onderstaande punten zijn reeds uitgevoerd en staan klaar voor deployment en validatie.

---

## 1. Preview & Vergelijking Laden (Data-efficiency)

**Huidige bottleneck:** De hoofdafbeelding zorgde voor een trage query (ca. 600ms). Daarnaast zorgden document-ophalingen vanuit RealSmart voor zware belasting en incidentele timeouts.

### Uitgevoerde acties

- **Data-shaping:** De hoofdafbeelding wordt nu direct vanuit het realestate record opgehaald. Dit elimineert de vertraging van de derde query.
- **Object-hergebruik:** Binnen API-calls wordt hetzelfde vergelijkingsobject hergebruikt. Dit voorkomt dat de vergelijking meerdere keren opnieuw moet worden opgehaald binnen één actie (vooral merkbaar bij save-acties).
- **RealSmart Integratie:** De queries voor documenten zijn geoptimaliseerd (minder calls, alleen indien nodig, no table scans) en er is een database-index toegevoegd voor structurele snelheidswinst.

---

## 2. Drawing & Kaart-interactie (Oplossing voor "Blokkages")

**Huidige bottleneck:** De module leek te "bevriezen" bij interactie. Dit kwam door een overdaad aan dure DOM-reads bij elke kleine beweging op de kaart.

### Uitgevoerde acties

- **Event Refactoring:** Het universele `mapChangedEvent` is opgesplitst in specifieke events voor positie, grootte en zoom.
- **Throttling:** Door throttling op deze nieuwe events te zetten, voeren we minder dure operaties uit en beperken we het aantal DOM-reads tot het strikt noodzakelijke (enkel bij een resize is de nieuwe container size relevant).
- **GeoServer & GIS Optimalisatie:** Implementatie van Hilbertcurve-sortering, opschonen van corrupte (0,0) data en activatie van in-memory caching (GeoWebCache).
- **Frontend Rendering:** Markers en de WMS-layer worden nu hergebruikt in plaats van telkens vernietigd en opnieuw aangemaakt.

---

## 3. Counter (Stabiliteit bij uitzoomen)

**Huidige bottleneck:** De teller vertraagde de overgang tussen kaartlagen (WFS/WMS) door zware BBOX-queries op een groot aanbod.

### Uitgevoerde acties

- **Limietstelling:** De teller is begrensd op 10.000 panden. Boven dit aantal tonen we "10.000+", wat de rekenlast bij diep uitzoomen wegneemt.
- **Data-hergebruik:** We hergebruiken de count-data die al aanwezig is, in plaats van een aparte extra count-call te doen via de WFS.

---

## Status & Prioritering

Alles wat hierboven beschreven staat is ontwikkeld en lokaal getest.

| Prioriteit | Actie |
|------------|-------|
| **Prio 1** | Deployment van deze fixes naar een testomgeving |
| **Prio 1** | Validatie van de "blokkade-fix" (de kaart-interactie) |
