# AUS-US Occupation Crosswalks (ISCO-08)

Supporting materials for preparing the data assessment and background notes for [xmap#14](https://github.com/cynthiahqy/xmap/issues/14): harmonising USA (SOC) and Australia (ANZSCO) occupation counts to ISCO-08, with committee-judged semantic-similarity weights for the many-to-many links.

This repo is not the vignette itself — it collects the source correspondence tables and reference material used to scope that work before any `xmap_tbl` construction begins.

## Directory listing

Each raw file below should be traceable to a publisher, a retrieval date, and a licence/usage note — this table is the working record for that, and is meant to feed directly into the `@source` tag of the corresponding dataset documentation once these files are packaged into `xmap` (e.g. `data-raw/*.R` + `R/data.R` roxygen blocks).

Template row (copy for each new file added):

| Path | Publisher | Description | Original URL | Retrieved | Licence / usage notes | Draft `@source` |
|---|---|---|---|---|---|---|
| `path/to/file.ext` | Agency name | One-line description of what the file is | `<https://...>` | YYYY-MM-DD | e.g. Creative Commons Attribution 4.0 | `\url{https://...}` |

Current files:

| Path | Publisher | Description | Original URL | Retrieved | Licence / usage notes | Draft `@source` |
|---|---|---|---|---|---|---|
| `docs/isco_soc_crosswalk.xls` | US Bureau of Labor Statistics (BLS) | Official ISCO-08 x SOC 2010 crosswalk (approved July 2012; built from the ISCO-88<->SOC 2000 crosswalk mapped forward to SOC 2010 (840 codes) and ISCO-08 (425 codes)) | <https://www.bls.gov/soc/isco_soc_crosswalk.xls> (via <https://www.bls.gov/soc/crosswalks.htm>) | TBC — not logged when this copy was downloaded | US federal government work, presumptively public domain under 17 U.S.C. §105 (not independently confirmed on-page — `bls.gov` blocks automated fetches from this environment with a 403, see note below) | `\url{https://www.bls.gov/soc/isco_soc_crosswalk.xls}` |
| `docs/isco_soc_crosswalk_process.pdf` | US Bureau of Labor Statistics (BLS) | Methodology write-up describing how the SOC-ISCO crosswalk was constructed (guiding principles included checking ISCO skill levels against BLS education/training assignments, and a "parsimony" principle avoiding over-inclusion of incidental matches) | <https://www.bls.gov/soc/isco_soc_crosswalk_process.pdf> (via <https://www.bls.gov/soc/crosswalks.htm>) | TBC — not logged when this copy was downloaded | Same as above (BLS / public domain, unconfirmed live) | `\url{https://www.bls.gov/soc/isco_soc_crosswalk_process.pdf}` |
| `ref_files/` | — | Not yet populated — see "To retrieve manually" below | — | — | — | — |

**Note on BLS verification:** every `bls.gov` path (including `/robots.txt`) returns `403 Forbidden` from `Server: AkamaiGHost` when fetched from this tooling environment, so the URLs above could not be re-verified live here — this reads as blanket bot-blocking rather than the files having moved, but treat "Retrieved"/licence as unconfirmed until checked from a regular browser.

`TBC` fields should be filled in before these files are used as the basis for a packaged dataset — in particular the exact retrieval date for the two BLS files already in `docs/`.

## To retrieve manually

The following ABS files were confirmed live (200, correct `Content-Type` and byte size) via direct navigation from `abs.gov.au` on 2026-08-14, but are not yet in this repo — please download them into `ref_files/` and add a row to the table above once they land:

| Suggested path | Publisher | Description | Direct URL | Notes |
|---|---|---|---|---|
| `ref_files/anzsco_v1.2_structure.xls` | Australian Bureau of Statistics (ABS) | ANZSCO Version 1.2 - Structure (the ANZSCO 2013 v1.2 classification itself) | <https://www.ausstats.abs.gov.au/ausstats/subscriber.nsf/0/6A8A6C9AC322D9ABCA257B9E0011956C/$File/1220.0%20ANZSCO%20Version%201.2%20Structure%20v3.xls> | 407,040 bytes, released 05/07/2013. Linked from the archived "2013, Version 1.2" edition page under [ANZSCO](https://www.abs.gov.au/statistics/classifications/anzsco-australian-and-new-zealand-standard-classification-occupations) → Downloads tab. |
| `ref_files/anzsco_v1.2_index.xls` | ABS | ANZSCO Version 1.2 Index of Principal Titles, Alternative Titles and Specialisations | same Downloads tab as above | 517,632 bytes. Companion index file, same edition page. |
| `ref_files/anzsco_v1.2_correspondence_to_isco08_v2.xls` | ABS | **ANZSCO v1.2 Correspondence to ISCO-08 (v2)** — the ANZSCO<->ISCO-08 crosswalk this vignette needs as the AUS-side counterpart to the BLS SOC<->ISCO-08 file above | <https://www.ausstats.abs.gov.au/ausstats/subscriber.nsf/0/A95F7BD105E1C5ABCA257BF90010E155/$File/1220.0%20ANZSCO%20Correspondence%20to%20ISCO-08%20v2.xls> | 365,568 bytes, released 04/10/2013. Same Downloads tab. Check whether the file itself contains an explanatory-notes sheet describing how the correspondence was built — no separate ABS methodology page for this was found. |

Also worth checking manually (not yet verified live from this environment due to the BLS 403 above — confirm from a regular browser):

- `https://www.bls.gov/soc/2010/` and `https://www.bls.gov/soc/crosswalks.htm` — BLS SOC 2010 structure/crosswalk landing pages.
- `https://www.bls.gov/soc/soc_2010_definitions.pdf` (or `.xls`), `soc_2010_user_guide.pdf`, `soc_2010_class_and_coding_structure.pdf` — SOC 2010 structure/definitions, useful background alongside the crosswalk already in `docs/`.

Licence note: ABS content is typically published under Creative Commons Attribution 4.0 International — confirm the specific licence on the ANZSCO edition page before adding it as the `Licence / usage notes` value for the rows above.

## Background

Both BLS and ABS publish official but **unweighted, many-to-many** correspondences between their national occupation classification and ISCO-08. Neither agency publishes a split proportion for the ambiguous links, so harmonising actual occupation *counts* (not just categories) across SOC and ANZSCO via ISCO-08 requires supplying weights — the scenario xmap#14 proposes to illustrate using committee-style semantic-similarity judgments as `xmap_tbl` weights.

See the issue for the full proposed vignette shape, reference year rationale (2016), and open questions.
