"""
Billing analysis: determine billable vestigingen per Omnicasa group.

Flow:
1. Deduplication: CSV rows -> unique (BrokerId, OfficeId) pairs
2. Group by Name
3. Exclude Ceusters (separate system)
4. Filter: group has >=1 publication
5. KBO validation: group has valid KBO (confirmed via CBEAPI), not on deactivation list
6. Count publishing offices per group (ActivePublications > 0)
7. Get KBO vestigingen count
8. Billable depends on mode:
   - conservative: min(publishing offices, KBO vestigingen)
   - full_kbo: all KBO vestigingen (if group publishes)

Usage: python billing-analysis.py [QUARTER] [--mode conservative|full_kbo]
"""

import argparse
import csv
import re
from collections import defaultdict
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("quarter", nargs="?", default="Q3")
parser.add_argument("--mode", choices=["conservative", "full_kbo"], default="conservative")
args = parser.parse_args()

QUARTER = args.quarter
MODE = args.mode

CSV_PATH = Path(__file__).parent / f"omnicasa-{QUARTER}.csv"
KBO_REPORT_PATH = Path(__file__).parent / "kbo-validation-report.csv"
OUTPUT_PATH = Path(__file__).parent / f"omnicasa-{QUARTER.lower()}-facturatie-{MODE}.csv"

SUSPECTED_PLACEHOLDER = "0867858802"

EXCLUDE_BROKERS = {"Ceusters"}  # separate system

DEACTIVATE_KBOS = {
    "0406536106", "0452592793", "0452704542", "0455544464", "0457089635",
    "0458086359", "0465774105", "0466188433", "0506747004", "0651619571",
    "0658808063", "0661991148", "0721552316", "0730572920", "0738256706",
    "0807453833", "0818032771", "0825272337", "0830139559", "0841642769",
    "0845303134", "0879821771", "0892088016", "0892301515", "0897570395",
    "0428342102", "0873376815",
}


def normalize_kbo(raw: str) -> str:
    if not raw:
        return ""
    cleaned = re.sub(r"[\u200b\u200c\u200d\ufeff]", "", raw)
    cleaned = re.sub(r"^BE\s*", "", cleaned, flags=re.IGNORECASE)
    cleaned = re.sub(r"^[A-Z]{2}\s+", "", cleaned)
    cleaned = re.sub(r"[^0-9]", "", cleaned)
    if len(cleaned) == 9:
        cleaned = "0" + cleaned
    return cleaned


def main():
    # Load KBO validation results
    kbo_data = {}
    with open(KBO_REPORT_PATH, "r", encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            kbo_data[row["kbo_number"]] = row

    # Step 1: Load CSV and deduplicate on (BrokerId, OfficeId)
    raw_rows = []
    with open(CSV_PATH, "r", encoding="utf-8-sig") as f:
        raw_rows = list(csv.DictReader(f))

    seen = set()
    offices = []  # deduplicated
    for r in raw_rows:
        key = (r.get("BrokerId", "").strip(), r.get("OfficeId", "").strip())
        if key not in seen:
            seen.add(key)
            offices.append(r)

    print(f"Stap 1: {len(raw_rows)} rijen -> {len(offices)} unieke kantoren")

    # Step 2: Group by Name
    groups = defaultdict(list)
    for r in offices:
        name = r.get("Name", "").strip()
        groups[name].append(r)

    print(f"Stap 2: {len(offices)} kantoren -> {len(groups)} groepen")

    # Step 3: Exclude Ceusters
    for excl in EXCLUDE_BROKERS:
        if excl in groups:
            del groups[excl]

    print(f"Stap 3: Na uitsluiting -> {len(groups)} groepen")

    # Process each group
    output_rows = []
    total_billable = 0
    total_groups_billable = 0
    total_no_pubs = 0
    total_no_kbo = 0
    total_deactivated = 0

    for name, group_offices in sorted(groups.items()):
        bid = group_offices[0].get("BrokerId", "").strip()
        total_pubs = max(
            int(r.get("TotalCustomerActivePublications", "0") or "0")
            for r in group_offices
        )
        num_offices = len(group_offices)

        # Collect KBO numbers for this group (excluding placeholder)
        kbos = set()
        for r in group_offices:
            kbo = normalize_kbo(r.get("OrganisationNumber", ""))
            if kbo and len(kbo) == 10 and kbo != SUSPECTED_PLACEHOLDER:
                kbos.add(kbo)

        primary_kbo = sorted(kbos)[0] if kbos else ""

        # Step 4: Filter on publications
        if total_pubs == 0:
            total_no_pubs += 1
            output_rows.append({
                "groep": name,
                "broker_id": bid,
                "kantoren_csv": num_offices,
                "publicerende_kantoren": 0,
                "total_publicaties": total_pubs,
                "kbo_nummer": primary_kbo,
                "kbo_status": "",
                "kbo_vestigingen": "",
                "factureerbaar": 0,
                "reden": "GEEN_PUBLICATIES",
                "detail": "",
            })
            continue

        # Step 5: KBO validation
        # Count publishing offices
        publishing = [
            r for r in group_offices
            if int(r.get("ActivePublications", "0") or "0") > 0
        ]
        num_publishing = len(publishing)

        if not primary_kbo:
            total_no_kbo += 1
            output_rows.append({
                "groep": name,
                "broker_id": bid,
                "kantoren_csv": num_offices,
                "publicerende_kantoren": num_publishing,
                "total_publicaties": total_pubs,
                "kbo_nummer": "",
                "kbo_status": "GEEN_KBO",
                "kbo_vestigingen": "",
                "factureerbaar": 0,
                "reden": "GEEN_KBO",
                "detail": "Geen geldig KBO-nummer in CSV",
            })
            continue

        # Check if KBO is on deactivation list
        if primary_kbo in DEACTIVATE_KBOS:
            total_deactivated += 1
            output_rows.append({
                "groep": name,
                "broker_id": bid,
                "kantoren_csv": num_offices,
                "publicerende_kantoren": num_publishing,
                "total_publicaties": total_pubs,
                "kbo_nummer": primary_kbo,
                "kbo_status": "GEDEACTIVEERD",
                "kbo_vestigingen": "",
                "factureerbaar": 0,
                "reden": "GEDEACTIVEERD",
                "detail": "Op deactivatielijst",
            })
            continue

        # Check KBO validation result
        kbo_info = kbo_data.get(primary_kbo, {})
        kbo_found = kbo_info.get("kbo_found", "NO")

        if kbo_found != "YES":
            total_no_kbo += 1
            output_rows.append({
                "groep": name,
                "broker_id": bid,
                "kantoren_csv": num_offices,
                "publicerende_kantoren": num_publishing,
                "total_publicaties": total_pubs,
                "kbo_nummer": primary_kbo,
                "kbo_status": "NIET_GEVONDEN",
                "kbo_vestigingen": "",
                "factureerbaar": 0,
                "reden": "KBO_NIET_GEVONDEN",
                "detail": "KBO-nummer niet gevonden in register",
            })
            continue

        # Steps 6-8: Count and determine billable
        num_kbo_vest = int(kbo_info.get("num_establishments_kbo", "0") or "0")
        legal_name = kbo_info.get("legal_name", "")

        if MODE == "full_kbo":
            billable = max(num_kbo_vest, 1)  # at least 1 if group publishes
            detail = ""
            if num_kbo_vest > num_publishing:
                detail = f"{num_kbo_vest} KBO-vestigingen, {num_publishing} publiceren"
            elif num_publishing > num_kbo_vest:
                detail = f"{num_publishing} kantoren publiceren, {num_kbo_vest} KBO-vestigingen"
        else:  # conservative
            billable = min(num_publishing, num_kbo_vest)
            if billable == 0 and total_pubs > 0:
                billable = 1
            detail = ""
            if num_publishing > num_kbo_vest:
                detail = f"{num_publishing} kantoren publiceren, afgetopt op {num_kbo_vest} KBO-vestigingen"
            elif num_kbo_vest > num_publishing:
                detail = f"{num_kbo_vest} KBO-vestigingen, {num_publishing} publiceren"

        total_billable += billable
        total_groups_billable += 1

        output_rows.append({
            "groep": name,
            "broker_id": bid,
            "kantoren_csv": num_offices,
            "publicerende_kantoren": num_publishing,
            "total_publicaties": total_pubs,
            "kbo_nummer": primary_kbo,
            "kbo_status": f"ACTIEF ({legal_name})",
            "kbo_vestigingen": num_kbo_vest,
            "factureerbaar": billable,
            "reden": "FACTUREERBAAR",
            "detail": detail,
        })

    # Write output
    fieldnames = [
        "groep", "broker_id", "kantoren_csv", "publicerende_kantoren",
        "total_publicaties", "kbo_nummer", "kbo_status", "kbo_vestigingen",
        "factureerbaar", "reden", "detail",
    ]

    with open(OUTPUT_PATH, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(output_rows)

    # Summary
    mode_label = "alle KBO-vestigingen" if MODE == "full_kbo" else "min(publicerend, KBO)"
    print()
    print("=" * 60)
    print(f"FACTURATIE-ANALYSE {QUARTER} ({mode_label})")
    print("=" * 60)
    print()
    print(f"Totaal groepen:              {len(groups)}")
    print(f"  Factureerbaar:             {total_groups_billable}")
    print(f"  Geen publicaties:          {total_no_pubs}")
    print(f"  Geen geldig KBO:           {total_no_kbo}")
    print(f"  Gedeactiveerd:             {total_deactivated}")
    print()
    print(f"Factureerbare vestigingen:   {total_billable}")
    print(f"Per maand:                   EUR {total_billable * 15:,.2f}")
    print(f"Per trimester:               EUR {total_billable * 15 * 3:,.2f}")
    print(f"Per jaar:                    EUR {total_billable * 15 * 12:,.2f}")
    print()
    print(f"Rapport: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
