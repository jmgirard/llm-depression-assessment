# Shared data loading for the analysis reports.
#
# Model predictions come from the public files in ../data. The human MADRS
# ratings and participant characteristics come from NDA collection 3860
# (controlled access): download the madrs01 and ndar_subject01 structures as
# madrs01.txt and ndar_subject01.txt, in NDA's standard tab-delimited format
# (row 1 = field names, row 2 = field descriptions).
#
# Controlled-access files belong on storage approved under your NDA Data Use
# Certification, not in this repository. Set NDA_DIR to the folder holding the
# NDA files and FITS_DIR to where fitted models should be cached (fits embed
# the analysis data), e.g. in ~/.Renviron. Both default to folders that are
# git-ignored.
#
# The loaders return data in the shapes the analyses were originally written
# against, so the downstream analysis code is unchanged.

library(tidyverse)

data_dir <- file.path("..", "data")
nda_dir <- Sys.getenv("NDA_DIR", unset = file.path("..", "nda"))
fits_dir <- Sys.getenv("FITS_DIR", unset = "fits")
dir.create(fits_dir, showWarnings = FALSE, recursive = TRUE)

targets <- c("total", sprintf("item%02d", 1:10))

target_labels <- c(
  "00 - Total Score", "01 - Apparent Sadness", "02 - Reported Sadness",
  "03 - Inner Tension", "04 - Reduced Sleep", "05 - Reduced Appetite",
  "06 - Concentration Difficulties", "07 - Lassitude",
  "08 - Inability to Feel", "09 - Pessimistic Thoughts",
  "10 - Suicidal Thoughts"
)

nda_madrs_fields <- c(
  total = "madrstot", item01 = "madrsaps", item02 = "madrssad",
  item03 = "madrsten", item04 = "madrsslp", item05 = "madrsapp",
  item06 = "madrscon", item07 = "madrslas", item08 = "madrsfee",
  item09 = "madrspes", item10 = "madrssui"
)

education_labels <- c(
  "Less than High School", "High School/GED",
  "Part College or 2-year degree", "4-year College degree",
  "Part or completed Graduate degree"
)

session_id <- function(subject, visit) paste0(subject, "_v", visit)

# NDA stores the visit as free text; this converts it to the visit numbers
# (1-8) used in the public files.
nda_visit_number <- function(visit) as.integer(str_extract(visit, "\\d+"))

# NDA stores education (reg_edu) as an integer code; codes 1-5 correspond to
# education_labels, and any other value (including missing) is treated as
# unknown.
nda_education <- function(code) {
  code <- suppressWarnings(as.integer(code))
  factor(education_labels[if_else(code %in% 1:5, code, NA_integer_)],
         levels = education_labels)
}

read_nda <- function(structure) {
  path <- file.path(nda_dir, paste0(structure, ".txt"))
  if (!file.exists(path)) {
    stop("Missing ", path, ". Download the ", structure, " structure from ",
         "NDA collection 3860; see data/README.md.", call. = FALSE)
  }
  fields <- names(read_tsv(path, n_max = 0, show_col_types = FALSE))
  read_tsv(path, skip = 2, col_names = fields,
           col_types = cols(.default = col_character()))
}

col_or_na <- function(df, col) {
  if (col %in% names(df)) df[[col]] else NA_character_
}

# Human MADRS ratings, one row per session x target
load_labels <- function() {
  read_nda("madrs01") |>
    transmute(
      patient = src_subject_id,
      visit = nda_visit_number(visit),
      across(all_of(unname(nda_madrs_fields)), as.numeric)
    ) |>
    distinct(patient, visit, .keep_all = TRUE) |>
    pivot_longer(
      all_of(unname(nda_madrs_fields)),
      names_to = "nda_field",
      values_to = "ground_truth"
    ) |>
    transmute(
      session = session_id(patient, visit),
      target = names(nda_madrs_fields)[match(nda_field, nda_madrs_fields)],
      ground_truth
    )
}

# Model predictions joined to the human ratings, split into one data frame
# per target (total score first, then items 1-10), with the column names of
# the original prediction workbooks
load_prediction_sheets <- function(conditions = "full", models = NULL) {
  preds <- read_csv(
    file.path(data_dir, "predictions.csv"),
    col_types = cols(
      src_subject_id = col_character(), visit = col_integer(),
      target = col_character(), condition = col_character(),
      model = col_character(), .default = col_double()
    )
  ) |>
    filter(condition %in% conditions)
  if (!is.null(models)) preds <- filter(preds, model %in% models)

  sheets <- preds |>
    mutate(session = session_id(src_subject_id, visit)) |>
    left_join(load_labels(), by = c("session", "target")) |>
    transmute(
      session, patient = src_subject_id, visit_no = visit, target,
      condition, model_name = model, ground_truth,
      rating_0 = rating_1, rating_1 = rating_2, rating_2 = rating_3
    ) |>
    split(~ target)

  set_names(sheets[targets], target_labels)
}

# Sessions used as few-shot examples: one character vector of session IDs per
# target, in the same order as load_prediction_sheets()
load_exemplars <- function() {
  ex <- read_csv(file.path(data_dir, "fewshot_exemplars.csv"),
                 col_types = "cic") |>
    mutate(session = session_id(src_subject_id, visit))
  map(targets, \(t) ex$session[ex$target == t])
}

# Session-level interviewer codes (RA1-RA4; NA if not recorded)
load_sessions <- function() {
  read_csv(file.path(data_dir, "sessions.csv"), col_types = "cic") |>
    transmute(
      session = session_id(src_subject_id, visit),
      patient = src_subject_id,
      visit,
      interviewer
    )
}

# Participant characteristics, one row per participant (earliest record)
load_subjects <- function() {
  subj <- read_nda("ndar_subject01")
  tibble(
    patient = subj$src_subject_id,
    interview_age = as.numeric(subj$interview_age),
    sex = subj$sex,
    race = subj$race,
    ethnicity = col_or_na(subj, "ethnic_group"),
    reg_edu = col_or_na(subj, "reg_edu"),
    phenotype = col_or_na(subj, "phenotype")
  ) |>
    arrange(patient, interview_age) |>
    distinct(patient, .keep_all = TRUE) |>
    transmute(
      patient,
      age = floor(interview_age / 12),
      sex = recode(sex, F = "Female", M = "Male"),
      race,
      ethnicity,
      education = nda_education(reg_edu),
      diagnosis = phenotype
    )
}
