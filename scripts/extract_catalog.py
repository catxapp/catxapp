#!/usr/bin/env python3
"""Extract ACC price list PDFs into catalog.json and pgm_config.json."""

from __future__ import annotations

import json
import re
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
PDF_MAY = ROOT / "source" / "pdfs" / "ACC PRICE LIST 5x19x2026.pdf"
PDF_JUN = ROOT / "source" / "pdfs" / "ACC PRICE LIST 6x17x2026.pdf"
OUT_DIR = ROOT / "catxapp" / "Resources"

MAY_DATE = "2026-05-19"
JUN_DATE = "2026-06-17"
PGM_SPOTS_PATH = ROOT / "source" / "pgm_spots.json"

PRICE_PATTERN = r"\$([\d,]+(?:\.\d+)?)"
JUN_LINE = re.compile(
    rf"^([A-Z][A-Za-z0-9]*)\s+(.+?)\s+{PRICE_PATTERN}$"
)
MAY_ENTRY = re.compile(
    rf"([A-Za-z0-9][A-Za-z0-9 \(\)\/-]*?)\s+([A-Z]{{2,10}})\s+{PRICE_PATTERN}"
)

def load_pgm_spots() -> tuple[dict[str, dict[str, float]], dict]:
    """Load Kitco bid spots keyed by PDF date from source/pgm_spots.json."""
    doc = json.loads(PGM_SPOTS_PATH.read_text())
    spots: dict[str, dict[str, float]] = {}
    for item in doc["priceLists"]:
        date = item["date"]
        spot = item["kitcoSpot"]
        spots[date] = {"pt": spot["pt"], "pd": spot["pd"], "rh": spot["rh"]}
    return spots, doc


def parse_price(raw: str) -> float:
    return float(raw.replace(",", ""))


def extract_june(text: str) -> dict[str, dict]:
    entries: dict[str, dict] = {}
    for line in text.splitlines():
        line = line.strip()
        match = JUN_LINE.match(line)
        if not match:
            continue
        code = match.group(2).strip()
        entries[code] = {
            "code": code,
            "category": match.group(1).strip(),
            "price": parse_price(match.group(3)),
        }
    return entries


def extract_may(text: str) -> dict[str, dict]:
    entries: dict[str, dict] = {}
    for match in MAY_ENTRY.finditer(text):
        code = match.group(1).strip()
        entries[code] = {
            "code": code,
            "category": match.group(2).strip(),
            "price": parse_price(match.group(3)),
        }
    return entries


def calibrate_weights(
    may: dict[str, dict],
    june: dict[str, dict],
    pgm_spots: dict[str, dict[str, float]],
) -> tuple[dict, float, float]:
    may_pgm = pgm_spots[MAY_DATE]
    jun_pgm = pgm_spots[JUN_DATE]

    best_weights = {"pt": 0.75, "pd": 0.2, "rh": 0.05}
    best_rmse = 1e9

    for wpt_i in range(21):
        for wpd_i in range(21):
            wpt, wpd = wpt_i / 20, wpd_i / 20
            wrh = 1.0 - wpt - wpd
            if wrh < 0 or wrh > 1:
                continue

            idx_may = wpt * may_pgm["pt"] + wpd * may_pgm["pd"] + wrh * may_pgm["rh"]
            idx_jun = wpt * jun_pgm["pt"] + wpd * jun_pgm["pd"] + wrh * jun_pgm["rh"]
            ratio = idx_jun / idx_may

            errors = []
            for code in set(may) & set(june):
                a, b = may[code]["price"], june[code]["price"]
                if a <= 0 or b <= 0:
                    continue
                pred = a * ratio
                errors.append((pred - b) ** 2)

            if not errors:
                continue

            rmse = (sum(errors) / len(errors)) ** 0.5
            if rmse < best_rmse:
                best_rmse = rmse
                best_weights = {"pt": round(wpt, 4), "pd": round(wpd, 4), "rh": round(wrh, 4)}

    w = best_weights
    anchor_index = round(
        w["pt"] * jun_pgm["pt"] + w["pd"] * jun_pgm["pd"] + w["rh"] * jun_pgm["rh"],
        4,
    )
    return best_weights, anchor_index, round(best_rmse, 2)


def main() -> None:
    pgm_spots, spots_doc = load_pgm_spots()

    may_text = "\n".join(page.extract_text() or "" for page in PdfReader(str(PDF_MAY)).pages)
    jun_text = "\n".join(page.extract_text() or "" for page in PdfReader(str(PDF_JUN)).pages)

    may_entries = extract_may(may_text)
    jun_entries = extract_june(jun_text)

    weights, anchor_index, rmse = calibrate_weights(may_entries, jun_entries, pgm_spots)

    catalog_entries = [
        {
            "code": item["code"],
            "category": item["category"],
            "anchorPrice": item["price"],
        }
        for _, item in sorted(jun_entries.items(), key=lambda pair: pair[0])
    ]

    catalog_doc = {
        "supplier": "American Iron and Metal, LLC",
        "anchorDate": JUN_DATE,
        "entryCount": len(catalog_entries),
        "entries": catalog_entries,
    }

    price_lists = [
        {
            "date": item["date"],
            "pdfFile": item["pdfFile"],
            "kitcoSpot": item["kitcoSpot"],
            "kitcoNotes": item.get("kitcoNotes"),
        }
        for item in spots_doc["priceLists"]
    ]

    pgm_doc = {
        "weights": weights,
        "anchorDate": JUN_DATE,
        "anchorIndex": anchor_index,
        "priceType": spots_doc.get("priceType", "bid"),
        "indexFormula": "index = (wPt × Pt) + (wPd × Pd) + (wRh × Rh)",
        "livePriceFormula": "livePrice = anchorPrice × (currentIndex ÷ anchorIndex)",
        "historical": pgm_spots,
        "priceLists": price_lists,
        "calibrationRMSE": rmse,
        "matchedPairs": len(set(may_entries) & set(jun_entries)),
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "catalog.json").write_text(json.dumps(catalog_doc))
    (OUT_DIR / "pgm_config.json").write_text(json.dumps(pgm_doc, indent=2))

    print(f"May entries: {len(may_entries)}")
    print(f"June entries: {len(jun_entries)}")
    print(f"Catalog written: {len(catalog_entries)}")
    print(f"Matched pairs: {pgm_doc['matchedPairs']}")
    print(f"PGM weights: {weights}")
    print(f"Calibration RMSE: ${rmse}")


if __name__ == "__main__":
    main()
