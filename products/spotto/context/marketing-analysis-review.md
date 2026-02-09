# Review: Customer Journey Map - Ervaren Kopers

> Reviewer: Product Management
> Bron: [marketing-analysis-detailed.md](marketing-analysis-detailed.md)
> Doel: Kritische lezing vanuit productperspectief — wat hebben we nodig om hierop te bouwen?

---

## Secties 1-4: Research Context & Fundament

### Algemeen

Het document leest als een **strategisch narratief** eerder dan een onderbouwd onderzoek. De conclusies klinken intuïtief juist, maar de onderbouwing ontbreekt. Als we productbeslissingen en roadmap-prioriteiten op deze analyse baseren, moeten we weten wat gevalideerd is en wat aangenomen.

### Opmerkingen

**1. Methodologie ontbreekt volledig** *(sectie 1)*
Er is geen vermelding van hoe dit onderzoek is uitgevoerd. Interviews? Enquêtes? Analyse van Spotto-data? Literatuur? Zonder methode kunnen we niet inschatten hoe betrouwbaar de conclusies zijn.

**2. "Ervaren kopers" is te breed gedefinieerd** *(secties 1, 3-4)*
De enige definitie is "minstens één eerdere aankoop." Dat omvat zeer verschillende profielen: upgraders, downsizers, investeerders, relocators. Elk van deze subgroepen heeft een ander zoekgedrag, andere prioriteiten en andere productbehoeften. Voor productbeslissingen hebben we meer segmentatie nodig.

Dit wordt concreet zichtbaar in secties 3 en 4: het gedrag dat in sectie 4 wordt beschreven ("sneller oordeel," "gerichte filtering," "tijd belangrijker dan volledigheid") geldt niet universeel. De **trigger bepaalt de modus**, niet het ervaringsniveau:
- **Scheiding / gedwongen verhuizing** → urgentie, efficiëntie, snel filteren en beslissen
- **Groter willen wonen / dromen** → exploratie, inspiratie, rustig vergelijken

Dit zijn fundamenteel verschillende gebruikerspatronen op het platform. De ene wil snelle shortlists, de andere wil rondkijken en mogelijkheden verkennen. Het document behandelt "ervaren koper" alsof er één gedragspatroon is, maar de trigger vormt het gedrag meer dan het ervaringsniveau.

De persona "Tom" (sectie 13) illustreert dit probleem. Tom is geen persona afgeleid uit onderzoek — hij is de thesis van het document met een naam. Elk gedrag dat beschreven wordt, ondersteunt de strategische conclusies. Er ontbreken demografische of situationele details (trigger, budget, regio, doel) die Tom tot een bruikbare persona zouden maken. Een tweede persona met een andere trigger (bijv. gedwongen verhuizing) zou onmiddellijk aantonen dat de "één journey"-aanpak tekortschiet.

**3. Geen kwantitatieve onderbouwing** *(secties 2-4)*
Kernvragen blijven onbeantwoord:
- Hoe lang duurt de zoektocht gemiddeld?
- Hoe vaak keert een koper terug naar het platform?
- Welk percentage van de gebruikers vertoont het beschreven cyclische gedrag?
- Wat is de verhouding tussen nieuwe en terugkerende bezoekers?

Dit zijn precies de cijfers die we nodig hebben om te meten of productwijzigingen effect hebben.

**4. Competitief landschap ontbreekt** *(sectie 2)*
Het document erkent dat concurrenten "sterker, groter en bekender" zijn, maar noemt ze niet bij naam en analyseert niet wat zij anders doen. Immoweb, Zimmo, en andere spelers worden niet behandeld. Voor productpositionering moeten we weten waar Spotto zich concreet onderscheidt.

**5. Claims zonder bronvermelding** *(secties 2-3)*
Uitspraken als "makelaar blijft een dominante actor" en "content speelt nauwelijks een rol" worden als feit gepresenteerd. Zijn dit bevindingen uit data, of aannames? Dit onderscheid is essentieel.

**6. België-specifieke nuances zijn oppervlakkig** *(sectie 2)*
Het compromis/notaris-systeem, regionale verschillen (Vlaanderen vs. Wallonië vs. Brussel), biedingscultuur — deze factoren vormen de journey maar worden niet geïntegreerd.

**7. Marktkenmerken en persona-ervaring worden vermengd** *(sectie 2)*
De drie kenmerken onder "Wat het aankoopproces in België typeert" zijn markt-breed geformuleerd, maar worden zonder onderscheid doorgetrokken naar de ervaren koper:
- **Gefragmenteerde informatie** — geldt voor de markt, maar een ervaren koper heeft dit traject al doorlopen. Juridische en financiële kennis is grotendeels aanwezig. Dit is waarschijnlijk geen primair pijnpunt voor deze persona.
- **Makelaarsdominantie** — geframed als marktfeit, maar vanuit kopersperspectief is de makelaar de vertegenwoordiger van de verkoper, niet een dominante actor in hún proces. Dit punt is relevanter voor Spotto's businessmodel (leads naar makelaars) dan voor het begrijpen van kopersgedrag.

Het document maakt niet duidelijk wanneer het over marktstructuur spreekt en wanneer over persona-ervaring. Voor productbeslissingen moeten we weten door welke lens we kijken.

### Wat we nodig hebben

| Vraag | Waarom | Actie |
|-------|--------|-------|
| Welke data onderbouwt de journey-fases? | Om te weten wat gevalideerd is vs. aangenomen | Opvragen bij marketing / freelancer |
| Kunnen we cyclisch gedrag zien in onze eigen analytics? | Validatie van de kernthese | GA4-data analyseren (terugkerende bezoekers, sessiefrequentie) |
| Welke subsegmenten zitten in "ervaren kopers"? | Verschillende segmenten → verschillende features | Persona's verder uitwerken |
| Hoe positioneren concurrenten zich? | Onderbouwt onze eigen positionering | Competitive analysis opvragen of zelf uitvoeren |

---

## Sectie 5-7: Informatiebehoefte, Vertrouwen & Touchpoints

### Opmerkingen

**8. Conclusie als titel, zonder bewijs** *(sectie 6)*
De sectietitel "Vertrouwen Boven Inspiratie" presenteert een conclusie als feit vóór enig bewijs wordt gegeven. De inhoud daaronder beschrijft wat vertrouwen betekent en wat niet werkt, maar maakt nergens de vergelijking met inspiratie. Er is geen bewijs dat ervaren kopers vertrouwen *meer* waarderen dan inspiratie — misschien willen ze beide, of speelt inspiratie een andere maar even relevante rol. De titel beweert een hiërarchie die de content niet onderbouwt.

Bovendien springt de implicatie ("Spotto moet begeleiden, niet overtuigen") van basiskwaliteitseisen (correctheid, consistentie, transparantie) naar een strategische positionering als "gids." Wat de vertrouwenspunten eigenlijk beschrijven is: **wees een betrouwbaar platform**. Dat is een baseline, geen differentiator. "Begeleiden" vereist features en content die nog niet bestaan — het document erkent die kloof niet. Dit is een strategische ambitie verpakt als onderzoeksconclusie, en het concept "begeleiden" keert verderop in het document herhaaldelijk terug als gegeven.

---

## Secties 8-10: Fricties & Marketingrealiteit

### Opmerkingen

**9. Operationele claims zonder benchmark** *(sectie 9)*
Sectie 9 is concreter dan de voorgaande secties en lijkt gebaseerd op werkelijke platformkennis. Maar de observaties missen benchmarks. "Beperkte lead ratio" — onze unique visitor conversie is 2,5%. Is dat beperkt? Vergeleken waarmee? Zonder industrie-benchmarks of vergelijking met concurrenten (Immoweb, Zimmo) is dit een subjectief oordeel dat de strategische richting stuurt. Voor een listingplatform waar de conversieactie "contacteer makelaar" is, kan 2,5% normaal of zelfs goed zijn. Hetzelfde geldt voor "blog speelt nauwelijks een rol" en "remarketing onderbenut" — deze observaties klinken plausibel maar missen de cijfers om ze te beoordelen. Dit versterkt de noodzaak uit opmerking 4: zonder competitief landschap worden operationele beoordelingen subjectief.

**10. Onbeargumenteerde tweedeling marketing/platform** *(sectie 10)*
"Marketing ondersteunt de zoektocht, het platform ondersteunt de makelaar." Dit statement verschijnt als samenvatting, maar is nergens in het document opgebouwd. De makelaarskant is in de hele analyse niet onderzocht — er is geen analyse van wat makelaars nodig hebben, hoe zij het platform gebruiken, of wat "ondersteuning" voor hen betekent. De zin introduceert een tweede doelgroep (makelaars) zonder enig voorwerk.

Bovendien ontstaat er een contradictie: het hele document is een kopersgerichte journey-analyse, maar concludeert met een platformmissie gericht op makelaars. Als marketing de zoektocht ondersteunt en het platform de makelaar, wie ondersteunt dan de koper *op* het platform? Dit is een businessmodel-uitspraak, geen onderzoeksconclusie — en bovendien een onjuiste. Spotto verdient niet per lead: makelaars hebben een abonnement bij het moederbedrijf, en Spotto ontvangt daar een deel van. Het aantal leads beïnvloedt de inkomsten niet direct. De tweedeling hoort niet in een journey-analyse tenzij de relatie tussen beide kanten is uitgewerkt.

---

## Sectie 11: Marketing Doelstelling (2026)

### Opmerkingen

**11. Conversie onterecht gedegradeerd tot secundair doel** *(sectie 11)*
Het document plaatst conversieratio als secundair doel ("stabiliseren of licht verhogen"). Maar als het primaire doel is om meer *relevante* bezoekers aan te trekken met *hogere kwaliteit interacties*, dan zou conversie niet moeten dalen — het zou een natuurlijk gevolg moeten zijn van betere acquisitie. Conversie degraderen tot secundair geeft impliciet toestemming om het te negeren. Het is bovendien een keuze die al vóór dit document was gemaakt (acquisitie als primaire focus voor 2026), waardoor het hier wordt gepresenteerd als onderzoeksconclusie terwijl het een bestaand besluit is.

**12. Onmeetbare succesdefinitie** *(sectie 11)*
"Spotto is top of mind wanneer iemand opnieuw begint te zoeken" — dit is niet meetbaar met de tools die Spotto vandaag heeft. Brand recall vereist surveyonderzoek. Een marketingdoelstelling-sectie zou moeten eindigen met KPI's die daadwerkelijk te monitoren zijn (bijv. terugkerende bezoekers, sessiefrequentie, retentie-ratio).

---

## Sectie 12-13: Journey Overzicht & Persona

### Opmerkingen

**13. Journey-overzicht contradicteert de kernthese** *(sectie 12)*
De overzichtstabel presenteert de journey als een lineaire 5-stappenstroom (Awareness → Consideration → Decision → Purchase → Re-entry/Retention). Maar de kernthese van het document (secties 19, 21, 22) is dat de journey cyclisch is, met structurele terugkeermomenten. De samenvattende tabel — die het centrale referentiepunt van het document zou moeten zijn — weerspiegelt de eigen hoofdconclusie niet.

Daarnaast bevat de tabel interne tegenspraken:
- **Awareness "Koper zegt": "I want to buy a (new) property"** — dit contradicteert sectie 3, die expliciet stelt dat er in deze fase "nog geen expliciete koopintentie" is.
- **Re-entry "Koper zegt": "I would use Spotto again"** — dit is een retentie-wens vanuit Spotto, geen kopersuitspraak. De koper in re-entry zou eerder zeggen: "Ik moet opnieuw beginnen met zoeken."

---

## Secties 14-29: Niet individueel beoordeeld

De gedetailleerde fase-uitwerkingen (14-18), de loop-based journey (19), Spotto's rol per fase (20-21), groeikansen (22), accountcreatie & data (23-24), en de samenvatting/next steps (25-29) zijn niet per sectie beoordeeld. De patronen die in secties 1-13 zijn geïdentificeerd herhalen zich structureel in de rest van het document.

---

## Algemeen Oordeel

### Wat het document goed doet

- De **kernthese** — de vastgoedzoektocht is cyclisch, niet lineair — is intuïtief overtuigend en vormt een bruikbaar denkkader.
- **Sectie 9** (Marketingrealiteit) bevat de meest concrete en bruikbare observaties.
- De **scheiding marketing/platform** (sectie 10) is als concept nuttig, hoewel slecht onderbouwd.
- De nadruk op **consideration en re-entry** als kernfases sluit aan bij wat we zien in platformgedrag.

### Structureel probleem

Het document is een **strategisch narratief dat zich presenteert als onderzoek**. De conclusies staan al vast voordat het bewijs wordt geleverd. Dit uit zich in een terugkerend patroon:

1. Een marktobservatie of algemene bewering wordt gepresenteerd
2. De implicatie springt naar een strategische positie ("begeleiden," "niet overtuigen," "rust en richting")
3. Die positie wordt verderop als gegeven behandeld

Dit maakt het document intern consistent maar **circulair**. De persona bevestigt de thesis, de thesis genereert de persona. De journey-fases ondersteunen de strategie, de strategie bepaalt hoe de fases worden beschreven.

### Wat ontbreekt voor productbeslissingen

| Lacune | Impact |
|--------|--------|
| **Methodologie** | We weten niet hoe betrouwbaar de conclusies zijn |
| **Kwantitatieve data** | We kunnen geen baselines bepalen of effect meten |
| **Persona-segmentatie** | We bouwen features voor een te breed gedefinieerde doelgroep |
| **Competitief landschap** | We weten niet waarop we ons onderscheiden |
| **Benchmarks** | Operationele beoordelingen ("beperkte lead ratio") zijn subjectief |
| **Meetbare KPI's** | De succesdefinitie is niet te monitoren |
| **Business model accuraatheid** | Het document gaat uit van een onjuist verdienmodel |

### Aanbeveling

Het document niet verwerpen, maar **ook niet als onderbouwing behandelen voor productbeslissingen**. Het is bruikbaar als:
- **Denkkader** voor hoe we over de journey nadenken
- **Gespreksstarter** met marketing over prioriteiten
- **Hypothesebron** die gevalideerd moet worden met data

Concrete vervolgstappen:
1. **Valideer de cyclische journey-these** met GA4-data (terugkerende bezoekers, sessiefrequentie, paden)
2. **Vraag de freelancer/marketing naar de onderliggende data** en methodologie
3. **Werk persona's uit** met specifieke triggers, situaties en gedragsverschillen
4. **Voer een competitive analysis uit** of vraag deze op
5. **Definieer meetbare KPI's** die aansluiten bij de doelstellingen voor 2026

---

## Productperspectief

### Waar we het mee eens zijn

- **De vastgoedzoektocht is cyclisch**, niet lineair — dit geldt voor elke persona, niet alleen ervaren kopers.
- **Terugkerende bezoekers behouden is makkelijker dan nieuwe vinden.** Retentie als focus is correct.
- **Kwalitatieve bezoekers aantrekken en activeren** leidt tot betere merkbinding. Dit is een juiste strategische keuze.
- **We winnen niet van Immoweb op marketingbudget of bereik.** Waar we wél op kunnen winnen is een open vraag die dit document niet beantwoordt.
- **Activatie is een hefboom voor terugkeer**, al is de vorm (accountcreatie, alerts, saved searches) nog open.

### Waar we het niet mee eens zijn

**Decision en Purchase zijn niet "buiten Spotto."**
Het document schrijft deze fases af als buiten de invloedssfeer. In de praktijk blijven kopers het platform gebruiken tijdens decision en purchase, juist omdat ze weten dat het nog mis kan gaan. Een koper die een bod voorbereidt, blijft zoeken als vangnet. Spotto is nog open in hun browser. Dit is geen fase om af te schrijven — het is een fase waar Spotto relevant blijft zonder er actief iets voor te hoeven doen.

**De journey is niet alleen cyclisch, maar parallel.**
Het document beschrijft de journey als één loop die herhaald wordt. In werkelijkheid lopen meerdere loops tegelijk. Een koper kan in dezelfde sessie in consideration zitten voor pand A, een contactverzoek sturen voor pand B (conversie), en al in re-entry zijn na pand C dat afviel. Meerdere conversies per sessie zijn hier bewijs van. Dit patroon is sterker bij urgente triggers (scheiding, verhuizing) dan bij dromers, wat opnieuw aantoont dat de trigger het gedrag bepaalt (zie opmerking 2).

### Samengevat

Het document is zwak opgebouwd. De structuur is circulair, de onderbouwing ontbreekt, en de conclusies worden als feiten gepresenteerd zonder bewijs. In deze vorm overtuigt het document de raad van bestuur niet — het leest als een strategisch verhaal, niet als een onderbouwde analyse.

De conclusies zijn grotendeels juist, maar ze zijn juist bij toeval — niet omdat de analyse ze bewezen heeft. De strategische richting klopt, de onderbouwing niet. Voor productbeslissingen hebben we validatie nodig, geen narratief.
