"""Generate LocusFocus feed from the latest commercials CSV in input/.

Output: output/feed_<today>.json containing all commercial properties with
publication arrays.
"""
import csv
import json
import re
from collections import defaultdict
from datetime import date
from pathlib import Path
from statistics import median

SCRIPT_DIR = Path(__file__).parent
INPUT_DIR = SCRIPT_DIR / "input"
OUTPUT_DIR = SCRIPT_DIR / "output"

# Per LocusFocus spec: PropertyType IN (4, 7, 9, 10, 11, 12, 13, 14)
COMMERCIAL_TYPES = {4, 7, 9, 10, 11, 12, 13, 14}


def latest_input() -> Path:
    pattern = re.compile(r"(\d{4}-\d{2}-\d{2})")
    candidates = []
    for p in INPUT_DIR.glob("*.csv"):
        m = pattern.search(p.name)
        if m:
            candidates.append((m.group(1), p))
    if not candidates:
        raise FileNotFoundError(f"No dated CSV in {INPUT_DIR}")
    candidates.sort(reverse=True)
    return candidates[0][1]


def clean(v):
    if v is None:
        return None
    s = str(v).strip()
    if s in ("", "null", "-"):
        return None
    return s


def to_int(v):
    v = clean(v)
    if v is None:
        return None
    return int(float(v))


def to_float(v):
    v = clean(v)
    return float(v) if v is not None else None


def display_address(r) -> str:
    street = clean(r.get("street_name"))
    num = clean(r.get("house_number"))
    box = clean(r.get("box_number"))
    pc = clean(r.get("postcode"))
    mun = clean(r.get("municipality_name"))

    line1 = " ".join(p for p in [street, num] if p)
    if box:
        line1 = f"{line1} bus {box}" if line1 else f"bus {box}"
    line2 = " ".join(p for p in [pc, mun] if p)
    return ", ".join(p for p in [line1, line2] if p) or None


def parse_publication(r):
    return {
        "publication_id": r["publication_id"],
        "agent_name": clean(r.get("agent_name")),
        "agent_logo_url": clean(r.get("agent_logo_url")),
        "property_type": to_int(r.get("property_type")),
        "property_subtype": to_int(r.get("property_subtype")),
        "transaction_type": to_int(r.get("transaction_type")),
        "price": to_float(r.get("price")),
        "price_type": to_int(r.get("price_type")),
        "available_surface_m2": to_float(r.get("available_surface_m2")),
        "built_surface_m2": to_float(r.get("built_surface_m2")),
        "plot_surface_m2": to_float(r.get("plot_surface_m2")),
        "photo_url": clean(r.get("photo_url")),
        "title": clean(r.get("title")),
        "available_from": clean(r.get("available_from")),
        "last_modified_at": clean(r.get("last_modified_at")),
        "spotto_url": clean(r.get("spotto_url")),
    }


def rollup_categorical(values):
    distinct = {v for v in values if v is not None}
    return next(iter(distinct)) if len(distinct) == 1 else None


def rollup_median(values):
    nums = [v for v in values if v is not None]
    return median(nums) if nums else None


def rollup_min(values):
    nums = [v for v in values if v is not None]
    return min(nums) if nums else None


def rollup_centroid(rows):
    coords = []
    for r in rows:
        la = to_float(r.get("latitude"))
        lo = to_float(r.get("longitude"))
        if la is not None and lo is not None:
            coords.append((la, lo))
    if not coords:
        return None, None
    return (
        sum(la for la, _ in coords) / len(coords),
        sum(lo for _, lo in coords) / len(coords),
    )


def rollup_most_recent(rows, field):
    candidates = [
        r for r in rows
        if clean(r.get(field)) and clean(r.get("last_modified_at"))
    ]
    if not candidates:
        return None
    candidates.sort(key=lambda r: r["last_modified_at"], reverse=True)
    return clean(candidates[0][field])


def build_property(group_rows):
    pubs = [parse_publication(r) for r in group_rows]
    lat, lng = rollup_centroid(group_rows)
    sample = group_rows[0]

    return {
        "address_key": sample["address_key"],
        "address": display_address(sample),
        "lat": lat,
        "lng": lng,
        "property_type": rollup_categorical(p["property_type"] for p in pubs),
        "property_subtype": rollup_categorical(p["property_subtype"] for p in pubs),
        "transaction_type": rollup_categorical(p["transaction_type"] for p in pubs),
        "available_surface_m2": rollup_median(p["available_surface_m2"] for p in pubs),
        "built_surface_m2": rollup_median(p["built_surface_m2"] for p in pubs),
        "plot_surface_m2": rollup_median(p["plot_surface_m2"] for p in pubs),
        "price": rollup_min(p["price"] for p in pubs),
        "price_type": rollup_categorical(p["price_type"] for p in pubs),
        "photo_url": rollup_most_recent(group_rows, "photo_url"),
        "title": rollup_most_recent(group_rows, "title"),
        "publications": pubs,
    }


def is_conflict(prop, field):
    return prop[field] is None and any(
        pub[field] is not None for pub in prop["publications"]
    )


def has_popup(prop):
    return any(p["transaction_type"] == 7 for p in prop["publications"])


def has_per_sqm(prop):
    return any(p["price_type"] == 5 for p in prop["publications"])


def has_future_available_from(prop):
    today = date.today().isoformat()
    return any(
        p["available_from"] and p["available_from"][:10] > today
        for p in prop["publications"]
    )


def edge_case_counts(properties):
    filters = [
        ("property_type_conflict", lambda p: is_conflict(p, "property_type")),
        ("transaction_type_conflict", lambda p: is_conflict(p, "transaction_type")),
        ("price_type_conflict", lambda p: is_conflict(p, "price_type")),
        ("popup", has_popup),
        ("per_sqm", has_per_sqm),
        ("future_available_from", has_future_available_from),
    ]
    return {label: sum(1 for p in properties if f(p)) for label, f in filters}


def main():
    OUTPUT_DIR.mkdir(exist_ok=True)
    src = latest_input()
    print(f"Loading {src.name}")
    with src.open(encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    print(f"  {len(rows)} publications")

    rows = [r for r in rows if to_int(r.get("property_type")) in COMMERCIAL_TYPES]
    print(f"  {len(rows)} after commercial filter")

    by_addr = defaultdict(list)
    for r in rows:
        by_addr[r["address_key"]].append(r)

    properties = [build_property(grp) for grp in by_addr.values()]
    print(f"  {len(properties)} unique properties")
    print(f"  edge-case counts: {edge_case_counts(properties)}")

    out = OUTPUT_DIR / f"feed_{date.today().isoformat()}.json"
    with out.open("w", encoding="utf-8") as f:
        json.dump({"properties": properties}, f, ensure_ascii=False, indent=2)
    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
