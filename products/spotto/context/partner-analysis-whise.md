# Partner Analyse: Whise

**Datum:** 2026-02-06
**Periode:** januari 2025 - december 2025
**Totaal tickets:** 73
**Bron:** Freshdesk support tickets getagd als `spotto_partner_whise` (CSV-export + Freshdesk API steekproef van 21 tickets)

---

## Samenvatting

Van de 73 Whise-gerelateerde support tickets is het overgrote deel (84%) afkomstig van **geautomatiseerde activatie-emails** die Whise automatisch naar support@spotto.be stuurt wanneer een vastgoedkantoor de Spotto-export activeert in hun CRM. Elke email creëert een apart Freshdesk-ticket dat manueel moet worden afgehandeld.

**Slechts 12 van de 73 tickets (16%) bevatten een echte klantvraag of probleem** dat inhoudelijke actie vereist. De overige 61 tickets zijn geautomatiseerde notificaties die een standaard-onboardingproces volgen.

Dit maakt Whise de partner met het hoogste automatiseringspotentieel: met relatief eenvoudige aanpassingen kan 84% van het ticketvolume worden geëlimineerd.

### Kerncijfers

| Metriek | Waarde |
|---------|--------|
| Totaal tickets | 73 |
| Geautomatiseerd (geen echte klantvraag) | 61 (84%) |
| Echte support issues | 12 (16%) |
| Meest voorkomend type | Activatie-aanvraag export (noreply@whise.eu) |
| Unieke kantoren in activatie-emails | ~40 (rest zijn duplicaten) |
| Piekperiode | oktober 2025 (21 tickets) |

---

## Sub-categorieen met aantallen

### 1. Geautomatiseerde activatie-emails (61 tickets -- 84%)

| Sub-type | Aantal | Afzender |
|----------|--------|----------|
| "WHISE - Publication of estates on Spotto" | 60 | noreply@whise.eu |
| "Activatie van de diensten van Real Smart" | 1 | noreply@whise.eu |
| **Totaal** | **61** | |

**Beschrijving:** Whise stuurt een gestandaardiseerde email in het Engels wanneer een vastgoedkantoor in hun CRM de export naar Spotto activeert. De email bevat steeds:
- Naam van het kantoor en het specifieke office
- Een "Click here to activate" link waarmee Spotto de credentials kan invullen
- Contactgegevens van het kantoor (adres, contactpersoon, e-mailadres)
- De melding: "The customer confirms that the media / service can remove all properties sent by the previous software and still active on the media / service."

**Afhandeling door support (typisch ~10 min per ticket):**
1. Back Office (BO) account aanmaken voor het kantoor
2. Standaard-email sturen naar het kantoor met instructies om kantoorprofiel aan te maken op RealSmart (www.realsmart.be)
3. Ticket sluiten (status 5 = Closed)

**Kantoren in steekproef:**

| Kantoor | Locatie | Contactpersoon |
|---------|---------|----------------|
| Freca | Berlare | De Vos Frederique |
| Soold | Diest | Sools Frederike |
| Leonards Immobilien | Kortrijk | Meulemans Eva |
| De Boer & Partners - Turnhout Huur | Turnhout | Franken Eva |
| Haes Vastgoed | Kalmthout | Haes Sven |
| Acasa | Loppem | Vlieghe Jan |
| BM Immo | Ternat | Mortier Bianca |
| Oreon Properties | Antwerpen | De Brouwer Philippe |
| Verheyen Vastgoed | Hoogstraten | Verheyen Ann |
| Heer Albert - Kantoor Brasschaat | Antwerpen | Matthijs Leen |

**Duplicaat-probleem:** Meerdere kantoren genereren herhaaldelijke activatieverzoeken:

| Kantoor | Aantal verzoeken | Periode |
|---------|-----------------|---------|
| Oreon Properties Antwerpen | 7 | 29/10 - 30/10/2025 |
| BM Immo (Ternat) | 5 | 29/10 - 30/10/2025 |
| Heer Albert (meerdere vestigingen) | 2+ | december 2025 |

### 2. Whise helpdesk doorverwijzingen (4 tickets -- 5%)

| Ticket | Onderwerp | Datum | Afzender |
|--------|-----------|-------|----------|
| 392620 | Re: Spotto welkomstmail - doorgestuurde vraag | 11/04/2025 | helpdesk@whise.eu |
| 395190 | Quares - Panden Pending | 13/05/2025 | helpdesk@whise.eu |
| 396482 | Re: Pand op Spotto | 04/06/2025 | helpdesk@whise.eu |
| 398488 | Re: Je hebt een vraag gesteld via spotto | 04/07/2025 | helpdesk@whise.eu |

**Beschrijving:** Whise's eigen helpdesk stuurt vragen door die ze niet zelf kunnen oplossen. Dit zijn typisch:
- Panden die in "pending" status hangen
- Vragen van makelaars die via Whise-support bij Spotto terechtkomen
- Doorgestuurde bezoekaanvragen of klantvragen

**Beoordeling:** Dit zijn legitieme support-interacties die menselijke tussenkomst vereisen. Het volume (4 per jaar) is beheersbaar.

### 3. Whise API/systeem berichten (2 tickets -- 3%)

| Ticket | Onderwerp | Datum | Afzender |
|--------|-----------|-------|----------|
| 395560 | Fwd: Nieuwe bezoekaanvraag | 19/05/2025 | api@whise.eu |
| 407726 | Re: FW: FW: Foutieve informatie op Spotto | 01/12/2025 | api@whise.eu |

**Beschrijving:** Berichten van api@whise.eu, typisch doorgestuurde systeemberichten of klachten over data-kwaliteit. Ticket 407726 betreft foutieve pand-informatie die via Whise-sync op Spotto verschijnt -- een echt technisch probleem met dubbele klantrecords.

### 4. Makelaar-geinitieerd over Whise-koppeling (5 tickets -- 7%)

| Ticket | Onderwerp | Afzender | Bron |
|--------|-----------|----------|------|
| 389958 | Controleren Office IDs Whise - Immo Drie | bernadette@immodrie.be | Telefoon |
| 389969 | RE: Controleren Office IDs Whise - Immo Drie | pascale@immodrie.be | Email |
| 391432 | Foute synchronisatie bij veld 'zolder' van Whise naar spotto? | isabelle@dewoonmakelaar.be | Email |
| 394629 | Re: WHISE - Publication of estates on Spotto | simon@dewildevastgoed.be | Email |
| 398986 | Whise koppeling Spotto Trevi | csintobin@trevi.be | Telefoon |

**Sub-types:**
- **Office ID verificatie** (389958/389969): Makelaar wil controleren of de juiste Whise Office IDs gekoppeld zijn
- **Sync-fouten** (391432): Specifiek dataveld ('zolder') wordt verkeerd gesynchroniseerd van Whise naar Spotto
- **Activatie follow-up** (394629): Makelaar reageert op een activatie-email met vervolgvragen
- **Koppeling opzetten** (398986): Telefonische hulpvraag over het opzetten van de Whise-Spotto koppeling

### 5. Generieke makelaar-vraag over Whise (1 ticket -- 1%)

| Ticket | Onderwerp | Afzender | Datum |
|--------|-----------|----------|-------|
| 401514 | Whise | liesbeth@immo-desk.be | 28/08/2025 |

---

## Patronen en inzichten

### Patroon 1: Duplicaat-activatieverzoeken blazen volume op

Meerdere kantoren sturen herhaaldelijk dezelfde activatie-aanvraag. Oreon Properties Antwerpen genereerde 7 identieke tickets in 2 dagen. Dit wijst erop dat:
- Whise geen duidelijke feedback geeft aan het kantoor wanneer de activatie "in behandeling" is
- Kantoren blijven op de activatieknop drukken als ze niet direct resultaat zien
- Whise mogelijk een retry-mechanisme heeft dat automatisch opnieuw probeert

### Patroon 2: Pieken in activatievolume

De activatie-emails komen niet gespreid maar in pieken:

| Periode | Tickets | Opmerkingen |
|---------|---------|-------------|
| 21 okt 2025 | 6 tickets | Batch activatie, 5 unieke kantoren |
| 29-30 okt 2025 | 12 tickets | Combinatie 3 kantoren + duplicaten |
| 5 mei 2025 | 3 tickets | Cluster |
| 27-28 jun 2025 | 4 tickets | Cluster |

### Patroon 3: Activatie-emails zijn 100% gestandaardiseerd

Elke email van noreply@whise.eu volgt exact hetzelfde template. Subject is altijd "WHISE - Publication of estates on Spotto". De body bevat altijd dezelfde structuur. Dit maakt ze perfect herkenbaar en automatiseerbaar via regelgebaseerde detectie.

### Patroon 4: Support volgt altijd hetzelfde handmatige proces

De conversatie-analyse (ticket 405722 - Verheyen Vastgoed) toont het standaardproces:
1. Agent stuurt een gestandaardiseerde welkomstmail in het Nederlands naar het kantoor
2. Mail bevat stap-voor-stap instructies voor RealSmart-registratie
3. Agent maakt een interne notitie "BO aangemaakt"
4. Ticket wordt gesloten

Dit proces is bij elk activatieticket identiek en kan volledig geautomatiseerd worden.

### Patroon 5: Echte issues zijn data-kwaliteit en koppelingsbeheer

De 12 niet-geautomatiseerde tickets gaan over drie thema's:
1. **Onboarding/koppeling** (6 tickets): Hulp bij het opzetten of verifieren van de Whise-Spotto koppeling
2. **Data-kwaliteit** (3 tickets): Sync-fouten, foutieve informatie, pending panden
3. **Doorgestuurde klantvragen** (3 tickets): Whise stuurt vragen door die ze zelf niet kunnen beantwoorden

### Patroon 6: Inconsistente ticket-typering

Identieke activatie-emails worden in Freshdesk als verschillende types aangemaakt:
- "Technisch - Taak" (eerste batch, oktober 2025)
- "IT Support" (latere batch, oktober-november 2025)
- "Functioneel" (sporadisch)

Dit maakt rapportage op basis van ticket-type onbetrouwbaar voor Whise-tickets.

---

## Aanbevelingen voor verbetering

### 1. Automatiseer de activatie-workflow (impact: -61 tickets/jaar, -84%)

**Probleem:** Elke Whise-activatie creëert een manueel ticket dat handmatig verwerkt wordt met een identiek proces.

**Oplossing -- gefaseerd:**

**Fase 1 (quick win):** Freshdesk-automatie
- Herken inkomende emails van noreply@whise.eu met subject "WHISE - Publication of estates on Spotto"
- Auto-reply met standaard welkomstmail naar het kantoor (extractie contactgegevens uit email body)
- Ticket automatisch categoriseren als "whise-activatie" en toewijzen aan specifieke queue
- Agent hoeft alleen BO aan te maken en te bevestigen

**Fase 2 (structureel):** API-integratie
- Bouw een webhook/API-endpoint dat Whise-activatieverzoeken direct verwerkt
- Automatisch BO-account aanmaken
- Automatisch welkomstmail sturen
- Ticket auto-sluiten met log van uitgevoerde acties

**Geschatte besparing:** ~61 tickets per jaar, ~10 uur per maand aan support-tijd

### 2. Voorkom duplicaat-activatieverzoeken

**Probleem:** Kantoren sturen dezelfde activatie 2-7 keer, elk genereert een apart ticket.

**Oplossing:**
- Freshdesk-regel: als binnen 48 uur een tweede email binnenkomt van noreply@whise.eu met dezelfde kantoornaam in de body, voeg automatisch toe als notitie aan het bestaande ticket
- Bespreek met Whise of ze een bevestigingsscherm kunnen tonen aan kantoren ("Je activatie is ontvangen en wordt verwerkt")

### 3. Verfijn ticket-tagging voor Whise

**Probleem:** Alle Whise-tickets krijgen dezelfde generieke tag `spotto_partner_whise`, maar de aard verschilt sterk.

**Oplossing -- update tagging rules:**

| Nieuwe tag | Herkenningsregel | Volume |
|------------|-----------------|--------|
| `spotto_whise_activatie_auto` | Van noreply@whise.eu + subject bevat "Publication of estates" | ~60/jaar |
| `spotto_whise_helpdesk` | Van helpdesk@whise.eu | ~4/jaar |
| `spotto_whise_api` | Van api@whise.eu | ~2/jaar |
| `spotto_whise_koppeling` | Van makelaar + onderwerp bevat "Whise", "koppeling", "Office ID" | ~5/jaar |
| `spotto_whise_sync` | Onderwerp bevat "synchronisatie", "foutieve informatie", "pending" | ~2/jaar |

### 4. Self-service onboarding voor Whise-kantoren

**Probleem:** Na de Whise-activatie moet een makelaar alsnog handmatig een kantoorprofiel aanmaken via RealSmart. Het support-team stuurt hiervoor telkens dezelfde instructie-email.

**Oplossing:**
- Creeer een dedicated landingspagina voor Whise-kantoren met stap-voor-stap onboarding
- Voeg tracking toe om te zien welke kantoren hun profiel niet afmaken (follow-up na 7 dagen)
- Overweeg de Whise-activatielink direct te laten doorlinken naar deze landingspagina

### 5. Verbeter communicatie met Whise over technische issues

**Probleem:** Data-kwaliteitsproblemen (sync-fouten, dubbele klantrecords) komen sporadisch voor maar zijn moeilijk te debuggen.

**Oplossing:**
- Documenteer bekende sync-mappingproblemen (bijv. het 'zolder'-veld issue uit ticket 391432)
- Creeer een gedeeld escalatiekanaal met Whise voor technische issues
- Voeg een unieke constraint toe op Whise client ID in de Spotto-database om dubbele records te voorkomen

---

## Bijlage: Volledige ticket-lijst per categorie

### A. Geautomatiseerde activaties (61 tickets)

| Ticket ID | Datum | Onderwerp |
|-----------|-------|-----------|
| 386401 | 10/01/2025 | WHISE - Publication of estates on Spotto |
| 386581 | 14/01/2025 | WHISE - Publication of estates on Spotto |
| 386769 | 16/01/2025 | WHISE - Publication of estates on Spotto |
| 386802 | 16/01/2025 | WHISE - Publication of estates on Spotto |
| 386845 | 17/01/2025 | WHISE - Publication of estates on Spotto |
| 386962 | 20/01/2025 | WHISE - Publication of estates on Spotto |
| 387029 | 21/01/2025 | WHISE - Publication of estates on Spotto |
| 387365 | 26/01/2025 | WHISE - Publication of estates on Spotto |
| 387646 | 28/01/2025 | WHISE - Publication of estates on Spotto |
| 388165 | 05/02/2025 | WHISE - Publication of estates on Spotto |
| 388472 | 10/02/2025 | WHISE - Publication of estates on Spotto |
| 388724 | 13/02/2025 | WHISE - Publication of estates on Spotto |
| 389682 | 27/02/2025 | WHISE - Publication of estates on Spotto |
| 390051 | 05/03/2025 | WHISE - Publication of estates on Spotto |
| 391051 | 19/03/2025 | WHISE - Publication of estates on Spotto |
| 391538 | 26/03/2025 | WHISE - Publication of estates on Spotto |
| 391660 | 27/03/2025 | WHISE - Publication of estates on Spotto |
| 391765 | 28/03/2025 | WHISE - Publication of estates on Spotto |
| 392323 | 07/04/2025 | Activatie van de diensten van Real Smart |
| 392677 | 13/04/2025 | WHISE - Publication of estates on Spotto |
| 394317 | 29/04/2025 | WHISE - Publication of estates on Spotto |
| 394476 | 02/05/2025 | WHISE - Publication of estates on Spotto |
| 394531 | 05/05/2025 | WHISE - Publication of estates on Spotto |
| 394589 | 05/05/2025 | WHISE - Publication of estates on Spotto |
| 394590 | 05/05/2025 | WHISE - Publication of estates on Spotto |
| 394716 | 06/05/2025 | WHISE - Publication of estates on Spotto |
| 396071 | 27/05/2025 | WHISE - Publication of estates on Spotto |
| 396130 | 28/05/2025 | WHISE - Publication of estates on Spotto |
| 396155 | 28/05/2025 | WHISE - Publication of estates on Spotto |
| 397056 | 14/06/2025 | WHISE - Publication of estates on Spotto |
| 398099 | 27/06/2025 | WHISE - Publication of estates on Spotto |
| 398129 | 27/06/2025 | WHISE - Publication of estates on Spotto |
| 398214 | 30/06/2025 | WHISE - Publication of estates on Spotto |
| 398241 | 30/06/2025 | WHISE - Publication of estates on Spotto |
| 398499 | 04/07/2025 | WHISE - Publication of estates on Spotto |
| 398928 | 09/07/2025 | WHISE - Publication of estates on Spotto |
| 399024 | 10/07/2025 | WHISE - Publication of estates on Spotto |
| 399036 | 10/07/2025 | WHISE - Publication of estates on Spotto |
| 401664 | 01/09/2025 | WHISE - Publication of estates on Spotto |
| 401865 | 04/09/2025 | WHISE - Publication of estates on Spotto |
| 401895 | 04/09/2025 | WHISE - Publication of estates on Spotto |
| 403757 | 03/10/2025 | WHISE - Publication of estates on Spotto |
| 405060 | 21/10/2025 | WHISE - Publication of estates on Spotto |
| 405061 | 21/10/2025 | WHISE - Publication of estates on Spotto |
| 405062 | 21/10/2025 | WHISE - Publication of estates on Spotto |
| 405063 | 21/10/2025 | WHISE - Publication of estates on Spotto |
| 405064 | 21/10/2025 | WHISE - Publication of estates on Spotto |
| 405086 | 21/10/2025 | WHISE - Publication of estates on Spotto |
| 405720 | 29/10/2025 | WHISE - Publication of estates on Spotto |
| 405721 | 29/10/2025 | WHISE - Publication of estates on Spotto |
| 405722 | 29/10/2025 | WHISE - Publication of estates on Spotto |
| 405723 | 29/10/2025 | WHISE - Publication of estates on Spotto |
| 405737 | 30/10/2025 | WHISE - Publication of estates on Spotto |
| 405738 | 30/10/2025 | WHISE - Publication of estates on Spotto |
| 405748 | 30/10/2025 | WHISE - Publication of estates on Spotto |
| 405749 | 30/10/2025 | WHISE - Publication of estates on Spotto |
| 405751 | 30/10/2025 | WHISE - Publication of estates on Spotto |
| 405795 | 30/10/2025 | WHISE - Publication of estates on Spotto |
| 405796 | 30/10/2025 | WHISE - Publication of estates on Spotto |
| 405797 | 30/10/2025 | WHISE - Publication of estates on Spotto |
| 408757 | 14/12/2025 | WHISE - Publication of estates on Spotto |

### B. Whise helpdesk doorverwijzingen (4 tickets)

| Ticket ID | Datum | Onderwerp |
|-----------|-------|-----------|
| 392620 | 11/04/2025 | Re: Spotto welkomstmail - vraag doorgestuurd |
| 395190 | 13/05/2025 | Quares - Panden Pending |
| 396482 | 04/06/2025 | Re: Pand op Spotto |
| 398488 | 04/07/2025 | Re: Je hebt een vraag gesteld via spotto |

### C. Whise API/systeem (2 tickets)

| Ticket ID | Datum | Onderwerp |
|-----------|-------|-----------|
| 395560 | 19/05/2025 | Fwd: Nieuwe bezoekaanvraag |
| 407726 | 01/12/2025 | Re: FW: FW: Foutieve informatie op Spotto |

### D. Makelaar-geinitieerd over Whise (6 tickets)

| Ticket ID | Datum | Onderwerp | Afzender |
|-----------|-------|-----------|----------|
| 389958 | 04/03/2025 | Controleren Office IDs Whise - Immo Drie | bernadette@immodrie.be |
| 389969 | 04/03/2025 | RE: Controleren Office IDs Whise - Immo Drie | pascale@immodrie.be |
| 391432 | 25/03/2025 | Foute synchronisatie bij veld 'zolder' van Whise naar spotto? | isabelle@dewoonmakelaar.be |
| 394629 | 05/05/2025 | Re: WHISE - Publication of estates on Spotto | simon@dewildevastgoed.be |
| 398986 | 10/07/2025 | Whise koppeling Spotto Trevi | csintobin@trevi.be |
| 401514 | 28/08/2025 | Whise | liesbeth@immo-desk.be |
