#!/usr/bin/env python3
"""Extract ACC price list PDFs into catalog.json and pgm_config.json."""

from __future__ import annotations

import json
import re
from pathlib import Path

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
PDF_PRIOR = ROOT / "source" / "pdfs" / "ACC PRICE LIST 6x17x2026.pdf"
PDF_LATEST = ROOT / "source" / "pdfs" / "ACC PRICE LIST 6x24x2026.pdf"
OUT_DIR = ROOT / "catxapp" / "Resources"

PRIOR_DATE = "2026-06-17"
LATEST_DATE = "2026-06-24"
PGM_SPOTS_PATH = ROOT / "source" / "pgm_spots.json"

PRICE_PATTERN = r"\$([\d,]+(?:\.\d+)?)"
LINE = re.compile(
    rf"^([A-Z][A-Za-z0-9]*)\s+(.+?)\s+{PRICE_PATTERN}$"
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


def extract_entries(text: str) -> dict[str, dict]:
    entries: dict[str, dict] = {}
    for line in text.splitlines():
        line = line.strip()
        match = LINE.match(line)
        if not match:
            continue
        code = match.group(2).strip()
        entries[code] = {
            "code": code,
            "category": match.group(1).strip(),
            "price": parse_price(match.group(3)),
        }
    return entries


def calibrate_weights(
    prior: dict[str, dict],
    latest: dict[str, dict],
    prior_pgm: dict[str, float],
    latest_pgm: dict[str, float],
) -> tuple[dict, float, float]:
    best_weights = {"pt": 0.75, "pd": 0.2, "rh": 0.05}
    best_rmse = 1e9

    for wpt_i in range(21):
        for wpd_i in range(21):
            wpt, wpd = wpt_i / 20, wpd_i / 20
            wrh = 1.0 - wpt - wpd
            if wrh < 0 or wrh > 1:
                continue

            idx_prior = wpt * prior_pgm["pt"] + wpd * prior_pgm["pd"] + wrh * prior_pgm["rh"]
            idx_latest = wpt * latest_pgm["pt"] + wpd * latest_pgm["pd"] + wrh * latest_pgm["rh"]
            ratio = idx_latest / idx_prior

            errors = []
            for code in set(prior) & set(latest):
                a, b = prior[code]["price"], latest[code]["price"]
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
        w["pt"] * latest_pgm["pt"] + w["pd"] * latest_pgm["pd"] + w["rh"] * latest_pgm["rh"],
        4,
    )
    return best_weights, anchor_index, round(best_rmse, 2)


def main() -> None:
    pgm_spots, spots_doc = load_pgm_spots()

    prior_text = "\n".join(page.extract_text() or "" for page in PdfReader(str(PDF_PRIOR)).pages)
    latest_text = "\n".join(page.extract_text() or "" for page in PdfReader(str(PDF_LATEST)).pages)

    prior_entries = extract_entries(prior_text)
    latest_entries = extract_entries(latest_text)

    weights, anchor_index, rmse = calibrate_weights(
        prior_entries,
        latest_entries,
        pgm_spots[PRIOR_DATE],
        pgm_spots[LATEST_DATE],
    )

    catalog_entries = [
        {
            "code": item["code"],
            "category": item["category"],
            "anchorPrice": item["price"],
        }
        for _, item in sorted(latest_entries.items(), key=lambda pair: pair[0])
    ]

    catalog_doc = {
        "supplier": "American Iron and Metal, LLC",
        "anchorDate": LATEST_DATE,
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
        "anchorDate": LATEST_DATE,
        "anchorIndex": anchor_index,
        "priceType": spots_doc.get("priceType", "bid"),
        "indexFormula": "index = (wPt × Pt) + (wPd × Pd) + (wRh × Rh)",
        "livePriceFormula": "livePrice = anchorPrice × (currentIndex ÷ anchorIndex)",
        "historical": pgm_spots,
        "priceLists": price_lists,
        "calibrationRMSE": rmse,
        "calibrationPair": f"{PRIOR_DATE} → {LATEST_DATE}",
        "matchedPairs": len(set(prior_entries) & set(latest_entries)),
    }

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    (OUT_DIR / "catalog.json").write_text(json.dumps(catalog_doc))
    (OUT_DIR / "pgm_config.json").write_text(json.dumps(pgm_doc, indent=2))

    print(f"Prior entries ({PRIOR_DATE}): {len(prior_entries)}")
    print(f"Latest entries ({LATEST_DATE}): {len(latest_entries)}")
    print(f"Catalog written: {len(catalog_entries)}")
    print(f"Matched pairs: {pgm_doc['matchedPairs']}")
    print(f"PGM weights: {weights}")
    print(f"Anchor index ({LATEST_DATE}): {anchor_index}")
    print(f"Calibration RMSE: ${rmse}")


if __name__ == "__main__":
    main()
