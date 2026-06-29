# PR-analyses & persberichten — werkwijze

Deze map bevat data-gedreven persbericht-drafts voor Spotto. Elke draft koppelt een **onderzochte cijfervaststelling** aan een **menselijk relevante hoek**. Dit document vat samen hoe we hier onderzoek én schrijven aanpakken. Voor DB-details en valkuilen, zie de memory [[db-mssql-comparison]].

## Rolverdeling (belangrijk)

- **Wij (de data-kant):** leveren de analyse, de cijfers en de hoek, in een rigoureuze draft met methodebox en databijlage.
- **PR-bureau (Story Forward) + CIB:** schrijven het uiteindelijke persbericht in de Spotto-huisstijl, voegen quotes en beeld toe, trimmen wat te veel is.

Onze draft is dus een **stevig onderbouwd bot met vlees eraan**, geen afgewerkt persbericht. Laat hem liever te volledig dan te dun: het bureau snoeit wel. De methodebox is back-matter die zij wegknippen maar die jou redt als een journalist of concurrent doorvraagt.

## Data & methode

Bron: `mssql-comparison` (Vergelijkingspanden referentie-DB, `databricks`-schema). Standaardrecept voor een prijs-/aanbodanalyse:

- **Eenheid = on-market-episode per woning** (`address_key` + `address_sequence_number`), nooit per publicatie (publicaties dubbeltellen ~1,5×).
- **Prijs = eerste vraagprijs van de episode** uit `…PublicationPrices`. Het zijn **vraagprijzen, geen transactieprijzen**.
- **€/m²** op `construction_area` (bewoonbare opp.). **Appartementen: filter studio's < 35 m² (kotmarkt)** — die vertekenen €/m² zwaar, vooral in studentensteden.
- **Periode** uit `online_from`; vergelijk telkens dezelfde lentemaanden (mrt–mei) jaar-op-jaar, zo vallen seizoenseffecten weg.
- Enums (huis=1, appartement=2; EPC 1–7 = A+…F; E/F = renovatieverplichting) staan in de memory.

### Verplichte controles vóór publicatie (hard geleerd)

1. **Onboarding/churn → stable-panel.** Spotto sluit doorlopend nieuwe makelaarskantoren aan, dus ruwe aantallen/aandelen/aanbod-trends zijn vertekend. Toets elke **count-/share-/aanbodclaim** op enkel kantoren (`immoconnect_organization_id`) die in **beide** jaren actief waren. Prijsmedianen (€/m²) zijn hier robuust tegen; aantallen niet.
2. **Grootte-mix binnen een prijsklasse.** Mediane €/m² kan stijgen/dalen puur doordat de woninggrootte verschuift. Check de mediane `construction_area` per klasse over de jaren. Stabiel → vermeld het kort; verschoven → het cijfer is een compositie-effect (bv. luxe-appartementen €750k+: −15% €/m² was grotendeels grotere units).
3. **Dunne segmenten.** De meest quotabele cijfers zijn vaak de kleinste cellen (luxe, provincie×klasse). Zet **N** in de bijlage en gebruik extreme/dunne cijfers niet in de lopende tekst.
4. **Vraagprijs vs transactieprijs.** Stem de **richting** (niet de absolute niveaus) af op notaris/Statbel: notariscijfers slaan op aktes ~4 mnd ná het verkoopakkoord, dus niveauvergelijking klopt qua timing niet. Segment-divergenties zijn vraagprijssignalen, niet getoetst aan geregistreerde prijzen.
5. **Mechanisme niet overclaimen.** Beweer geen oorzaak die je niet geïsoleerd hebt. "Prijscreep rond de grens" alleen waar de prijzen er ook echt stijgen (bv. €350k-grens, niet de onderkant als die vlak is).
6. **Meet wat je meet, claim niet meer.** EPC-label = energie, niet staat of bewoonbaarheid. A/B betekent energiezuinig, niet "instapklaar"; E/F betekent renovatie**plicht** (hard, wettelijk), niet "onbewoonbaar". De staat van de woning zit apart in `condition_state_type`. En "voorbije jaren liep X op" mag, "X zal verder oplopen" (voorspelling) niet.

## Structuur van een draft

Findings in de tekst, *waarom we ze vertrouwen* in de methodebox, *dunne/vertekende cijfers* enkel in de bijlage.

1. Titel: pakkende vaststelling, liefst met één hard cijfer (`Spotto-analyse: …`).
2. Lead + "In dit artikel"-bullets (kort, scanbaar).
3. Body in korte secties met tussenkoppen; per provincie/gemeente granulair waar relevant.
4. "In lijn met de bredere markt" (externe afstemming).
5. Methodebox (vraagprijzen, dedup, kotfilter, stable-panel-controle, grootte-check, vraagprijs-vs-transactie).
6. Databijlage met alle tabellen **incl. N** (zo kan het bureau er grafieken op maken).

## Schrijven & toon

- **Hou onze rigueur, maar laat het niet als AI klinken.** Geen em-dashes als lijmwoord, geen "niet omdat X maar omdat Y"-antithese, geen gebalanceerde abstracte zinnen, geen jargon/Engels waar gewoon Nederlands kan. Korte stellige zinnen. Zie [[avoid-ai-prose]].
- **Laat je inspireren door de vorige artikels** (`vorige_artikels/`) qua toon: concreet, vlot Vlaams, "Concreet:"-voorbeelden met ronde getallen, constructieve/opportuniteits-insteek. Maar **kopieer de volledige huisstijl niet** (quote-per-paragraaf, "check je gemeente"-CTA, kleurquotes) — dat is de laag van het PR-bureau. Zie [[spotto-pr-style]].
- **Quotes laten we leeg** (placeholder); het bureau vult ze in. Woordvoerder: Willem Degol (voorzitter Spotto), eventueel een regionale makelaar-expert.
- Boilerplate: "Spotto, het vastgoedplatform van de Vlaamse vastgoedmakelaars."
- **Geen "Status: Draft"-header** of watermerk op drafts — zie [[no-draft-status-headers]]. Alles in het Nederlands.

## Reeds gepubliceerde hoeken (niet herhalen)

- **Renovatie-meerwaarde** (E/F → D loont, vooral landelijk) — `vorige_artikels/`.
- **Kust: oud vs nieuw, groeiende prijskloof** — `vorige_artikels/`.

De EPC-prijskloof/"groene kloof" overlapt hiermee; een nieuwe draft daarrond heeft een verse hoek nodig (bv. de starter-insteek of Vlaanderen-breed i.p.v. enkel de kust). Zie `groene-kloof/`.
