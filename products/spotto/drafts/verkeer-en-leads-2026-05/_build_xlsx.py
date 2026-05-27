"""
Build the channel x sale/rent split workbook for the period 2026-04-12 to 2026-05-11.

Tabs:
  - Detail views (h+a): aggregated, consent-adjusted (x1.37 bump)
  - Leads (h+a): aggregated, SQL truth + GA4-distributed for null-UTM rows
  - GA4 raw: full GA4 export, all property types and transaction types
  - SQL raw: full SQL leads export from Questions table
  - Methode: notes, sources, decoder for SQL int enums
"""

import json
from pathlib import Path

from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill
from openpyxl.utils import get_column_letter

HERE = Path(__file__).parent
OUTPUT = HERE / "verkeer-en-leads-2026-05.xlsx"

HEADER_FILL = PatternFill("solid", fgColor="1F4E78")
HEADER_FONT = Font(bold=True, color="FFFFFF")
TOTAL_FILL = PatternFill("solid", fgColor="D9E1F2")
TOTAL_FONT = Font(bold=True)


def write_table(ws, headers, rows, total_row):
    for col, h in enumerate(headers, start=1):
        c = ws.cell(row=1, column=col, value=h)
        c.fill = HEADER_FILL
        c.font = HEADER_FONT
        c.alignment = Alignment(horizontal="center")

    for r_idx, row in enumerate(rows, start=2):
        for c_idx, value in enumerate(row, start=1):
            ws.cell(row=r_idx, column=c_idx, value=value)

    total_r = len(rows) + 2
    for c_idx, value in enumerate(total_row, start=1):
        c = ws.cell(row=total_r, column=c_idx, value=value)
        c.fill = TOTAL_FILL
        c.font = TOTAL_FONT

    for col_idx, h in enumerate(headers, start=1):
        if h in ("Sale %", "Rent %", "Share %"):
            for r in range(2, total_r + 1):
                ws.cell(row=r, column=col_idx).number_format = "0.0%"
        elif h not in ("Channel",):
            for r in range(2, total_r + 1):
                ws.cell(row=r, column=col_idx).number_format = "#,##0"

    widths = {"Channel": 18, "Sale": 12, "Sale %": 10, "Rent": 12, "Rent %": 10,
              "Other": 10, "Combined": 12, "Share %": 10}
    for col_idx, h in enumerate(headers, start=1):
        ws.column_dimensions[get_column_letter(col_idx)].width = widths.get(h, 14)

    ws.freeze_panes = "A2"


# ----- Detail views (h+a), consent-adjusted -----
detail_headers = ["Channel", "Sale", "Sale %", "Rent", "Rent %", "Other", "Combined", "Share %"]
detail_rows = [
    ["Organic Search", 92437, 0.690, 41526, 0.310, 12662, 146624, 0.571],
    ["Paid Search",    23282, 0.526, 20995, 0.474,  6276,  50553, 0.197],
    ["Direct",         15218, 0.620,  9313, 0.380,   997,  25529, 0.099],
    ["Unassigned",      5943, 0.627,  3530, 0.373,   533,  10006, 0.039],
    ["Email",           6251, 0.719,  2437, 0.281,   160,   8849, 0.034],
    ["Cross-network",   5073, 0.682,  2366, 0.318,  1123,   8563, 0.033],
    ["Organic Social",  2189, 0.649,  1186, 0.351,    30,   3406, 0.013],
    ["Referral",        1132, 0.357,  2040, 0.643,   104,   3277, 0.013],
    ["Paid Other",         7, 0.833,     1, 0.167,     1,     10, 0.000],
]
detail_total = ["Total", 151532, 0.645, 83396, 0.355, 21887, 256815, 1.0]

# ----- Leads (h+a), SQL truth + GA4 distribution -----
lead_headers = ["Channel", "Sale", "Sale %", "Rent", "Rent %", "Combined", "Share %"]
lead_rows = [
    ["Organic Search",  542, 0.175, 2561, 0.825, 3103, 0.486],
    ["Paid Search",     107, 0.095, 1022, 0.905, 1129, 0.177],
    ["Referral",          9, 0.011,  829, 0.989,  838, 0.131],
    ["Direct",          139, 0.195,  573, 0.805,  712, 0.112],
    ["Unassigned",       71, 0.249,  214, 0.751,  285, 0.045],
    ["Email",            25, 0.236,   81, 0.764,  106, 0.017],
    ["Cross-network",    21, 0.206,   81, 0.794,  102, 0.016],
    ["Organic Social",   18, 0.310,   40, 0.690,   58, 0.009],
    ["WhatsApp",         15, 0.313,   33, 0.688,   48, 0.008],
]
lead_total = ["Total", 947, 0.148, 5433, 0.852, 6380, 1.0]

wb = Workbook()
ws1 = wb.active
ws1.title = "Detail views (h+a)"
write_table(ws1, detail_headers, detail_rows, detail_total)

ws2 = wb.create_sheet("Leads (h+a)")
write_table(ws2, lead_headers, lead_rows, lead_total)

ga4_raw = json.loads((HERE / "ga4_raw.json").read_text(encoding="utf-8"))
ws_ga4 = wb.create_sheet("GA4 raw")
ga4_headers = ["Channel", "Property type", "Transaction type", "Event count"]
for col, h in enumerate(ga4_headers, start=1):
    c = ws_ga4.cell(row=1, column=col, value=h)
    c.fill = HEADER_FILL
    c.font = HEADER_FONT
    c.alignment = Alignment(horizontal="center")
for r_idx, row in enumerate(ga4_raw, start=2):
    for c_idx, value in enumerate(row, start=1):
        ws_ga4.cell(row=r_idx, column=c_idx, value=value)
for c_idx in (4,):
    for r in range(2, len(ga4_raw) + 2):
        ws_ga4.cell(row=r, column=c_idx).number_format = "#,##0"
ws_ga4.column_dimensions["A"].width = 18
ws_ga4.column_dimensions["B"].width = 28
ws_ga4.column_dimensions["C"].width = 18
ws_ga4.column_dimensions["D"].width = 14
ws_ga4.freeze_panes = "A2"
ws_ga4.auto_filter.ref = f"A1:D{len(ga4_raw) + 1}"

sql_raw = json.loads((HERE / "sql_raw.json").read_text(encoding="utf-8"))
property_type_lookup = {1: "house", 2: "apartment"}
transaction_type_lookup = {1: "sale", 2: "rent", 8: "takeOver"}
ws_sql = wb.create_sheet("SQL raw")
sql_headers = ["UTM medium", "Question type", "PropertyType (int)", "Property type", "TransactionType (int)", "Transaction type", "Leads"]
for col, h in enumerate(sql_headers, start=1):
    c = ws_sql.cell(row=1, column=col, value=h)
    c.fill = HEADER_FILL
    c.font = HEADER_FONT
    c.alignment = Alignment(horizontal="center")
for r_idx, row in enumerate(sql_raw, start=2):
    utm, qtype, pt_int, tt_int, leads = row
    ws_sql.cell(row=r_idx, column=1, value=utm)
    ws_sql.cell(row=r_idx, column=2, value=qtype)
    ws_sql.cell(row=r_idx, column=3, value=pt_int)
    ws_sql.cell(row=r_idx, column=4, value=property_type_lookup.get(pt_int, ""))
    ws_sql.cell(row=r_idx, column=5, value=tt_int)
    ws_sql.cell(row=r_idx, column=6, value=transaction_type_lookup.get(tt_int, ""))
    ws_sql.cell(row=r_idx, column=7, value=leads)
for r in range(2, len(sql_raw) + 2):
    ws_sql.cell(row=r, column=7).number_format = "#,##0"
widths_sql = [14, 22, 18, 16, 22, 18, 10]
for col_idx, w in enumerate(widths_sql, start=1):
    ws_sql.column_dimensions[get_column_letter(col_idx)].width = w
ws_sql.freeze_panes = "A2"
ws_sql.auto_filter.ref = f"A1:G{len(sql_raw) + 1}"

ws3 = wb.create_sheet("Methode")
notes = [
    ["Periode", "2026-04-12 t/m 2026-05-11 (30 dagen)"],
    ["Filter", "Property type: house + apartment"],
    [],
    ["DETAIL VIEWS TAB"],
    ["Bron", "GA4 event property_pageview_detail, custom dim property_type IN (house, apartment)"],
    ["Splitsing", "customEvent:transaction_type (sale / rent / Other = '(not set)' of leeg)"],
    ["Correctie", "×1.37 bump factor — cookie/consent verlies"],
    ["Bump bron", "Google Ads clicks (63.110) vs GA4 google/cpc sessions (46.156) = 73,1% capture"],
    ["Sale % / Rent %", "Berekend op Sale + Rent (Other excl.)"],
    ["Combined", "Sale + Rent + Other, na bump"],
    ["Share %", "Channel Combined / Grand Combined"],
    [],
    ["LEADS TAB"],
    ["Bron totalen", "SQL Questions tabel, QuestionType = PublicationQuestion, joined op Publications met PropertyType IN (1=house, 2=apartment)"],
    ["Splitsing", "Publications.TransactionType (1=sale, 2=rent)"],
    ["Geen Other kolom", "SQL heeft 100% transaction_type coverage voor h+a publications"],
    ["Channel attributie", "Paid/Email/WhatsApp: SQL utm_medium direct. Null UTM (4995 leads): verdeeld via GA4 property_question_form_submit relatieve shares per niet-betaalde channel"],
    ["GA4 capture rate", "3417 / 6380 = 53,6% (leads worden veel slechter gecapture dan pageviews)"],
    [],
    ["BELANGRIJKE OBSERVATIE"],
    ["Detail views sale share", "64,5%"],
    ["Detail views rent share", "35,5%"],
    ["Leads sale share", "14,8%"],
    ["Leads rent share", "85,2%"],
    ["Implicatie", "Huurders sturen ~12x meer contactaanvragen per detail view dan kopers. Lead volume is geen proxy voor koopintentie."],
    [],
    ["RAW DATA TABS"],
    ["GA4 raw", "property_pageview_detail events, gegroepeerd op (sessionDefaultChannelGroup, customEvent:property_type, customEvent:transaction_type). Geen filter — alle property types en transaction types incl. (not set) en lege strings."],
    ["SQL raw", "Questions tabel joined op Publications, gegroepeerd op (utm_medium, QuestionType, PropertyType int, TransactionType int). Alle question types (PublicationQuestion, ProfessionalQuestion, RealtorQuestion) en alle property types."],
    [],
    ["PROPERTY TYPE DECODER (SQL int)"],
    ["1", "house (huis)"],
    ["2", "apartment (appartement)"],
    ["3-14", "garage, land, commercial, office, etc. — niet gedecodeerd. Sluit aan op GA4 property_type strings via cross-reference op volume of via PublicationUrls_DutchUrl slug."],
    [],
    ["TRANSACTION TYPE DECODER (SQL int)"],
    ["1", "sale (te-koop)"],
    ["2", "rent (te-huur)"],
    ["8", "takeOver (overname, vooral horeca/commercieel)"],
]
for r_idx, row in enumerate(notes, start=1):
    for c_idx, value in enumerate(row, start=1):
        cell = ws3.cell(row=r_idx, column=c_idx, value=value)
        if c_idx == 1 and isinstance(value, str) and value.isupper():
            cell.font = Font(bold=True)
ws3.column_dimensions["A"].width = 26
ws3.column_dimensions["B"].width = 110

wb.save(OUTPUT)
print(f"Saved: {OUTPUT}")
