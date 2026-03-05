import argparse
import os
import pandas as pd

parser = argparse.ArgumentParser(description="Filter overheidswebsites uit de linking sites CSV")
parser.add_argument("--excel", type=str, nargs="?", const="overheidslinks.xlsx", default=None,
                    help="Export naar Excel. Optioneel bestandsnaam (default: results/overheidslinks.xlsx)")
args = parser.parse_args()

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CSV = os.path.join(SCRIPT_DIR, "source", "spotto.be-Top linking sites-2026-03-04.csv")
RESULTS_DIR = os.path.join(SCRIPT_DIR, "results")

# ============================================================
# Referentielijsten
# ============================================================

# Vlaamse gemeenten (300 gemeenten)
VLAAMSE_GEMEENTEN = {
    "aalst", "aalter", "aarschot", "aartselaar", "affligem", "alken", "alveringem",
    "antwerpen", "anzegem", "ardooie", "arendonk", "as", "asse", "assenede",
    "avelgem", "baarle-hertog", "balen", "beernem", "beerse", "beersel",
    "begijnendijk", "bekkevoort", "beringen", "berlaar", "berlare", "bertem",
    "bever", "beveren", "bierbeek", "bilzen", "blankenberge", "bocholt",
    "boechout", "bonheiden", "boom", "boortmeerbeek", "borgloon", "bornem",
    "borsbeek", "boutersem", "brakel", "brasschaat", "brecht", "bredene",
    "bree", "brugge", "buggenhout", "damme", "de-haan", "de-panne",
    "de-pinte", "deerlijk", "deinze", "denderleeuw", "dendermonde",
    "dentergem", "dessel", "destelbergen", "diepenbeek", "diest", "diksmuide",
    "dilbeek", "dilsen-stokkem", "drogenbos", "duffel", "edegem", "eeklo",
    "erpe-mere", "essen", "evergem", "galmaarden", "gavere", "geel",
    "geetbets", "genk", "gent", "geraardsbergen", "gingelom", "gistel",
    "glabbeek", "gooik", "grimbergen", "grobbendonk", "haacht", "haaltert",
    "halen", "halle", "ham", "hamme", "hamont-achel", "harelbeke",
    "hasselt", "hechtel-eksel", "heers", "heist-op-den-berg", "hemiksem",
    "herent", "herentals", "herenthout", "herk-de-stad", "herne",
    "herselt", "herstappe", "herzele", "heusden-zolder", "heuvelland",
    "hoegaarden", "hoeilaart", "hoeselt", "holsbeek", "hooglede",
    "hoogstraten", "horebeke", "houthalen-helchteren", "houthulst",
    "hulshout", "ichtegem", "ieper", "ingelmunster", "izegem", "jabbeke",
    "kalmthout", "kampenhout", "kapelle-op-den-bos", "kapellen", "kaprijke",
    "kasterlee", "keerbergen", "kinrooi", "kluisbergen", "knesselare",
    "knokke-heist", "koekelare", "koksijde", "kontich", "kortemark",
    "kortenaken", "kortenberg", "kortessem", "kortrijk", "kraainem",
    "kruibeke", "kruisem", "kuurne", "laakdal", "laarne", "lanaken",
    "landen", "langemark-poelkapelle", "lebbeke", "lede", "ledegem",
    "lendelede", "lennik", "leopoldsburg", "leuven", "lichtervelde",
    "liedekerke", "lier", "lierde", "lievegem", "lille", "linkebeek",
    "lint", "linter", "lochristi", "lokeren", "lommel", "londerzeel",
    "lo-reninge", "lubbeek", "lummen", "maarkedal", "maaseik", "maasmechelen",
    "machelen", "maldegem", "malle", "mechelen", "meerhout", "meise",
    "melle", "menen", "merchtem", "merelbeke", "merksplas", "meulebeke",
    "middelkerke", "moerbeke", "mol", "moorslede", "mortsel", "nazareth",
    "niel", "nieuwerkerken", "nieuwpoort", "nijlen", "ninove", "olen",
    "oostende", "oosterzele", "oostkamp", "oostrozebeke", "opglabbeek",
    "opwijk", "oudenaarde", "oudenburg", "oud-heverlee", "oud-turnhout",
    "overijse", "peer", "pepingen", "pittem", "poperinge", "putte",
    "puurs-sint-amands", "ranst", "ravels", "retie", "riemst", "rijkevorsel",
    "roeselare", "ronse", "roosdaal", "rotselaar", "ruiselede",
    "rumst", "schelle", "scherpenheuvel-zichem", "schilde", "schoten",
    "sint-genesius-rode", "sint-gillis-waas", "sint-katelijne-waver",
    "sintkatelijnewaver", "sint-laureins", "sint-lievens-houtem",
    "sint-martens-latem", "sint-niklaas", "sint-pieters-leeuw",
    "sint-truiden", "spiere-helkijn", "stabroek", "staden",
    "steenokkerzeel", "stekene", "temse", "tervuren", "tessenderlo",
    "tielt", "tielt-winge", "tienen", "tongeren", "torhout", "tremelo",
    "turnhout", "veurne", "vilvoorde", "vleteren", "voeren", "vorselaar",
    "vosselaar", "waarschoot", "waasmunster", "wachtebeke", "waregem",
    "wellen", "wemmel", "wervik", "westerlo", "wetteren", "wevelgem",
    "wezembeek-oppem", "wichelen", "wielsbeke", "wijnegem", "willebroek",
    "wingene", "wommelgem", "wortegem-petegem", "wuustwezel", "zandhoven",
    "zaventem", "zedelgem", "zele", "zelzate", "zemst", "zingem",
    "zoersel", "zonnebeke", "zottegem", "zoutleeuw", "zuienkerke",
    "zulte", "zwalm", "zwevegem", "zwijndrecht",
}

# Vlaamse/federale overheidsdomeinen
OVERHEID_DOMEINEN = {
    "vlaanderen.be", "vlaio.be", "belgium.be", "fod.be",
    "vdab.be", "kind-en-gezin.be", "agentschapondernemen.be",
    "bouwenaanvlaanderen.be", "mijntoeslagen.be",
}

# Intercommunales en samenwerkingsverbanden
INTERCOMMUNALES = {
    "veneco.be", "interwaas.be", "igemo.be", "so-lva.be",
    "westlittoral.be", "c-plus.be",
    "ondernemeninsintniklaas.be", "ondernemeninsinttruiden.be",
    "dds-streekregisseurs.be",
}

# Provinciale domeinen
PROVINCIES = {
    "west-vlaanderen.be", "oost-vlaanderen.be",
    "vlaams-brabant.be", "antwerpen.be", "limburg.be",
}


# Aangesloten gemeenten/overheden uit de Spotto-database (4 maart 2026)
# Mapping: klantnaam → verwacht domein (enkel gemeenten/steden, geen intercommunales/POM's)
AANGESLOTEN_GEMEENTEN = {
    "Diksmuide": "diksmuide.be",
    "Gemeente Asse": "asse.be",
    "Gemeente Avelgem": "avelgem.be",
    "Gemeente Berlaar": "berlaar.be",
    "Gemeente Beveren": "beveren.be",
    "Gemeente Bonheiden": "bonheiden.be",
    "Gemeente Bornem": "bornem.be",
    "Gemeente Borsbeek": "borsbeek.be",
    "Gemeente Brakel": "brakel.be",
    "Gemeente Bredene": "bredene.be",
    "Gemeente Buggenhout": "buggenhout.be",
    "Gemeente Denderleeuw": "denderleeuw.be",
    "Gemeente Destelbergen": "destelbergen.be",
    "Gemeente Dilbeek": "dilbeek.be",
    "Gemeente Duffel": "duffel.be",
    "Gemeente Erpe-Mere": "erpe-mere.be",
    "Gemeente Haacht": "haacht.be",
    "Gemeente Haaltert": "haaltert.be",
    "Gemeente Ham": "ham.be",
    "Gemeente Hamme (Vl.)": "hamme.be",
    "Gemeente Hechtel-Eksel": "hechtel-eksel.be",
    "Gemeente Herzele": "herzele.be",
    "Gemeente Heusden-Zolder": "heusden-zolder.be",
    "Gemeente Horebeke": "horebeke.be",
    "Gemeente Ingelmunster": "ingelmunster.be",
    "Gemeente Kluisbergen": "kluisbergen.be",
    "Gemeente Knokke-Heist": "knokke-heist.be",
    "Gemeente Kruisem": "kruisem.be",
    "Gemeente Lanaken": "lanaken.be",
    "Gemeente Lebbeke": "lebbeke.be",
    "Gemeente Lede": "lede.be",
    "Gemeente Lichtervelde": "lichtervelde.be",
    "Gemeente Lubbeek": "lubbeek.be",
    "Gemeente Lummen": "lummen.be",
    "Gemeente Maarkedal": "maarkedal.be",
    "Gemeente Maasmechelen": "maasmechelen.be",
    "Gemeente Machelen": "machelen.be",
    "Gemeente Maldegem": "maldegem.be",
    "Gemeente Moerbeke": "moerbeke.be",
    "Gemeente Nijlen": "nijlen.be",
    "Gemeente Ninove": "ninove.be",
    "Gemeente Oosterzele": "oosterzele.be",
    "Gemeente Puurs": "puurs-sint-amands.be",
    "Gemeente Schoten": "schoten.be",
    "Gemeente Sint-Amands": "puurs-sint-amands.be",
    "Gemeente Sint-Katelijne-Waver": "sint-katelijne-waver.be",
    "Gemeente Sint-Lievens-Houtem": "sint-lievens-houtem.be",
    "Gemeente Staden": "staden.be",
    "Gemeente Temse": "temse.be",
    "Gemeente Ternat": "ternat.be",
    "Gemeente Waasmunster": "waasmunster.be",
    "Gemeente Wetteren": "wetteren.be",
    "Gemeente Wevelgem": "wevelgem.be",
    "Gemeente Wichelen": "wichelen.be",
    "Gemeente Wingene": "wingene.be",
    "Gemeente Zele": "zele.be",
    "Gemeente Zonhoven": "zonhoven.be",
    "Gemeente Zwalm": "zwalm.be",
    "Gemeente Zwijndrecht": "zwijndrecht.be",
    "Gemeentebestuur Rijkevorsel": "rijkevorsel.be",
    "Hooglede": "hooglede.be",
    "Ieper": "ieper.be",
    "Izegem": "izegem.be",
    "Koksijde": "koksijde.be",
    "Leuven": "leuven.be",
    "Lokeren": "lokeren.be",
    "Poperinge": "poperinge.be",
    "Sint-Niklaas": "sint-niklaas.be",
    "Stad Aalst": "aalst.be",
    "Stad Bilzen": "bilzen.be",
    "Stad Blankenberge": "blankenberge.be",
    "Stad Bree": "bree.be",
    "Stad Brugge": "brugge.be",
    "Stad Diest": "diest.be",
    "Stad Eeklo": "eeklo.be",
    "Stad Geel": "geel.be",
    "Stad Genk": "genk.be",
    "Stad Geraardsbergen": "geraardsbergen.be",
    "Stad Halen": "halen.be",
    "Stad Harelbeke": "harelbeke.be",
    "Stad Hasselt": "hasselt.be",
    "Stad Herentals": "herentals.be",
    "Stad Hoogstraten": "hoogstraten.be",
    "Stad Kortrijk": "kortrijk.be",
    "Stad Landen": "landen.be",
    "Stad Lier": "lier.be",
    "Stad Mechelen": "mechelen.be",
    "Stad Menen": "menen.be",
    "Stad Oudenaarde": "oudenaarde.be",
    "Stad Roeselare": "roeselare.be",
    "Stad Ronse": "ronse.be",
    "Stad Scherpenheuvel-Zichem": "scherpenheuvel-zichem.be",
    "Stad Sint-Truiden": "sint-truiden.be",
    "Stad Tienen": "tienen.be",
    "Stad Tongeren": "tongeren.be",
    "Stad Torhout": "torhout.be",
    "Stad Turnhout": "turnhout.be",
    "Stad Vilvoorde": "vilvoorde.be",
    "Veurne": "veurne.be",
}

# Alternatieve domeinen (sommige gemeenten gebruiken een afwijkend domein)
ALTERNATIEVE_DOMEINEN = {
    "sint-katelijne-waver.be": "sintkatelijnewaver.be",
    "destelbergen.be": "ocmw-destelbergen.be",  # OCMW linkt i.p.v. gemeente zelf
}


def is_overheidssite(domain):
    """Bepaal of een domein een overheidswebsite is."""
    # Directe match op bekende overheidsdomeinen
    if domain in OVERHEID_DOMEINEN:
        return "Vlaamse/federale overheid"
    if domain in INTERCOMMUNALES:
        return "Intercommunale"
    if domain in PROVINCIES:
        return "Provincie"

    # OCMW-patroon
    if domain.startswith("ocmw-") and domain.endswith(".be"):
        return "OCMW"

    # Gemeentelijke website: domeinnaam (zonder .be) in gemeentelijst
    if domain.endswith(".be"):
        naam = domain.removesuffix(".be")
        if naam in VLAAMSE_GEMEENTEN:
            return "Gemeente"

    return None


# ============================================================
# Data inlezen en filteren
# ============================================================
df = pd.read_csv(CSV)

df["categorie"] = df["Site"].apply(is_overheidssite)
overheid = df[df["categorie"].notna()].copy()
overheid = overheid.sort_values("Linking pages", ascending=False)

# ============================================================
# Console output: simple list per category
# ============================================================
print("OVERHEIDSWEBSITES DIE LINKEN NAAR SPOTTO.BE")
print("Totaal: {} / {}".format(len(overheid), len(df)))
print()

for cat in ["Vlaamse/federale overheid", "Intercommunale", "Gemeente", "OCMW", "Provincie"]:
    subset = overheid[overheid["categorie"] == cat]
    if len(subset) == 0:
        continue
    print("{}:".format(cat))
    for _, row in subset.iterrows():
        print("  {}".format(row["Site"]))
    print()

# ============================================================
# Gap-analyse: aangesloten gemeenten zonder backlink
# ============================================================
linking_domains = set(overheid["Site"].str.lower())

met_link = {}
zonder_link = {}

for naam, domein in AANGESLOTEN_GEMEENTEN.items():
    alt_domein = ALTERNATIEVE_DOMEINEN.get(domein)
    if domein in linking_domains or (alt_domein and alt_domein in linking_domains):
        met_link[naam] = domein
    else:
        zonder_link[naam] = domein

print("=" * 60)
print("GAP-ANALYSE: AANGESLOTEN GEMEENTEN ZONDER BACKLINK")
print("Met link: {} / {}".format(len(met_link), len(AANGESLOTEN_GEMEENTEN)))
print("Zonder link: {} / {}".format(len(zonder_link), len(AANGESLOTEN_GEMEENTEN)))
print()
print("Gemeenten ZONDER backlink naar spotto.be:")
for naam in sorted(zonder_link.keys()):
    print("  {} ({})".format(naam, zonder_link[naam]))
print()

# ============================================================
# Excel export
# ============================================================
if args.excel:
    from openpyxl.worksheet.table import Table, TableStyleInfo
    from openpyxl.utils import get_column_letter

    os.makedirs(RESULTS_DIR, exist_ok=True)
    excel_path = os.path.join(RESULTS_DIR, args.excel)

    def format_as_table(ws, table_name):
        """Formatteer een worksheet als Excel-tabel met auto-breedte."""
        max_row = ws.max_row
        max_col = ws.max_column
        ref = "A1:{}{}".format(get_column_letter(max_col), max_row)

        table = Table(displayName=table_name, ref=ref)
        style = TableStyleInfo(
            name="TableStyleMedium2", showFirstColumn=False,
            showLastColumn=False, showRowStripes=True, showColumnStripes=False)
        table.tableStyleInfo = style
        ws.add_table(table)

        for col_idx in range(1, max_col + 1):
            header = ws.cell(row=1, column=col_idx).value
            max_len = len(str(header or ""))
            for row_idx in range(2, max_row + 1):
                val = ws.cell(row=row_idx, column=col_idx).value
                if val is not None:
                    max_len = max(max_len, len(str(val)))
            ws.column_dimensions[get_column_letter(col_idx)].width = min(max_len + 3, 40)

    # Gap-analyse DataFrame
    gap_rows = [{"Gemeente": naam, "Verwacht domein": domein, "Status": "Geen backlink"}
                for naam, domein in sorted(zonder_link.items())]
    gap_rows += [{"Gemeente": naam, "Verwacht domein": domein, "Status": "Backlink OK"}
                 for naam, domein in sorted(met_link.items())]
    df_gap = pd.DataFrame(gap_rows)

    with pd.ExcelWriter(excel_path, engine="openpyxl") as writer:
        overheid[["Site", "Linking pages", "Target pages", "categorie"]].to_excel(
            writer, sheet_name="Overheidslinks", index=False)
        format_as_table(writer.sheets["Overheidslinks"], "Overheidslinks")

        df_gap.to_excel(writer, sheet_name="Gap-analyse", index=False)
        format_as_table(writer.sheets["Gap-analyse"], "GapAnalyse")

    print("Exported naar: {}".format(excel_path))
