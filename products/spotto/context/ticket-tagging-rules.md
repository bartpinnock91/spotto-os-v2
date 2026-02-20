# Spotto Ticket Tagging Rules

Dit document beschrijft de classificatieregels voor support tickets in het Spotto helpdesk systeem. Elke ticket krijgt exact 1 tag en 1 groep toegewezen.

## Groepen (parent categorie)

Elke tag valt onder een groep voor high-level rapportage:

| Groep | Beschrijving | Tags |
|---|---|---|
| **Automatisch** | Systeemgegenereerde mails — geen handmatige actie nodig, niet factureerbaar | `activatie_cib_auto`, `factuur_auto`, `vraag_auto`, `bezoekaanvraag_auto` |
| **Partner** | Operationele partner communicatie (activaties, migraties, deactivaties) | `partner_whise`, `partner_zabun`, `partner_omnicasa`, `partner_skarabee`, `partner_apimo`, `partner_sweepbright`, `partner_api` |
| **CIB** | CIB-geïnitieerde manuele activaties en lidmaatschap | `activatie_cib_manueel`, `lidmaatschap` |
| **Content** | Wijzigingen aan listing-inhoud en profielgegevens | `logo`, `foto`, `data_wijziging`, `makelaar_profiel`, `privacy` |
| **Publicatie** | Zichtbaarheid, synchronisatie en pand-specifieke issues | `publicatie`, `sync_fout`, `pand_specifiek`, `verwijderen` |
| **Consument** | Niet-professionele inkomende berichten | `particulier`, `commercieel`, `advertentie` |
| **Onboarding** | Nieuwe klant setup en accountbeheer | `activatie_klant`, `account`, `klant_bevestiging` |
| **Support** | Algemene support vragen en verzoeken | `vraag`, `bezoekaanvraag_manueel`, `factuur_manueel`, `verbetering` |
| **Technisch** | Platform bugs en technische problemen | `technisch`, `website`, `mail_probleem` |
| **Intern** | Interne operaties | `intern` |
| **Overig** | Spam en niet-geclassificeerd | `spam`, `ongetagd` |

---

## Classificatieprioriteit

Tags worden in onderstaande volgorde geëvalueerd. De **eerste match wint**.

1. Partner tags (sterkste signaal: afzender email) — **met functionele override**
2. Geautomatiseerde systeem-emails (afzender + onderwerp combo)
3. Spam
4. Intern (Spotto/Oris/CIB-VIVO medewerkers)
5. CIB lidmaatschap & activaties
6. Content-specifieke tags (logo, foto, data, privacy)
7. Functionele tags (publicatie, sync, technisch, bezoekaanvraag, factuur)
8. Consumenten tags (particulier, commercieel, advertentie)
9. Catch-all (vraag, account, website, verbetering, ongetagd)

### Functionele override bij partner tickets

Partner tickets worden **niet** automatisch als partner getagd als het onderwerp een herkenbaar functioneel probleem beschrijft. In dat geval krijgt het ticket de functionele tag in plaats van de partner tag.

Binnen elke partner-match wordt eerst gecontroleerd op:

| Functioneel onderwerp | Resulterende tag | Voorbeeld |
|---|---|---|
| Sync/data fout ("foute synchronisatie", "als verkocht", "velden niet correct", "panden pending") | `spotto_sync_fout` | Zabun: "velden nee op spotto" |
| Foto probleem ("foto") | `spotto_foto` | Omnicasa: foto-sync INFINIMMO |
| Bezoekaanvraag ("nieuwe bezoekaanvraag") | `spotto_bezoekaanvraag_auto` | Whise: doorgestuurde bezoekaanvraag |
| Systeem notificatie ("je hebt een vraag gesteld") | `spotto_vraag_auto` | Whise: doorgestuurde vraag |
| Publicatie probleem ("geen aanbod", "niet op spotto", "niet zichtbaar", "publicatie"¹) | `spotto_publicatie` | Zabun: "Geen aanbod op Spotto" |
| Verwijderen ("verwijderen", "offline halen", "mag niet meer gepubliceerd", "beëindigen") | `spotto_verwijderen` | Omnicasa: "Pand mag niet meer gepubliceerd" |
| Makelaar profiel ("makelaarspagina", "kantoorprofiel", "meerdere kantoren") | `spotto_makelaar_profiel` | Omnicasa: multi-kantoor configuratie |
| Factuur ("factuur", "facturatie") | `spotto_factuur_manueel` | Partner factuurvraag |
| Mail probleem ("ticketsystemen botsen") | `spotto_mail_probleem` | Omnicasa: "onze ticketsystemen botsen" |

¹ "publicatie kanaal" wordt uitgesloten — dat is een activatieverzoek, geen publicatieprobleem.

**Noot:** Aanhalingstekens worden gestript bij sync-matching zodat "als 'verkocht'" ook "als verkocht" matcht.

Als geen functionele match gevonden wordt, valt het ticket terug op de generieke partner tag (activatie, migratie, deactivatie, etc.).

---

## Tag Definities

### Partner Tags

| Tag | Herkenningsregel |
|---|---|
| `spotto_partner_whise` | Afzender `*@whise.eu` OF onderwerp bevat "Whise" — na functionele override check |
| `spotto_partner_zabun` | Afzender `*@zabun.be` OF onderwerp bevat "Zabun" — na functionele override check |
| `spotto_partner_omnicasa` | Afzender `*@omnicasa.com` OF onderwerp bevat ticketref `{xxxxxx}` — na functionele override check |
| `spotto_partner_skarabee` | Afzender `*@skarabee.com` OF onderwerp bevat "Skarabee" — na functionele override check |
| `spotto_partner_apimo` | Afzender `*@apimo.com` OF onderwerp bevat "Apimo" |
| `spotto_partner_sweepbright` | Afzender `*@sweepbright.com` of `hello@sweepbright.com` OF onderwerp bevat "Sweepbright" |
| `spotto_partner_api` | Onderwerp bevat "API" maar matcht geen specifieke partner hierboven |

### Geautomatiseerde Tags

| Tag | Herkenningsregel |
|---|---|
| `spotto_activatie_cib_auto` | Afzender is `jill.kloeck@cib.be` of `noreply@orisnv.be` — geautomatiseerde batch notificaties over nieuwe CIB leden |
| `spotto_factuur_auto` | Afzender is `noreply@spotto.be` EN onderwerp bevat "factuur" — systeemgegenereerde factuurverzoeken |
| `spotto_vraag_auto` | Systeemgegenereerde notificaties: onderwerp bevat "Je hebt een vraag gesteld via spotto" |
| `spotto_bezoekaanvraag_auto` | Onderwerp bevat "Nieuwe bezoekaanvraag" — doorgestuurde geautomatiseerde Spotto bezoekaanvragen |

**Noot:** Overige `noreply@spotto.be` mails (marketing, notificaties) → `spotto_intern`

### Spam

| Tag | Herkenningsregel |
|---|---|
| `spotto_spam` | Ongevraagde commerciële berichten, marketing agencies ("Je website mist...", "Ik weet dat je het druk hebt"), samenwerking/affiliate pitches, afzender van marketing domeinen (`*@xms-marketing.com`), Linktree notificaties, Azure API management mails (`*@mail.windowsazure.com`), Google Docs notificaties (`*@docs.google.com`), Google Alerts ("Nieuwe resultaten gevonden"), ongewenste samenwerkingsverzoeken ("a new collaboration"), irrelevante vastgoed-mails ("buitenlands vastgoed", "real estate spain") |

### Intern

| Tag | Herkenningsregel |
|---|---|
| `spotto_intern` | Afzender is Spotto/Oris/CIB-VIVO medewerker (`*@spotto.be`, `*@orisnv.be`, `*@cib-vivo.be`, `support@orisnv.freshdesk.com`). Vaste interne medewerkers: `bart.pinnock@`, `jantien.vanderbeke@`, `bart.van.der.schueren@`, `ilse.himschoot@`, `communicatie@`. Keywords: "toegang", "shared mailbox", "admin", "test", "widget", "bug", "lopende abonnementen". Ook: overige `noreply@spotto.be` mails |

### CIB / Lidmaatschap

| Tag | Herkenningsregel |
|---|---|
| `spotto_activatie_cib_manueel` | Afzender is CIB medewerker (`elke.uyttenhove@`, `simon.lehaen@`, `sven.de.vuyst@`, `annelien.lambrechts@`, `filipa.de.bastos@`, `michel.engelbosch@`, `mikail.sogut@`, `melissa.vriendt@`, `tine.terryn@` — allen `@cib.be`). Ook: `info@cib.be`, antwoorden op CIB uitnodigingen ("uitnodiging voor spotto"), VLAIO/Bizlocator migratie, POM West-Vlaanderen, "Nieuw CIB-lidmaatschap" (van nieuwe leden zelf), "welkom cib" |
| `spotto_lidmaatschap` | Over CIB lidmaatschap zelf: "wanbetalers", "wanbetaler", "factuur cib", "opzeg lidmaatschap", "stopzetting lidmaatschap", "ex-lid", "cib lidmaatschap", "cib-lidmaatschap", van `ledenservice@cib.be`. **Niet** activatie van nieuwe leden |

### Content / Profiel Wijzigingen

| Tag | Herkenningsregel |
|---|---|
| `spotto_logo` | Onderwerp bevat "logo": "aanpassing logo", "wijziging logo", "nieuw logo", "vervanging logo" |
| `spotto_foto` | Onderwerp bevat "foto" of "afbeelding": fotoweergave problemen, foto verwijderverzoeken, fotovolgorde, upload afbeeldingen |
| `spotto_privacy` | Onderwerp bevat "privacy", "privé-gegevens", "recht om vergeten te worden", "GDPR", "adres verbergen", "informations personnelles", "retirer informations" |
| `spotto_data_wijziging` | Onderwerp bevat "adreswijziging", "adres wijziging", "openingsuren", "emailadres", "e-mailadres", "contactgegevens", "bedrijfsgegevens", "aanpassing mail", "aanpassen gegevens", "wijziging e-mail", "mailadres", "telefoonnummer", "verkeerde contactpersoon", "verkeerd e-mail", "verkeerde gegevens", "changement adresse", "contactpersoon" |
| `spotto_makelaar_profiel` | Onderwerp bevat "kantoorprofiel", "makelaarspagina", "aanbiedersprofiel", "aanpassing team", "teamlid", "verandering kantoor", "meerdere kantoren" |

### Publicatie & Panden

| Tag | Herkenningsregel |
|---|---|
| `spotto_sync_fout` | Data mismatch: "foute synchronisatie", "synchronisatie", "verkocht maar", "als verkocht", "niet als verhuurd", "velden niet correct", "foutieve informatie", "mix up panden", "panden pending", "foutieve panden", "foutieve vermelding", "foutive info", "verkeerde info", "aanbod klopt niet", "kloppen niet", "panden blijven zichtbaar" |
| `spotto_publicatie` | "publicatie"¹, "publiceren", "publiciteit", "pand plaatsen", "panden niet op spotto", "geen aanbod", "niet zichtbaar", "niet online op spotto", "niet gepubliceerd", "niet on line", "niet on-line", "verschijnen niet", "panden niet actief", "gearchiveerde panden", "komen niet online", "geen informatie zichtbaar" |
| `spotto_pand_specifiek` | Specifiek adres/pand: straatnamen, "pand offline halen", "verwijderen appartement [adres]", pandnummers, prijswijzigingen, postcode-patronen |
| `spotto_verwijderen` | "verwijderen", "offline halen", "weghalen", "verwijdering", "uittreden", "dient offline", "offline panden", "oude panden", "mag niet meer gepubliceerd" |

¹ Exclusief "publicatie kanaal" — dat is een partner activatieverzoek.

### Technisch & Platform

| Tag | Herkenningsregel |
|---|---|
| `spotto_technisch` | Platform bugs: "site werkt", "foutmelding", "reistijdzoeker", "scrollen", "tijdzoneprobleem", "betaalscherm", "digitaal tekenen faalt", "fouten op de site", "taalfout", "doorgeklikt worden" |
| `spotto_website` | Over de spotto.be website zelf: "website", "contactnummer website" |
| `spotto_mail_probleem` | E-mail bezorgproblemen: "mails komen niet door", "uitschrijven lukt niet", "ticketsystemen botsen" |

### Consumenten

| Tag | Herkenningsregel |
|---|---|
| `spotto_particulier` | Van consument email (gmail, hotmail, telenet, skynet, icloud, outlook, live.nl, hot.com, yahoo, proximus, etc.) met consument-type onderwerp: "huis te koop", "te huur", "appartement", "woning", "huren", "garage", "bezoek", "bezichting", "huisbezichting", "inquiry about/for", "magazijn" |
| `spotto_commercieel` | Onderwerp bevat "bedrijfsvastgoed", "commercieel", "pop up", "industriegrond", "commerciële ruimte", "kantoorruimte", "retail vastgoed", "vrachtwagenparkeren" |
| `spotto_advertentie` | Over het plaatsen/betalen van een advertentie: "kostprijs advertentie", "adverteren", "zoekertje plaatsen", "informatie adverteren", "advertentiekost" — van niet-makelaars |

### Onboarding & Account

| Tag | Herkenningsregel |
|---|---|
| `spotto_account` | Onderwerp bevat "account", "aanmelden", "inlogprobleem", "registratie", "login", "inloggen", "uitschrijven", "afmelden", "profiel wissen", "wachtwoord" |
| `spotto_activatie_klant` | Directe klantactivatie-verzoeken (niet via CIB of partner): "activatie [kantoornaam]", "Toegang Spotto", "Eerste pand plaatsen", "aanvraag samenwerking" |
| `spotto_klant_bevestiging` | Post-activatie bevestiging: "confirmatie", "bevestiging", "welkomstmail" |

### Support

| Tag | Herkenningsregel |
|---|---|
| `spotto_factuur_manueel` | Onderwerp bevat "factuur", "facturatie", "betalen", "betaling" maar **niet** van `noreply@spotto.be` |
| `spotto_bezoekaanvraag_manueel` | Over leads/bezoekaanvragen met handmatige afhandeling: "leads", "doorgeven leads", "aanvraagformulieren", "bezoekaanvragen", "behandeling lead" |
| `spotto_vraag` | Generieke vragen van professionals die niet in andere categorieën passen: "vraag", "info", "vragen" |
| `spotto_verbetering` | Feature requests/suggesties: "favoriete panden", "aantal views", "EPC labels", "URL's weergeven", "referentie beheer", "statistieken", "inzichten zoekertjes", "mogelijkheden ranking" |

### Overig

| Tag | Herkenningsregel |
|---|---|
| `spotto_spam` | Zie hierboven |
| `spotto_ongetagd` | Standaard fallback — tickets die geen enkele regel matchen |

---

## Voorbeelden per Tag

| Tag | Voorbeeldtickets |
|---|---|
| `spotto_partner_whise` | "WHISE - Publication of estates on Spotto" (activatie, blijft partner tag) |
| `spotto_partner_zabun` | "Nieuwe Spotto koppeling / Schraepen Vastgoed", "Switch Max-Immo > Zabun" |
| `spotto_partner_omnicasa` | "{254815} Dag Arnout...", "activatie nieuwe klant Pillar Estate" |
| `spotto_partner_skarabee` | "Skarabee activatie - Spotto" |
| `spotto_activatie_cib_auto` | "Nieuw lidmaatschap" (van jill.kloeck) |
| `spotto_factuur_auto` | "Vraag om factuur Spotto" (van noreply@spotto.be) |
| `spotto_sync_fout` | "Foute synchronisatie bij veld 'zolder'" (van Whise → override), "velden nee op spotto" (van Zabun → override) |
| `spotto_publicatie` | "Geen aanbod op Spotto / Gabit" (van Zabun → override), "Publicatie Fluo Immo Spotto" |
| `spotto_foto` | "Foto's aanpassen", foto-sync issue INFINIMMO (van Omnicasa → override) |
| `spotto_verwijderen` | "Pand mag niet meer gepubliceerd staan" (van Omnicasa → override) |
| `spotto_logo` | "Wijziging logo", "aanpassing logo", "Vervanging nieuw logo Topo-Immo" |
| `spotto_lidmaatschap` | "Opzeg lidmaatschap CIB 2024", "Wanbetaler Domus Immobiliën" |
| `spotto_klant_bevestiging` | "Welkomstmail Spotto" |
| `spotto_particulier` | "Huis te koop", "Te huur App", "appartement in de Vlamingenstraat" |
| `spotto_commercieel` | "Vraag rond bedrijfsvastgoed", "Te huur kantoorruimtes" |
| `spotto_technisch` | "Site werkt maar half", "Tijdzoneprobleem bij ingave openingsuren" |
| `spotto_spam` | "Je website mist een belangrijk detail...", "Ik weet dat je het druk hebt", "Your subscription to the Partner" |

---

## Resultaatsverdeling

### 2025 (n=844)

| Groep | Aantal | % |
|---|---|---|
| Partner | 247 | 29.3% |
| Automatisch | 130 | 15.4% |
| Publicatie | 107 | 12.7% |
| Consument | 85 | 10.1% |
| CIB | 71 | 8.4% |
| Content | 60 | 7.1% |
| Support | 49 | 5.8% |
| Onboarding | 45 | 5.3% |
| Technisch | 20 | 2.4% |
| Overig | 16 | 1.9% |
| Intern | 14 | 1.7% |

### 2024 (n=910)

| Groep | Aantal | % |
|---|---|---|
| Partner | 248 | 27.3% |
| CIB | 157 | 17.3% |
| Onboarding | 113 | 12.4% |
| Publicatie | 103 | 11.3% |
| Consument | 90 | 9.9% |
| Support | 72 | 7.9% |
| Content | 64 | 7.0% |
| Intern | 27 | 3.0% |
| Overig | 23 | 2.5% |
| Technisch | 13 | 1.4% |

**Noot:** 2024 heeft geen "Automatisch" groep omdat `noreply@spotto.be` factuurmails en `noreply@orisnv.be`-berichten in dat jaar niet voorkwamen in de export.
