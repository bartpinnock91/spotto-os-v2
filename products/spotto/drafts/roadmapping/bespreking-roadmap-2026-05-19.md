# Roadmap-bespreking — 2026-05-19

Korte beschrijving + schatting per onderwerp. Schattingen komen uit `plans_spotto_19052026.xlsx` (afgerond op halve uren).

## In de huidige planning

### Pand beoordeling

Gebruikers kunnen panden scoren op eigen criteria; v2 voegt **Samen Vergelijken** toe zodat koppels/gezinnen elkaars scores zien en hun verwachting (online) kunnen vergelijken met de realiteit (na bezoek).
**Schatting:** ~127 u totaal — 10 u gedaan, **117 u open**.

### ERA API-integratie

Koppeling met de ERA-API om hun aanbod automatisch op Spotto te krijgen (analoog aan andere kantoorintegraties).
**Schatting:** nog niet gedetailleerd bekeken -> Verwachting +- 3d zoals Dewaele

### Minder SQL

Tech-debt: SQL-opslag verminderen door zware tabellen (publication hits, herald hits, lifestyle searches) naar Databricks of blob-storage te verhuizen. Reden: de SQL-DB zit constant vol.
**Schatting:** nog teschnisch te bekijken.

### Dashboards

Markttendensen-project rond dashboarding. Functioneel grotendeels uitgewerkt, nog niet technisch ingeschat.
**Schatting:** Nog geen volledige estimate.

### Simpele lege landingspagina's

Marketeer kan een lege pagina met eigen URL en custom HTML/CSS aanmaken voor campagnes, automatisch in de XML-sitemap. Geen template, gewoon een blanco canvas. Deal van niche landingspagina's roadmap.
**Schatting:** 1 dag.

## Roadmap

### Reistijdzoeker

Reistijdzoeker engagement boosten door meer interactief te maken vanaf de start.
**Schatting**: Moet nog functioneel bekeken worden.

### Locus Focus

Dagelijkse feed van Spotto-panden naar LocusFocus zodat makelaars hun aanbod daar getoond zien.
**Schatting:** ~13,5 u open - deels ingeschat.

### Century 21 CRM

C21 integreert onze API in hun CRM. Geen dev tijd nodig.
**Schatting:** n.v.t.

### ChatGPT-integratie

Spotto doorzoekbaar maken vanuit ChatGPT via een MCP-server: ChatGPT kan rechtstreeks onze zoekmotor en reistijdzoeker aanroepen voor natuurlijke-taalqueries (bv. "appartementen in Gent < €350k met EPC C").
**Afgevoerd:**

### Niche landingspagina's (SEO/SEA)

Thematische, high-intent landingspagina's (EPC, renovatie, nieuwbouw, notariskosten, buurtinfo…) gebouwd op een herbruikbaar sjabloon, om organisch verkeer te vangen.
Eerste story in volgende sprint om te kijken wat marketing er mee doet.
**Schatting:** n.v.t.

### Snellere notificaties

Gebruikers sneller alerten bij nieuwe panden, prijsdalingen en statuswijzigingen via mail.
**Schatting:** n.v.t. Ten vroegste voor Q3.

### Dataformats

Data-gedreven contentpagina's à la _"Hoeveel kan ik kopen voor €X in regio Y?"_ — gekoppeld aan ons pandaanbod, om populaire budget-/oriëntatiezoekopdrachten te vangen.
**Schatting:** Kijken om dit zonder dev tijd te doen.

### Aanbevelingen

Slimme aanbevelingsblokken op pandpagina en homepage: recent bekeken, vergelijkbare panden, "anderen bekeken ook". Huidige logica is beperkt.
**Afgevoerd voor 2026**.

### CRO-optimalisatie

Grondige conversie-optimalisatie van de pandpagina: betere CTA-posities, layout, trust-blokken (EPC-uitleg, makelaarsprofielen) en A/B-test-infrastructuur, om meer contactaanvragen uit hetzelfde verkeer te halen.
**Schatting:** CRO-project staat in Excel met **30 u open** (0 u gedaan) — werd niet in de huidige discussielijst opgenomen.

---

## Open vragen

- **Dashboards (Alpaca):** scope en doelgroep bevestigen.
