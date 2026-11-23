"""Step 1: reproduce the newspaper style comparison from source data.

Splits trusts into two halves by real terms funding growth and compares
productivity growth in each half. This reproduces the method, not the
newspaper's figures, which are never treated as verified.
"""
import numpy as np
import pandas as pd

# Output of sql/02_views.sql, joined to dim_trust for trust attributes
df = pd.read_csv("data/processed/trust_productivity.csv")

# Median split by funding growth, as the news analysis did
median_growth = df["resource_growth"].median()
df["half"] = np.where(
    df["resource_growth"] >= median_growth, "Bigger increase", "Smaller increase"
)

# Report mean AND median, because a few extreme trusts can drive a mean
headline = df.groupby("half")["productivity_growth"].agg(["mean", "median", "count"])
print(headline)

# Sensitivity: repeat without trusts that host shared services
clean = df[~df["hosts_shared_services"]]
print(clean.groupby("half")["productivity_growth"].agg(["mean", "median", "count"]))
