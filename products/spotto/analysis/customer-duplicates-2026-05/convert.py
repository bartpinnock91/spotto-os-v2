"""Convert MSSQL JSON tool-result files to CSVs for the customer-duplicates cleanup.

Refined version after enum confirmation:
- CustomerStatus: 0=Unknown 1=Pending 2=Active 3=Inactive 4=Archived
- CustomerType: 1=Person 2=Organization 3=Establishment 4=Government 99=Other
- KBO dups grouped by (KBO + EstablishmentNumber) so legit vestigingen are excluded.
- IC OrgId dups exclude placeholder value "1" (29 rows from onboarding test data).
- Person ID dups skipped (mostly legit cross-org contact persons, not real dups).
"""
import csv
import json
from pathlib import Path

OUT = Path(__file__).parent
TOOL_RESULTS = Path(r"C:\Users\Bart\.claude\projects\d--Werk-Repos-spotto-os\8ef3db51-e272-4ddb-abd5-49585ffd3b6d\tool-results")

SOURCES = [
    ("kbo-establishment-duplicates.csv", TOOL_RESULTS / "mcp-mssql-read_data-1779868848320.txt"),
    ("immoconnect-orgid-duplicates.csv", TOOL_RESULTS / "mcp-mssql-read_data-1779868858069.txt"),
]

STATUS_LABEL = {0: "Unknown(0)", 1: "Pending(1)", 2: "Active(2)", 3: "Inactive(3)", 4: "Archived(4)"}
TYPE_LABEL = {1: "Person(1)", 2: "Organization(2)", 3: "Establishment(3)", 4: "Government(4)", 99: "Other(99)"}

def write_csv(name, rows):
    if not rows:
        return
    headers = list(rows[0].keys())
    with (OUT / name).open("w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f)
        w.writerow(headers + ["StatusLabel", "TypeLabel"])
        for r in rows:
            r2 = [r.get(h, "") for h in headers]
            r2.append(STATUS_LABEL.get(r.get("Status"), str(r.get("Status"))))
            r2.append(TYPE_LABEL.get(r.get("CustomerType"), str(r.get("CustomerType"))))
            w.writerow(r2)

for fname, path in SOURCES:
    data = json.loads(path.read_text(encoding="utf-8"))
    write_csv(fname, data["data"])
    print(f"Wrote {fname}: {len(data['data'])} rows")

# Placeholder IC OrgId = "1" (29 onboarding rows, 25 KBOs — bogus data)
placeholder_ic_one = [{"Id":"312DB7C9-5C90-4039-8D9D-AFA3008528F9","Name":"Axius","Status":2,"CustomerType":2,"OrganizationNumber":"0862695432","EstablishmentNumber":"","Email":"ac@axius.be","CreatedDate":"2023-02-08","PubCount":0},{"Id":"01CE5F97-4DF2-4DF2-A70A-B14F0091F3EF","Name":"Bastijns Projects","Status":4,"CustomerType":2,"OrganizationNumber":"0884282484","EstablishmentNumber":"","Email":"kris.bastijns@telenet.be","CreatedDate":"2024-04-11","PubCount":0},{"Id":"C20C9124-FFC5-49E8-BB18-AFA200F71CE3","Name":"Beheergebouwen.be","Status":2,"CustomerType":2,"OrganizationNumber":"0863600403","EstablishmentNumber":"","Email":"willem@beheergebouwen.be","CreatedDate":"2023-02-07","PubCount":0},{"Id":"C87792DE-3695-4D84-AD79-B0FA00ADDE2A","Name":"Blokbeheer","Status":2,"CustomerType":2,"OrganizationNumber":"0715421718","EstablishmentNumber":"","Email":"els@blokbeheer.be","CreatedDate":"2024-01-17","PubCount":0},{"Id":"F5E7576C-B8EE-48E3-BE35-B126007F2DE5","Name":"Cereal","Status":4,"CustomerType":2,"OrganizationNumber":"0708983193","EstablishmentNumber":None,"Email":"d@g","CreatedDate":"2024-03-01","PubCount":0},{"Id":"FC0670B0-A401-4D42-928A-AFA200F42FA1","Name":"Cobelpro","Status":2,"CustomerType":2,"OrganizationNumber":"0891227783","EstablishmentNumber":"","Email":"g.naeyaert@cobelpro.eu","CreatedDate":"2023-02-07","PubCount":0},{"Id":"9CB9F8A5-DA50-498A-B36F-AFA3008DA7F9","Name":"Diggit StudentLife","Status":2,"CustomerType":2,"OrganizationNumber":"0708983193","EstablishmentNumber":"","Email":"arne@diggitstudentlife.eu","CreatedDate":"2023-02-08","PubCount":0},{"Id":"8E16CB6D-4C6F-46D0-AF43-B019009AB1ED","Name":"Essentimmo","Status":4,"CustomerType":2,"OrganizationNumber":"0878853553","EstablishmentNumber":None,"Email":"d@g","CreatedDate":"2023-06-06","PubCount":19},{"Id":"594041C6-C60C-4AA5-8D6F-AFA200AD8929","Name":"Hertsens Beheer","Status":2,"CustomerType":2,"OrganizationNumber":"0627895450","EstablishmentNumber":"","Email":"caroline@hertsens.eu","CreatedDate":"2023-02-07","PubCount":0},{"Id":"014CAA73-CD46-414F-9F3A-B01800A0C86C","Name":"Hertsens Beheer BVBA","Status":4,"CustomerType":2,"OrganizationNumber":"0627895450","EstablishmentNumber":None,"Email":"d@g","CreatedDate":"2023-06-05","PubCount":0},{"Id":"133533AE-FA7C-407E-B620-AFA200EE370C","Name":"Huyskens Vastgoed","Status":2,"CustomerType":2,"OrganizationNumber":"0785485709","EstablishmentNumber":"","Email":"astrid@huyskensvastgoed.be","CreatedDate":"2023-02-07","PubCount":0},{"Id":"88DEF998-6277-46E6-9EEA-AFA200A57B9C","Name":"Immo Atelier","Status":3,"CustomerType":2,"OrganizationNumber":"0870624686","EstablishmentNumber":"","Email":"els@immo-atelier.be","CreatedDate":"2023-02-07","PubCount":1},{"Id":"76A7D2F1-5258-467D-A9D1-AFA300A40FC4","Name":"Immo C","Status":2,"CustomerType":2,"OrganizationNumber":"0764531135","EstablishmentNumber":"","Email":"christophe.nouwen@immo-c.be","CreatedDate":"2023-02-08","PubCount":0},{"Id":"FF2688A2-8B90-4CB3-AE29-AFA200EF025D","Name":"Immo De Groot & Celen","Status":4,"CustomerType":2,"OrganizationNumber":"0762996159","EstablishmentNumber":"","Email":"marjan@degroot-celen.be","CreatedDate":"2023-02-07","PubCount":0},{"Id":"EECED6C1-FCF3-490E-B260-AFB300B1A8C0","Name":"Immo Hanssens","Status":4,"CustomerType":2,"OrganizationNumber":"0670698580","EstablishmentNumber":"","Email":"info@immohanssens.be","CreatedDate":"2023-02-24","PubCount":0},{"Id":"EED96DFE-F016-4DEC-B772-AFE200DE7FA4","Name":"IMMO PAULY","Status":4,"CustomerType":2,"OrganizationNumber":"0820888630","EstablishmentNumber":"","Email":"immopauly@skynet.be","CreatedDate":"2023-04-12","PubCount":0},{"Id":"B0A494D5-D0EC-4141-9677-AFE200E245B2","Name":"IMMO PAULY BV","Status":4,"CustomerType":2,"OrganizationNumber":"0820888630","EstablishmentNumber":None,"Email":"d@f","CreatedDate":"2023-04-12","PubCount":1},{"Id":"2C7FDA75-1F21-44E9-8635-AFA200B51A0E","Name":"J&E Holdings","Status":2,"CustomerType":2,"OrganizationNumber":"0643882733","EstablishmentNumber":"","Email":"evi@elementsprojects.be","CreatedDate":"2023-02-07","PubCount":0},{"Id":"258E8A84-AF02-44B5-8E00-AFA200A62456","Name":"Johan De Syndicus","Status":2,"CustomerType":2,"OrganizationNumber":"0752757414","EstablishmentNumber":"","Email":"johandesyndicus@gmail.com","CreatedDate":"2023-02-07","PubCount":0},{"Id":"46D8D74A-9D8B-4B12-BABE-AFA200F0AF16","Name":"Leon Reniers","Status":2,"CustomerType":2,"OrganizationNumber":"0509991158","EstablishmentNumber":"","Email":"leon.reniers.bvba@telenet.be","CreatedDate":"2023-02-07","PubCount":0},{"Id":"B1BB41EF-F303-400E-9FB8-AFAE00934E9A","Name":"Marnix Vastgoed","Status":4,"CustomerType":2,"OrganizationNumber":"0737586911","EstablishmentNumber":"","Email":"info@marnixvastgoed.be","CreatedDate":"2023-02-19","PubCount":0},{"Id":"A0A5BDC7-E15C-4044-B969-B16500C9D14A","Name":"Max Vastgoed","Status":2,"CustomerType":2,"OrganizationNumber":"0795731580","EstablishmentNumber":"","Email":"info@maxvastgoed.be","CreatedDate":"2024-05-03","PubCount":0},{"Id":"71F040A2-FF48-4DA7-8AC6-B03900CB8731","Name":"Michèle Van Damme bv","Status":4,"CustomerType":2,"OrganizationNumber":"0778846949","EstablishmentNumber":None,"Email":"d@g","CreatedDate":"2023-07-08","PubCount":1},{"Id":"EAFF368E-A1F7-4417-9593-AFA200CDB192","Name":"Michèle Van Damme Vastgoed & Advies","Status":4,"CustomerType":2,"OrganizationNumber":"0778846949","EstablishmentNumber":"","Email":"michele@vandamme.immo","CreatedDate":"2023-02-07","PubCount":0},{"Id":"678B05E6-1824-4B9C-802C-AFA30098A032","Name":"Philippe Puissant","Status":4,"CustomerType":2,"OrganizationNumber":"0759834652","EstablishmentNumber":"","Email":"ppuissant@gmail.com","CreatedDate":"2023-02-08","PubCount":0},{"Id":"25751E9F-385B-4F04-9522-AFA300844B8F","Name":"Syndic Beheer","Status":2,"CustomerType":2,"OrganizationNumber":"0864301771","EstablishmentNumber":"","Email":"lieven@syndic-beheer.com","CreatedDate":"2023-02-08","PubCount":0},{"Id":"7504FEDD-A818-4EBC-9E12-AFA200EFE5B5","Name":"V² Construct","Status":2,"CustomerType":2,"OrganizationNumber":"0765878049","EstablishmentNumber":"","Email":"info@v2construct.be","CreatedDate":"2023-02-07","PubCount":0},{"Id":"01C84343-6D87-4D45-8379-B00C0093624E","Name":"Vastgoed Spriet","Status":4,"CustomerType":2,"OrganizationNumber":"0503785237","EstablishmentNumber":"","Email":"info@vastgoedspriet.be","CreatedDate":"2023-05-24","PubCount":0},{"Id":"778A4F94-CA94-40FF-800E-AFA200EC0652","Name":"Yally","Status":2,"CustomerType":2,"OrganizationNumber":"0784379414","EstablishmentNumber":"","Email":"anneleen.desmyter@thinktogether.be","CreatedDate":"2023-02-07","PubCount":0}]

write_csv("placeholder-ic-orgid-1.csv", placeholder_ic_one)
print(f"Wrote placeholder-ic-orgid-1.csv: {len(placeholder_ic_one)} rows")

# Establishment dup (3 rows for Altro)
estab_data = [{"DupKey":"2313848589","Id":"CCC81568-4A11-48EE-84EE-AFEE00F3D5E5","Name":"Altro Vastgoed Heusden","Status":2,"CustomerType":2,"OrganizationNumber":"0680782523","IcOrgId":"62e1330f-26c0-4814-a8e6-2a2d50f13893","IcParentId":"","Email":"info@altro-vastgoed.be","CreatedDate":"2023-04-24"},{"DupKey":"2313848589","Id":"C03434EA-7B8B-4E5B-B3F2-AFF600C12586","Name":"Altro Invest","Status":2,"CustomerType":2,"OrganizationNumber":"0680782523","IcOrgId":"1e834985-2a04-4721-9f1d-dba848254770","IcParentId":"","Email":"info@altro-vastgoed.be","CreatedDate":"2023-05-02"},{"DupKey":"2313848589","Id":"41AF895D-8079-4706-BB18-AFF600C1BC5B","Name":"Altro Projects","Status":2,"CustomerType":2,"OrganizationNumber":"0680782523","IcOrgId":"1e834985-2a04-4721-9f1d-dba848254770","IcParentId":"","Email":"info@altro-vastgoed.be","CreatedDate":"2023-05-02"}]

write_csv("establishment-number-collisions.csv", estab_data)
print(f"Wrote establishment-number-collisions.csv: {len(estab_data)} rows")
