"""
Fetch office details from Omnicasa API for all Spotto customers.
Uses the projectandproperty endpoint which includes office address data.
Outputs a CSV with office locations for cross-referencing with KBO.
"""

import csv
import hashlib
import json
import time
import urllib.request
import urllib.error
from pathlib import Path

PORTAL_BASE_KEY = "aER02fUpFezhiHdWTesm3vQ3PRPhwSJ3"
API_BASE = "https://omnicasaapiv3.omnicasa.com/portal/Spotto/projectandproperty"
CUSTOMER_API = "https://omnicasaapiv3.omnicasa.com/portal/Spotto/customer"

OUTPUT_PATH = Path(__file__).parent / "omnicasa-offices-detailed.csv"


def get_customer_list() -> list[dict]:
    """Fetch the list of all customers."""
    key = f"{PORTAL_BASE_KEY}-customer"
    md5 = hashlib.md5(key.encode()).hexdigest().upper()
    url = f"{CUSTOMER_API}/{md5}"

    req = urllib.request.Request(url)
    req.add_header("Accept", "application/json")
    req.add_header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")

    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read().decode("utf-8"))
        return data["Value"]["Customers"]


def fetch_customer_offices(customer_id: int, max_retries: int = 3) -> list[dict]:
    """Fetch office details for a specific customer."""
    key = f"{PORTAL_BASE_KEY}-projectandproperty-{customer_id}"
    md5 = hashlib.md5(key.encode()).hexdigest().upper()
    url = f"{API_BASE}/{md5}?CustomerId={customer_id}"

    for attempt in range(max_retries):
        req = urllib.request.Request(url)
        req.add_header("Accept", "application/json")
        req.add_header("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")

        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                if data.get("Success"):
                    return data["Value"].get("Offices", [])
                return []
        except urllib.error.HTTPError as e:
            if e.code == 429:
                wait = 5 * (attempt + 1)
                print(f"  [rate limited, waiting {wait}s]", end="", flush=True)
                time.sleep(wait)
                continue
            print(f"  HTTP {e.code}: {e.reason}", end="")
            return []
        except Exception as e:
            if "timed out" in str(e).lower() and attempt < max_retries - 1:
                print(f"  [timeout, retrying]", end="", flush=True)
                time.sleep(2)
                continue
            print(f"  Error: {e}", end="")
            return []

    return []


def main():
    # 1. Get all customers
    print("Fetching customer list...")
    customers = get_customer_list()
    print(f"Found {len(customers)} customers.\n")

    # 2. Fetch offices for each customer
    all_offices = []
    for i, customer in enumerate(customers, 1):
        cid = customer["Id"]
        cname = customer["Name"]
        print(f"[{i}/{len(customers)}] {cid} - {cname}", end="", flush=True)

        offices = fetch_customer_offices(cid)
        print(f" -> {len(offices)} offices")

        for office in offices:
            all_offices.append({
                "customer_id": cid,
                "customer_name": cname,
                "office_id": office.get("OfficeId", ""),
                "office_name": office.get("Name", ""),
                "company": office.get("Company", ""),
                "vat_number": office.get("TaxInscriptionNumber", ""),
                "street": office.get("Street", ""),
                "street_number": office.get("StreetNumber", ""),
                "postal_code": office.get("PostalCode", ""),
                "city": office.get("City", ""),
                "country": office.get("Country", ""),
                "phone": office.get("Phone", ""),
                "email": office.get("Email", ""),
                "website": office.get("Website", ""),
                "latitude": office.get("Latitude", ""),
                "longitude": office.get("Longitude", ""),
                "activities": office.get("Activities", ""),
            })

        # Be gentle with the API
        time.sleep(0.5)

    # 3. Write output
    fieldnames = [
        "customer_id", "customer_name", "office_id", "office_name", "company",
        "vat_number", "street", "street_number", "postal_code", "city",
        "country", "phone", "email", "website", "latitude", "longitude",
        "activities",
    ]

    with open(OUTPUT_PATH, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(all_offices)

    print(f"\n{'='*60}")
    print(f"SUMMARY")
    print(f"{'='*60}")
    print(f"Customers queried:  {len(customers)}")
    print(f"Total offices:      {len(all_offices)}")
    print(f"Report written to:  {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
