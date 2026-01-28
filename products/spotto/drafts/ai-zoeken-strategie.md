# AI-zoeken strategie: opties en afwegingen

**Status:** Draft - ter bespreking met Marketing
**Datum:** 21 januari 2026
**Context:** Herziening van SPOTTO-1188 (MCP-integratie)

## Aanleiding

We zien significant en groeiend ChatGPT-traffic naar Spotto:

| Maand | Sessies | Actieve gebruikers |
|-------|---------|-------------------|
| Oktober 2025 | 2,634 | 1,599 |
| November 2025 | 2,228 | 1,331 |
| December 2025 | 1,765 | 1,086 |
| Januari 2026 | 1,448 | 911 |

Dit verkeer komt **organisch** - gebruikers vragen ChatGPT naar vastgoed in België en worden doorgestuurd naar Spotto. Probleem: ChatGPT toont soms verouderde/verkochte panden.

De oorspronkelijke epic (SPOTTO-1188) stelt een MCP/Custom GPT integratie voor. Na analyse zijn er meerdere paden mogelijk.

---

## De drie opties

### Optie A: Betere indexering (defensief)

**Wat:** Zorgen dat ChatGPT/Bing sneller up-to-date informatie heeft over onze panden.

**Hoe:**
- Schema.org RealEstateListing markup optimaliseren
- IndexNow protocol implementeren (instant updates naar Bing)
- Duidelijke "verkocht" / "offline" signalen in HTML/metadata
- Bing Webmaster Tools actief beheren

**Voordelen:**
- Lost het stale-data probleem op in de bestaande flow
- Werkt ook voor Perplexity, Bing Copilot, Google AI Overviews
- Relatief laag effort
- Geen nieuwe user journey nodig

**Nadelen:**
- Geen garantie dat ChatGPT het direct oppikt
- Geen differentiatie t.o.v. concurrenten
- Geen controle over presentatie

**Effort:** Laag-Middel
**Impact:** Verbetert bestaande ~2000 sessies/maand

---

### Optie B: Custom GPT met reistijdzoeker (offensief)

**Wat:** Een "Spotto Woningzoeker" GPT in de ChatGPT store die onze unieke reistijdzoeker ontsluit.

**Voorbeeld queries die dan werken:**
- "Waar kan ik wonen op 30 minuten van mijn werk in Brussel?"
- "Appartementen binnen 20 minuten fietsen van Gent-Sint-Pieters"
- "Huizen te koop max 45 min met de auto naar Antwerpen, budget 400k"

**Voordelen:**
- Unieke feature die geen concurrent kan bieden
- Real-time data (geen stale listings)
- Duidelijk marketingverhaal: "Zoek op reistijd via ChatGPT"
- Volledige tracking en controle

**Nadelen:**
- Gebruiker moet actief naar de GPT navigeren (friction)
- Lost het stale-probleem in de organische flow NIET op
- €10k campagnebudget nodig voor awareness
- Afhankelijk van ChatGPT Plus/Team/Enterprise users

**Effort:** Middel (huidige stories in SPOTTO-1188)
**Impact:** Nieuwe user journey, onbekend volume

---

### Optie C: Eigen chatbot op spotto.be (premium)

**Wat:** Een chat-interface op spotto.be zelf, aangedreven door OpenAI API + onze zoek/reistijd APIs.

**Voordelen:**
- Gebruiker blijft volledig binnen Spotto
- Beste mogelijke ervaring en controle
- Geen afhankelijkheid van ChatGPT's beperkingen
- Kan ook andere AI-features ondersteunen in de toekomst

**Nadelen:**
- Meeste development effort
- Kosten per conversatie (~€0.01-0.03 per gesprek)
- Risico op "gimmick" perceptie (zie Immoweb)
- Vraag: is chat echt beter dan de huidige reistijdzoeker UI?

**Effort:** Hoog
**Impact:** Onbekend - hangt af van adoptie

---

## Aanbevolen aanpak: gefaseerd

### Fase 1: Indexering verbeteren (quick win)
- Implementeer IndexNow
- Optimaliseer structured data
- Meet of stale-probleem afneemt in organisch ChatGPT verkeer

### Fase 2: Custom GPT met reistijd (differentiatie)
- Bouw GPT met reistijdzoeker als hero feature
- Test met kleine groep gebruikers
- Besluit over marketingcampagne op basis van resultaten

### Fase 3: Evaluatie eigen chatbot (optioneel)
- Alleen als Fase 2 aantoont dat er vraag is naar conversational search
- Business case afhankelijk van GPT adoptie data

---

## Open vragen voor bespreking

1. **Budget allocatie:** Is €10k campagne voor Custom GPT de juiste investering, of eerst kleinschalig testen?

2. **Reistijdzoeker API:** Is deze klaar voor externe ontsluiting? Schaalbaarheid?

3. **Concurrentie:** Weten we of Immoweb/Zimmo aan iets gelijkaardigs werken?

4. **Doelgroep:** Hoeveel van onze doelgroep gebruikt ChatGPT Plus? (Gratis gebruikers kunnen geen Custom GPTs gebruiken met Actions)

5. **Metrics:** Wat is succes? X sessies via GPT? X contactaanvragen? X% van de organische daling stoppen?

---

## Relatie tot huidige Jira tickets

| Ticket | Relevant voor | Aanpassing nodig? |
|--------|---------------|-------------------|
| SPOTTO-1189 (Search tool) | Optie B & C | Nee |
| SPOTTO-1190 (Details tool) | Optie B & C | Nee |
| SPOTTO-1191 (UTM tracking) | Alle opties | Nee |
| SPOTTO-1192 (Typeform feedback) | Optie B & C | Nee |
| SPOTTO-1193 (Rate limiting) | Optie B & C | Nee |
| SPOTTO-1194 (Directory docs) | Optie B | Nee |
| **NIEUW: Indexering** | Optie A | Toe te voegen |
| **NIEUW: Reistijd MCP-tool** | Optie B | Toe te voegen |

---

## Volgende stappen

1. Bespreking Product + Marketing over gewenste richting
2. Validatie technische haalbaarheid reistijd-API voor externe calls
3. Besluit over fasering en budget
4. Backlog aanpassen op basis van gekozen pad
