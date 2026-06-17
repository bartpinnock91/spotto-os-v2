# Bouwt het wekelijkse Spotto-rapport, sectie 4 (Leads & interactie).
# Bronnen: Spotto-productiedatabank (contactaanvragen via dbo.Questions, registraties,
# favorieten) en GA4 "Spotto - V2" (klikgedrag, banners). Opgehaald 2026-06-12.
# Weken = ISO-weken. Week 24 is de lopende week (t/m 12 juni).
# NB: contactaanvragen leven sinds sept 2024 in dbo.Questions (QuestionType =
# 'PublicationQuestion'); de oudere tabel PublicationContactForms wordt niet meer gevuld.
import datetime
import os
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, PatternFill
from openpyxl.utils import get_column_letter

# (isoweek, koop info, koop bezoek, huur info, huur bezoek,
#  totaal (incl. niet-koppelbaar), unieke e-mailadressen)
# dbo.Questions, QuestionType='PublicationQuestion'; PublicationQuestionType-enum uit de
# broncode: 0=RequestsInformation, 1=RequestsVisit. Koop/huur via gekoppelde publicatie.
# NB: de info/bezoek-verhouding kantelt abrupt in week 12-13 (half maart) - vermoedelijk
# een formulierwijziging, geen marktbeweging.
CONTACT = [
    ("202601", 137, 172, 441, 516, 1266, 765),
    ("202602", 126, 170, 609, 707, 1612, 957),
    ("202603", 126, 357, 573, 650, 1706, 958),
    ("202604", 156, 204, 530, 913, 1803, 958),
    ("202605", 107, 638, 509, 624, 1878, 878),
    ("202606", 152, 212, 567, 719, 1650, 983),
    ("202607", 126, 176, 696, 846, 1844, 1076),
    ("202608", 198, 190, 622, 866, 1878, 1091),
    ("202609", 119, 189, 520, 744, 1572, 954),
    ("202610", 105, 146, 541, 719, 1511, 927),
    ("202611", 128, 156, 554, 814, 1652, 1007),
    ("202612", 83, 197, 273, 984, 1537, 922),
    ("202613", 41, 257, 71, 1237, 1606, 1012),
    ("202614", 44, 215, 61, 1045, 1366, 880),
    ("202615", 15, 215, 61, 1134, 1425, 840),
    ("202616", 28, 186, 61, 1195, 1470, 880),
    ("202617", 32, 243, 88, 1316, 1679, 961),
    ("202618", 24, 218, 62, 1136, 1441, 894),
    ("202619", 34, 203, 70, 1323, 1630, 972),
    ("202620", 29, 213, 73, 1291, 1606, 957),
    ("202621", 25, 198, 55, 1236, 1514, 926),
    ("202622", 22, 195, 59, 1043, 1319, 800),
    ("202623", 29, 197, 81, 1334, 1641, 964),
    ("202624", 12, 148, 34, 743, 936, 627),
]

# (isoweek, belmakelaar events, users, cta-klik events, users) - GA4
KLIKS = [
    ("202601", 291, 212, 631, 418), ("202602", 390, 257, 804, 556),
    ("202603", 454, 302, 889, 616), ("202604", 440, 297, 844, 580),
    ("202605", 378, 259, 726, 538), ("202606", 452, 278, 754, 534),
    ("202607", 485, 314, 939, 646), ("202608", 507, 312, 953, 639),
    ("202609", 422, 282, 815, 584), ("202610", 454, 282, 800, 553),
    ("202611", 458, 278, 862, 590), ("202612", 443, 277, 786, 568),
    ("202613", 482, 280, 975, 651), ("202614", 332, 225, 859, 593),
    ("202615", 298, 197, 935, 584), ("202616", 313, 223, 980, 620),
    ("202617", 354, 244, 1065, 668), ("202618", 356, 222, 899, 615),
    ("202619", 327, 233, 1006, 666), ("202620", 308, 201, 983, 669),
    ("202621", 339, 224, 994, 684), ("202622", 201, 149, 796, 533),
    ("202623", 353, 224, 1117, 694), ("202624", 229, 138, 601, 430),
]

# (isoweek, ad views, bereikte gebruikers, ad clicks) - GA4
BANNERS = [
    ("202601", 144030, 26635, 69), ("202602", 162824, 30315, 70),
    ("202603", 175959, 32698, 83), ("202604", 175120, 31248, 61),
    ("202605", 155454, 28388, 52), ("202606", 175314, 31493, 86),
    ("202607", 174986, 33622, 75), ("202608", 157273, 34172, 68),
    ("202609", 139573, 31704, 58), ("202610", 131932, 30552, 53),
    ("202611", 136999, 31320, 72), ("202612", 127626, 29848, 59),
    ("202613", 132278, 30497, 58), ("202614", 121358, 28122, 45),
    ("202615", 110983, 25613, 56), ("202616", 116631, 27470, 53),
    ("202617", 119500, 27339, 52), ("202618", 119258, 27212, 63),
    ("202619", 120250, 27630, 38), ("202620", 124215, 28131, 62),
    ("202621", 110224, 25453, 33), ("202622", 101740, 23851, 48),
    ("202623", 113354, 26119, 54), ("202624", 72014, 17656, 37),
]

# (isoweek, nieuwe accounts, waarvan makelaar, met nieuwsbriefinschrijving) - Spotto-DB
REGISTRATIES = [
    ("202601", 249, 0, 9), ("202602", 258, 3, 16), ("202603", 228, 2, 4),
    ("202604", 229, 3, 18), ("202605", 218, 2, 16), ("202606", 241, 5, 23),
    ("202607", 246, 2, 30), ("202608", 248, 1, 26), ("202609", 210, 4, 23),
    ("202610", 227, 4, 19), ("202611", 214, 1, 25), ("202612", 200, 4, 22),
    ("202613", 182, 4, 33), ("202614", 176, 1, 19), ("202615", 172, 0, 27),
    ("202616", 168, 4, 21), ("202617", 191, 4, 33), ("202618", 191, 3, 22),
    ("202619", 176, 2, 25), ("202620", 161, 2, 23), ("202621", 172, 8, 19),
    ("202622", 171, 1, 30), ("202623", 203, 7, 32), ("202624", 85, 1, 15),
]

# (isoweek, favorieten koop, huur, totaal incl. overige types) - Spotto-DB
FAVORIETEN = [
    ("202601", 215, 260, 475), ("202602", 287, 251, 538), ("202603", 209, 272, 481),
    ("202604", 195, 232, 427), ("202605", 221, 211, 432), ("202606", 227, 238, 465),
    ("202607", 234, 247, 481), ("202608", 461, 212, 673), ("202609", 165, 257, 422),
    ("202610", 238, 288, 527), ("202611", 157, 181, 338), ("202612", 200, 149, 349),
    ("202613", 148, 128, 276), ("202614", 147, 250, 397), ("202615", 127, 211, 338),
    ("202616", 127, 183, 310), ("202617", 257, 192, 449), ("202618", 144, 222, 366),
    ("202619", 208, 241, 449), ("202620", 225, 164, 389), ("202621", 125, 168, 293),
    ("202622", 202, 205, 407), ("202623", 173, 192, 365), ("202624", 89, 132, 221),
]

HEADER_FILL = PatternFill("solid", fgColor="7030A0")
HEADER_FONT = Font(bold=True, color="FFFFFF")
NUM = "#,##0"


def weekinfo(isoweek):
    year, wk = int(isoweek[:4]), int(isoweek[4:])
    monday = datetime.date.fromisocalendar(year, wk, 1)
    return f"{year}-W{wk:02d}", monday


def make_sheet(wb, title, headers, rows, numfmts=None, widths=None):
    ws = wb.create_sheet(title)
    for c, h in enumerate(headers, 1):
        cell = ws.cell(row=1, column=c, value=h)
        cell.fill = HEADER_FILL
        cell.font = HEADER_FONT
        cell.alignment = Alignment(horizontal="center", wrap_text=True)
    for r, row in enumerate(rows, 2):
        for c, v in enumerate(row, 1):
            cell = ws.cell(row=r, column=c, value=v)
            if numfmts and c in numfmts:
                cell.number_format = numfmts[c]
    for c in range(1, len(headers) + 1):
        ws.column_dimensions[get_column_letter(c)].width = (widths or {}).get(c, 12)
    ws.freeze_panes = "A2"
    return ws


wb = Workbook()
wb.remove(wb.active)

# --- Contactaanvragen (Spotto-DB) ---
rows = [(*weekinfo(w), ki, kb, ki + kb, hi, hb, hi + hb, t, u)
        for w, ki, kb, hi, hb, t, u in CONTACT]
make_sheet(
    wb, "Contactaanvragen",
    ["Week", "Maandag", "Koop: infovraag", "Koop: bezoekaanvraag", "Koop totaal",
     "Huur: infovraag", "Huur: bezoekaanvraag", "Huur totaal",
     "Totaal", "Unieke e-mailadressen"],
    rows, numfmts={c: NUM for c in range(3, 11)},
    widths={2: 12, 4: 14, 7: 14, 10: 15},
)

# --- Klikgedrag contact (GA4) ---
rows = [(*weekinfo(w), *vals) for w, *vals in KLIKS]
make_sheet(
    wb, "Klikgedrag contact",
    ["Week", "Maandag", "Bel-makelaar geklikt", "Unieke gebruikers",
     "Formulier-CTA geklikt", "Unieke gebruikers"],
    rows, numfmts={c: NUM for c in range(3, 7)},
    widths={2: 12, 3: 14, 5: 14},
)

# --- Registraties (Spotto-DB) ---
rows = [(*weekinfo(w), n, m, nb) for w, n, m, nb in REGISTRATIES]
make_sheet(
    wb, "Registraties",
    ["Week", "Maandag", "Nieuwe accounts", "Waarvan makelaar", "Met nieuwsbriefinschrijving"],
    rows, numfmts={3: NUM, 4: NUM, 5: NUM},
    widths={2: 12, 3: 13, 4: 14, 5: 16},
)

# --- Favorieten (Spotto-DB) ---
rows = [(*weekinfo(w), k, h, t) for w, k, h, t in FAVORIETEN]
make_sheet(
    wb, "Favorieten",
    ["Week", "Maandag", "Koop", "Huur", "Totaal (incl. overige types)"],
    rows, numfmts={3: NUM, 4: NUM, 5: NUM},
    widths={2: 12, 5: 16},
)

# --- Partnerbanners (GA4) ---
rows = [(*weekinfo(w), v, u, c) for w, v, u, c in BANNERS]
make_sheet(
    wb, "Partnerbanners",
    ["Week", "Maandag", "Bannerweergaves", "Bereikte gebruikers", "Bannerkliks"],
    rows, numfmts={3: NUM, 4: NUM, 5: NUM},
    widths={2: 12, 3: 14, 4: 14},
)

out_dir = os.path.dirname(os.path.abspath(__file__))
out_path = os.path.join(out_dir, "spotto-weekrapport-2026-sectie4-leads.xlsx")
wb.save(out_path)
print(f"OK: {out_path}")
