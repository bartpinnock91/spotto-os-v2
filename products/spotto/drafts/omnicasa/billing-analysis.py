"""
Billing analysis: determine billable vestigingen per Omnicasa group.

Flow:
1. Load CSV rows
2. Group by BrokerId (aggregates across multiple SpottoIds/Names)
3. Exclude Ceusters (separate system)
4. Filter: group has >=1 publication
5. KBO validation: collect all unique KBOs per group, validate via CBEAPI
6. Count publishing offices per group (ActivePublications > 0)
7. Sum KBO vestigingen across all KBOs in the group
8. Billable = total KBO vestigingen (if group is active, all establishments count)

Usage: python billing-analysis.py [QUARTER]
"""

import argparse
import csv
import re
from collections import defaultdict
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("quarter", nargs="?", default="Q3")
args = parser.parse_args()

QUARTER = args.quarter

CSV_PATH = Path(__file__).parent / f"omnicasa-{QUARTER}.csv"
KBO_REPORT_PATH = Path(__file__).parent / "kbo-validation-report.csv"
OUTPUT_PATH = Path(__file__).parent / f"omnicasa-{QUARTER.lower()}-facturatie.csv"

SUSPECTED_PLACEHOLDER = "0867858802"

EXCLUDE_BROKERS = set()  # Ceusters was previously excluded (separate system) but is now counted

# No deactivation list — activity per quarter determines billing.
# If a group publishes, they count. If not, they don't.


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

    # Step 1: Load CSV
    raw_rows = []
    with open(CSV_PATH, "r", encoding="utf-8-sig") as f:
        raw_rows = list(csv.DictReader(f))

    print(f"Stap 1: {len(raw_rows)} rijen geladen")

    # Step 2: Group by BrokerId (aggregates across SpottoIds/Names)
    broker_groups = defaultdict(list)
    for r in raw_rows:
        bid = r.get("BrokerId", "").strip()
        broker_groups[bid].append(r)

    print(f"Stap 2: {len(raw_rows)} rijen -> {len(broker_groups)} groepen (per BrokerId)")

    # Step 3: Exclude Ceusters
    exclude_bids = set()
    for bid, rows in broker_groups.items():
        names = {r.get("Name", "").strip() for r in rows}
        if names & EXCLUDE_BROKERS:
            exclude_bids.add(bid)
    for bid in exclude_bids:
        del broker_groups[bid]

    print(f"Stap 3: Na uitsluiting -> {len(broker_groups)} groepen")

    # Process each group
    output_rows = []
    total_billable = 0
    total_groups_billable = 0
    total_no_pubs = 0
    total_no_kbo = 0

    for bid, group_rows in sorted(broker_groups.items(), key=lambda x: int(x[0])):
        # Pick the most common name, or the one with publications
        names = [r.get("Name", "").strip() for r in group_rows]
        group_name = max(set(names), key=names.count)

        # Deduplicate offices: unique (BrokerId, OfficeId) pairs
        # but keep all rows for publication counting across SpottoIds
        seen_offices = set()
        unique_offices = []
        for r in group_rows:
            office_key = (r.get("BrokerId", "").strip(), r.get("OfficeId", "").strip())
            if office_key not in seen_offices:
                seen_offices.add(office_key)
                unique_offices.append(r)

        num_offices = len(unique_offices)

        # Total publications: max of TotalCustomerActivePublications across all rows
        total_pubs = max(
            int(r.get("TotalCustomerActivePublications", "0") or "0")
            for r in group_rows
        )

        # Publishing offices: count unique offices that have ActivePublications > 0
        # across ANY SpottoId (an office might show 0 under one SpottoId but >0 under another)
        office_pubs = defaultdict(int)
        for r in group_rows:
            oid = r.get("OfficeId", "").strip()
            pubs = int(r.get("ActivePublications", "0") or "0")
            office_pubs[oid] = max(office_pubs[oid], pubs)
        num_publishing = sum(1 for p in office_pubs.values() if p > 0)

        # Collect all unique KBO numbers for this group (excluding placeholder)
        kbos = set()
        for r in group_rows:
            kbo = normalize_kbo(r.get("OrganisationNumber", ""))
            if kbo and len(kbo) == 10 and kbo != SUSPECTED_PLACEHOLDER:
                kbos.add(kbo)

        # Filter on publications
        if total_pubs == 0:
            total_no_pubs += 1
            output_rows.append({
                "groep": group_name,
                "broker_id": bid,
                "kantoren_csv": num_offices,
                "publicerende_kantoren": 0,
                "total_publicaties": total_pubs,
                "kbo_nummers": ";".join(sorted(kbos)),
                "kbo_status": "",
                "kbo_vestigingen": "",
                "factureerbaar": 0,
                "reden": "GEEN_PUBLICATIES",
                "detail": "",
            })
            continue

        if not kbos:
            total_no_kbo += 1
            output_rows.append({
                "groep": group_name,
                "broker_id": bid,
                "kantoren_csv": num_offices,
                "publicerende_kantoren": num_publishing,
                "total_publicaties": total_pubs,
                "kbo_nummers": "",
                "kbo_status": "GEEN_KBO",
                "kbo_vestigingen": "",
                "factureerbaar": 0,
                "reden": "GEEN_KBO",
                "detail": "Geen geldig KBO-nummer in CSV",
            })
            continue

        # KBO validation: sum vestigingen across all KBOs
        total_kbo_vest = 0
        kbo_details = []
        all_found = True
        for kbo in sorted(kbos):
            kbo_info = kbo_data.get(kbo, {})
            kbo_found = kbo_info.get("kbo_found", "NO")
            if kbo_found != "YES":
                all_found = False
                kbo_details.append(f"{kbo}: niet gevonden")
            else:
                vest = int(kbo_info.get("num_establishments_kbo", "0") or "0")
                legal_name = kbo_info.get("legal_name", "")
                total_kbo_vest += vest
                kbo_details.append(f"{kbo}: {legal_name} ({vest} vest.)")

        if not all_found and total_kbo_vest == 0:
            total_no_kbo += 1
            output_rows.append({
                "groep": group_name,
                "broker_id": bid,
                "kantoren_csv": num_offices,
                "publicerende_kantoren": num_publishing,
                "total_publicaties": total_pubs,
                "kbo_nummers": ";".join(sorted(kbos)),
                "kbo_status": "NIET_GEVONDEN",
                "kbo_vestigingen": "",
                "factureerbaar": 0,
                "reden": "KBO_NIET_GEVONDEN",
                "detail": "; ".join(kbo_details),
            })
            continue

        # Billable = total KBO vestigingen (group is active, so all establishments count)
        billable = max(total_kbo_vest, 1)  # at least 1 if group publishes

        detail = "; ".join(kbo_details)

        total_billable += billable
        total_groups_billable += 1

        output_rows.append({
            "groep": group_name,
            "broker_id": bid,
            "kantoren_csv": num_offices,
            "publicerende_kantoren": num_publishing,
            "total_publicaties": total_pubs,
            "kbo_nummers": ";".join(sorted(kbos)),
            "kbo_status": "FACTUREERBAAR",
            "kbo_vestigingen": total_kbo_vest,
            "factureerbaar": billable,
            "reden": "FACTUREERBAAR",
            "detail": detail,
        })

    # Write output
    fieldnames = [
        "groep", "broker_id", "kantoren_csv", "publicerende_kantoren",
        "total_publicaties", "kbo_nummers", "kbo_status", "kbo_vestigingen",
        "factureerbaar", "reden", "detail",
    ]

    with open(OUTPUT_PATH, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(output_rows)

    # Summary
    print()
    print("=" * 60)
    print(f"FACTURATIE-ANALYSE {QUARTER}")
    print("=" * 60)
    print()
    print(f"Totaal groepen:              {len(broker_groups)}")
    print(f"  Factureerbaar:             {total_groups_billable}")
    print(f"  Geen publicaties:          {total_no_pubs}")
    print(f"  Geen geldig KBO:           {total_no_kbo}")
    print()
    print(f"Factureerbare vestigingen:   {total_billable}")
    print(f"Per maand:                   EUR {total_billable * 15:,.2f}")
    print(f"Per trimester:               EUR {total_billable * 15 * 3:,.2f}")
    print(f"Per jaar:                    EUR {total_billable * 15 * 12:,.2f}")
    print()
    print(f"Rapport: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
