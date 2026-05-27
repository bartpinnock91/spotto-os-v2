# LocusFocus feed — pand-niveau data-export voor externe sync

**Status:** Draft
**Jira Ticket:** <!-- Add after pushing to Jira -->
**Epic:** <!-- Link to parent epic if applicable -->

## User Story

Als **LocusFocus (dataconsument)**,
wil ik **een gestructureerde feed van commercieel vastgoed op pand-niveau met per-publicatie detail**,
zodat ik **onze Spotto-data kan synchroniseren en tonen in hun eigen interface zonder zelf adressen te geocoderen, publicaties te dedupliceren of prijsconflicten op te lossen**.

## Context

LocusFocus is een externe partner die commercieel vastgoed wil ontsluiten in hun eigen platform. Zij hebben behoefte aan een kant-en-klare feed waar ze zonder interne verwerking mee aan de slag kunnen. De meeste van onze ruwe data zit op **publicatie-niveau** (één rij per listing van een makelaar), terwijl LocusFocus in hun productaanzicht per **pand** (fysiek gebouw/adres) wil werken. Hetzelfde pand kan meerdere keren online staan: meerdere makelaars, units binnen hetzelfde gebouw, of oudere herpublicaties.

Deze feed lost dat op met een **opinionated pand-niveau samenvatting** én een **publicatie-array met volledige detail**. LocusFocus kan de defaults meteen gebruiken of eigen logica bouwen op de array.

## Scope

Alleen **commercieel vastgoed** (`PropertyType IN {Commercial, Industrial, Office, BusinessCenter, Catering, CommercialLand, TradingPremises, IndustrialWarehouseLogistics}`) en alleen **actieve publicaties** (`IsOnline = true`). Panden zonder actieve publicaties zijn niet aanwezig in de feed.

## Acceptance Criteria

- [ ] Databricks medallion-pipeline (bronze → silver → gold) transformeert `dbo.Publications` naar een pand-gegroepeerde feed
- [ ] `property_id` is deterministisch (hash over genormaliseerd adres) en stabiel tussen runs
- [ ] Feed bevat enkel panden met ≥1 actieve publicatie
- [ ] Pand-niveau velden worden `null` wanneer publicaties conflicterende waarden hebben (geen forced resolution)
- [ ] Publicatie-array bevat altijd volledige detail per individuele publicatie
- [ ] Enums worden verzonden als integers, met mapping-tabel in de API-documentatie
- [ ] Endpoint ondersteunt `?since=<ISO-timestamp>` voor incrementele sync
- [ ] Response schema valideert tegen een JSON Schema dat bij de documentatie hoort
- [ ] Postman collection met realistisch voorbeeld (happy path + conflict-case) zit in de repo
- [ ] LocusFocus ontvangt `spotto_url` waarmee zij diep kunnen deep-linken naar de specifieke publicatie

## Datamodel

### Silver — `silver.publications` (1 rij per publicatie)

```
publication_id            string   uniqueidentifier → lowercase UUID
property_id               string   SHA256 van address_key (zie onder)
customer_id               string
realtor_profile_id        string   FK naar silver.realtors
address_raw               string   onbewerkt zoals ontvangen
address_normalized        string   display: "Kerkstraat 12 bus 3, 8300 Knokke-Heist"
address_key               string   matching: "BE|31043|8300|kerkstraat|12|3"
country_code              string
municipality_code         string
postal_code               string
street_normalized         string   lowercase, diacritics strip, "str." → "straat"
house_number              string
box                       string
lat                       double
lng                       double
coordinates_verified      boolean
property_type             int      enum
property_subtype          int      enum
transaction_type          int      enum
price                     decimal
price_type                int      enum
surface_m2                decimal  Construction_SquareMeters
main_image_url            string
available_from            date
spotto_url                string   PublicationUrls_DutchUrl
is_online                 boolean
online_from               timestamp
online_to                 timestamp
source_last_modified_at   timestamp
```

### Silver — `silver.properties` (1 rij per pand)

```
property_id               string   PK, SHA256(address_key)
address_key               string   UNIQUE
address_canonical         string   display-versie
country_code              string
municipality_code         string
postal_code               string
street_normalized         string
house_number              string
box                       string
lat                       double   centroid van publicatie-coördinaten
lng                       double
first_seen_at             timestamp
last_seen_at              timestamp
```

### Silver — `silver.realtors` (1 rij per makelaar)

```
realtor_profile_id        string   FK RealtorProfiles.Id
customer_id               string   RealtorProfiles.CustomerId
name                      string   RealtorProfiles.Name
organization_number       string
logo_url                  string   placeholder (zie open questions)
```

### `property_id` derivatie

```python
address_key = "|".join([
    country_code.upper(),                # "BE"
    municipality_code or "",              # NIS-code
    postal_code,
    street_normalized,                    # lowercase, diacritics strip
    house_number,
    box or ""
])
property_id = sha256(address_key).hexdigest()
```

**Fallback bij onvolledig adres:** gebruik H3-cel (resolution 13, ±5m) van `lat/lng` als vervangende key met prefix `geo|`. Publicaties zonder adres én zonder coördinaten worden uit de feed geweerd.

### Gold — `gold.locusfocus_feed`

Eén rij per pand, publicatie-array als ingebedde struct-array. Dit is 1-op-1 de response body van het API-endpoint.

## Rollup-regels

Alleen actieve publicaties (`is_online = true`) tellen mee. Bij conflicten wordt het pand-niveau veld `null` — LocusFocus kan dan terugvallen op de array.

| Veld             | Regel                                                        | Bij conflict |
|------------------|--------------------------------------------------------------|--------------|
| `address`        | `silver.properties.address_canonical`                        | —            |
| `lat/lng`        | Centroid; `coordinates_verified=true` krijgt voorrang        | —            |
| `property_type`  | Modus over publicaties                                       | `null`       |
| `property_subtype` | Modus                                                       | `null`       |
| `transaction_type` | Modus                                                       | `null`       |
| `surface_m2`     | Mediaan over publicaties die waarde hebben                   | `null` als alle missing |
| `price`          | Minimum, mits uniforme `price_type`                          | `null` bij type-conflict |
| `price_type`     | Modus                                                        | `null`       |
| `photo_url`      | Foto van publicatie met hoogste `source_last_modified_at`    | —            |

**Motivatie van deze keuzes:**
- **Prijs op minimum**: pand-niveau is voor LocusFocus een "vanaf"-indicatie, niet de gemiddelde waarde. Minimum is ook bestand tegen outliers.
- **Oppervlakte mediaan**: robuuster tegen outliers dan gemiddelde. Sterk afwijkende oppervlaktes zijn een dataprobleem, niet een displayprobleem.
- **Foto laatste upload**: vaak de meest kwalitatieve/recente foto.
- **Conflict = null**: geen geforceerde defaults. De array blijft altijd de bron van waarheid voor details.

## Enum-referenties

```
PropertyType:
  0=Unknown  1=House  2=Apartment  3=Room  4=Commercial
  5=Garage   6=Land   7=Industrial 8=Other 9=Office
  10=BusinessCenter  11=Catering  12=CommercialLand
  13=TradingPremises 14=IndustrialWarehouseLogistics

PropertySubType:
  0=Unknown     1=Villa          2=Bungalow         3=Serviceflat
  4=Loft        5=TerracedHouse  6=SemiDetached     7=Chalet
  8=CommercialSpace  9=Garage    10=ParkingSpot     11=Land
  12=FarmHouse  13=Warehouse     14=IndustrialTerrain 15=HouseBoat
  16=ArchitectHouse  17=Castle   18=Building        19=Studio
  20=Penthouse  21=VacationHome  22=Other           23=Office

TransactionType:
  0=Unknown  1=Sale     2=Rent       3=Annuity
  4=RentSale 5=VacationHome 6=BusinessPurchase
  7=Popup    8=TakeOver 9=Leasehold

PriceType:
  0=Unknown  1=Fixed    2=From       3=Negotiable
  4=Range    5=PerSquareMeter

AvailabilityStatusType:
  0=Unknown  1=Available  2=Unavailable  3=UnderOption
```

Commerciële filter voor MVP: `PropertyType IN (4, 7, 9, 10, 11, 12, 13, 14)`.

## API-contract

### Endpoint

```
GET /api/locusfocus/properties
```

### Query parameters

| Parameter | Type | Required | Beschrijving |
|-----------|------|----------|--------------|
| `since` | ISO-8601 timestamp | optioneel | Enkel panden waar minstens één publicatie na dit tijdstip gewijzigd is |

> **Paginering:** nog niet afgesproken. Voor MVP voorstel om de volledige feed in één response te retourneren; paginering toevoegen als de dataset te groot wordt. Zie open questions.

### Authenticatie

API-key via `X-API-Key` header (aparte key per partner — LocusFocus krijgt een dedicated key).

### Response schema

```
{
  "feed_generated_at": string<ISO-8601>,
  "count": int,
  "properties": [
    {
      "property_id": string,
      "address": string,
      "lat": number,
      "lng": number,
      "property_type": int|null,
      "property_subtype": int|null,
      "transaction_type": int|null,
      "surface_m2": number|null,
      "price": number|null,
      "price_type": int|null,
      "photo_url": string,
      "publications": [
        {
          "publication_id": string,
          "agent_name": string,
          "agent_logo_url": string,
          "property_type": int,
          "property_subtype": int|null,
          "transaction_type": int,
          "price": number|null,
          "price_type": int|null,
          "surface_m2": number|null,
          "photo_url": string,
          "available_from": string<date>|null,
          "last_modified_at": string<ISO-8601>,
          "spotto_url": string
        }
      ]
    }
  ]
}
```

## Postman voorbeeld

**Request:**
```
GET https://api.spotto.be/api/locusfocus/properties?since=2026-04-14T00:00:00Z
X-API-Key: <locusfocus-api-key>
```

**Response (200 OK):**

Dit voorbeeld dekt opzettelijk veel scenario's voor de Postman mock server, zodat LocusFocus al hun rendering- en edge-case logica hiermee kan testen:

1. **Type-conflict** — zelfde pand, verschillende agents, verschillende `property_type` (Fabriekstraat 1) → pand `property_type=null`
2. **Clean single-publicatie huur** (Kerkstraat 12 bus 3) → alle pand-velden gevuld
3. **Prijs op `PerSquareMeter`** (Zuidpoort logistiek) → `price_type=5`
4. **Rent/Sale gecombineerd** (Meir 48) → `transaction_type=null`, array toont beide transactietypes
5. **Horeca met `available_from`** in de toekomst (Graslei 9)
6. **Popup / tijdelijk gebruik** (Nieuwstraat 77) → `transaction_type=7`
7. **Industriële site met meerdere identieke publicaties** (Havenlaan 200) → clean rollup, mediaan oppervlakte
8. **Kantoortoren met ontbrekende oppervlakte** in sommige publicaties → mediaan over enkel niet-null waarden
9. **`price_type` conflict** (Stationsstraat 14) → `price=null, price_type=null`
10. **Retail zonder coördinaten** (Grote Markt 3, verified=false) → lat/lng toch aanwezig via fallback

```json
{
  "feed_generated_at": "2026-04-15T08:00:00Z",
  "count": 10,
  "properties": [
    {
      "property_id": "a7f3e8b2c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0",
      "address": "Fabriekstraat 1, 2260 Westerlo",
      "lat": 51.09478528584294,
      "lng": 4.815117726802757,
      "property_type": null,
      "property_subtype": 0,
      "transaction_type": 1,
      "surface_m2": null,
      "price": 363630,
      "price_type": 0,
      "photo_url": "https://file.immo-connect.be/Document?token=...Lancksweerd-latest",
      "publications": [
        {
          "publication_id": "52eeda6c-899b-43ec-63fe-08dd7d29fb56",
          "agent_name": "DGI",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 7,
          "property_subtype": null,
          "transaction_type": 1,
          "price": 0,
          "price_type": 0,
          "surface_m2": null,
          "photo_url": "https://file.immo-connect.be/Document?token=...dgi",
          "available_from": null,
          "last_modified_at": "2025-08-07T19:32:28.114Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-koop/2260-westerlo/bedrijfsvastgoed-fabriekstraat-1/bNruUpuJ7ENj_gjdfSn7Vg"
        },
        {
          "publication_id": "288a1791-68fc-4bb5-ed38-08dd9707a8fc",
          "agent_name": "Lancksweerd Real Estate",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 0,
          "transaction_type": 1,
          "price": 428400,
          "price_type": 0,
          "surface_m2": null,
          "photo_url": "https://file.immo-connect.be/Document?token=...lancksweerd-1",
          "available_from": null,
          "last_modified_at": "2025-08-26T00:06:43.900Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-koop/2260-westerlo/commercieel-fabriekstraat-1/kReKKPxotUvtOAjdlweo_A"
        },
        {
          "publication_id": "abc09085-8fbb-461c-ed6e-08dd9707a8fc",
          "agent_name": "Lancksweerd Real Estate",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 0,
          "transaction_type": 1,
          "price": 363630,
          "price_type": 0,
          "surface_m2": null,
          "photo_url": "https://file.immo-connect.be/Document?token=...lancksweerd-2",
          "available_from": null,
          "last_modified_at": "2025-08-26T00:06:42.118Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-koop/2260-westerlo/commercieel-fabriekstraat-1/hZDAq7uPHEbtbgjdlweo_A"
        },
        {
          "publication_id": "276d8f84-74d8-4cfa-a820-08dd971082c8",
          "agent_name": "Lancksweerd Real Estate",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 0,
          "transaction_type": 1,
          "price": 1638980,
          "price_type": 0,
          "surface_m2": null,
          "photo_url": "https://file.immo-connect.be/Document?token=...lancksweerd-3",
          "available_from": null,
          "last_modified_at": "2025-08-26T00:06:40.628Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-koop/2260-westerlo/commercieel-fabriekstraat-1/hI9tJ9h0-kyoIAjdlxCCyA"
        },
        {
          "publication_id": "bc4b5f30-cbbc-47f0-29a5-08dd9713fc66",
          "agent_name": "Lancksweerd Real Estate",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 0,
          "transaction_type": 1,
          "price": 978740,
          "price_type": 0,
          "surface_m2": null,
          "photo_url": "https://file.immo-connect.be/Document?token=...lancksweerd-4",
          "available_from": null,
          "last_modified_at": "2025-08-26T00:06:43.572Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-koop/2260-westerlo/commercieel-fabriekstraat-1/MF9LvLzL8EcppQjdlxP8Zg"
        }
      ]
    },
    {
      "property_id": "b8e4f9c3d2e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1",
      "address": "Kerkstraat 12 bus 3, 8300 Knokke-Heist",
      "lat": 51.3456,
      "lng": 3.2891,
      "property_type": 9,
      "property_subtype": 23,
      "transaction_type": 2,
      "surface_m2": 145.5,
      "price": 2200,
      "price_type": 1,
      "photo_url": "https://file.immo-connect.be/Document?token=...office-knokke",
      "publications": [
        {
          "publication_id": "11111111-2222-3333-4444-555555555555",
          "agent_name": "Dewaele Vastgoed",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 9,
          "property_subtype": 23,
          "transaction_type": 2,
          "price": 2200,
          "price_type": 1,
          "surface_m2": 145.5,
          "photo_url": "https://file.immo-connect.be/Document?token=...office-knokke",
          "available_from": "2026-05-01",
          "last_modified_at": "2026-04-10T14:22:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/8300-knokke-heist/kantoor-kerkstraat-12/AbCdEfGhIjKlMnOp"
        }
      ]
    },
    {
      "property_id": "c9f5a0d4e3f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2",
      "address": "Zuidpoort 45, 9000 Gent",
      "lat": 51.0459,
      "lng": 3.7181,
      "property_type": 14,
      "property_subtype": 13,
      "transaction_type": 2,
      "surface_m2": 3200.0,
      "price": 85.50,
      "price_type": 5,
      "photo_url": "https://file.immo-connect.be/Document?token=...zuidpoort-warehouse",
      "publications": [
        {
          "publication_id": "22222222-aaaa-bbbb-cccc-dddddddddddd",
          "agent_name": "Cushman & Wakefield",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 14,
          "property_subtype": 13,
          "transaction_type": 2,
          "price": 85.50,
          "price_type": 5,
          "surface_m2": 3200.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...zuidpoort-warehouse",
          "available_from": "2026-06-01",
          "last_modified_at": "2026-04-12T09:15:33.210Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/9000-gent/industrieel-zuidpoort-45/ZpW45GentIndLog"
        }
      ]
    },
    {
      "property_id": "d0a6b1e5f4a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3",
      "address": "Meir 48, 2000 Antwerpen",
      "lat": 51.2180,
      "lng": 4.4065,
      "property_type": 4,
      "property_subtype": 8,
      "transaction_type": null,
      "surface_m2": 215.0,
      "price": 4500,
      "price_type": 1,
      "photo_url": "https://file.immo-connect.be/Document?token=...meir48-latest",
      "publications": [
        {
          "publication_id": "33333333-aaaa-bbbb-cccc-dddddddddddd",
          "agent_name": "JLL Belgium",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 8,
          "transaction_type": 1,
          "price": 895000,
          "price_type": 1,
          "surface_m2": 215.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...meir48-sale",
          "available_from": null,
          "last_modified_at": "2026-04-13T11:02:44.881Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-koop/2000-antwerpen/commercieel-meir-48/MeirSale48"
        },
        {
          "publication_id": "33333333-aaaa-bbbb-cccc-eeeeeeeeeeee",
          "agent_name": "JLL Belgium",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 8,
          "transaction_type": 2,
          "price": 4500,
          "price_type": 1,
          "surface_m2": 215.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...meir48-rent",
          "available_from": "2026-07-01",
          "last_modified_at": "2026-04-13T11:10:12.501Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/2000-antwerpen/commercieel-meir-48/MeirRent48"
        }
      ]
    },
    {
      "property_id": "e1b7c2f6a5b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4",
      "address": "Graslei 9, 9000 Gent",
      "lat": 51.0548,
      "lng": 3.7207,
      "property_type": 11,
      "property_subtype": 8,
      "transaction_type": 2,
      "surface_m2": 180.0,
      "price": 6500,
      "price_type": 2,
      "photo_url": "https://file.immo-connect.be/Document?token=...graslei-horeca",
      "publications": [
        {
          "publication_id": "44444444-aaaa-bbbb-cccc-dddddddddddd",
          "agent_name": "ERA Gent Centrum",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 11,
          "property_subtype": 8,
          "transaction_type": 2,
          "price": 6500,
          "price_type": 2,
          "surface_m2": 180.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...graslei-horeca",
          "available_from": "2026-09-15",
          "last_modified_at": "2026-04-08T16:45:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/9000-gent/horeca-graslei-9/GrasleiHoreca9"
        }
      ]
    },
    {
      "property_id": "f2c8d3a7b6c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5",
      "address": "Nieuwstraat 77, 1000 Brussel",
      "lat": 50.8545,
      "lng": 4.3541,
      "property_type": 4,
      "property_subtype": 8,
      "transaction_type": 7,
      "surface_m2": 65.0,
      "price": 3200,
      "price_type": 1,
      "photo_url": "https://file.immo-connect.be/Document?token=...nieuwstraat-popup",
      "publications": [
        {
          "publication_id": "55555555-aaaa-bbbb-cccc-dddddddddddd",
          "agent_name": "CBRE Brussels",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 8,
          "transaction_type": 7,
          "price": 3200,
          "price_type": 1,
          "surface_m2": 65.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...nieuwstraat-popup",
          "available_from": "2026-05-01",
          "last_modified_at": "2026-04-14T13:22:17.330Z",
          "spotto_url": "https://www.spotto.be/nl/p/popup/1000-brussel/commercieel-nieuwstraat-77/NieuwPop77"
        }
      ]
    },
    {
      "property_id": "a3d9e4b8c7d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6",
      "address": "Havenlaan 200, 2030 Antwerpen",
      "lat": 51.2650,
      "lng": 4.3580,
      "property_type": 14,
      "property_subtype": 13,
      "transaction_type": 1,
      "surface_m2": 8500.0,
      "price": 6250000,
      "price_type": 1,
      "photo_url": "https://file.immo-connect.be/Document?token=...havenlaan-unit-c",
      "publications": [
        {
          "publication_id": "66666666-aaaa-bbbb-cccc-111111111111",
          "agent_name": "Savills Belgium",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 14,
          "property_subtype": 13,
          "transaction_type": 1,
          "price": 6250000,
          "price_type": 1,
          "surface_m2": 8200.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...havenlaan-unit-a",
          "available_from": "2026-06-01",
          "last_modified_at": "2026-04-01T08:00:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-koop/2030-antwerpen/industrieel-havenlaan-200/HavenA200"
        },
        {
          "publication_id": "66666666-aaaa-bbbb-cccc-222222222222",
          "agent_name": "Savills Belgium",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 14,
          "property_subtype": 13,
          "transaction_type": 1,
          "price": 6500000,
          "price_type": 1,
          "surface_m2": 8500.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...havenlaan-unit-b",
          "available_from": "2026-06-01",
          "last_modified_at": "2026-04-05T10:30:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-koop/2030-antwerpen/industrieel-havenlaan-200/HavenB200"
        },
        {
          "publication_id": "66666666-aaaa-bbbb-cccc-333333333333",
          "agent_name": "Savills Belgium",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 14,
          "property_subtype": 13,
          "transaction_type": 1,
          "price": 6750000,
          "price_type": 1,
          "surface_m2": 8800.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...havenlaan-unit-c",
          "available_from": "2026-06-01",
          "last_modified_at": "2026-04-11T09:45:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-koop/2030-antwerpen/industrieel-havenlaan-200/HavenC200"
        }
      ]
    },
    {
      "property_id": "b4e0f5c9d8e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7",
      "address": "Boulevard de Waterloo 30, 1000 Brussel",
      "lat": 50.8397,
      "lng": 4.3577,
      "property_type": 9,
      "property_subtype": 23,
      "transaction_type": 2,
      "surface_m2": 420.0,
      "price": 9500,
      "price_type": 1,
      "photo_url": "https://file.immo-connect.be/Document?token=...waterloo30-recent",
      "publications": [
        {
          "publication_id": "77777777-aaaa-bbbb-cccc-111111111111",
          "agent_name": "Colliers International",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 9,
          "property_subtype": 23,
          "transaction_type": 2,
          "price": 9500,
          "price_type": 1,
          "surface_m2": 420.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...waterloo30-recent",
          "available_from": null,
          "last_modified_at": "2026-04-14T07:20:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/1000-brussel/kantoor-waterloo-30/Water30Floor4"
        },
        {
          "publication_id": "77777777-aaaa-bbbb-cccc-222222222222",
          "agent_name": "Colliers International",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 9,
          "property_subtype": 23,
          "transaction_type": 2,
          "price": 11200,
          "price_type": 1,
          "surface_m2": null,
          "photo_url": "https://file.immo-connect.be/Document?token=...waterloo30-floor7",
          "available_from": "2026-05-15",
          "last_modified_at": "2026-04-09T14:12:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/1000-brussel/kantoor-waterloo-30/Water30Floor7"
        },
        {
          "publication_id": "77777777-aaaa-bbbb-cccc-333333333333",
          "agent_name": "Colliers International",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 9,
          "property_subtype": 23,
          "transaction_type": 2,
          "price": 12800,
          "price_type": 1,
          "surface_m2": null,
          "photo_url": "https://file.immo-connect.be/Document?token=...waterloo30-floor9",
          "available_from": "2026-08-01",
          "last_modified_at": "2026-04-03T10:05:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/1000-brussel/kantoor-waterloo-30/Water30Floor9"
        }
      ]
    },
    {
      "property_id": "c5f1a6d0e9f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8",
      "address": "Stationsstraat 14, 8500 Kortrijk",
      "lat": 50.8269,
      "lng": 3.2646,
      "property_type": 4,
      "property_subtype": 8,
      "transaction_type": 2,
      "surface_m2": 95.0,
      "price": null,
      "price_type": null,
      "photo_url": "https://file.immo-connect.be/Document?token=...kortrijk-station-14",
      "publications": [
        {
          "publication_id": "88888888-aaaa-bbbb-cccc-111111111111",
          "agent_name": "Immo Dewaele Kortrijk",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 8,
          "transaction_type": 2,
          "price": 2400,
          "price_type": 1,
          "surface_m2": 95.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...kortrijk-station-14",
          "available_from": "2026-05-01",
          "last_modified_at": "2026-04-12T09:00:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/8500-kortrijk/commercieel-stationsstraat-14/KortrijkStation14A"
        },
        {
          "publication_id": "88888888-aaaa-bbbb-cccc-222222222222",
          "agent_name": "Heylen Vastgoed",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 8,
          "transaction_type": 2,
          "price": 28.50,
          "price_type": 5,
          "surface_m2": 95.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...kortrijk-station-14-heylen",
          "available_from": "2026-05-01",
          "last_modified_at": "2026-04-10T15:30:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/8500-kortrijk/commercieel-stationsstraat-14/KortrijkStation14B"
        }
      ]
    },
    {
      "property_id": "d6a2b7e1f0a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9",
      "address": "Grote Markt 3, 3000 Leuven",
      "lat": 50.8798,
      "lng": 4.7005,
      "property_type": 4,
      "property_subtype": 8,
      "transaction_type": 2,
      "surface_m2": 140.0,
      "price": 5800,
      "price_type": 1,
      "photo_url": "https://file.immo-connect.be/Document?token=...leuven-markt-3",
      "publications": [
        {
          "publication_id": "99999999-aaaa-bbbb-cccc-111111111111",
          "agent_name": "Heeren Vastgoed Leuven",
          "agent_logo_url": "https://cdn.spotto.be/placeholder/agent-logo.png",
          "property_type": 4,
          "property_subtype": 8,
          "transaction_type": 2,
          "price": 5800,
          "price_type": 1,
          "surface_m2": 140.0,
          "photo_url": "https://file.immo-connect.be/Document?token=...leuven-markt-3",
          "available_from": null,
          "last_modified_at": "2026-04-11T12:00:00.000Z",
          "spotto_url": "https://www.spotto.be/nl/p/te-huur/3000-leuven/commercieel-grote-markt-3/LeuvenGM3"
        }
      ]
    }
  ]
}
```

## Technical Notes

- **Pipeline**: Databricks medallion — bronze (raw mirror), silver (normalized + property-grouped), gold (feed-shape). Delta Live Tables aanbevolen voor incremental refresh.
- **Refresh-interval**: nightly voldoet voor MVP; `since` parameter maakt near-realtime sync op partnerzijde mogelijk tussen pipeline-runs.
- **Adresnormalisatie**: bestaande street-cleanup logic hergebruiken indien aanwezig, anders basisregels (lowercase, diacritics, "str." → "straat", "laan" behouden, etc.).
- **Coordinates-handling**: `geometry` kolom in SQL heeft `STY` (latitude) en `STX` (longitude) methods — beide extraheren in silver.
- **Immo-Connect URLs**: niet rewriten naar eigen CDN. Tokens zijn tijdelijk geldig; LocusFocus verantwoordelijk voor recente sync als URLs verlopen.
- **Logo's**: placeholder `https://cdn.spotto.be/placeholder/agent-logo.png` tot we logo-hosting per makelaar hebben (aparte story — zie open questions).
- **Rate limiting**: endpoint buiten publieke API; dedicated partner-key met hogere limits (bv. 60 req/min).
- **Observability**: log per request de `count` en `since`-waarde; alert als `count = 0` onverwacht.

## Open Questions

1. **Agent logo hosting** — logo-URLs zitten vermoedelijk in een ander systeem (CRM?). Vervolgstory nodig om deze te ontsluiten en op `RealtorProfiles.LogoUrl` te persistenteren.
2. **Conflict-resolution voor `transaction_type`** — indien zelfde pand zowel `Sale` als `Rent` publicaties heeft, is pand-niveau nu `null`. Alternatief: splitsen in twee `property_id`-rijen met suffix. Beslissing nodig vóór GA.
3. **Historisch inzicht** — wil LocusFocus ook zicht op *recent uitgegane* publicaties, of strikt enkel actief? MVP: enkel actief.
4. **Pagination**: cursor-based of offset-based? Cursor is safer bij grote datasets met actieve updates.
5. **Contract-versioning** — `Accept: application/vnd.spotto.locusfocus.v1+json` of URL-prefix `/v1/`?

## Out of Scope

- Webhook-push naar LocusFocus (enkel pull voor MVP)
- Residentieel vastgoed (alleen commercieel)
- Hosten/uploaden van makelaarslogo's (aparte story)
- Rewriting van Immo-Connect fotolinks naar Spotto CDN
- Two-way sync (LocusFocus → Spotto)
- Publieke documentatie / developer portal — LocusFocus krijgt Postman collection + JSON Schema direct
