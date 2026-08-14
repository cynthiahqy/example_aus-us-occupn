# AUS-US Occupation Crosswalks (ISCO-08)

Supporting materials for preparing the data assessment and background notes for [xmap#14](https://github.com/cynthiahqy/xmap/issues/14): harmonising USA (SOC) and Australia (ANZSCO) occupation counts to ISCO-08, with committee-judged semantic-similarity weights for the many-to-many links.

This repo is not the vignette itself — it collects the source correspondence tables and reference material used to scope that work before any `xmap_tbl` construction begins. Per [this comment](https://github.com/cynthiahqy/xmap/issues/14#issuecomment-5292821933), retrieving/documenting/licence-checking the source files has been split out of `xmap` and issue #14 into this repo specifically, to feed `data-raw/*.R` + `R/data.R` once ready to package. The vignette itself lives as a draft shell in `xmap` PR #26, currently using placeholder data (`demo$anzsco22_isco8_crosswalk` is a real ABS subset already in `xmap`; `demo$soc2018_isco8_crosswalk` is hand-authored, not yet real — and per the same comment, that name is a misnomer: the correct vintage is **SOC 2010**, not SOC 2018, for the proposed 2016 reference year).

## Checklist before PR #26 can swap in real data

From [issue #14](https://github.com/cynthiahqy/xmap/issues/14#issuecomment-5292821933):

**1. `data-raw/` files (raw retrieved sources)**
- [x] ANZSCO 2013 v1.2 classification structure file — `data/external/anzsco/1220.0 ANZSCO Version 1.2 Structure v3.xls`
- [x] ANZSCO 2013 v1.2 → ISCO-08 v2 correspondence file — `data/external/anzsco/1220.0 ANZSCO Correspondence to ISCO-08 v2.xls`
- [x] SOC 2010 classification structure file — `data/external/soc/soc_structure_2010.xls` (plus `soc_2010_definitions.xls` and `soc_2010_user_guide.pdf` for background)
- [x] SOC 2010 → ISCO-08 crosswalk file — `data/external/soc/isco_soc_crosswalk.xls`
- [x] BLS crosswalk methodology doc — `data/external/soc/isco_soc_crosswalk_process.pdf`
- [ ] Converted/tidied CSV versions of the above where the source is `.xls`/`.xlsx`, following the existing `xmap` convention (see `data-raw/indstat_rev3_masked_subset.csv` as the pattern) — keeps diffs small and avoids shipping proprietary binary formats
- [ ] Masked/subsetted sample versions of any full-size USA/AUS occupation-count source data (real BLS OEWS / ABS Census counts), following the `timor_occupn`/`indstat_masked` masking pattern already used in `xmap`

**2. Data documentation**
- [ ] Per-file column definitions (code, description, target code, partial-match flag, etc.) — enough detail to write the `@describe{}` blocks `R/data.R` already uses for `demo`/`timor_occupn`/`indstat`
- [ ] Row/column counts and coverage notes (how many occupation codes, which countries/years, full table vs. illustrative subset) — same level of detail as `indstat`'s roxygen docs
- [ ] Confirmation of whether the ANZSCO/ISCO-08 `partial` flag's exact meaning is documented anywhere upstream — no live ABS page explaining the correspondence methodology was found (only an abbreviations glossary), so this may need to be inferred from the data or sourced from the BLS process PDF once reachable

**3. Provenance information**
- [x] For every file: publisher, exact retrieval URL, retrieval date, classification vintage/version, licence/usage terms — see "Download provenance" below
- [ ] Explicit vintage cross-check against the proposed 2016 reference year for both ANZSCO (2013 v1.2) and SOC (2010) — flag if either wasn't current for the full 2016 reference period
- [ ] A decision on whether the real correspondence *structure* (which codes link to which) can be used as-is, or whether it also needs committee-judgment weights authored fresh against the real data — the currently-drafted vignette's weights are illustrative and tied to the placeholder crosswalk's specific rows, so they'll need re-deriving against whatever real many-to-many links show up

Once this checklist is done, the next step is porting the real crosswalks into `xmap`'s `data-raw/` (replacing the placeholder `demo$soc2018_isco8_crosswalk`) and re-running the vignette against real data.

## Download provenance

- Correspondences and supporting documentation for **ANZSCO 1.2 ↔ ISCO-08** were all downloaded from the Downloads tab of: <https://www.abs.gov.au/AUSSTATS/abs@.nsf/Lookup/1220.0Main+Features12013,%20Version%201.2>
- The **SOC 2010 ↔ ISCO-08** crosswalk and its methodology write-up (`isco_soc_crosswalk.xls`, `isco_soc_crosswalk_process.pdf`) were downloaded from: <https://www.bls.gov/soc/soccrosswalks.htm>
- The SOC 2010 classification background (`soc_2010_user_guide.pdf`, `soc_2010_definitions.pdf`/`.xls`, `soc_structure_2010.pdf`/`.xls`) were downloaded from "Downloadable Materials" on: <https://www.bls.gov/soc/2010/home.htm>
- **ISCO-08** (the target classification): structure/definitions, the ISCO-08↔ISCO-88 index, and the skill-level mapping were all downloaded from: <https://isco-ilo.netlify.app/en/isco-08/>

Retrieved: 2026-08-14, by manual download (BLS blocks automated fetches from this tooling environment with a 403; ABS and the ILO ISCO-08 site were reachable but downloaded manually alongside it for consistency). Licence: ABS content is published under Creative Commons Attribution 4.0 International; BLS content is a US federal government work, presumptively public domain under 17 U.S.C. §105; ILO ISCO-08 content licence not yet confirmed — check the site before packaging.

### `data/external/anzsco/`

| File | Sheets | Contents |
|---|---|---|
| `1220.0 ANZSCO Version 1.2 Structure v3.xls` | Contents, Table 1–6, Explanatory Notes | The ANZSCO 2013 v1.2 classification itself, at every hierarchy level: Table 1 (Major Groups) down to Table 5 (Major/Sub-Major/Minor/Unit Groups and Occupations); Table 6 lists all valid 6-digit ANZSCO codes. |
| `12200 ANZSCO Version 1.2 Index of Principal Titles, Alternative Titles and Specialisations v3.xls` | Contents, Table 1, Table 2, Explanatory Notes | Index of occupation titles (principal, alternative, and specialisations/nec categories) mapped to ANZSCO codes — Table 1 alphabetical, Table 2 by code. |
| `1220.0 ANZSCO Correspondence to ISCO-08 v2.xls` | Contents, ANZSCO Version 1.2 to ISCO-08, ISCO-08 to ANZSCO Version 1.2, Explanatory Notes | The ANZSCO↔ISCO-08 crosswalk itself: Table 1 is ANZSCO occupation → ISCO-08 unit group, Table 2 is the reverse (ISCO-08 unit group → ANZSCO occupation). |

### `data/external/soc/`

| File | Contents |
|---|---|
| `isco_soc_crosswalk.xls` | Official ISCO-08 × SOC 2010 crosswalk (approved July 2012; built from the ISCO-88↔SOC 2000 crosswalk mapped forward to SOC 2010 (840 codes) and ISCO-08 (425 codes)). |
| `isco_soc_crosswalk_process.pdf` | Methodology write-up describing how the SOC↔ISCO crosswalk was constructed (guiding principles included checking ISCO skill levels against BLS education/training assignments, and a "parsimony" principle avoiding over-inclusion of incidental matches). |
| `soc_2010_user_guide.pdf` | SOC 2010 user guide — background on the SOC 2010 classification structure. |
| `soc_2010_definitions.pdf` / `.xls` | SOC 2010 definitions — full text definitions for each SOC 2010 occupation code. |
| `soc_structure_2010.pdf` / `.xls` | SOC 2010 classification structure — the hierarchy of major/minor/broad groups down to detailed occupation codes. |

### `data/external/isco/`

| File | Contents |
|---|---|
| `ISCO-08 EN Structure and definitions.xlsx` | The ISCO-08 classification itself: one row per level (major/sub-major/minor/unit group) with code, title, definition, included/excluded tasks and occupations, and notes. |
| `ISCO-08 EN.csv` | Tidy long-format version of the same ISCO-08 hierarchy — one row per unit group with its major/sub-major/minor group codes and labels alongside it (also includes ISCO-88 and ISCO-68 rows for reference). |
| `ISCO-08 -88 EN Index.xlsx` | Alphabetical index of ~7,000 occupation titles, each mapped to its ISCO-08 and (predecessor) ISCO-88 unit group code. |
| `ISCO-08 88 EN Skills .xlsx` | ISCO-08/ISCO-88 major and sub-major groups mapped to ILO skill levels (1–4) and ILOSTAT's aggregated skill categories. |
| `ISCO-08 EN Vol 1.pdf` | ILO's full ISCO-08 Volume 1 publication (structure, definitions and correspondence tables) — the source document the spreadsheets above are extracted from. |

## Illustrative subset (`code/subset/`, `data/subset/`)

Per [#2](https://github.com/cynthiahqy/example_aus-us-occupn/issues/2), the vignette works with a deliberately small subset of occupations rather than the full ANZSCO (~1,000+ occupations) or SOC (840 codes): **ISCO-08 Sub-Major Group 11 "Chief Executives, Senior Officials and Legislators"** (unit groups `1111`, `1112`, `1113`, `1114`, `1120`) — including `1113` Traditional Chiefs and Heads of Villages specifically because it has **no ANZSCO correspondence**, a useful illustration of a target key with no corresponding source key (see [paper_crossmap-def#5](https://github.com/cynthiahqy/paper_crossmap-def/issues/5)).

`code/subset/build_subset_lookups.R` derives this subset's data assets from the raw files in `data/external/` and writes them to `data/subset/` (run from the repo root: `Rscript code/subset/build_subset_lookups.R`):

| File | Contents |
|---|---|
| `isco08_definitions.csv` | ISCO-08 definitions for the 5 anchor unit groups. |
| `anzsco1.2_definitions.csv` | ANZSCO occupation definitions for the codes the crosswalk subset actually links to (6 codes). ANZSCO's downloadable structure file has no free-text definitions — only titles/hierarchy/skill level. The full definitions ABS *does* publish, but only as individual "Unit Group" pages on abs.gov.au (e.g. [`UNIT GROUP 1111 Chief Executives and Managing Directors`](https://www.abs.gov.au/ausstats/abs@.nsf/Product+Lookup/1220.0~2013,+Version+1.2~Chapter~UNIT+GROUP+1111+Chief+Executives+and+Managing+Directors)), not as one downloadable file. The raw retrieved text for the 4 relevant unit groups (1111, 1112, 1113, 1399) is saved verbatim in `data/subset/raw/anzsco_unit_group_*.txt`; the build script hand-transcribes that into the structured CSV. |
| `soc2010_definitions.csv` | SOC 2010 definitions for the codes the crosswalk subset links to (6 codes). |
| `anzsco_to_isco08_crosswalk.csv` | ANZSCO→ISCO-08 crosswalk subset, filtered to the 5 anchor ISCO-08 codes. `1113`'s row has `anzsco_code` recoded from ABS's literal `"0"`/"No Correspondence" to `NA` — see the linked issue for why `NA`, not `0` or an omitted row, is the correct representation here. |
| `soc2010_to_isco08_crosswalk.csv` | SOC 2010→ISCO-08 crosswalk subset, filtered to the same 5 anchor ISCO-08 codes. |

## LLM-generated similarity weights prototype (`code/llm_weights/`)

Per [#3](https://github.com/cynthiahqy/example_aus-us-occupn/issues/3): a small Quarto prototype exploring whether an LLM can generate the same kind of semantic-similarity weight the vignette's "committee judgment" step calls for — not as a replacement or a validated alternative (there's no ground truth to check either against), but to show that the judgment call can be made **explicit and reproducible**: one documented prompt, one named model, one recorded date, producing a specific weight.

`code/llm_weights/llm_similarity_weights.qmd` (rendered: `llm_similarity_weights.html`) uses [`ellmer`](https://ellmer.tidyverse.org/) to run the Round 1 prompt from Ma, Huang & Haensch (2025), ["Can Large Language Models Advance Crosswalks? The Case of Danish Occupation Codes"](https://aclanthology.org/2025.naacl-srw.38/) (NAACL 2025 SRW), against every many-to-many source→target pair already present in the two crosswalk subsets, and normalizes the resulting A–E similarity ratings into split weights. Output: `data/subset/llm_similarity_weights_prototype.csv`.

Requires an OpenAI API key in a project-local `.Renviron` (gitignored — copy `.Renviron.example` and fill in `OPENAI_API_KEY`), loaded via `readRenviron(".Renviron")` at the top of the `.qmd`.

## Background

Both BLS and ABS publish official but **unweighted, many-to-many** correspondences between their national occupation classification and ISCO-08. Neither agency publishes a split proportion for the ambiguous links, so harmonising actual occupation *counts* (not just categories) across SOC and ANZSCO via ISCO-08 requires supplying weights — the scenario xmap#14 proposes to illustrate using committee-style semantic-similarity judgments as `xmap_tbl` weights.

See the issue for the full proposed vignette shape, reference year rationale (2016), and open questions.

## Why SOC 2010 and ANZSCO 2013 v1.2 (and not SOC 2018)

The goal is to compare US and Australian occupation counts for the same year, on the same classification (ISCO-08). That means each country's crosswalk to ISCO-08 has to be the version that was actually official in the chosen reference year.

- **2016 as the reference year:** in the US, SOC 2010 remained BLS's operational classification all the way through 2018 — SOC 2018 wasn't adopted until the May 2019 data release. In Australia, ANZSCO 2013 Version 1.2 (with its own "correspondence to ISCO-08 v2" table) was the version in use for the August 2016 Census. 2016 is the latest year where both countries' classifications are unambiguously the current official version, without a mid-year revision on either side.
- **SOC 2010, not SOC 2018:** since 2016 needs SOC 2010, not SOC 2018, that's the crosswalk vintage to source. The `xmap` package's placeholder data is currently named `demo$soc2018_isco8_crosswalk`, which is a misnomer left over from an earlier assumption — flagged in the [issue #14 comments](https://github.com/cynthiahqy/xmap/issues/14#issuecomment-5292821933) and worth fixing when the real data lands.
- **ISCO-08 itself** isn't a vintage choice in the same sense — it's just the common international target both national crosswalks already map onto, so it's the natural meeting point for comparison rather than a decision with its own year attached.
