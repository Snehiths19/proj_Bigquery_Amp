# proj_Bigquery_Amp — project context

A **dbt + BigQuery learning project** for customer segmentation. Public ecommerce
data (`bigquery-public-data.thelook_ecommerce`) is transformed through a
staged dbt pipeline into two business-facing outputs:

1. **RFM segmentation** — bucket users into actionable groups
   (`champions`, `at_risk`, `hibernating`, etc.) for marketing prioritization.
2. **Amplitude event prep** — reshape the event stream into Amplitude's
   ingestion format so attribution modeling can run downstream.

The real deliverable is the *practice* of layered, tested, version-controlled
analytics — not the segments themselves.

## Directory layout

- **`lessons/`** — active workspace. All edits go here.
- **`answers/`** — reference solutions, locally-only. The root `.gitignore`
  excludes them from the repo, so what you see locally is fuller than what's
  on GitHub.
- **`docs/`** — published dbt docs (DAG screenshot, exported manifest).
- **`venv/`** — local Python 3.12 venv. Rebuild via
  `python -m venv --clear venv` if it ever breaks.

## dbt model layers (in `lessons/models/`)

```
sources       → bigquery-public-data.thelook_ecommerce
                (declared in src_ecommerce.yml)

staging/      → stg_ecommerce_{orders, order_items, products, users, events}
                One-to-one cleanup of sources. No joins. Mostly rename/cast.

intermediate/ → int_ecommerce_order_items_products
                int_ecommerce_first_last_order_created
                Joins + per-user rollups. Stepping stones to marts.

marts/        → dim_orders, dim_RFM_base
                RFM_Segmentation, Attribution_base, Amplitude_events
                Final business-facing tables.

seeds/        → seed_distribution_centers_new (example CSV-as-table)
                rfm_segments (drives segment + priority assignment;
                              partitions the 5×5×5 RFM score cube exactly)
```

## BigQuery target

- **Profile**: `lessons` (defined in `~/.dbt/profiles.yml`, not in the repo)
- **Project / dataset**: see `~/.dbt/profiles.yml`; dataset is `dbt_Amplitude`
- **Auth**: gcloud application-default credentials. If you see
  `invalid_grant: Bad Request`, run:
  ```
  gcloud auth application-default login
  ```

## Running the project

All commands run from inside `lessons/` (the dbt project root):

```powershell
..\venv\Scripts\dbt.exe deps                            # install packages from packages.yml
..\venv\Scripts\dbt.exe build                           # run + test in dependency order — usual default
..\venv\Scripts\dbt.exe run --select +RFM_Segmentation+ # rebuild a model with upstream + downstream
..\venv\Scripts\dbt.exe seed --select rfm_segments      # reload a single seed CSV
..\venv\Scripts\dbt.exe docs generate                   # produce target/index.html
..\venv\Scripts\dbt.exe docs serve                      # browse the DAG locally
```

`dbt-bigquery` is pinned to `~=1.7.0` in `requirements.txt` to gain unit-test
support (added in 1.7). Upgrading past 1.7.x requires adding a separate
`dbt-core` pin because 1.8+ split the package layout.

## Known issues / open improvements

Prioritized list of things we've identified but not yet shipped:

| # | Issue | Risk |
|---|---|---|
| 7 | All tests have `+severity: warn` set globally in `lessons/dbt_project.yml` — they emit warnings but never fail the build. | Real |
| 8 | `stg_ecommerce_events` uses `WHERE created_at > MAX(created_at)` for incremental — strictly-greater drops same-timestamp late-arriving events. | Real correctness bug |
| — | Mart naming is inconsistent: `Amplitude_events`, `Attribution_base`, `RFM_Segmentation` (PascalCase) coexist with `dim_orders` (snake_case). dbt convention is snake_case throughout with `fct_`/`dim_` prefixes. | Cosmetic but compounds |
| — | No SQL linter (sqlfluff with dbt templater) and no pre-commit hook. Mixed indentation already present (tabs in some files, spaces in others). | Quality |
| — | No CI. No GitHub Actions running `dbt compile`/`dbt test`/lint on PRs. | Process |
| — | No `profiles.yml.example` or setup docs for new contributors. | Onboarding |

## Temporary workaround — needs cleanup

`lessons/dbt_project.yml` currently has:

```yaml
packages-install-path: "dbt_packages_new"
```

This was a one-off workaround for a Windows file lock VS Code held on
`lessons/dbt_packages/` during `dbt deps`. To clean up:

1. Restart VS Code (releases the file handle).
2. Delete `lessons/dbt_packages/`.
3. Revert the `packages-install-path` line in `lessons/dbt_project.yml`.
4. `dbt deps` reinstalls to the standard `dbt_packages/` location.

Both `dbt_packages/` and `dbt_packages_new/` are already in `lessons/.gitignore`.
