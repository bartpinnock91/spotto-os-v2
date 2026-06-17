"""
Pull full sale property-detail-view price distribution per postcode from GA4,
bucket into the search filter's 50k brackets, write exact-coverage CSVs.

Signals: event=property_pageview_detail, transaction_type=sale.
Period: 2025-06-15 .. 2026-06-14. Property: Spotto V2 (491908260).
"""
import math, csv, os
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    RunReportRequest, DateRange, Dimension, Metric, Filter, FilterExpression,
    FilterExpressionList,
)

PROP = "491908260"
OUT = os.path.dirname(os.path.abspath(__file__))
client = BetaAnalyticsDataClient()

def dim_filter():
    return FilterExpression(and_group=FilterExpressionList(expressions=[
        FilterExpression(filter=Filter(field_name="eventName",
            string_filter=Filter.StringFilter(value="property_pageview_detail"))),
        FilterExpression(filter=Filter(field_name="customEvent:transaction_type",
            string_filter=Filter.StringFilter(value="sale"))),
    ]))

# Pull all (postal_code, price) rows, paginated.
rows = []
offset = 0
PAGE = 100000
while True:
    req = RunReportRequest(
        property=f"properties/{PROP}",
        date_ranges=[DateRange(start_date="2025-06-15", end_date="2026-06-14")],
        dimensions=[Dimension(name="customEvent:postal_code"),
                    Dimension(name="customEvent:price")],
        metrics=[Metric(name="eventCount")],
        dimension_filter=dim_filter(),
        limit=PAGE, offset=offset,
    )
    resp = client.run_report(req)
    for r in resp.rows:
        pc = r.dimension_values[0].value
        price = r.dimension_values[1].value
        views = int(r.metric_values[0].value)
        rows.append((pc, price, views))
    got = len(resp.rows)
    offset += got
    if got < PAGE or offset >= resp.row_count:
        break
print(f"pulled {len(rows)} (postcode,price) rows; total_row_count={resp.row_count}")

# Place names + total sale views per postcode (top 20 we've been working with).
PLACES = {"9000":"Gent","3600":"Genk","8400":"Oostende","3500":"Hasselt",
"3630":"Maasmechelen","3700":"Tongeren","2000":"Antwerpen","3620":"Lanaken",
"8800":"Roeselare","8670":"Koksijde","9100":"Sint-Niklaas","8300":"Knokke-Heist",
"3550":"Heusden-Zolder","2800":"Mechelen","3680":"Maaseik","8000":"Brugge",
"3800":"Sint-Truiden","8430":"Middelkerke","3300":"Tienen","8420":"De Haan"}

def is_num(s):
    return s.isdigit()

def bucket(p):
    return math.ceil(p/50000)*50000

def blab(v):
    if v < 1_000_000: return f"<={v//1000}k"
    s = f"{v/1_000_000:.2f}".rstrip("0").rstrip(".")
    return f"<={s}M"

# Aggregate.
per_pc = {}          # pc -> {bucket: views}
priced_total = {}    # pc -> sum of numeric-priced views (>0)
onrequest = {}       # pc -> views with price 0
noprice = {}         # pc -> views with (not set)/blank
for pc, price, views in rows:
    if pc in ("(not set)", ""):
        continue
    if not is_num(price):
        noprice[pc] = noprice.get(pc, 0) + views
        continue
    p = int(price)
    if p <= 0:
        onrequest[pc] = onrequest.get(pc, 0) + views
        continue
    per_pc.setdefault(pc, {})
    b = bucket(p)
    per_pc[pc][b] = per_pc[pc].get(b, 0) + views
    priced_total[pc] = priced_total.get(pc, 0) + views

# --- Raw distribution CSV (the query result) ---
with open(os.path.join(OUT, "02-raw-price-views-per-postcode.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f); w.writerow(["postcode","place","price","views"])
    for pc, price, views in sorted(rows, key=lambda x: (x[0], -x[2])):
        if pc in ("(not set)", ""): continue
        w.writerow([pc, PLACES.get(pc, ""), price, views])

# --- Full bracket distribution for the 20 focus postcodes, ranked by priced views ---
ALL_BUCKETS = [150000,200000,250000,300000,350000,400000,450000,500000,
               600000,750000,1000000,1500000,2000000,3000000,5000000]
focus = sorted(PLACES, key=lambda pc: -priced_total.get(pc, 0))
with open(os.path.join(OUT, "03-brackets-full.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["rank","postcode","place","priced_views","on_request_views","no_price_views"]
               + [blab(b) for b in ALL_BUCKETS])
    for i, pc in enumerate(focus, 1):
        b = per_pc.get(pc, {})
        # fold anything above the largest named bucket into the last column
        row = [i, pc, PLACES[pc], priced_total.get(pc,0), onrequest.get(pc,0), noprice.get(pc,0)]
        named = set(ALL_BUCKETS)
        for bk in b:
            if bk not in named:
                # round up to nearest listed bucket
                for cand in ALL_BUCKETS:
                    if bk <= cand:
                        b[cand] = b.get(cand,0)+0
                        break
        row += [b.get(bk, 0) for bk in ALL_BUCKETS]
        w.writerow(row)

# --- Top 5 brackets per postcode (exact), mirrors earlier deliverable ---
with open(os.path.join(OUT, "04-brackets-top5.csv"), "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["rank","postcode","place","priced_views",
                "bracket_1","views_1","bracket_2","views_2","bracket_3","views_3",
                "bracket_4","views_4","bracket_5","views_5"])
    for i, pc in enumerate(focus, 1):
        b = per_pc.get(pc, {})
        top = sorted(b.items(), key=lambda x: -x[1])[:5]
        row = [i, pc, PLACES[pc], priced_total.get(pc,0)]
        for bk, cv in top: row += [blab(bk), cv]
        w.writerow(row)

print("focus postcodes priced-view coverage check (priced / (priced+onreq+noprice)):")
for pc in focus[:5]:
    tot = priced_total.get(pc,0)+onrequest.get(pc,0)+noprice.get(pc,0)
    print(f"  {pc} {PLACES[pc]}: priced={priced_total.get(pc,0)} onreq={onrequest.get(pc,0)} noprice={noprice.get(pc,0)}")
print("wrote 02-raw, 03-brackets-full, 04-brackets-top5")
