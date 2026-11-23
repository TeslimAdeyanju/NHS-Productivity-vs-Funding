"""Step 2: test whether the headline survives controls and persistence checks."""
import numpy as np
import pandas as pd
import statsmodels.formula.api as smf

df = pd.read_csv("data/processed/trust_productivity.csv")

# Sort first so the lag lines up within each trust
df = df.sort_values(["trust_code", "financial_year"])

# Prior year productivity growth lets us test for regression to the mean
df["prior_productivity_growth"] = df.groupby("trust_code")["productivity_growth"].shift(1)

# Baseline: does funding growth explain productivity growth?
m1 = smf.ols("productivity_growth ~ resource_growth", data=df).fit(cov_type="HC3")

# Add controls: prior performance, trust type and size.
# HC3 gives robust standard errors when variance differs across trusts.
m2 = smf.ols(
    "productivity_growth ~ resource_growth + prior_productivity_growth"
    " + C(trust_type) + np.log(real_resources)",
    data=df,
).fit(cov_type="HC3")

print("Funding coefficient, no controls:  ", m1.params["resource_growth"])
print("Funding coefficient, with controls:", m2.params["resource_growth"])

# Persistence: does last year's funding growth predict this year's productivity change?
df["funding_growth_lag"] = df.groupby("trust_code")["resource_growth"].shift(1)
persistence = (
    df[["funding_growth_lag", "productivity_growth"]].dropna().corr(method="spearman")
)
print(persistence)  # Spearman is robust to extreme trusts
