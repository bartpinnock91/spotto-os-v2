# Customer dubbels — opkuis-analyse (2026-05-27, v2)

Verfijnde analyse van `dbo.Customers` op de prod Spotto DB (`oris-prod-immox-sql`, 3.031 rijen).
Bron voor de meeting van 2026-05-05 met Yasmine, Bart VDS, Jelle, Laura, Jeroen.

## Enums bevestigd via Azure DevOps (ImmoX/server)

- **CustomerStatus**: `0=Unknown, 1=Pending, 2=Active, 3=Inactive, 4=Archived`
- **CustomerType**: `1=Person, 2=Organization, 3=Establishment, 4=Government, 99=Other`
- **Collation IC ID kolommen** sinds [migratie 2025-12-29](https://dev.azure.com/build-orisnv/ImmoX) → `SQL_Latin1_General_CP1_CI_AI`: case- én accent-insensitive (dus `1E834...` = `1e834...` op DB-niveau).
- `ImmoConnect_ParentOrganizationId` was vroeger `ImmoConnect_EstablishmentId` (rename in maart 2023). Semantiek: vestigingen verwijzen naar hun parent IC erkenning.

## Verfijnde dup-definitie

| Type | Definitie | Redenering |
|---|---|---|
| **Echte KBO-dubbel** | Zelfde KBO + zelfde Establishment-nummer (incl. beide NULL/leeg) | Vestigingen van één KBO horen verschillende establishmentnummers te hebben — die zijn legitiem en worden uitgesloten. |
| **Echte IC-erkenning-dubbel** | Zelfde IC `ImmoConnect_OrganizationId` (case-insensitive), exclusief placeholder `"1"` | De waarde `"1"` is een placeholder uit oude onboarding en zit op 29 customer rows van 25 verschillende KBOs — geen echte erkenning. |
| **Niet meer beschouwd** | IC PersonId dubbels | Bijna allemaal legitieme cases: zelfde IC-persoon is contact bij meerdere organisaties (bv. Bart Pinnock bij Stad Aalst én CIB OVL). |

## Samenvatting

| Soort | Aantal dup-groepen | Rijen betrokken | Groepen met ≥2 actieve (Status 1/2) |
|---|---:|---:|---:|
| **KBO + Establishment dubbels** | **275** | **641** | ~125 |
| **IC OrgId dubbels** (excl. `"1"`) | **155** | **352** | ~115 |
| Establishmentnr. dubbels (zelfde KBO) | 1 (Altro) | 3 | 1 |

> *Belangrijke nuance*: 274 van de 275 KBO+Est dup-groepen zijn rijen waar het EstablishmentNumber `(none)` is — dwz. **niet** ingevuld. Slechts één KBO (`0680782523` = Altro) heeft duplicates binnen een echt establishmentnummer. Conclusie: de huidige data heeft amper establishment-nummers ingevuld, dus de "vestigingen via establishmentnummer onderscheiden"-strategie levert in praktijk weinig verschil op.

## Edge cases en data-kwaliteit findings

### 1. Placeholder `ImmoConnect_OrganizationId = "1"` (zie `placeholder-ic-orgid-1.csv`)

29 customer rows hebben `"1"` als IC erkenning. Dit zijn vooral oude onboarding entries uit feb–jun 2023, 25 verschillende KBOs. Bijna allemaal 0 publications (5 hebben 1+, max 19 — Essentimmo, Status Archived). **Actie**: deze rijen zouden ofwel het echte IC ID moeten krijgen ofwel definitief gearchiveerd worden.

### 2. Geen cross-KBO establishment-collisions

Geen enkel establishmentnummer komt voor onder meerdere KBOs. Goed nieuws.

### 3. IC-erkenning gedeeld over meerdere KBOs (10 cases, totaal 49 rijen)

Behalve de "1" placeholder, zijn er 9 echte cases waar één IC OrgId gedeeld is over 2-4 verschillende KBOs:

| IC OrgId | # KBOs | Customers |
|---|---:|---|
| `0212cdda-...` | 3 | Topo-Immo bvba (Liedekerke, Lennik, Aalst, Geraardsbergen) |
| `9d13ba08-...` | 2 | Home Consult / Sterrebeek / Tervuren |
| `7bdc86cb-...` | 2 | domoXim (twee KBOs) |
| `c618f0a0-...` | 2 | Vastgoed Luk & Horemans (Oostende + Brugge) |
| `d1040916-...` | 2 | Unik Vastgoed / Decimmo |
| `e89f0f26-...` | 2 | Optimmo Zulte / Wakken |
| `f3f4a00b-...` | 2 | Quares / Quares Residential Agency |
| `1118a724-...` | 2 | Immo Tijl Aalst / Herdersem |
| `73036e54-...` | 2 | Arcasa / Immo Van Hauwaert |

→ Typisch: één moederfirma met meerdere kantoorprofielen / sub-vennootschappen onder dezelfde BIV-erkenning. Past in de "kantoorprofiel onder parent org" structuur (zie agenda). Niet noodzakelijk fout, maar onderzoekswaardig.

### 4. Actieve organisationele rijen zonder KBO

| CustomerType | Actief zonder KBO | Opmerking |
|---|---:|---|
| 2 Organization | 16 | **Echt issue** — bv. Fluo (197 pubs), Omnia Vastgoed (196 pubs), Lombaerts Vastgoed (6 pubs) |
| 3 Establishment | 8 | Vestiging zonder eigen KBO geregistreerd (mogelijk ok als parent KBO wel ingevuld is) |
| 4 Government | 107 | Verwacht — gemeentes/intercommunales hebben niet altijd een KBO in het systeem |

→ Fluo en Omnia Vastgoed zijn de grootste cases: actieve organisaties met >190 publicaties, maar zonder KBO. **Actie**: KBO laten aanvullen.

### 5. Inconsistent zichtbare casing in IC OrgIds (Altro case)

De Altro rijen hadden zichtbaar `1e834985-...` en `1E834985-...` als IC OrgId. Sinds de Dec 2025 collation-migratie wordt dit DB-side gelijk behandeld, maar de **opgeslagen waarden zijn nog steeds gemengd**. Geen functioneel probleem, wel een data-hygiëne ding.

### 6. Soms enkel `(none)` (NULL) EstablishmentNumber bij hoge dup-counts

KBO `0835168218` (Albert - Aalbeke): 11 rijen, allemaal zonder EstablishmentNumber maar 10 verschillende IC OrgIds. → Vermoedelijk meerdere vestigingen waarvan establishment-nrs nooit gesynchroniseerd zijn. Dit type case zou via IC OrgId opgesplitst kunnen worden tot 10 aparte "vestigingen" — maar zonder establishment-nummer kunnen we ze niet zeker linken aan echte vestigingen in KBO/IC.

## Files

| File | Inhoud |
|---|---|
| [kbo-establishment-duplicates.csv](kbo-establishment-duplicates.csv) | 641 rijen — alle customers in een KBO+Establishment dup-groep, met PubCount en OnlinePubCount. |
| [immoconnect-orgid-duplicates.csv](immoconnect-orgid-duplicates.csv) | 352 rijen — IC OrgId dubbels (excl. placeholder `"1"`), met PubCount. |
| [placeholder-ic-orgid-1.csv](placeholder-ic-orgid-1.csv) | 29 rijen — onbruikbare placeholder-erkenning, te corrigeren of archiveren. |
| [establishment-number-collisions.csv](establishment-number-collisions.csv) | 3 rijen — enige case (Altro) van echte EstablishmentNumber-dubbel binnen één KBO. |
| [convert.py](convert.py) | Script dat de CSV's hergenereert uit de MCP query results. |

## Kolommen (CSV's)

- `DupKey_KBO` / `DupKey_IcOrgId` — de gedeelde waarde
- `EstabKey` — `(none)` als establishment leeg/NULL is, anders het nummer
- `Id`, `Name`, `Email`, `CreatedDate`
- `Status` + `StatusLabel` (1=Pending, 2=Active, 3=Inactive, 4=Archived)
- `CustomerType` + `TypeLabel` (1=Person, 2=Organization, 3=Establishment, 4=Government, 99=Other)
- `OrganizationNumber`, `EstablishmentNumber`, `IcOrgId`, `IcParentId`
- `PubCount` — totaal aantal Publications gekoppeld aan deze Customer.Id
- `OnlinePubCount` — actieve (IsOnline=1) publications (alleen op KBO+Est CSV)

## Suggested cleanup approach

Per dup-groep, gebruik volgende prioriteit om te kiezen welke row te behouden:

1. **Hoogste `OnlinePubCount`** — die customer is operationeel actief
2. Bij gelijk → **hoogste `PubCount`** (incl. archived)
3. Bij gelijk → **meest recente `LastModified_On`** (niet in CSV, maar in DB)
4. Bij gelijk → **niet-Archived Status**
5. De andere rijen archiveren (Status=4), niet hard-deleten — Publications blijven gekoppeld.

## Aanbevelingen voor de meeting

1. **Definitieve aanpak placeholder `"1"`**: 29 rijen ofwel KBO/IC opvullen, ofwel archiveren. Niemand zou met `"1"` als erkenning mogen blijven werken.
2. **Establishment-nummer verplichten in WeGov-flow**: Bijna geen enkele vestiging in de DB heeft een echt establishmentnummer. Zonder die data kunnen we kantoorprofielen niet betrouwbaar deduplicaten van moedervennootschap. Bart & Jelle bekijken dit voor de "kantoorprofiel" feature.
3. **Bij ongeldig worden van IC-erkenning**: zoals in agenda → **alle** Customer rows met die IC OrgId archiveren, niet enkel de eerste.
4. **KBO-validatie verplichten bij nieuwe Organization (Type 2) onboarding**: 16 actieve Type-2 orgs hebben geen KBO. Voor Type 4 (gemeente) is dit ok.
5. **Manuele review nieuwe orgs**: bevestigen workflow — Bart & Support kijken nieuwe erkenningen na vóór activatie.
6. **IC PersonId dubbels skippen**: nagenoeg allemaal valide cross-org contact persons.

## Update-flow

Om de analyse opnieuw te draaien (bv. na cleanup):

1. MSSQL MCP gebruiken om dezelfde queries te herhalen (zie `convert.py` voor de gebruikte tool-result paden)
2. `python convert.py` om CSV's te regenereren
