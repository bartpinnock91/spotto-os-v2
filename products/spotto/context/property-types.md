# Property Types

## PropertyType (main)

Source: [PropertyType.cs](https://dev.azure.com/build-orisnv/_git/ImmoX?path=/server/src/RealEstateDataStore.Shared.Domain.Enums/Properties/PropertyType.cs)

| Value | Code                          | NL                              | Category    |
| ----- | ----------------------------- | ------------------------------- | ----------- |
| 0     | `Unknown`                     | Onbekend                        | -           |
| 1     | `House`                       | Woning                          | Residential |
| 2     | `Apartment`                   | Appartement                     | Residential |
| 3     | `Room`                        | Kamer                           | Residential |
| 4     | `Commercial`                  | Commercieel                     | Commercial  |
| 5     | `Garage`                      | Garage                          | Other       |
| 6     | `Land`                        | Grond                           | Land        |
| 7     | `Industrial`                  | Industrieel                     | Commercial  |
| 8     | `Other`                       | Andere                          | Other       |
| 9     | `Office`                      | Kantoor                         | Commercial  |
| 10    | `BusinessCenter`              | Business Center                 | Commercial  |
| 11    | `Catering`                    | Horeca                          | Commercial  |
| 12    | `CommercialLand`              | Commerciële grond               | Land        |
| 13    | `TradingPremises`             | Handelspand                     | Commercial  |
| 14    | `IndustrialWarehouseLogistics`| Industrieel magazijn/logistiek  | Commercial  |

### Categories

- **Residential**: House, Apartment, Room
- **Commercial**: Commercial, Industrial, Office, BusinessCenter, Catering, TradingPremises, IndustrialWarehouseLogistics
- **Land**: Land, CommercialLand
- **Other**: Garage, Other, Unknown

---

## PropertySubType

Source: [PropertySubType.cs](https://dev.azure.com/build-orisnv/_git/ImmoX?path=/server/src/RealEstateDataStore.Shared.Domain/Enums/Properties/PropertySubType.cs)

| Value | Code              | NL                  | Parent Type |
| ----- | ----------------- | ------------------- | ----------- |
| 0     | `Unknown`         | Onbekend            | -           |
| 1     | `Villa`           | Villa               | House       |
| 2     | `Bungalow`        | Bungalow            | House       |
| 3     | `Serviceflat`     | Serviceflat         | Apartment   |
| 4     | `Loft`            | Loft                | Apartment   |
| 5     | `TerracedHouse`   | Rijwoning           | House       |
| 6     | `SemiDetached`    | Halfopen bebouwing  | House       |
| 7     | `Chalet`          | Chalet              | House       |
| 8     | `CommercialSpace` | Commerciële ruimte  | Commercial  |
| 9     | `Garage`          | Garage              | Garage      |
| 10    | `ParkingSpot`     | Parkeerplaats       | Garage      |
| 11    | `Land`            | Grond               | Land        |
| 12    | `FarmHouse`       | Hoeve               | House       |
| 13    | `Warehouse`       | Magazijn            | Industrial  |
| 14    | `IndustrialTerrain`| Industrieterrein   | Industrial  |
| 15    | `HouseBoat`       | Woonboot            | House       |
| 16    | `ArchitectHouse`  | Architectenwoning   | House       |
| 17    | `Castle`          | Kasteel             | House       |
| 18    | `Building`        | Gebouw              | Other       |
| 19    | `Studio`          | Studio              | Apartment   |
| 20    | `Penthouse`       | Penthouse           | Apartment   |
| 21    | `VacationHome`    | Vakantiewoning      | House       |
| 22    | `Other`           | Andere              | Other       |
| 23    | `Office`          | Kantoor             | Office      |

---

## GeoData Mapping

Mapping between GeoData RealEstateType and Spotto types (used for market data integration):

| GeoData RealEstateType | Spotto PropertyType | Spotto PropertySubType |
| ---------------------- | ------------------- | ---------------------- |
| Appartment             | Apartment           | -                      |
| Studio                 | Apartment           | Studio                 |
| Room                   | Room                | -                      |
| StudentRoom            | Room                | -                      |
| Villa                  | House               | Villa                  |
| DetachedHouse          | House               | -                      |
| SemiDetachedHouse      | House               | SemiDetached           |
| RowHouse               | House               | TerracedHouse          |
| SecondaryResidence     | House               | VacationHome           |
| Horeca                 | Catering            | -                      |
| Office                 | Office              | Office                 |
| Shop                   | TradingPremises     | CommercialSpace        |
| Industrial             | Industrial          | -                      |
| Craft                  | Industrial          | Warehouse              |
| Garage                 | Garage              | Garage                 |
| ParkingSpace           | Garage              | ParkingSpot            |
| Other                  | Other               | Other                  |
| Unknown                | Unknown             | Unknown                |
