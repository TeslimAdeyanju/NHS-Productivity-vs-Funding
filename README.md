# Does Money Buy Productivity in NHS Trusts?

An independent, evidence led test of whether extra funding turns into extra treatment at trust level, built on public NHS data.

**Stack:** Python, MySQL star schema, SQL views, Power BI with DAX
**Status:** Planned build, scaffold only

---

## The claim being tested

In its analysis headlined "NHS wastes billions doled out by Labour" ([Laura Donnelly and Ben Butcher, The Telegraph, published 22 November 2026](https://www.telegraph.co.uk/news/2026/11/22/nhs-wasting-billions-taxpayers-cash-data-hospitals/)), the newspaper compared 111 acute and specialist trusts across April to July 2026 against the same period a year earlier. It reported that trusts in the half with the biggest funding increases saw productivity fall on average, while trusts in the other half saw it rise. The article itself notes that its statistics are provisional, cover four months, and weight treatment volumes by average cost rather than measuring outcomes. The chair of NHS England was reported as describing a "significant reduction in productivity" alongside a large spending rise.

This project does not take a side on the politics. It asks a narrower question: **does that relationship survive a proper test?**

> Attribution note: figures from the article are described, not reproduced, and are never treated as verified. Every number in this repository comes from the source datasets listed in `docs/data_sources.md`.

## Why the headline needs testing

| Threat | Why it matters | How this project handles it |
|---|---|---|
| Short window | Four months is dominated by seasonal and one off effects | Use full financial years and several years where available |
| Productivity is a ratio | Pay awards raise resources without raising treatment | Separate pay driven growth from capacity driven growth |
| Regression to the mean | Unusually weak or strong trusts drift back toward average | Control for prior year productivity |
| Data recording differences | Activity can be counted by a different trust from the one employing the staff | Flag shared service hosts and show results with and without them |
| Case mix | A specialist hospital is not comparable to a district general hospital | Group by trust type and weight activity by cost |
| Averages hide outliers | A few trusts can drive a mean | Report medians and interquartile ranges |

## Hypotheses

| Code | Hypothesis |
|---|---|
| H1 | Larger funding growth is associated with weaker short run productivity growth |
| H2 | The association weakens over a two to three year window |
| H3 | Part of the gap is a measurement artefact of dividing by resources |
| H4 | Prior year productivity predicts change better than funding does |

## Repository layout

```text
.
├── README.md
├── docs/
│   ├── data_sources.md      # every dataset, access date, version
│   └── method.md            # definitions and limits
├── sql/
│   ├── 01_schema.sql        # star schema
│   └── 02_views.sql         # productivity growth view
├── python/
│   ├── 01_reproduce_headline.py
│   └── 02_controls_and_persistence.py
├── data/                    # not committed, see data/README.md
└── powerbi/                 # report file and screenshots (later)
```

## How to reproduce

1. Download the datasets listed in `docs/data_sources.md` into `data/raw/`.
2. Run `sql/01_schema.sql` then load the cleaned tables.
3. Run `sql/02_views.sql` and export `vw_trust_productivity` to `data/processed/trust_productivity.csv`.
4. Run the Python scripts in order.

## Limits

- Public data may not reproduce the newspaper's productivity measure exactly. This project defines its own measure and documents it in `docs/method.md`.
- Results show association, not causation.
- Weighted activity is published with a lag, so the latest period may be unavailable.

## Author

Teslim Adeyanju, Financial Data Analyst and Associate Chartered Accountant. This is independent analysis of public data and does not represent an NHS position.
