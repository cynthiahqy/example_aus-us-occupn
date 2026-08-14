# Build the illustrative-subset data assets for the xmap AUS-US occupation
# vignette (xmap#14 / example_aus-us-occupn#2).
#
# Subset: ISCO-08 Sub-Major Group 11 "Chief Executives, Senior Officials and
# Legislators" (unit groups 1111, 1112, 1113, 1114, 1120). Chosen per
# example_aus-us-occupn#2 as the smallest deliberate step up from the
# xmap placeholder's five hand-picked codes, and because it includes 1113
# (Traditional Chiefs and Heads of Villages), which has no ANZSCO
# correspondence -- a useful illustration of a target key with no
# corresponding source key (see paper_crossmap-def#5).
#
# Outputs (data/subset/):
#   isco08_definitions.csv          - ISCO-08 unit group definitions
#   anzsco1.2_definitions.csv       - ANZSCO occupation definitions
#   soc2010_definitions.csv         - SOC 2010 detailed occupation definitions
#   anzsco_to_isco08_crosswalk.csv  - ANZSCO -> ISCO-08 crosswalk subset
#   soc2010_to_isco08_crosswalk.csv - SOC 2010 -> ISCO-08 crosswalk subset
#
# Run from the repo root: Rscript code/subset/build_subset_lookups.R

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)

external_dir <- file.path("data", "external")
subset_dir <- file.path("data", "subset")
dir.create(subset_dir, showWarnings = FALSE, recursive = TRUE)

isco08_subset <- c("1111", "1112", "1113", "1114", "1120")

# ---------------------------------------------------------------------------
# 1. Crosswalk subsets, anchored on the ISCO-08 subset
# ---------------------------------------------------------------------------

# ANZSCO -> ISCO-08 (ABS Table 1: "ANZSCO Version 1.2 to ISCO-08")
anzsco_correspondence_raw <- read_excel(
  file.path(external_dir, "anzsco", "1220.0 ANZSCO Correspondence to ISCO-08 v2.xls"),
  sheet = "ANZSCO Version 1.2 to ISCO-08",
  col_names = c("anzsco_code", "anzsco_title", "isco08_code", "partial_match", "isco08_title"),
  skip = 7
)

anzsco_to_isco08 <- anzsco_correspondence_raw |>
  filter(!is.na(isco08_code), isco08_code %in% isco08_subset) |>
  mutate(
    partial_match = !is.na(partial_match) & partial_match == "p",
    # ABS marks unit groups with no ANZSCO correspondence with an
    # "anzsco_code" of "0" / "No Correspondence" -- recode to NA so it
    # isn't mistaken for a real ANZSCO code (see paper_crossmap-def#5 on
    # why NA, not 0/omission, is the right representation for this case).
    anzsco_code = na_if(anzsco_code, "0")
  ) |>
  arrange(isco08_code, anzsco_code)

write.csv(
  anzsco_to_isco08,
  file.path(subset_dir, "anzsco_to_isco08_crosswalk.csv"),
  row.names = FALSE, na = ""
)

# SOC 2010 -> ISCO-08 (BLS "ISCO-08 to 2010 SOC")
soc_crosswalk_raw <- read_excel(
  file.path(external_dir, "soc", "isco_soc_crosswalk.xls"),
  sheet = "ISCO-08 to 2010 SOC",
  skip = 6
)

soc2010_to_isco08 <- soc_crosswalk_raw |>
  rename(
    isco08_code = `ISCO-08 Code`,
    isco08_title = `ISCO-08 Title EN`,
    partial_match = part,
    soc2010_code = `2010 SOC Code`,
    soc2010_title = `2010 SOC Title`,
    comment = `Comment 8/17/11`
  ) |>
  filter(isco08_code %in% isco08_subset) |>
  mutate(
    soc2010_code = str_trim(soc2010_code),
    partial_match = !is.na(partial_match) & partial_match == "*"
  ) |>
  arrange(isco08_code, soc2010_code)

write.csv(
  soc2010_to_isco08,
  file.path(subset_dir, "soc2010_to_isco08_crosswalk.csv"),
  row.names = FALSE, na = ""
)

# ---------------------------------------------------------------------------
# 2. Definition lookups, filtered to codes appearing in the crosswalk subsets
# ---------------------------------------------------------------------------

anzsco_subset_codes <- sort(na.omit(unique(anzsco_to_isco08$anzsco_code)))
soc2010_subset_codes <- sort(unique(soc2010_to_isco08$soc2010_code))

# ISCO-08 definitions
isco08_definitions_raw <- read_excel(
  file.path(external_dir, "isco", "ISCO-08 EN Structure and definitions.xlsx"),
  sheet = 1
)

isco08_definitions <- isco08_definitions_raw |>
  filter(Level == "4", `ISCO 08 Code` %in% isco08_subset) |>
  transmute(
    isco08_code = `ISCO 08 Code`,
    title = `Title EN`,
    definition = Definition,
    tasks_include = `Tasks include`,
    included_occupations = `Included occupations`,
    excluded_occupations = `Excluded occupations`,
    notes = Notes
  ) |>
  arrange(isco08_code)

write.csv(
  isco08_definitions,
  file.path(subset_dir, "isco08_definitions.csv"),
  row.names = FALSE, na = ""
)

# SOC 2010 definitions
soc2010_definitions_raw <- read_excel(
  file.path(external_dir, "soc", "soc_2010_definitions.xls"),
  skip = 6
)

soc2010_definitions <- soc2010_definitions_raw |>
  mutate(soc_code = str_trim(`SOC Code`)) |>
  filter(soc_code %in% soc2010_subset_codes) |>
  transmute(
    soc2010_code = soc_code,
    title = `SOC Title`,
    definition = `SOC Definition`
  ) |>
  arrange(soc2010_code)

write.csv(
  soc2010_definitions,
  file.path(subset_dir, "soc2010_definitions.csv"),
  row.names = FALSE, na = ""
)

# ANZSCO 1.2 definitions
#
# The ANZSCO Structure file lays out the Major/Sub-Major/Minor/Unit/
# Occupation hierarchy as a staggered table (one level per column, most
# cells blank) rather than a tidy one-row-per-occupation table, and (unlike
# ISCO-08 and SOC) doesn't include free-text definitions -- only titles and,
# at the occupation level, a skill-level rating. We flatten it by walking
# down the rows, tracking the most recent code/title seen at each level, and
# emitting one row per occupation (identified by having a non-NA value in
# the skill-level column).
anzsco_structure_raw <- read_excel(
  file.path(external_dir, "anzsco", "1220.0 ANZSCO Version 1.2 Structure v3.xls"),
  sheet = "Table 5",
  col_names = FALSE,
  skip = 10
)

flatten_anzsco_hierarchy <- function(raw) {
  state <- list(
    major_code = NA_character_, major_title = NA_character_,
    submajor_code = NA_character_, submajor_title = NA_character_,
    minor_code = NA_character_, minor_title = NA_character_,
    unit_code = NA_character_, unit_title = NA_character_
  )
  rows <- vector("list", nrow(raw))

  for (i in seq_len(nrow(raw))) {
    vals <- as.character(unlist(raw[i, 1:5], use.names = FALSE))
    level <- which(!is.na(vals))[1]
    if (is.na(level)) next

    code <- vals[level]
    title <- as.character(raw[[i, level + 1]])

    if (level == 1) {
      state$major_code <- code; state$major_title <- title
    } else if (level == 2) {
      state$submajor_code <- code; state$submajor_title <- title
    } else if (level == 3) {
      state$minor_code <- code; state$minor_title <- title
    } else if (level == 4) {
      state$unit_code <- code; state$unit_title <- title
    } else if (level == 5) {
      rows[[i]] <- c(
        state,
        list(
          occupation_code = code,
          occupation_title = title,
          skill_level = as.character(raw[[i, 7]])
        )
      )
    }
  }

  bind_rows(rows)
}

anzsco_definitions <- flatten_anzsco_hierarchy(anzsco_structure_raw) |>
  filter(occupation_code %in% anzsco_subset_codes) |>
  transmute(
    anzsco_code = occupation_code,
    title = occupation_title,
    skill_level,
    major_code, major_title,
    submajor_code, submajor_title,
    minor_code, minor_title,
    unit_code, unit_title
  ) |>
  arrange(anzsco_code)

write.csv(
  anzsco_definitions,
  file.path(subset_dir, "anzsco1.2_definitions.csv"),
  row.names = FALSE, na = ""
)

message(
  "Wrote ", nrow(isco08_definitions), " ISCO-08, ",
  nrow(anzsco_definitions), " ANZSCO, ",
  nrow(soc2010_definitions), " SOC 2010 definitions, and ",
  nrow(anzsco_to_isco08), " ANZSCO->ISCO-08 / ",
  nrow(soc2010_to_isco08), " SOC->ISCO-08 crosswalk rows to ", subset_dir
)
