# Supportgids: WeGov Erkenningen & Approve Customers

## Wat is dit?

Spotto is nu gekoppeld aan **WeGov**, het systeem dat CIB-erkenningen beheert. Wanneer een bedrijf een CIB-erkenning krijgt of verliest, stuurt WeGov automatisch een event naar Spotto. Het systeem verwerkt deze events en creëert of deactiveert klanten waar nodig.

**Belangrijk:** Niet elk bedrijf met een CIB-erkenning is relevant voor Spotto (bv. notarissen, syndici). Daarom worden nieuwe klanten niet meteen actief, maar komen ze eerst in een **goedkeurings-queue** terecht.

---

## Automatische flows (achter de schermen)

### Nieuwe erkenning binnenkomt → bedrijf bestaat nog niet in Spotto
- Het systeem maakt automatisch een klant aan met de gegevens uit WeGov (naam, ondernemingsnummer, etc.)
- Als er al een klant bestaat met hetzelfde ondernemingsnummer, wordt er geen nieuwe aangemaakt
- De klant krijgt de invite-status **Pending** en verschijnt in de **Approve Customers Queue**
- Er wordt **geen** onboarding-mail verstuurd — dat gebeurt pas na goedkeuring door CX

### Nieuwe erkenning binnenkomt → klant bestaat al in Spotto (actief)
- Het systeem herkent de klant op basis van ondernemingsnummer/organisatie-ID
- Er wordt niets gedaan — de bestaande klant blijft ongewijzigd

### Erkenning vervalt → klant is actief in Spotto
- Het systeem controleert of de klant een **niet-CIB contract** heeft
  - **Wel een niet-CIB contract:** er gebeurt niets (klant blijft actief)
  - **Geen niet-CIB contract:** klant wordt automatisch gedeactiveerd (het systeem controleert ook of er geen nieuwere actieve CIB-erkenning is)
- Er wordt automatisch een **deactivatie-mail** gestuurd naar de CRM-leverancier(s) waar de klant een koppeling mee heeft (Skarabee, Omnicasa, Zabun, Whise)
- **Let op:** als de deactivatie door een **Admin** (manueel via backoffice) wordt gedaan, worden er géén CRM-mails verstuurd. Alleen bij automatische (systeem-)deactivatie via WeGov worden CRM-mails verstuurd.

### Erkenning wordt actief → klant bestaat maar is niet actief
- Het systeem **heractiveeert de klant automatisch** (mits de klant niet gearchiveerd is)
- Er wordt een audit log aangemaakt
- **Let op:** er wordt geen notificatiemail verstuurd bij automatische heractivatie

---

## Approve Customers Queue

### Waar vind je het?
**Spotto Backoffice → Customers → Approve Customers**

### Wat zie je?
Een lijst van alle klanten die automatisch zijn aangemaakt via WeGov-erkenningen en nog moeten worden beoordeeld. De lijst toont standaard enkel items met status **Pending**.

| Kolom | Uitleg |
|---|---|
| Bedrijfsnaam | Naam van het bedrijf uit WeGov |
| Ondernemingsnummer | BTW-nummer |
| IC ID | Klikbare link naar het profiel in Immo Connect (opent in nieuw tabblad) |
| Heeft CRM-koppeling | Ja/Nee — of er al een CRM gekoppeld is |
| Datum aangemaakt | Wanneer de klant is aangemaakt in Spotto |
| Datum erkenning | Wanneer de CIB-erkenning is ontvangen |

### Wat moet je doen?

1. **Bekijk de lijst** — controleer of het bedrijf een relevante makelaar is (geen notaris, syndicus, etc.)
2. **Selecteer items** — gebruik Ctrl+klik, Shift+klik, of "Select all"
3. **Kies een actie:**
   - **Approve** → status wordt "Approved" en de klant ontvangt een **onboarding-mail**
   - **Skip** → status wordt "Skipped", er wordt geen mail verstuurd

### Statussen

| Status | Betekenis |
|---|---|
| **Pending** | Nieuw uit WeGov, nog niet beoordeeld |
| **Approved** | Goedgekeurd door CX, onboarding-mail is verstuurd |
| **Skipped** | Overgeslagen, geen actie ondernomen |
| **Migrated** | Was al actieve klant vóór dit systeem werd gelanceerd |

---

## Individuele klant beheren (Customer Detail)

### Invite sectie
Op de **klantdetailpagina** (Customers → [Klant] → tabblad Details) is een nieuwe **Invite-sectie** toegevoegd met:

- **Invite Status** — Pending / Approved / Skipped / Migrated
- **Status gewijzigd op** — datum en tijd van de laatste wijziging
- **Account aangemaakt op** — wanneer de klant is aangemaakt
- **WeGov erkenning datum** — wanneer de erkenning ontvangen werd

### Acties op klantniveau

| Actie | Wanneer beschikbaar | Wat gebeurt er |
|---|---|---|
| **Verstuur Invite** | Status is Pending of Skipped | Status wordt Approved, onboarding-mail wordt verstuurd |
| **Markeer als Skipped** | Status is Pending | Status wordt Skipped, geen mail |

> **Tip:** Dit is handig voor klanten die buiten de bulk queue om benaderd moeten worden, of om een eerdere "Skip" te corrigeren.

### Invite History Log
Onder **Customers → [Klant] → Logs** vind je een overzicht van alle statuswijzigingen voor die klant. Dit toont wanneer de status is gewijzigd (nieuwste eerst), handig om de volledige lifecycle te zien.

---

## Duplicate waarschuwing

Bij het **manueel aanmaken** van een klant in de backoffice controleert het systeem nu automatisch:
- Of het **BTW-nummer** al bestaat bij een andere klant
- Of het **IC ID (Company)** al bestaat bij een andere klant

Als er een match gevonden wordt:
- Je ziet een waarschuwing met de naam en status van de bestaande klant
- Je kan doorklikken naar de bestaande klant
- Je kan alsnog aanmaken als het toch nodig is (bv. fout in bestaande data)

---

## Onboarding-mail (inhoud)

Wanneer een klant wordt goedgekeurd (via queue of individueel), ontvangt het bedrijf een mail met:

- Uitleg over CIB-lidmaatschap en toegang tot Spotto
- Hoe ze panden kunnen publiceren (via kantoorsoftware of manueel via spotto.be)
- Wat ze moeten doorgeven: toestemming voor koppeling, naam kantoorsoftware, aantal kantoren/vestigingen

De mail wordt verstuurd naar het **e-mailadres van de klant**, met een configureerbare **BCC** (typisch helpdesk). De mail template wordt beheerd in het CMS.

---

## CRM-mails bij deactivatie/reactivatie

Bij deactivatie of reactivatie stuurt het systeem automatisch een mail naar de CRM-leverancier(s) waarmee de klant een koppeling heeft. De e-mailadressen worden uit de configuratie gehaald.

| CRM | Deactivatie-mail | Reactivatie-mail |
|---|---|---|
| Skarabee | Ja | Ja |
| Omnicasa | Ja | Ja |
| Zabun | Ja | Ja |
| Whise | **Nee** | **Nee** (Whise verwacht dat de klant dit zelf regelt) |

**Let op:**
- CRM-mails worden **alleen** verstuurd bij automatische (systeem-)deactivatie. Bij manuele deactivatie door een Admin worden er **geen** CRM-mails gestuurd.
- Als een klant al een CRM-code heeft, moet die **niet verwijderd worden** bij deactivatie. De code blijft staan, enkel de klant wordt gedeactiveerd.

---

## Veelgestelde vragen

**V: Er staat een notaris in de Approve queue. Wat doe ik?**
A: Klik op "Skip". Notarissen, syndici en andere niet-relevante bedrijven sla je over.

**V: Ik heb per ongeluk een klant geskipt. Kan ik dat herstellen?**
A: Ja. Ga naar de klantdetailpagina en gebruik daar de knop "Verstuur Invite" om alsnog goed te keuren.

**V: Een klant is gedeactiveerd maar heeft nog een niet-CIB contract. Wat nu?**
A: Het systeem houdt hier al rekening mee — klanten met een niet-CIB contract worden niet automatisch gedeactiveerd.

**V: Ik krijg een melding dat een BTW-nummer al bestaat bij het aanmaken. Wat nu?**
A: Klik door naar de bestaande klant om te controleren. Waarschijnlijk bestaat de klant al en hoef je geen nieuwe aan te maken.

**V: De erkenning van een bestaande maar inactieve klant is weer actief geworden. Wat moet ik doen?**
A: Niets — het systeem heractiveeert de klant automatisch. Je kan dit verifiëren via de audit logs op de klantdetailpagina. Gearchiveerde klanten worden niet automatisch geheractiveerd.
