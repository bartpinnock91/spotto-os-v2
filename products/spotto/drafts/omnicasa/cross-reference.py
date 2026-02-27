"""
Cross-reference Omnicasa offices (with addresses) against KBO vestigingseenheden.

Uses the detailed office data from Omnicasa API and KBO validation results
to match offices by city and postal code.
"""

import csv
import re
from pathlib import Path

OMNICASA_OFFICES_PATH = Path(__file__).parent / "omnicasa-offices-detailed.csv"
KBO_REPORT_PATH = Path(__file__).parent / "kbo-validation-report.csv"
OMNICASA_CSV_PATH = Path(__file__).parent / "omnicasa-Q3.csv"
OUTPUT_PATH = Path(__file__).parent / "cross-reference-report.csv"

SUSPECTED_PLACEHOLDER = "0867858802"


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


def normalize_city(text: str) -> str:
    text = text.lower().strip()
    text = re.sub(r"\([^)]*\)", "", text)
    text = re.sub(r"[^a-z0-9\s]", "", text)
    return text.strip()


def parse_kbo_establishments(est_str: str) -> list[dict]:
    """Parse '2064850777: Keizersplein 71, Aalst | ...' into structured list."""
    results = []
    if not est_str:
        return results
    for est in est_str.split(" | "):
        est_num = ""
        street = ""
        city = ""
        if ":" in est:
            est_num, rest = est.split(":", 1)
            est_num = est_num.strip()
            rest = rest.strip()
        else:
            rest = est

        if "," in rest:
            street, city = rest.rsplit(",", 1)
            street = street.strip()
            city = city.strip()
        else:
            street = rest

        results.append({
            "est_num": est_num,
            "street": street,
            "city": city,
            "raw": est,
            "matched": False,
        })
    return results


def cities_match(city1: str, city2: str) -> bool:
    """Fuzzy city matching."""
    c1 = normalize_city(city1)
    c2 = normalize_city(city2)
    if not c1 or not c2:
        return False
    if c1 == c2:
        return True
    if c1 in c2 or c2 in c1:
        return True
    # Check main word (first significant word)
    words1 = [w for w in c1.split() if len(w) > 3]
    words2 = [w for w in c2.split() if len(w) > 3]
    for w1 in words1:
        for w2 in words2:
            if w1 == w2:
                return True
    return False


def main():
    # 1. Load KBO validation results indexed by KBO number
    kbo_data = {}
    with open(KBO_REPORT_PATH, "r", encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            kbo_data[row["kbo_number"]] = row

    # 2. Load Omnicasa detailed offices
    omni_offices = {}  # customer_id -> list of office dicts
    with open(OMNICASA_OFFICES_PATH, "r", encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            cid = row["customer_id"]
            if cid not in omni_offices:
                omni_offices[cid] = []
            omni_offices[cid].append(row)

    # 3. Load original CSV for broker-level info and per-office publication counts
    broker_info = {}  # broker_id -> {name, kbos, total_pubs, status}
    office_pubs = {}  # (broker_id, office_id) -> active_publications
    with open(OMNICASA_CSV_PATH, "r", encoding="utf-8-sig") as f:
        for row in csv.DictReader(f):
            bid = row.get("BrokerId", "").strip()
            oid = row.get("OfficeId", "").strip()
            if bid not in broker_info:
                broker_info[bid] = {
                    "name": row.get("Name", "").strip(),
                    "kbos": set(),
                    "total_pubs": int(row.get("TotalCustomerActivePublications", "0") or "0"),
                    "status": set(),
                }
            kbo = normalize_kbo(row.get("OrganisationNumber", ""))
            if kbo and len(kbo) == 10 and kbo != SUSPECTED_PLACEHOLDER:
                broker_info[bid]["kbos"].add(kbo)
            broker_info[bid]["status"].add(row.get("status", "").strip())
            office_pubs[(bid, oid)] = int(row.get("ActivePublications", "0") or "0")

    # Helper to look up office publications
    def get_office_pubs(broker_id: str, office_id: str) -> int:
        return office_pubs.get((broker_id, office_id), 0)

    # 4. Cross-reference: for each customer, match offices to KBO vestigingen
    output_rows = []

    for cid, offices in sorted(omni_offices.items(), key=lambda x: x[0]):
        binfo = broker_info.get(cid, {})
        broker_name = binfo.get("name", offices[0].get("customer_name", ""))
        kbos = binfo.get("kbos", set())
        total_pubs = binfo.get("total_pubs", 0)
        broker_status = " / ".join(sorted(binfo.get("status", set()))) if binfo else ""

        # Get primary KBO (most offices share one)
        vat_from_api = set()
        for o in offices:
            vat = normalize_kbo(o.get("vat_number", ""))
            if vat and len(vat) == 10 and vat != SUSPECTED_PLACEHOLDER:
                vat_from_api.add(vat)

        all_kbos = kbos | vat_from_api

        if not all_kbos:
            # No KBO at all
            for o in offices:
                oid = o.get("office_id", "")
                output_rows.append({
                    "broker_name": broker_name,
                    "broker_id": cid,
                    "total_publications": total_pubs,
                    "office_publications": get_office_pubs(cid, oid),
                    "broker_status": broker_status,
                    "kbo_number": "",
                    "kbo_legal_name": "",
                    "kbo_status": "NO KBO",
                    "omni_office_id": oid,
                    "omni_office_name": o.get("office_name", ""),
                    "omni_city": o.get("city", ""),
                    "omni_postal": o.get("postal_code", ""),
                    "omni_street": f"{o.get('street', '')} {o.get('street_number', '')}".strip(),
                    "omni_vat": o.get("vat_number", ""),
                    "matched_kbo_vestiging": "",
                    "match_type": "NO_KBO",
                    "kbo_all_vestigingen": "",
                })
            continue

        for kbo in sorted(all_kbos):
            kbo_info = kbo_data.get(kbo, {})
            kbo_found = kbo_info.get("kbo_found", "NO")
            legal_name = kbo_info.get("legal_name", "")
            est_str = kbo_info.get("establishments_kbo", "")

            kbo_ests = parse_kbo_establishments(est_str)

            # Get offices that belong to this KBO
            kbo_offices = [
                o for o in offices
                if normalize_kbo(o.get("vat_number", "")) == kbo
            ]
            # If no direct VAT match, and this is the only KBO, assign all offices
            if not kbo_offices and len(all_kbos) == 1:
                kbo_offices = offices

            if kbo_found != "YES":
                for o in kbo_offices:
                    oid = o.get("office_id", "")
                    output_rows.append({
                        "broker_name": broker_name,
                        "broker_id": cid,
                        "total_publications": total_pubs,
                        "office_publications": get_office_pubs(cid, oid),
                        "broker_status": broker_status,
                        "kbo_number": kbo,
                        "kbo_legal_name": "",
                        "kbo_status": "NOT FOUND",
                        "omni_office_id": oid,
                        "omni_office_name": o.get("office_name", ""),
                        "omni_city": o.get("city", ""),
                        "omni_postal": o.get("postal_code", ""),
                        "omni_street": f"{o.get('street', '')} {o.get('street_number', '')}".strip(),
                        "omni_vat": o.get("vat_number", ""),
                        "matched_kbo_vestiging": "",
                        "match_type": "KBO_NOT_FOUND",
                        "kbo_all_vestigingen": est_str,
                    })
                continue

            # Match offices to vestigingen by city
            for o in kbo_offices:
                omni_city = o.get("city", "").strip()
                match_type = "NO_MATCH"
                matched_est = ""

                if not omni_city:
                    match_type = "NO_CITY"
                else:
                    for est in kbo_ests:
                        if est["matched"]:
                            continue
                        if cities_match(omni_city, est["city"]):
                            matched_est = est["raw"]
                            est["matched"] = True
                            match_type = "CITY_MATCH"
                            break

                    # If no city match, still try
                    if match_type == "NO_MATCH":
                        # Check if there's only 1 unmatched vestiging left
                        unmatched = [e for e in kbo_ests if not e["matched"]]
                        if len(unmatched) == 1 and len(kbo_offices) == 1:
                            matched_est = unmatched[0]["raw"]
                            unmatched[0]["matched"] = True
                            match_type = "ONLY_OPTION"

                oid = o.get("office_id", "")
                output_rows.append({
                    "broker_name": broker_name,
                    "broker_id": cid,
                    "total_publications": total_pubs,
                    "office_publications": get_office_pubs(cid, oid),
                    "broker_status": broker_status,
                    "kbo_number": kbo,
                    "kbo_legal_name": legal_name,
                    "kbo_status": "ACTIVE",
                    "omni_office_id": oid,
                    "omni_office_name": o.get("office_name", ""),
                    "omni_city": o.get("city", ""),
                    "omni_postal": o.get("postal_code", ""),
                    "omni_street": f"{o.get('street', '')} {o.get('street_number', '')}".strip(),
                    "omni_vat": o.get("vat_number", ""),
                    "matched_kbo_vestiging": matched_est,
                    "match_type": match_type,
                    "kbo_all_vestigingen": est_str,
                })

            # Append unmatched KBO vestigingen as extra rows
            unmatched_ests = [e for e in kbo_ests if not e["matched"]]
            for est in unmatched_ests:
                output_rows.append({
                    "broker_name": broker_name,
                    "broker_id": cid,
                    "total_publications": total_pubs,
                    "office_publications": "",
                    "broker_status": broker_status,
                    "kbo_number": kbo,
                    "kbo_legal_name": legal_name,
                    "kbo_status": "ACTIVE",
                    "omni_office_id": "",
                    "omni_office_name": "",
                    "omni_city": "",
                    "omni_postal": "",
                    "omni_street": "",
                    "omni_vat": "",
                    "matched_kbo_vestiging": est["raw"],
                    "match_type": "KBO_ONLY",
                    "kbo_all_vestigingen": est_str,
                })

    # 5. Write output
    fieldnames = [
        "broker_name", "broker_id", "total_publications", "office_publications", "broker_status",
        "kbo_number", "kbo_legal_name", "kbo_status",
        "omni_office_id", "omni_office_name", "omni_city", "omni_postal", "omni_street",
        "omni_vat",
        "matched_kbo_vestiging", "match_type",
        "kbo_all_vestigingen",
    ]

    with open(OUTPUT_PATH, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(output_rows)

    # 6. Summary
    from collections import Counter
    types = Counter(r["match_type"] for r in output_rows)

    print(f"{'='*60}")
    print(f"CROSS-REFERENCE SUMMARY")
    print(f"{'='*60}")
    print(f"Total rows:  {len(output_rows)}")
    print()
    for mt, count in sorted(types.items(), key=lambda x: -x[1]):
        print(f"  {mt:25s} {count}")
    print()
    print(f"Report: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
