# Werkdraft — De groene kloof op de Vlaamse woningmarkt

> **Status:** Ruwe analysenotities, nog niet persklaar. Afsplitsing van het starters-verhaal ([starters-woonladder](../starters-woonladder/rapport.md)).
> **Bron:** Spotto referentie-woningdata — vraagprijzen nieuwe te-koopzettingen, huizen, Vlaanderen, lentes 2024/2025/2026, ontdubbeld per woning (on-market-episode). EPC-label uit ReferenceProperties (~97% gevuld).

## Kernvinding

De markt prijst energiezuinigheid steeds scherper. Energiezuinige woningen (EPC A–B) stijgen duidelijk sneller in waarde dan renovatiewoningen (EPC E/F), en de kloof wordt elk jaar groter. Wie onderaan instapt (waar bijna alles E/F is), erft daardoor niet alleen een renovatiefactuur maar ook een trager stijgende waarde — een dubbel nadeel.

## Data — mediane prijs per m², huizen Vlaanderen, per EPC-groep

| EPC-groep | 2024 | 2025 | 2026 | Δ 2 jaar |
| --- | --: | --: | --: | --: |
| A–B (zuinig) | €2.444 | €2.528 | €2.606 | **+6,6%** |
| C–D | €2.108 | €2.121 | €2.193 | +4,0% |
| E–F (renoverplicht) | €1.793 | €1.794 | €1.844 | **+2,8%** |

**Mediane prijs (niveau):** A–B €445k → €484k (**+8,8%**); C–D €375k → €399k (+6,4%); E–F €290k → €299k (**+3,1%**). Zuinige huizen stegen ~3× sneller dan renovatiewoningen.

**Premie A–B t.o.v. E–F (per m²):** +36% (2024) → **+41% (2026)** — de kloof groeit.

## Twee vragen die dit beantwoordt

1. **Betalen kopers meer voor een beter EPC-label?** Ja, en steeds meer. De €/m²-premie van A–B boven E–F liep op van 36% naar 41% in twee jaar.
2. **"Migreren" betere woningen naar hogere prijsklassen?** Het mechanisme zit in de differentiële waardestijging: omdat zuinige woningen sneller in prijs stijgen, schuiven ze sneller over prijsklasse-grenzen omhoog dan E/F-woningen. Een zuinig huis van €245k (2024) herprijst naar €265k en verlaat het <€250k-segment; het F-huis ernaast (+3%) blijft. Zo concentreert het goedkope segment steeds meer E/F.

## Belangrijke voorbehouden (niet weglaten)

- **Beschrijvende premie, geen zuivere energiepremie.** Goede-EPC-woningen zijn ook vaker nieuwer, beter gelegen, beter onderhouden — een deel van de kloof zit in die gebundelde kenmerken, niet in energie alleen. De *verbreding* over tijd is moeilijker weg te verklaren als compositie, maar om een echte energiepremie te isoleren is een hedonisch model nodig (controle voor grootte/ligging/ouderdom). → framing: "de markt prijst energiezuinigheid steeds scherper", niet "een EPC-label kost X euro".
- Vraagprijzen, geen transactieprijzen.
- We meten wat gelíst wordt (flow), niet de volledige stock.

## Ondersteunende context (uit het startersverhaal)

- Onder €250k: ~63% EPC E/F, amper 8% A–B, nieuwbouw <1%.
- Trend onderaan (monotoon, maar bescheiden): <€250k E/F-aandeel 61%→62%→64%; instapklaar (A–B) 10%→7%. Grotendeels marktsortering via prijsstijging (betere goedkope woningen prijzen zich uit het segment), niet woningen die fysiek verslechteren.

## Mogelijke invalshoek / kop

"De groene kloof: energiezuinige woningen worden almaar duurder, renovatiewoningen blijven achter — en dat treft net wie onderaan instapt." Tweede laag: energie wordt niet alleen een instapkost maar een vermogenskloof.

---

# Vervolgonderzoek — sessie 2026-06-26

> Pistes uit de lijst hieronder uitgewerkt. Methodologie identiek aan het startersverhaal: on-market-episodes (grain `address_key` + `address_sequence_number` uit `ReferencePropertiesSequences`), lente (mrt–mei), prijs = eerste vraagprijs van de episode uit `…PublicationPrices`, €/m² op `construction_area`. Mediaan-€/m² gereproduceerd binnen ~1–2% van de cijfers hierboven (zelfde richting en grootte; klein verschil door exacte prijs-per-episode-regel). Eénmalige replicatie A–B huizen: €2.454/€2.526/€2.602.

## 1. Appartementen — de groene kloof is een *huizen*-verhaal

Mediane €/m², appartementen Vlaanderen (kotfilter: `construction_area` ≥ 35):

| EPC-groep | 2024 | 2025 | 2026 | Δ 2 jaar | n (2026) |
| --- | --: | --: | --: | --: | --: |
| A–B (zuinig) | €3.350 | €3.376 | €3.499 | +4,5% | 2.568 |
| C–D | €2.838 | €3.000 | €2.990 | +5,3% | 939 |
| E–F (renoverplicht) | €2.524 | €2.641 | €2.932 | +16,2% | **109** |

**Conclusie:** bij appartementen treedt de kloof *niet* op. De premie A–B↔E–F **versmalt** zelfs (+33% → +19%). Maar de E–F-groep is veel te dun (109–170 episodes/jaar) om iets hards te zeggen — appartementen zijn overwegend A–B/C–D (nieuwer). De groene-kloof-thesis blijft dus voorbehouden aan **huizen**. Niet meenemen als parallel; hooguit als contrast ("bij appartementen speelt dit niet, want de stock is er al energiezuiniger").

## 2. `condition_state_type` ontcijferd (staat van de woning)

Enum bevestigd in broncode (`ConditionStateType.cs`, RealEstateDataStore) én via correlatie met EPC/bouwjaar. De **databricks-data gebruikt de domein-volgorde** (niet de API/JSON-volgorde, die `New=1` heeft):

| code | label | NL | gem. EPC-label | interpretatie |
| --: | --- | --- | --: | --- |
| 0 | Unknown | onbekend | 4,3 | leeg/onbekend |
| 1 | RenovationRequired | te renoveren | 6,3 (E/F) | renovatieproject |
| 2 | FresheningUpRequired | op te frissen | 5,7 (D/E) | |
| 3 | WellMaintained | goed onderhouden | 4,0 (C) | |
| 4 | AsNew | zo goed als nieuw | 3,2 (B/C) | |
| 5 | New | nieuw | 1,7 (A) | nieuwbouw |
| 6 | DemolitionRequired | af te breken | 7,0 (F) | verwaarloosbaar (n≈8) |

**Prijsladder naar staat (huizen, lente 2026):** te renoveren €1.748/m² (mediaan €295k) → op te frissen €1.916 → goed onderhouden €2.347 → zo goed als nieuw €2.750 → nieuw €2.730. De markt prijst de *staat* monotoon, net als het EPC-label.

**Belangrijk gevolg voor de framing:** EPC en staat zijn sterk **verstrengeld** — "te renoveren" woningen zijn tegelijk slecht-EPC (gem. 6,3 = E/F) én goedkoop. De "groene kloof" is in feite grotendeels een **renovatiekloof**: de markt verdisconteert woningen-die-werk-vragen, waarvan een slecht EPC de wettelijk-bindende dimensie is (renovatieplicht). Dit versterkt het voorbehoud uit de kernnotitie: het is een beschrijvende premie op een *bundel* (energie + staat + ouderdom + ligging), niet een geïsoleerde energiepremie.

## 3. Regionale spreiding van de EPC-premie (huizen)

Premie = mediane €/m² A–B t.o.v. E–F, per provincie:

| Provincie | premie 2024 | premie 2026 | Δ | A–B Δ2j | E–F Δ2j |
| --- | --: | --: | --: | --: | --: |
| Vlaams-Brabant | +23% | +33% | **+10 pp** | +7,1% | −1,0% |
| Oost-Vlaanderen | +30% | +38% | +8 pp | +10,2% | +3,5% |
| Limburg | +40% | +48% | +8 pp | +10,6% | +4,8% |
| Antwerpen | +30% | +34% | +4 pp | +2,6% | −0,3% |
| West-Vlaanderen | +52% | +45% | **−6 pp** | +6,6% | +11,2% |

**Conclusie:** de kloof verbreedt in **4 van de 5** provincies; rond de steden (Vlaams-Brabant, Oost-Vl.) en in Limburg het sterkst — daar staan zuinige woningen op een steeds hogere €/m² terwijl renovatiewoningen stilstaan of dalen. **West-Vlaanderen is de uitzondering**: daar stegen net de E–F-renovatiewoningen het hardst (+11%), waardoor de (al grootste) kloof versmalt. Het absolute prijsverschil is het grootst in West-Vl. en Limburg, waar de goedkope renovatiestock de E–F-€/m² heel laag trekt.

## 4. Hedonische controle (light) — overleeft de verbreding een grootte-correctie?

Eerst leek de verbreding te verdwijnen binnen één band (100–175 m²: A–B +4,4% ≈ E–F +4,6%). Fijnere banden tonen dat dat een artefact van die ene snede was:

| Grootte (m²) | A–B Δ2j | E–F Δ2j | premie 2024 | premie 2026 |
| --- | --: | --: | --: | --: |
| < 100 | +5,3% | +6,0% | +40% | +39% |
| 100–150 | +8,6% | +2,4% | +32% | **+40%** |
| 150–220 | +6,1% | +3,6% | +40% | +44% |
| 220+ | +7,0% | +2,1% | +49% | **+56%** |

**Conclusie:** in 3 van de 4 banden stijgt A–B duidelijk sneller dan E–F — de verbreding is dus **niet louter een grootte-/compositie-effect**, ze overleeft binnen vergelijkbare woninggroottes. Enkel bij de kleinste huizen (<100 m², overwegend stedelijk, kleine n) speelt ze niet. Dit ontkracht de simpelste tegenwerping (≈ "A–B-huizen zijn gewoon kleiner geworden"), maar isoleert de energiepremie nog niet van staat/ouderdom/ligging — daarvoor blijft een volwaardig hedonisch model nodig (zie piste hieronder).

## Positionering t.o.v. eerdere Spotto-artikels (belangrijk)

Twee eerdere persberichten (`vorige_artikels/`) dekken al een groot deel van dit terrein. De groene-kloof moet zich daarvan onderscheiden, anders is het een herhaling.

**"Oude woning renoveren loont vooral op de Vlaamse boerenbuiten"** (woordvoerder Willem Degol):
- Deed al de Vlaanderen-brede EPC E/F-vs-D-vergelijking op vraagprijzen, **per provincie én gemeente**. Renovatie E/F→D = +24% waarde gemiddeld; Limburg +24,9%, West-Vl +24,8%, Vl-Brabant +20,8%, Antwerpen +19,7%, Oost-Vl +15,7%. Enkel huizen (bewust). Hook: "bekijk in jouw gemeente".
- Frame: *renovatie loont* (positief/opportuniteit), landelijk > stedelijk.

**"Verouderd kustvastgoed raakt moeizaam verkocht"** (woordvoerder Maïté Maes):
- Dit ís de groeiende prijskloof-thesis, gelokaliseerd op de kust. "Markt in twee snelheden": E/F huizen −2,3%, E/F app −4,2% (2025); A/B huizen +6,7%, app +1,8%. **Prijskloof oud↔nieuw groeit**: huizen €90k→€170k, app €70k→€108k (2023→2025). Bevat ook doorlooptijd (E/F huizen +10 dagen langer te koop).

**Wat dit betekent voor de groene-kloof.** Het kale "de kloof groeit / markt in twee snelheden" is bij Spotto **al verteld**. Wat hier nieuw en verdedigbaar is:
1. **De starterskoppeling / vermogenskloof** — de eigen, niet-eerder-vertelde laag. Niet "renovatie loont" of "koopjes aan de kust", maar: energie is geen instapkóst meer maar een **vermogenskloof** die net wie onderaan de woonladder instapt vastzet (trager stijgende waarde bovenop de renovatiefactuur). Dit is de differentiator; alles draait er best omheen.
2. **Vlaanderen-breed + vers (2024→2026)**, niet kust-only en niet 2023–2025.
3. **Nieuw bewijsmateriaal dat de priors niet hadden:** de `condition_state_type`-prijsladder (mechanisme: renovatiekloof, niet zuiver energie), within-grootteband-persistentie, het appartementen-contrast.

**Stijl-conventies (overnemen):** beschrijvende vraagprijzen, géén hedonisch model (bevestigt onze conclusie); benoemde Spotto-woordvoerder met kleurquotes; provincie/gemeente-granulariteit + "in jouw gemeente"-hook; positief eindbeeld (opportuniteit/handelingsperspectief), niet enkel somber.

**Let op — tegenstrijdigheid checken:** ons 2024→2026-cijfer toont West-Vl E/F-huizen **+11%** (kloof versmalt daar), terwijl het kuststuk voor 2024→2025 E/F-kustwoningen op **−2,3%** zette. Verschil in periode/gebied (kust ⊂ West-Vl) — uitklaren vóór publicatie, want het oogt als een ommekeer t.o.v. het vorige bericht.

## Stand van de pistes

- [x] Appartementen → afgehandeld: kloof is een huizenverhaal (E–F-appartementen te dun).
- [x] `condition_state_type`-enum → ontcijferd + bevestigd in broncode; staat ⟷ EPC sterk verstrengeld (renovatiekloof-framing).
- [x] Regionale spreiding → verbreedt in 4/5 provincies; West-Vl. uitzondering.
- [x] Hedonische controle (light) → verbreding overleeft binnen grootte-banden (behalve <100 m²).
- [ ] **Volwaardig hedonisch model** — regressie van €/m² op EPC-groep mét controle voor staat (`condition_state_type`), grootte, bouwjaar, provincie, om de *zuivere* energiepremie te schatten. Nu enkel univariate/gestratificeerde benadering.
- [ ] EPC-premie in **transactie**prijzen i.p.v. vraagprijzen (extern: Notaris/Statbel publiceren EPC-gesplitste cijfers).
- [ ] Tijdsdimensie: doorlooptijd-verschil A–B vs E–F (verkopen renovatiewoningen trager, los van prijs?).
