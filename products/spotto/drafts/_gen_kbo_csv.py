"""Generate customers-zonder-orgnummer CSV from DB query + research findings."""
import csv
from pathlib import Path


def fmt_kbo(n: str) -> str:
    """0475907338 -> 'BE 0475 907 338'."""
    if not n:
        return ""
    n = n.strip()
    if len(n) != 10 or not n.isdigit():
        return n
    return f"BE {n[0:4]} {n[4:7]} {n[7:10]}"


# All 69 customers, with researched KBO for the 22 active ones.
# Other rows: DB-derived candidates only, none researched.
rows = [
    # Active (22)
    {"Status": "Active", "Naam": "Activo", "KBO": "0475907338", "Confidence": "high",
     "Bron": "https://www.activo.be/nl/privacy + companyweb",
     "Telefoon": "", "Email": "info@activo.be", "Plaats": "Kuurne",
     "IcOrgId": "805d13ef-3352-48a4-948f-a7d1c1c64257", "ParentOrgId": "",
     "EstablishmentNumber": "0475907338", "HasActiveDuplicate": 1,
     "Notes": "Bevestigd: matcht ook EstablishmentNumber en active duplicate. Activo NV."},

    {"Status": "Active", "Naam": "Avantivastgoed", "KBO": "0765413538", "Confidence": "high",
     "Bron": "https://www.avantivastgoed.be",
     "Telefoon": "+32479010000", "Email": "info@avantivastgoed.be", "Plaats": "Lier",
     "IcOrgId": "bd16c2b0-4490-40fa-961d-e6538d519b51", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Footer: BTW-BE 0765.413.538 - RPR Mechelen."},

    {"Status": "Active", "Naam": "Dult Vastgoed", "KBO": "0780707765", "Confidence": "high",
     "Bron": "https://www.dultvastgoed.be/wettelijke-gegevens",
     "Telefoon": "+32493060085", "Email": "info@dultvastgoed.be", "Plaats": "Laarne",
     "IcOrgId": "d9e8fbc4-e1eb-43fa-bd57-9317f7586ca1", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": ""},

    {"Status": "Active", "Naam": "Eberhard Vastgoed", "KBO": "0434476460", "Confidence": "high",
     "Bron": "https://www.eberhardvastgoed.be",
     "Telefoon": "+3237796929", "Email": "contact@eberhardvastgoed.be", "Plaats": "Stekene",
     "IcOrgId": "d5a3697b-6d16-455d-9fdf-61a28b9f3787", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Footer: BTW BE0434 476 460."},

    {"Status": "Active", "Naam": "Fluo", "KBO": "0696995973", "Confidence": "high",
     "Bron": "https://www.companyweb.be/en/0696995973/fluo",
     "Telefoon": "+32494505123", "Email": "info@fluo.immo", "Plaats": "Roeselare",
     "IcOrgId": "5d77acd8-e1cc-4f8d-aec3-39ce90aa8fe0", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Fluo SRL, Armoedestraat 40/51 Roeselare. BIV 509163 staat ook op site (niet KBO)."},

    {"Status": "Active", "Naam": "FS-Vastgoed", "KBO": "0685679142", "Confidence": "high",
     "Bron": "https://fs-vastgoed.be/contact + companyweb",
     "Telefoon": "+32471246722", "Email": "info@fs-vastgoed.be", "Plaats": "Aalter",
     "IcOrgId": "25a86839-b259-4082-bbea-5c1eaeeab235", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Juridische entiteit: Fs-Admin BV, Urselseweg 117 Aalter."},

    {"Status": "Active", "Naam": "IMASBO", "KBO": "0459210767", "Confidence": "high",
     "Bron": "https://www.companyweb.be/en/0459210767/imasbo",
     "Telefoon": "059/30.15.13", "Email": "info@laplage", "Plaats": "Middelkerke",
     "IcOrgId": "249b4f55-5a15-40df-b57a-00a6c5a28c28", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "IMASBO BV trading as ERA La Plage. Email in DB lijkt corrupt (ontbreekt TLD)."},

    {"Status": "Active", "Naam": "Immo 36", "KBO": "1031928560", "Confidence": "high",
     "Bron": "https://www.immo36.be",
     "Telefoon": "+32493537971", "Email": "info@immo36.be", "Plaats": "Maasmechelen",
     "IcOrgId": "4933ccf3-80aa-4512-8ddf-4dfe4cf73634", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Nieuw KBO-formaat (start met 1)."},

    {"Status": "Active", "Naam": "Immo Heidi", "KBO": "", "Confidence": "none",
     "Bron": "https://www.biv.be/vastgoedmakelaars/heidi-van-tichelen-506549",
     "Telefoon": "+32494841792", "Email": "heidi@immoheidi.be", "Plaats": "Averbode",
     "IcOrgId": "28806b22-02f8-4523-99c3-605385fc5b89", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Heidi Van Tichelen: BIV 506549, mogelijk natuurlijk persoon of via ERA Tournier (Geel). Manuele KBO-zoekopdracht nodig."},

    {"Status": "Active", "Naam": "Immo Jamar", "KBO": "0800184672", "Confidence": "high",
     "Bron": "https://jamar.immo/algemene-voorwaarden/",
     "Telefoon": "+3234353133", "Email": "veronique@jamar.immo", "Plaats": "Antwerpen",
     "IcOrgId": "d619d6d0-7310-4341-99a6-1b42dabfb599", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Immo Jamar Antwerpen BV, Vleminckveld 72."},

    {"Status": "Active", "Naam": "Immo Novas", "KBO": "0697977257", "Confidence": "high",
     "Bron": "https://www.immonovas.be",
     "Telefoon": "+32477351844", "Email": "dirk@immonovas.be", "Plaats": "Lommel",
     "IcOrgId": "d379a88e-68f5-4919-865b-7543d0dc89ec", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Immobilien Dirk Van Ham bv. BIV 511415."},

    {"Status": "Active", "Naam": "Immo Nuvo", "KBO": "0751620534", "Confidence": "high",
     "Bron": "https://www.immonuvo.be/contact",
     "Telefoon": "", "Email": "info@immonuvo.be", "Plaats": "Aalst",
     "IcOrgId": "b2b500b4-0529-46dd-b066-19eb7b793855", "ParentOrgId": "",
     "EstablishmentNumber": "2305330011", "HasActiveDuplicate": 0,
     "Notes": "Juridische entiteit: HemFre BV, Slagmolenlaan 28, 1785 Merchtem. EstNr in DB is vestigingsnummer."},

    {"Status": "Active", "Naam": "Jantien Vanderbeke", "KBO": "", "Confidence": "none",
     "Bron": "https://www.linkedin.com/in/jantien-vanderbeke/",
     "Telefoon": "", "Email": "jantien.vanderbeke@cib-vivo.be", "Plaats": "Gent",
     "IcOrgId": "1231588e-49ba-4f2f-8f3d-27960614046e", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Email is CIB-VIVO domein (federatie). Waarschijnlijk geen aparte makelaar/KBO. Record review aanbevolen."},

    {"Status": "Active", "Naam": "Libeer Vastgoed", "KBO": "0772543830", "Confidence": "high",
     "Bron": "https://libeervastgoed.be + companyweb",
     "Telefoon": "+32477928199", "Email": "info@michaellibeer.be", "Plaats": "Gent",
     "IcOrgId": "5bb392d5-0d56-4c42-89e7-4fe73aaa47eb", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Libeer Michael BV, Ledeberg."},

    {"Status": "Active", "Naam": "Lombaerts Vastgoed BV", "KBO": "1029112095", "Confidence": "high",
     "Bron": "https://www.lombaertsvastgoed.be",
     "Telefoon": "+3234351022", "Email": "info@lombaertsvastgoed.be", "Plaats": "Schilde",
     "IcOrgId": "409135dd-81e8-460c-9531-885dbab4dac7", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Nieuw KBO-formaat. BIV 514886."},

    {"Status": "Active", "Naam": "Omnia Vastgoed", "KBO": "0683639568", "Confidence": "high",
     "Bron": "https://www.omniavastgoed.be",
     "Telefoon": "+3232849748", "Email": "info@omniavastgoed.be", "Plaats": "Mortsel",
     "IcOrgId": "3a30b095-3da7-4194-97e1-ae2f1abc2009", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Omnia Vastgoedmanagement bv."},

    {"Status": "Active", "Naam": "Vastgoed Zebra", "KBO": "0745955932", "Confidence": "high",
     "Bron": "https://www.companyweb.be/en/0745955932/vastgoed-zebra",
     "Telefoon": "+3251970990", "Email": "mathias@vastgoedzebra.be", "Plaats": "Tielt",
     "IcOrgId": "64efc33f-5105-48c5-8245-1147deef32db", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Vastgoed Zebra BV, Kortrijkstraat 44 Tielt."},

    {"Status": "Active", "Naam": "Onid Real Estate (Boechout)", "KBO": "0820397888", "Confidence": "high",
     "Bron": "https://www.onid.be",
     "Telefoon": "+3232891100", "Email": "hallo@onid.be", "Plaats": "Boechout",
     "IcOrgId": "407c8935-8bf9-4491-aa8b-1e162f53ee78",
     "ParentOrgId": "6b36b57a-3eef-4227-95c6-5a51f01be29b",
     "EstablishmentNumber": "2315737418", "HasActiveDuplicate": 0,
     "Notes": "Parent: De Kern BV. Alle Onid vestigingen delen dit KBO."},

    {"Status": "Active", "Naam": "Onid Real Estate (Merksem)", "KBO": "0820397888", "Confidence": "high",
     "Bron": "https://www.onid.be",
     "Telefoon": "+3232891100", "Email": "hallo@onid.be", "Plaats": "Merksem",
     "IcOrgId": "0710a196-9f32-4e65-a41c-dca09c7e62df",
     "ParentOrgId": "6b36b57a-3eef-4227-95c6-5a51f01be29b",
     "EstablishmentNumber": "2366597189", "HasActiveDuplicate": 0,
     "Notes": "Parent: De Kern BV."},

    {"Status": "Active", "Naam": "Onid Real Estate (Mortsel)", "KBO": "0820397888", "Confidence": "high",
     "Bron": "https://www.onid.be",
     "Telefoon": "+3232891100", "Email": "hallo@onid.be", "Plaats": "Mortsel",
     "IcOrgId": "7746cd0c-b0fe-4784-892e-8447d7db9ac3",
     "ParentOrgId": "6b36b57a-3eef-4227-95c6-5a51f01be29b",
     "EstablishmentNumber": "2341436973", "HasActiveDuplicate": 0,
     "Notes": "Parent: De Kern BV."},

    {"Status": "Active", "Naam": "Onid Real Estate (Schoten)", "KBO": "0820397888", "Confidence": "high",
     "Bron": "https://www.onid.be",
     "Telefoon": "+3232891100", "Email": "hallo@onid.be", "Plaats": "Schoten",
     "IcOrgId": "c4f0ec95-9094-4469-8ff8-52b644c687f4",
     "ParentOrgId": "6b36b57a-3eef-4227-95c6-5a51f01be29b",
     "EstablishmentNumber": "2366597288", "HasActiveDuplicate": 0,
     "Notes": "Parent: De Kern BV."},

    {"Status": "Active", "Naam": "Onid Real Estate (Wilrijk)", "KBO": "0820397888", "Confidence": "high",
     "Bron": "https://www.onid.be",
     "Telefoon": "+3232891100", "Email": "hallo@onid.be", "Plaats": "Wilrijk",
     "IcOrgId": "1e520327-8b4e-4dcf-ada3-91596fd03891",
     "ParentOrgId": "6b36b57a-3eef-4227-95c6-5a51f01be29b",
     "EstablishmentNumber": "2182734283", "HasActiveDuplicate": 0,
     "Notes": "Parent: De Kern BV."},

    # Inactive (3) - DB only, no web research done
    {"Status": "Inactive", "Naam": "Arnout Montald", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0474750979", "Email": "arnoutmontald@gmail.com", "Plaats": "Gent",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Gmail-adres - mogelijk natuurlijk persoon."},

    {"Status": "Inactive", "Naam": "Evimmo", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "+32476693300", "Email": "evi@elementsprojects.be",
     "Plaats": "Barvaux-sur-Ourthe", "IcOrgId": "e817c58b-0167-4226-9679-5ffcbe3418c3",
     "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": ""},

    {"Status": "Inactive", "Naam": "TOPO-IMMO bvba (Denderhoutem)", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "liedekerke@topo-immo.be", "Plaats": "Liederkerke",
     "IcOrgId": "d7cb074d-7128-44dc-8d07-02c3eb2c66b1", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": ""},

    # Archived (44) - DB info only; KBO filled in only where a reliable join exists
    {"Status": "Archived", "Naam": "Acasa Loppem (Immo Albert)", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "info@acasa.be", "Plaats": "Loppem",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Aertsen Beheer", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "jan@aertsen.be", "Plaats": "Loenhout",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Agence Claeys", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "koen@agenceclaeys.be", "Plaats": "De Haan",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Agence Van den Abeele", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0499 46 88 79", "Email": "info@didierdelille.com", "Plaats": "Brugge",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Altro Vastgoed Edegem", "KBO": "0680782523", "Confidence": "medium",
     "Bron": "Active duplicate via IC id + Kantoor Informatie.csv",
     "Telefoon": "+3234598959", "Email": "info@altro-vastgoed.be", "Plaats": "Edegem",
     "IcOrgId": "57a76e69-26ba-41b0-8b40-e03bc941c8ee", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 1,
     "Notes": "Altro Vastgoed groep deelt KBO. Active duplicate bevestigt."},

    {"Status": "Archived", "Naam": "Altro Vastgoed Hemiksem", "KBO": "0680782523", "Confidence": "medium",
     "Bron": "Active duplicate via IC id + Kantoor Informatie.csv",
     "Telefoon": "+3234598959", "Email": "info@altro-vastgoed.be", "Plaats": "Hemiksem",
     "IcOrgId": "44a000f8-758b-44a7-9fab-ff2e8232de9c", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 1,
     "Notes": "Altro Vastgoed groep deelt KBO."},

    {"Status": "Archived", "Naam": "Altro Vastgoed Heusden", "KBO": "0680782523", "Confidence": "medium",
     "Bron": "Kantoor Informatie.csv (omnicasa export)",
     "Telefoon": "+3292798892", "Email": "info@altro-vastgoed.be", "Plaats": "Heusden",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Altro Vastgoed groep - KBO uit omnicasa Kantoor Informatie."},

    {"Status": "Archived", "Naam": "Altro Vastgoed Oostende", "KBO": "0680782523", "Confidence": "medium",
     "Bron": "Active duplicate via IC id + Kantoor Informatie.csv",
     "Telefoon": "+32497192252", "Email": "info@altro-vastgoed.be", "Plaats": "Destelbergen",
     "IcOrgId": "d5757a0d-9f05-4a13-aaeb-6c728ed35e4d", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 1,
     "Notes": "Altro Vastgoed groep deelt KBO. Plaats 'Destelbergen' lijkt foutief (vestiging is Oostende)."},

    {"Status": "Archived", "Naam": "CEUSTERS", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "support@spotto.be", "Plaats": "Antwerpen (berchem)",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Email is intern (support@spotto.be) - lijkt teststaat."},

    {"Status": "Archived", "Naam": "Charles Van Heyghen", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "charles@immo-cvh.be", "Plaats": "Gent",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Claes & Willems", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "oliva.claes@claeswillems.be", "Plaats": "Halle",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Co immo Steenokkerzeel", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "+32491253178", "Email": "info.steenokkerzeel@co-immo.be",
     "Plaats": "Steenokkerzeel", "IcOrgId": "", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Co Immo Stone & Steel", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0474293793", "Email": "vicky@co-immo.be", "Plaats": "Glabbeek",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Colorcasa", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "+3222703702", "Email": "immo@colorcasa.be", "Plaats": "Meise",
     "IcOrgId": "f43dc9b1-dcb5-41cb-88a3-5e6247f7d46e", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "De Boer & Partners Antwerpen NV", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "brasschaat@deboerenpartners.be", "Plaats": "Antwerpen",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "De Boer & Partners Brasschaat", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "brasschaat@deboerenpartners.be", "Plaats": "Brasschaat",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Engel & Volkers Brugge", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0491 25 01 15", "Email": "joke.despiegelaere@engelvoelkers.com",
     "Plaats": "Brugge", "IcOrgId": "", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Engel & Volkers Gent-Zuid-Latem", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0477 37 41 49", "Email": "latem@evlatem.be",
     "Plaats": "Sint-Martens-Latem", "IcOrgId": "", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "euro fout", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "info@ceusters.be", "Plaats": "Antwerpen",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Naam suggereert testdata ('fout')."},

    {"Status": "Archived", "Naam": "Gabit", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "+32475654538", "Email": "laurence@gabit.be", "Plaats": "Kortrijk",
     "IcOrgId": "801803c4-fb64-41e4-9c26-1546c971c03a", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Global Invest (oud)", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0497 97 70 56", "Email": "stijn@stijnvoet.be", "Plaats": "Aalter",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Naam vermeldt '(oud)' - vermoedelijk vervangen door nieuw record."},

    {"Status": "Archived", "Naam": "Immo Expert Albert - Backoffice", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0473 69 99 96", "Email": "familie@albert.immo",
     "Plaats": "Sint-Genesius-Rode", "IcOrgId": "123 (placeholder)", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "IC OrganizationId is placeholder '123' - data quality issue."},

    {"Status": "Archived", "Naam": "Immo Jux", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "+32475230578", "Email": "hello@immojux.be", "Plaats": "Duffel",
     "IcOrgId": "c15729bd-18f5-4a1f-9256-a3b0e5730467", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Immo Koen Dhont", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0475 50 81 00", "Email": "info@koendhont.be", "Plaats": "Deinze",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "IMMO METEX", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "annsophie@immometex.be", "Plaats": "Pittem",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Immo Roje", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "+3250894039", "Email": "jennifer-descamps@hotmail.com",
     "Plaats": "De Haan", "IcOrgId": "", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Immo Vesta", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "+3211747080", "Email": "info@immovesta.be", "Plaats": "Sint-Truiden",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Immo.3", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "wim@immopersyn.be", "Plaats": "Scherpenheuvel",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Immobilien Johan Telen", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0475 37 59 51", "Email": "johan@johantelen.be", "Plaats": "Neeroeteren",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "M3 makelaars bv", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "glenn@m3makelaars.be", "Plaats": "Bornem",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Meuleman & Loeters", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "renee@meuleman-loeters.be", "Plaats": "Oostkamp",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "mi vida", "KBO": "0694997278", "Confidence": "low",
     "Bron": "Active duplicate via IC id (had 9 cijfers in DB)",
     "Telefoon": "+32492063005", "Email": "inge@mi-vida.be", "Plaats": "Neeroeteren",
     "IcOrgId": "82528d2b-506e-4494-9ada-8407da750d7a", "ParentOrgId": "",
     "EstablishmentNumber": "", "HasActiveDuplicate": 1,
     "Notes": "Active duplicate had OrgNumber '694997278' (9 cijfers) - voorloopnul toegevoegd. Verifieer."},

    {"Status": "Archived", "Naam": "Nina Bruno Vastgoed", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "nina@ninabrunovastgoed.be", "Plaats": "Genk",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Reypens Real Estate Mentor", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0494 12 10 42", "Email": "info@reypensmentor.com", "Plaats": "Itegem",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "STERK vastgoedmakelaars", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "yorick@sterkvastgoedmakelaars.be", "Plaats": "Tongeren",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Stijn Voet Immobilien: Credofin", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0497 977 056", "Email": "stijn@stijnvoet.be", "Plaats": "Aalter",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Structura", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "wouter.deneve@structura.be", "Plaats": "Wemmel",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Viva Immo", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "katrien@viva-immo.be", "Plaats": "Leuven",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Viva Vastgoed", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "sophie@vivavastgoed.be", "Plaats": "Grimbergen",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Welleman | Wonen met Meerwaarde (oud)", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "0497 55 00 50", "Email": "yvan@welleman.be", "Plaats": "Erpe-Mere",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Naam vermeldt '(oud)' - mogelijk vervangen door 'Welleman bvba'."},

    {"Status": "Archived", "Naam": "Welleman bvba", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "yvan@welleman.be", "Plaats": "Erpe-Mere",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Wolff Bv", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "steve@wolff.be", "Plaats": "Gent",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "Woonbureau Lokeren", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "03 777 36 77", "Email": "j.vanbuynder@woonbureau.be", "Plaats": "Lokeren",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0, "Notes": ""},

    {"Status": "Archived", "Naam": "YANNICK CROMMEN", "KBO": "", "Confidence": "",
     "Bron": "", "Telefoon": "", "Email": "yannick@immovadis.be", "Plaats": "Lanaken",
     "IcOrgId": "", "ParentOrgId": "", "EstablishmentNumber": "", "HasActiveDuplicate": 0,
     "Notes": "Email-domein 'immovadis.be' suggereert vestigingsmakelaar bij Immo Vadis."},
]


def write_csv(path: Path, rows: list[dict]) -> None:
    fieldnames = [
        "Status", "Naam", "Verwacht BTW nummer", "Confidence", "Bron",
        "Telefoon", "Email", "Plaats",
        "IC_OrganizationId", "Parent_OrganizationId", "EstablishmentNumber",
        "HasActiveDuplicate", "Notes",
    ]
    with path.open("w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_MINIMAL)
        w.writeheader()
        for r in rows:
            w.writerow({
                "Status": r["Status"],
                "Naam": r["Naam"],
                "Verwacht BTW nummer": fmt_kbo(r["KBO"]),
                "Confidence": r["Confidence"],
                "Bron": r["Bron"],
                "Telefoon": r["Telefoon"],
                "Email": r["Email"],
                "Plaats": r["Plaats"],
                "IC_OrganizationId": r["IcOrgId"],
                "Parent_OrganizationId": r["ParentOrgId"],
                "EstablishmentNumber": r["EstablishmentNumber"],
                "HasActiveDuplicate": r["HasActiveDuplicate"],
                "Notes": r["Notes"],
            })


if __name__ == "__main__":
    out = Path(__file__).parent / "klanten-zonder-orgnummer-2026-04-29-v2.csv"
    write_csv(out, rows)
    print(f"Wrote {len(rows)} rows to {out}")
