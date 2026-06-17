# Open vragen — Spotto weekrapport 2026 (week 1–24)

Status: grotendeels beantwoord op 12 juni 2026 (Bart + eigen onderzoek).
Hoort bij de vier Excels in deze map (sectie 1: aanbod, 2: objecten, 3: bezoekers, 4: leads).

---

## A. Nog open

*(geen — alle vragen beantwoord per 12 juni 2026)*

---

## B. Beslist (Bart, 12 juni 2026)

| # | Vraag | Beslissing |
|---|---|---|
| B1 | Scope residentieel/commercieel | **Huidige opzet**: alles, met splitsing huis/appartement/overig |
| B2 | Nieuwbouwprojecten | **Laten zoals nu**: één publicatie/object + voetnoot |
| B3 | Historiek vóór 2026 | **Niet meenemen** |
| B4 | Geografische uitsplitsing | **Niet**: nationaal niveau |
| B5 | Frequentie | **Eenmalige export** |
| B6 | Gemengde koop/huur-episodes tellen als koop (doorlooptijd) | **Akkoord** |

---

## C. Beantwoord / uitgeklaard

### Productwijzigingen & data-events
- **Februari-importpiek (A1)**: probleem bij **Dewaele** — de koppeling stuurde te veel
  publicaties door. Technische churn: in- en uitstroom piekten samen (tot 10,7k koop/week),
  online aanbod en objectinstroom bleven normaal. Voetnoot bij weken 6–9 in sectie 1.
- **Formulierwijziging half maart (A2)**: **SPOTTO-1281** ("Vragen gaat naar vraag, bezoek gaat
  naar bezoek"), live ~18 maart via release-PR 32366. De dropdown in de contact-popup volgt
  sindsdien de geklikte CTA; voordien stond hij altijd op "Meer info aanvragen". De
  info/bezoek-uitsplitsing in sectie 4 is dus pas vanaf week 13 betrouwbaar; het totaal is
  doorlopend bruikbaar.
- **Paid Search-verlaging vanaf maart (A3)**: **bewuste budgetkeuze**. Cruciale context bij het
  lezen van bezoekers- en registratietendensen (daling ≠ marktafkoeling).
- **Daling bel-makelaar-kliks vanaf eind maart (A5)**: **bevestigd — nieuwe mobiele actiebalk.**
  Met de release van 1 april 2026 (PR 32678, o.a. SPOTTO-1307 afsprakenflow v2) kwam onderaan
  de mobiele detailpagina een nieuwe balk: *favoriet | bezoek | bel | pandscore* (voorheen
  *favoriet | contacteer | bel*). De "bezoek"-CTA vangt nu kliks die vroeger naar "bel" gingen.
  Past bij de data: daling abrupt (week van 30 maart), volledig mobiel, −25–30% per
  detailweergave, terwijl formulier-CTA-kliks licht stegen. **Kanaalverschuiving, geen
  leadverlies** — zo ook lezen in sectie 4 (bel-makelaar-reeks is vóór/na eind maart niet
  vergelijkbaar).
- **GA4 week 24-anomalie (A4)**: **geen tagging-probleem maar verwerkingsvertraging.** Sessies
  uit Google Ads staan de eerste ~24–48 uur als "Unassigned" (geen bron bekend) of
  "Cross-network" (Performance Max-campagnes over meerdere Google-netwerken) tot de
  Ads-koppeling ze toewijst. De ochtend-snapshot toonde daardoor 8,8k Unassigned; een verse
  query dezelfde namiddag gaf al een normaal beeld (~2k, waarvan de helft niet-toegewezen
  sessies van de lopende dag, ~270 gedeelde WhatsApp-links en ~80 ChatGPT-verwijzingen).
  Sectie 3 is gecorrigeerd. Vuistregel: kanaalcijfers van de lopende week pas definitief
  lezen na afsluiting.

### Datakwesties
- **Reden offline (A6)**: **kan niet** — makelaars geven niet mee of een pand verkocht/verhuurd
  dan wel teruggetrokken is. "Offline gehaald" blijft de som van beide; zo benoemen in het
  begeleidende document.
- **GA4-dekking contactaanvragen (A7)**: eerdere claim "GA4 vangt maar 40–50%" was **fout**
  (vergeleek één van de twee formulierevents met het databanktotaal). Beide GA4-formulierevents
  samen volgen de databank goed (84–118% per week; interne dashboard-validatie: 101% totaal,
  98% koop, 92% huur). De databank blijft de bron voor contactaanvragen.
- **GA4-ondertelling bezoekers/sessies (A7-vervolg)**: het interne dashboard vergelijkt Search
  Console (199.320 organische URL-kliks) met GA4 (132.601 sessies) = **67% dekking**. GA4-
  bezoekers- en sessiecijfers in sectie 3 onderschatten de werkelijkheid dus met ~33%
  (consent-weigeraars, adblockers). **Afspraak: als vaste notitie bij sectie 3 opnemen, cijfers
  niet ophogen** — de factor is enkel voor organisch verkeer gevalideerd en kan per kanaal
  verschillen; trends en koop/huur-verhoudingen blijven geldig omdat de ondertelling
  structureel is.

### Eerder uitgeklaard
- **Zoekersdefinitie (sectie 3)**: brede definitie — unieke gebruikers met ≥1 bekeken pandpagina
  per week; overlap koop/huur mogelijk, niet optellen; gebruiker = browser/toestel. Afgeklopt.
- **Huidige prijs vs startprijs (sectie 1)**: drift verwaarloosbaar (mediaanverschil hooguit
  enkele honderden euro's; 3–5% van oudste cohortes ooit verlaagd).
- **Week 23-huuranomalie**: Ceusters-feed (commercieel, 2 juni) — structurele baseline-
  verschuiving huurstock 8,5k → 9,4k; zit in "overig", residentieel onaangetast.
- **Contactaanvragen-bron**: dbo.Questions (vervangt PublicationContactForms sinds sept 2024);
  enum uit broncode: 0 = infovraag, 1 = bezoekaanvraag.
- **Publicaties vs objecten**: beide gerapporteerd (sectie 1 vs 2); verschil = herpublicatie-/
  churngraad.
