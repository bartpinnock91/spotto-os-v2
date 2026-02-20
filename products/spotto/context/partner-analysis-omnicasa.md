# Partner Analyse: Omnicasa

_Analyse op basis van 61 Omnicasa-gerelateerde support tickets (steekproef van ~15 tickets in detail bekeken)_
_Datum: 6 februari 2026_

---

## Samenvatting

Omnicasa is een CRM/software-partner voor vastgoedkantoren in Belgie die pandendata beheert en synchroniseert naar portalen zoals Spotto. Van de 61 geanalyseerde tickets zijn de meeste **operationele verzoeken** (activaties van nieuwe klanten) en **synchronisatieproblemen** (data komt niet correct door). Het merendeel van de tickets wordt ingediend door **Omnicasa supportmedewerkers** (Asia Ngoto, Anne De Backer, Farah) namens hun gezamenlijke klanten. De tickets volgen een voorspelbaar patroon en bieden aanzienlijke mogelijkheden voor automatisering.

---

## Sub-categorieen met geschatte aantallen

Op basis van de steekproef schatten we de verdeling van de 61 tickets als volgt:

### 1. Activatie nieuwe klant (~25-30 tickets, ~45%)

**Beschrijving:** Omnicasa stuurt een API-link door naar Spotto om een nieuwe gezamenlijke klant te activeren. Omnicasa heeft de koppeling aan hun kant al ingesteld en verwacht dat Spotto de klant configureert.

**Typisch verloop:**
- Omnicasa stuurt mail met API-URL (formaat: `omnicasaapiv3.omnicasa.com/portal/Spotto/projectandproperty/{key}?CustomerId={id}`)
- Spotto configureert de import
- Bevestiging terug naar Omnicasa
- Omnicasa test of panden correct verschijnen

**Voorbeeldtickets:** 403005 (Ifac Service), 405594 (Astrid Immobilia), 408388 (Century 21 Future Home), 409585 (Wowimmo), 404774/404946 (VanHoye Vastgoed)

**Wie contacteert:** Omnicasa supportmedewerkers (Anne De Backer, Asia Ngoto)

---

### 2. Synchronisatieproblemen - Status mismatch (~10-12 tickets, ~18%)

**Beschrijving:** Pandendata wordt niet correct gesynchroniseerd tussen Omnicasa en Spotto. Panden verschijnen met een verkeerde status (bijv. "te koop" vs. "verkocht", "te huur" vs. "verhuurd").

**Typisch verloop:**
- Makelaar of Omnicasa meldt dat een pand een verkeerde status toont op Spotto
- Spotto onderzoekt de importgegevens en synchronisatie
- Handmatige correctie of bugfix nodig

**Voorbeeldtickets:** 409135 (te koop vs. verkocht), 409489 (te huur vs. verhuurd)

**Wie contacteert:** Mix van vastgoedkantoren (rechtstreeks) en Omnicasa support

---

### 3. Synchronisatieproblemen - Foto's en media (~6-8 tickets, ~12%)

**Beschrijving:** Foto-updates (volgorde, vervanging) worden niet correct doorgevoerd van Omnicasa naar Spotto, vaak door caching-problemen bij Omnicasa's CDN (Cloudflare).

**Typisch verloop:**
- Makelaar past foto's aan in Omnicasa
- Wijzigingen komen niet door op Spotto
- Technisch onderzoek wijst op cache-probleem bij Omnicasa (31 dagen cache)
- Handmatige cache-reset nodig bij Omnicasa

**Voorbeeldtickets:** 407953, 408374, 408480, 409058 (allen INFINIMMO foto-probleem, SPOTTO-1151)

**Wie contacteert:** Omnicasa support (Farah), doorgestuurd naar Omnicasa webdeveloper (Tijs Deleu)

---

### 4. Depublicatie / Pand afhalen (~5-7 tickets, ~10%)

**Beschrijving:** Een pand staat nog gepubliceerd op Spotto maar zou al offline moeten zijn. Omnicasa stuurt het pand niet meer door, maar Spotto heeft het nog niet verwijderd.

**Typisch verloop:**
- Omnicasa meldt dat een pand niet meer doorgestuurd wordt
- Verzoek om het pand van Spotto te halen
- Spotto verwijdert of archiveert het pand handmatig

**Voorbeeldtickets:** 409821 (Immo-zone pand nog gepubliceerd)

**Wie contacteert:** Omnicasa support (Asia Ngoto)

---

### 5. Multi-kantoor / Pandenstroom configuratie (~4-5 tickets, ~7%)

**Beschrijving:** Kantoren met meerdere vestigingen hebben problemen met de toewijzing van panden aan het juiste kantoor, of e-mails worden naar het verkeerde adres gestuurd.

**Typisch verloop:**
- Klant met meerdere vestigingen merkt dat leads naar het verkeerde mailadres gaan
- Aparte pandenstromen nodig per kantoor (aparte Omnicasa API-sleutels)
- Omnicasa en Spotto moeten samenwerken om de configuratie correct in te stellen
- Betreft ook RealSmart-kantoorprofielen

**Voorbeeldtickets:** 409922 (VanHoye Vastgoed multi-kantoor setup)

**Wie contacteert:** Mix van makelaars en Omnicasa support

---

### 6. Overige / Diverse (~4-5 tickets, ~8%)

Overige tickets omvatten:
- Vragen over synchronisatiefrequentie
- Technische API-vragen
- Dubbele tickets over hetzelfde onderwerp (dezelfde conversatie genereert meerdere tickets)

---

## Patronen en inzichten

### Wie neemt contact op?

| Afzender | Geschat % | Toelichting |
|----------|-----------|-------------|
| Omnicasa Support (Asia, Anne, Farah) | ~70% | Stuurt API-links, meldt problemen namens klanten |
| Vastgoedkantoren (rechtstreeks) | ~20% | Melden statusfouten of ontbrekende panden |
| Intern Spotto/Oris | ~10% | Interne tickets na melding van Omnicasa |

### Belangrijkste Omnicasa contactpersonen

- **Asia Ngoto** - Meest frequent, handelt activaties en probleemmeldingen af
- **Anne De Backer** - Voornamelijk activatie van nieuwe klanten
- **Farah** - Technische synchronisatieproblemen, escaleert naar webdevelopers
- **Tijs Deleu** - Omnicasa webdeveloper, betrokken bij technische issues (cache, API)

### Veelvoorkomende patronen

1. **Activatieproces is handmatig en repetitief**: Elke nieuwe klant vereist een mail van Omnicasa met API-link, handmatige configuratie bij Spotto, en een bevestigingsmail terug. Dit is het meest voorkomende tickettype.

2. **Synchronisatieproblemen zijn vaak cache-gerelateerd**: Omnicasa cached foto's tot 31 dagen, wat conflicten veroorzaakt wanneer makelaars foto's updaten.

3. **Status-mapping is foutgevoelig**: De vertaling van Omnicasa-statussen naar Spotto-statussen (te koop/verkocht, te huur/verhuurd) gaat soms fout, wat leidt tot verkeerde weergave op de website.

4. **Multi-kantoor configuratie is complex**: Kantoren met meerdere vestigingen hebben structurele problemen met de toewijzing van leads en pandenstromen.

5. **Dubbele tickets**: Dezelfde e-mailthread genereert soms meerdere Freshdesk-tickets (bijv. 404767/404774/404946 zijn delen van dezelfde VanHoye activatie; 407953/408374/408480/409058 zijn dezelfde foto-sync conversatie).

---

## Aanbevelingen voor verbetering

### Hoge prioriteit

1. **Self-service activatieportaal voor Omnicasa**
   - Bouw een admin-interface waar Omnicasa (of Spotto support) een API-URL kan invoeren om automatisch een klant te activeren
   - Elimineert ~45% van de tickets
   - Potentieel zelfs als onderdeel van een partner-API waar Omnicasa direct klanten kan registreren

2. **Automatische depublicatie bij sync-stop**
   - Wanneer Omnicasa een pand niet meer doorstuurt, automatisch na X dagen depubliceren of markeren
   - Vermijdt handmatige depublicatie-verzoeken (~10% van tickets)

### Gemiddelde prioriteit

3. **Verbeterde status-mapping**
   - Robuustere mapping tussen Omnicasa-statussen en Spotto-statussen
   - Validatie bij import: als een status niet herkend wordt, flag voor manuele review in plaats van een verkeerde status te tonen
   - Vermindert status-mismatch tickets (~18%)

4. **Foto-sync verbetering**
   - Cache-busting implementeren of Omnicasa vragen om kortere cache-tijden
   - Detectie van foto-wijzigingen onafhankelijk van caching (bijv. hash-vergelijking)
   - Reduceert foto-sync problemen (~12%)

### Lage prioriteit

5. **Multi-kantoor ondersteuning verbeteren**
   - Ondersteuning voor meerdere pandenstromen per organisatie
   - Per-kantoor configuratie van universeel mailadres
   - Betere documentatie voor multi-kantoor setup

6. **Communicatiekanaal stroomlijnen**
   - Omnicasa stuurt mails naar support@spotto.be die dubbele tickets creeren
   - Overweeg een dedicated partnerkanaal of tickettype voor Omnicasa
   - Voorkom dat dezelfde conversatiethread meerdere tickets genereert

---

## Impactschatting

| Verbetering | Tickets verminderd | Effort |
|-------------|-------------------|--------|
| Self-service activatie | ~25-30 per batch van 61 | Medium |
| Auto-depublicatie | ~5-7 | Laag |
| Status-mapping fix | ~10-12 | Medium |
| Foto-sync fix | ~6-8 | Medium-Hoog |
| Multi-kantoor support | ~4-5 | Hoog |

**Totaal automatiseerbaar/vermijdbaar: ~50-60 van de 61 tickets (80-98%)**

De Omnicasa-relatie is operationeel intensief maar voorspelbaar. Met gerichte investeringen in automatisering van het activatieproces en verbetering van de synchronisatie-pipeline kan het merendeel van deze tickets geelimineerd worden.
