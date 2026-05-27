"""
Validate KBO numbers from all omnicasa-YYYY-Q#.csv files against CBEAPI.be.
Produces a single report with legal status and registered vestigingseenheden,
covering every KBO ever seen across quarters.
"""

import csv
import json
import re
import time
import urllib.request
import urllib.error
from pathlib import Path

API_KEY = "P8U4OqzDDZ2v3WU8dyM9x16wwVYV8zX0"
API_BASE = "https://cbeapi.be/api/v1"
DATA_DIR = Path(__file__).parent
CSV_PATHS = sorted(DATA_DIR.glob("omnicasa-20*-Q*.csv"))
OUTPUT_PATH = DATA_DIR / "kbo-validation-report.csv"

SUSPECTED_PLACEHOLDER = "0867858802"


def normalize_kbo(raw: str) -> str:
    """Strip BE prefix, dots, spaces, dashes, zero-width chars and pad to 10 digits."""
    if not raw:
        return ""
    # Remove zero-width spaces and other unicode control chars
    cleaned = re.sub(r"[\u200b\u200c\u200d\ufeff]", "", raw)
    # Remove BE prefix
    cleaned = re.sub(r"^BE\s*", "", cleaned, flags=re.IGNORECASE)
    # Remove prefix codes like "HB " or "BO "
    cleaned = re.sub(r"^[A-Z]{2}\s+", "", cleaned)
    # Keep only digits
    cleaned = re.sub(r"[^0-9]", "", cleaned)
    # Pad to 10 digits if 9
    if len(cleaned) == 9:
        cleaned = "0" + cleaned
    return cleaned


def fetch_company(kbo_number: str, max_retries: int = 3) -> dict | None:
    """Call CBEAPI to get company data. Returns parsed JSON or None."""
    url = f"{API_BASE}/company/{kbo_number}"

    for attempt in range(max_retries):
        req = urllib.request.Request(url)
        req.add_header("Authorization", f"Bearer {API_KEY}")
        req.add_header("Accept", "application/json")
        req.add_header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")

        try:
            with urllib.request.urlopen(req, timeout=15) as resp:
                body = json.loads(resp.read().decode("utf-8"))
                return body.get("data", body)
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return None
            if e.code == 429:
                wait = 5 * (attempt + 1)
                print(f"  [rate limited, waiting {wait}s]", end="", flush=True)
                time.sleep(wait)
                continue
            print(f"  HTTP {e.code} for {kbo_number}: {e.reason}")
            return None
        except Exception as e:
            print(f"  Error for {kbo_number}: {e}")
            return None

    print(f"  [max retries exceeded]", end="")
    return None


def main():
    # 1. Parse all quarter CSVs and collect unique brokers with their KBO numbers
    brokers = {}  # kbo -> {names, offices_in_csv, raw_numbers, csv_statuses}
    empty_kbo_brokers = []

    print(f"Reading {len(CSV_PATHS)} quarter file(s): {[p.name for p in CSV_PATHS]}")
    for csv_path in CSV_PATHS:
        with open(csv_path, "r", encoding="utf-8-sig") as f:
            reader = csv.DictReader(f)
            for row in reader:
                raw = row.get("OrganisationNumber", "").strip()
                kbo = normalize_kbo(raw)
                broker_name = row.get("Name", "").strip()
                office_name = row.get("OfficeName", "").strip()
                status = row.get("status", "").strip()

                if not kbo or len(kbo) != 10:
                    empty_kbo_brokers.append(broker_name)
                    continue

                if kbo not in brokers:
                    brokers[kbo] = {
                        "names": set(),
                        "offices_in_csv": [],
                        "raw_numbers": set(),
                        "csv_statuses": set(),
                    }
                brokers[kbo]["names"].add(broker_name)
                brokers[kbo]["raw_numbers"].add(raw)
                brokers[kbo]["csv_statuses"].add(status)
                if office_name:
                    brokers[kbo]["offices_in_csv"].append(office_name)

    print(f"Unique KBO numbers to validate: {len(brokers)}")
    print(f"Brokers without KBO number: {len(set(empty_kbo_brokers))}")
    print()

    # 2. Load previously successful results to allow resuming
    already_done = {}
    if OUTPUT_PATH.exists():
        with open(OUTPUT_PATH, "r", encoding="utf-8-sig") as f:
            for row in csv.DictReader(f):
                if row.get("kbo_found") in ("YES", "PLACEHOLDER"):
                    already_done[row["kbo_number"]] = row
        print(f"Resuming: {len(already_done)} already validated, skipping those.\n")

    # 3. Call CBEAPI for each unique KBO number
    results = []
    for i, (kbo, info) in enumerate(sorted(brokers.items()), 1):
        is_placeholder = kbo == SUSPECTED_PLACEHOLDER
        names_str = " / ".join(sorted(info["names"]))
        print(f"[{i}/{len(brokers)}] {kbo} - {names_str}", end="")

        if kbo in already_done:
            print(" [CACHED]")
            results.append(already_done[kbo])
            continue

        if is_placeholder:
            print(" [SKIPPED - suspected placeholder]")
            results.append({
                "kbo_number": kbo,
                "broker_names_csv": names_str,
                "offices_in_csv": "; ".join(info["offices_in_csv"]),
                "csv_status": " / ".join(sorted(info["csv_statuses"])),
                "kbo_found": "PLACEHOLDER",
                "legal_name": "",
                "juridical_situation": "",
                "start_date": "",
                "enterprise_status": "",
                "num_establishments_kbo": "",
                "establishments_kbo": "",
            })
            continue

        data = fetch_company(kbo)

        if data is None:
            print(" -> NOT FOUND")
            results.append({
                "kbo_number": kbo,
                "broker_names_csv": names_str,
                "offices_in_csv": "; ".join(info["offices_in_csv"]),
                "csv_status": " / ".join(sorted(info["csv_statuses"])),
                "kbo_found": "NO",
                "legal_name": "",
                "juridical_situation": "",
                "start_date": "",
                "enterprise_status": "",
                "num_establishments_kbo": "",
                "establishments_kbo": "",
            })
        else:
            # Extract key fields from CBEAPI response
            legal_name = data.get("denomination", "") or data.get("denomination_with_legal_form", "")
            jur_label = data.get("juridical_situation", "") or ""
            start_date = data.get("start_date", "") or ""
            status_label = data.get("status", "") or ""

            # Address info
            addr = data.get("address", {}) or {}
            full_addr = addr.get("full_address", "") if isinstance(addr, dict) else ""

            establishments = data.get("establishments", []) or []
            est_descriptions = []
            for est in establishments:
                est_num = est.get("establishment_number", "")
                city = est.get("city", "")
                street = est.get("street", "")
                house = est.get("house_number", "")
                est_descriptions.append(
                    f"{est_num}: {street} {house}, {city}".strip()
                )

            print(f" -> {len(establishments)} vestigingen")

            results.append({
                "kbo_number": kbo,
                "broker_names_csv": names_str,
                "offices_in_csv": "; ".join(info["offices_in_csv"]),
                "csv_status": " / ".join(sorted(info["csv_statuses"])),
                "kbo_found": "YES",
                "legal_name": legal_name,
                "juridical_situation": jur_label,
                "start_date": start_date,
                "enterprise_status": status_label,
                "num_establishments_kbo": str(len(establishments)),
                "establishments_kbo": " | ".join(est_descriptions),
            })

        # Rate limiting: free tier needs ~1s between requests
        time.sleep(1.2)

    # 3. Write output report
    fieldnames = [
        "kbo_number",
        "broker_names_csv",
        "offices_in_csv",
        "csv_status",
        "kbo_found",
        "legal_name",
        "juridical_situation",
        "start_date",
        "enterprise_status",
        "num_establishments_kbo",
        "establishments_kbo",
    ]

    with open(OUTPUT_PATH, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)

    # 4. Print summary
    found = sum(1 for r in results if r["kbo_found"] == "YES")
    not_found = sum(1 for r in results if r["kbo_found"] == "NO")
    placeholder = sum(1 for r in results if r["kbo_found"] == "PLACEHOLDER")

    print(f"\n{'='*60}")
    print(f"RESULTS SUMMARY")
    print(f"{'='*60}")
    print(f"Found in KBO:      {found}")
    print(f"NOT found in KBO:  {not_found}")
    print(f"Placeholder:       {placeholder}")
    print(f"No KBO number:     {len(set(empty_kbo_brokers))} brokers")
    print(f"\nReport written to: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
