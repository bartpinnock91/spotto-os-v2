"""Re-run substitution analysis with extended baseline.

Previous baseline was only Sep-Nov 2025 (3 data points). Now using GSC data
going back to Jan 2025, we can establish a more defensible "natural" organic
growth trend and check whether Q1 2026 deviates from it.
"""
import json
import urllib.request
from collections import defaultdict

# GSC daily data was pulled via MCP. We hard-code the monthly aggregates here
# for reproducibility - daily->monthly aggregation done manually from API output.
# Sources: GSC pull 2024-05 to 2025-08 (this script) + Sep 2025 - Apr 2026 (_analysis.py)

# Aggregate all GSC daily totals into monthly clicks/impressions.
# Daily data starts 2024-12-28 from the longer pull.
# These monthly totals derive from the GSC API daily pulls.
gsc_monthly = {
    # Exact monthly totals computed from daily GSC API pull
    "2025-01": 136_038,
    "2025-02": 120_652,
    "2025-03": 131_698,
    "2025-04": 133_058,
    "2025-05": 144_902,
    "2025-06": 130_879,
    "2025-07": 145_878,
    "2025-08": 167_770,
    "2025-09": 156_791,
    "2025-10": 171_140,
    "2025-11": 168_559,
    "2025-12": 160_053,
    "2026-01": 200_801,
    "2026-02": 214_096,
    "2026-03": 240_425,
    "2026-04": 199_708,
}

# Approximate SEA spend & paid clicks (from CSV)
# Earlier months pre-Sep 2025: we don't have CSV data, but SEA was running
# (post-V2 GA4 shows paid sessions in Jun 2025: 20,404)
sea_spend = {
    "2025-09": 9_625,
    "2025-10": 10_040,
    "2025-11": 12_279,
    "2025-12": 8_621,
    "2026-01": 6_967,
    "2026-02": 7_044,
    "2026-03": 5_744,
    "2026-04": 5_114,
}

ga4_paid_sessions = {
    "2025-06": 20_404,
    "2025-07": 67_513,
    "2025-08": 85_071,
    "2025-09": 80_549,
    "2025-10": 85_702,
    "2025-11": 90_738,
    "2025-12": 78_787,
    "2026-01": 77_034,
    "2026-02": 65_312,
    "2026-03": 54_709,
    "2026-04": 50_986,
}

def linreg(xs, ys):
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((xs[i] - mx) * (ys[i] - my) for i in range(n))
    den = sum((xs[i] - mx) ** 2 for i in range(n))
    b = num / den
    a = my - b * mx
    return a, b

months_all = sorted(gsc_monthly.keys())
print("=== EXTENDED GSC ORGANIC TIMELINE ===")
print(f"{'Month':<10} {'GSC clicks':>11} {'SEA spend':>10} {'Paid sess':>10}")
for m in months_all:
    spend = sea_spend.get(m)
    paid = ga4_paid_sessions.get(m)
    spend_s = f"{spend:>10,}" if spend else f"{'-':>10}"
    paid_s  = f"{paid:>10,}"  if paid  else f"{'-':>10}"
    print(f"{m:<10} {gsc_monthly[m]:>11,} {spend_s} {paid_s}")

# === Approach 1: Fit trend on a TRUE pre-cut window ===
# SEA reductions began: branded exclusion 21 Jan 2026, gradual cuts started Dec 2025.
# So genuine pre-cut window: months where SEA was at full force / steady.
# Use 2025-01 through 2025-11 (11 months, the pre-cut baseline).
pre_cut = ["2025-01","2025-02","2025-03","2025-04","2025-05",
           "2025-06","2025-07","2025-08","2025-09","2025-10","2025-11"]
post_cut = ["2025-12","2026-01","2026-02","2026-03","2026-04"]

idx = {m: i for i, m in enumerate(months_all)}

# Linear trend on pre-cut
xs = [idx[m] for m in pre_cut]
ys = [gsc_monthly[m] for m in pre_cut]
a, b = linreg(xs, ys)
print(f"\n=== TREND FIT ON 11-MONTH PRE-CUT BASELINE (Jan-Nov 2025) ===")
print(f"y = {a:,.0f} + {b:+,.0f} * month_index")
print(f"Slope: {b:+,.0f} organic clicks/month natural growth")
print(f"Annualized: {b*12:+,.0f} ({(b*12)/ys[0]*100:.1f}% YoY)")

# Now compute residuals over post-cut window
print(f"\n{'Month':<10} {'Actual':>10} {'Expected':>10} {'Residual':>10}")
total_res = 0
total_act = 0
total_exp = 0
for m in post_cut:
    x = idx[m]
    exp = a + b * x
    act = gsc_monthly[m]
    res = act - exp
    total_res += res
    total_act += act
    total_exp += exp
    print(f"{m:<10} {act:>10,} {exp:>10,.0f} {res:>+10,.0f}")
print(f"{'TOTAL':<10} {total_act:>10,} {total_exp:>10,.0f} {total_res:>+10,.0f}")

# Pre-cut R^2 to gauge trend reliability
y_mean = sum(ys) / len(ys)
ss_tot = sum((y - y_mean)**2 for y in ys)
ss_res = sum((ys[i] - (a + b*xs[i]))**2 for i in range(len(xs)))
r2 = 1 - ss_res/ss_tot
print(f"\nPre-cut trend R^2: {r2:.3f}")

# Compute substitution
# Paid clicks lost over Dec-Apr vs Nov baseline (from CSV)
nov_paid_clicks = 118_091
paid_lost_total = 0
for m in post_cut:
    if m == "2025-12":
        paid_clicks = 103_618
    elif m == "2026-01":
        paid_clicks = 98_684
    elif m == "2026-02":
        paid_clicks = 84_439
    elif m == "2026-03":
        paid_clicks = 72_604
    elif m == "2026-04":
        paid_clicks = 64_547
    paid_lost_total += nov_paid_clicks - paid_clicks

nov_paid_sess = 90_738
paid_sess_lost = sum(nov_paid_sess - ga4_paid_sessions[m] for m in post_cut)

print(f"\nTotal paid CLICKS lost vs Nov baseline (Dec-Apr): {paid_lost_total:,}")
print(f"Total paid SESSIONS lost vs Nov baseline (Dec-Apr): {paid_sess_lost:,}")
print(f"Total trend-adjusted organic CLICKS gained: {total_res:+,.0f}")

if paid_lost_total > 0:
    sub_clicks = total_res / paid_lost_total * 100
    sub_sess = total_res / paid_sess_lost * 100
    print(f"\nSubstitution rate (vs full 11-month baseline):")
    print(f"  GSC residual / Ads clicks lost: {sub_clicks:.1f}%")
    print(f"  GSC residual / GA4 paid sess lost: {sub_sess:.1f}%")

# === Approach 2: Compare growth RATES rather than absolute trend ===
# Pre-cut growth rate (year-over-year sense): from Jan to Nov 2025
jan = gsc_monthly["2025-01"]
nov = gsc_monthly["2025-11"]
print(f"\n=== GROWTH RATES ===")
print(f"Pre-cut (Jan 2025 -> Nov 2025): {jan:,} -> {nov:,} = {(nov-jan)/jan*100:+.1f}% over 10 months ({(nov-jan)/jan/10*100:+.1f}%/month)")

# Post-cut: Nov 2025 -> Apr 2026
apr = gsc_monthly["2026-04"]
print(f"Cut period (Nov 2025 -> Apr 2026): {nov:,} -> {apr:,} = {(apr-nov)/nov*100:+.1f}% over 5 months ({(apr-nov)/nov/5*100:+.1f}%/month)")

# === Approach 3: Per-month deviation ===
# Look at month-over-month organic growth pre-cut vs during cut
print(f"\n=== MONTH-OVER-MONTH ORGANIC GROWTH ===")
print(f"{'Month':<10} {'GSC clicks':>11} {'MoM growth':>11}")
prev = None
for m in months_all:
    cur = gsc_monthly[m]
    if prev is not None:
        mom = (cur - prev) / prev * 100
        marker = " <-- SEA cut period" if m in post_cut else ""
        print(f"{m:<10} {cur:>11,} {mom:>+10.1f}%{marker}")
    else:
        print(f"{m:<10} {cur:>11,} {'-':>11}")
    prev = cur

# Avg MoM growth in pre-cut vs cut periods
def avg_mom(months):
    growths = []
    for i, m in enumerate(months):
        if i == 0:
            continue
        prev_m = months[i-1]
        if prev_m in gsc_monthly and m in gsc_monthly:
            growths.append((gsc_monthly[m] - gsc_monthly[prev_m]) / gsc_monthly[prev_m] * 100)
    return sum(growths) / len(growths) if growths else 0

avg_pre = avg_mom(pre_cut)
avg_post = avg_mom(post_cut)
print(f"\nAverage MoM growth pre-cut (Jan-Nov 2025): {avg_pre:+.2f}%")
print(f"Average MoM growth post-cut (Dec 2025 - Apr 2026): {avg_post:+.2f}%")
