# Data

Model predictions analyzed in the article. Human MADRS ratings, demographics,
and admission diagnoses for the same participants are available under
controlled access in the NIMH Data Archive (NDA),
[collection 3860](https://nda.nih.gov/edit_collection.html?id=3860); see
[Linking to NDA](#linking-to-nda) below.

These files contain no interview dates, GUIDs, human ratings, demographics, or
diagnoses. Participants are identified only by their NDA `src_subject_id`.

## Files

### `predictions.csv`

One row per participant × visit × prediction target × prompt condition × model.

| Column | Description |
|---|---|
| `src_subject_id` | Participant ID; matches `src_subject_id` in NDA collection 3860 |
| `visit` | Visit number within participant (1–8); together with `src_subject_id`, uniquely identifies an interview session |
| `target` | What was predicted: `item01`–`item10` (MADRS items; see crosswalk) or `total` (direct prediction of the MADRS total score) |
| `condition` | Prompt condition: `full` (maximal prompt), `no_demonstrative` (examples withheld), `no_descriptive` (item descriptions, questions, and rating scale withheld), `minimal` (both withheld). Ablation conditions exist only for Qwen 3 (22B-235B) and item targets. |
| `model` | Model name, as in Table 2 of the article |
| `rating_1`–`rating_3` | Predicted score from three independent generations (random seeds). Items range 0–6; `total` ranges 0–60. Blank = no valid prediction returned. |

In the article, the three ratings are averaged within model to form each
prediction (self-ensembling), and indirect total scores are the sum of the ten
item predictions.

### `sessions.csv`

One row per interview session (541 sessions, 277 participants).

| Column | Description |
|---|---|
| `src_subject_id` | Participant ID (as above) |
| `visit` | Visit number (as above) |
| `interviewer` | Research assistant who administered all instruments in the session, coded `RA1`–`RA4`. Blank = not recorded (13 sessions). |

### `fewshot_exemplars.csv`

Sessions whose transcripts were used as worked examples in the prompts (73
entries, 61 distinct sessions). These must be excluded from evaluation of the
corresponding target; analyses of indirect total scores exclude a session if it
served as an example for any item.

| Column | Description |
|---|---|
| `src_subject_id`, `visit` | Session (as above) |
| `target` | Target for which the session was an example (`item01`–`item10`, `total`) |

## Linking to NDA

Researchers with NDA access ([how to request access](https://nda.nih.gov/nda/access-data-info)) can obtain
the following for these participants from
[collection 3860](https://nda.nih.gov/edit_collection.html?id=3860) and join them to these files on `src_subject_id` (and
visit, for session-level data):

| Needed for | NDA structure | Fields |
|---|---|---|
| Human MADRS ratings (all analyses) | `madrs01` | See crosswalk below |
| Sex, age, race (fairness audit) | `ndar_subject01` | `sex`, `interview_age` (months), `race` |
| Education (fairness audit) | `ndar_subject01` | `reg_edu` |
| Admission diagnosis (fairness audit) | `ndar_subject01` | `phenotype`, `phenotype_description` |

### MADRS item crosswalk

| `target` | MADRS item | NDA `madrs01` field |
|---|---|---|
| `item01` | Apparent Sadness | `madrsaps` |
| `item02` | Reported Sadness | `madrssad` |
| `item03` | Inner Tension | `madrsten` |
| `item04` | Reduced Sleep | `madrsslp` |
| `item05` | Reduced Appetite | `madrsapp` |
| `item06` | Concentration Difficulties | `madrscon` |
| `item07` | Lassitude | `madrslas` |
| `item08` | Inability to Feel | `madrsfee` |
| `item09` | Pessimistic Thoughts | `madrspes` |
| `item10` | Suicidal Thoughts | `madrssui` |
| `total` | Total score | `madrstot` |

## License

CC BY 4.0; see [`LICENSE-CC-BY.md`](../LICENSE-CC-BY.md).
