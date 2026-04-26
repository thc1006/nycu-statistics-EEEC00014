# AGENTS.md — Homework Assignments 1 R Statistics Agent Guide

This file defines the expected behavior, coding style, structure, and statistical workflow for AI coding agents writing R code for **Homework Assignments 1**.

The target is not merely “working R code.” The target is code that looks like the teacher’s Chapter 1–4 R examples: sectioned, reproducible, explicitly statistical, visually diagnostic, and able to print a clean R Console-style output.

---

## 1. Project Goal

Generate R code and output for **Homework Assignments 1**, covering these exercises:

| Exercise | Section | Statistical Topic |
|---:|---|---|
| 4-42 | 4-4 | One-sample mean inference, known variance / known `sigma`; one-sided z test; P-value; beta; sample size; one-sided lower CI |
| 4-44 | 4-4 | Sample size for estimating a mean with specified margin of error, known `sigma` |
| 4-54 | 4-5 | One-sample mean inference, unknown variance; two-sided t test; normality check; CI; sample size for power |
| 4-59 | 4-5 | One-sample mean inference, unknown variance; one-sided t test; upper confidence bound; sample size for power |
| 4-65 | 4-5 | One-sample mean inference, unknown variance; one-sided t test; normality check; power; sample size; one-sided confidence bound |
| 4-71 | 4-6 | Inference on population standard deviation `sigma`; chi-square test; CI for `sigma` |
| 4-75 | 4-7 | One-sample population proportion; one-sided test; beta; sample size; lower confidence bound |
| 4-76 | 4-7 | One-sample population proportion; two-sided test; traditional CI; sample size |
| 4-89 | 4-7 | Agresti-Coull two-sided CI for a population proportion |
| 4-95 | 4-8 | Prediction interval and tolerance interval for normal data |

The output should include:
1. A self-contained `homework1.R` script.
2. A console-style output file such as `homework1_output.txt`.
3. Optional plots saved under `plots/` when a problem asks for normality checks or when a plot clarifies a test or interval.
4. No external data files; all data vectors must be hard-coded exactly from the assignment.

---

## 2. Teacher-Style Coding Pattern to Imitate

The teacher’s R code consistently follows this pattern:

```r
# CHAPTER 4 Decision Making for a Single Sample
# EXERCISE 4-42 Thermocouple Life
# --- 1. Setup ---
if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, car, HH, BSDA, pwr, tolerance, Hmisc)

# --- 2. Data Preparation ---
# ...

# --- 3. Summary Statistics ---
# ...

# --- 4. Assumption Checks ---
# ...

# --- 5. Hypothesis Test / Confidence Interval ---
# ...

# --- 6. Power / Sample Size ---
# ...

# --- 7. Visualizations ---
# ...

# --- 8. Final Report ---
# ...
```

Follow this structure for every exercise or for every logical exercise group.

Do **not** write compact “competition code.” This homework should be easy for the teacher to read line by line.

---

## 3. Required R Style

### 3.1 Package loading

Use the teacher’s style:

```r
if(!require(pacman)) install.packages("pacman")
pacman::p_load(tidyverse, car, HH, BSDA, pwr, tolerance, Hmisc, ggpubr, infer, patchwork)
```

Load only packages that are actually used in the final script.

Preferred packages by topic:

| Task | Preferred R Tools |
|---|---|
| Data frames and summaries | `data.frame`, `tibble`, `dplyr`, `summarise`, `mutate` |
| Plots | `ggplot2`, base R plots, `car::qqPlot`, `HH::NTplot`, `HH::normal.and.t.dist` |
| z tests | manual formula + `BSDA::z.test` cross-check |
| t tests | `t.test` + manual formula if needed |
| normality | `shapiro.test`, `car::qqPlot`, Q-Q plot |
| power for z tests | custom `Pwr.z.test` |
| power for t tests | custom noncentral-t function or `pwr::pwr.t.test` |
| chi-square variance tests | manual `pchisq`, `qchisq`, optional custom `Pwr.chisq.test` |
| proportions | manual z approximation + `prop.test(..., correct = FALSE)` as cross-check |
| Agresti-Coull CI | custom formula |
| prediction interval | manual t-based formula |
| tolerance interval | `tolerance::normtol.int` plus manual explanation |

### 3.2 Naming conventions

Use readable names, close to the teacher examples:

```r
alpha <- 0.05
conf_level <- 0.95
n_reps <- 10000

tc_values <- c(...)
diode_values <- c(...)
rain_df <- data.frame(...)
params <- list(mu0 = 540, sigma = 20, alpha = 0.05, n = 15)
```

Use `snake_case` for new objects, but it is acceptable to use teacher-style names such as:

```r
PVal_gr
CritVal_2s
CI_2s
SplSz_CI_gr
```

Do not use vague names such as `a`, `b`, `test1`, `stuff`, `ans`.

### 3.3 Printed intermediate values

The teacher often wraps assignments in parentheses to print values:

```r
(xbar <- mean(x))
(se <- sigma / sqrt(n))
(z0 <- (xbar - mu0) / se)
(PVal_gr <- 1 - pnorm(z0))
```

Use this style for important intermediate values, especially:
- `xbar`
- `s`
- `n`
- `se`
- `z0` or `t0`
- `p_value`
- `critical_value`
- `CI`
- `beta`
- `power`
- required sample size

### 3.4 Output formatting

Use `cat()` and `sprintf()` to create readable console output:

```r
cat("\n=== EXERCISE 4-42: THERMOCOUPLE LIFE ===\n")
cat(sprintf("Sample mean: %.4f\n", xbar))
cat(sprintf("Test Statistic (z0): %.4f\n", z0))
cat(sprintf("P-Value: %.4f\n", p_value))
cat("Decision:", if(p_value < alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
```

Use these rounding rules unless the problem demands more precision:

| Quantity | Default Rounding |
|---|---:|
| Means / SD / SE / CI endpoints | 4 decimal places |
| Test statistic | 4 decimal places |
| P-value | 4 decimal places, but print `< 0.0001` if very small |
| Required sample size | integer via `ceiling()` |
| Power / beta | 4 decimal places |

---

## 4. Statistical Workflow Required for Each Problem

Each exercise should be solved in the following order.

### Step A — Restate the exercise context in comments

For example:

```r
# EXERCISE 4-42
# Life in hours of thermocouples.
# Known sigma = 20 hours.
# Test whether mean life exceeds 540 hours at alpha = 0.05.
```

### Step B — Data preparation

Hard-code the data exactly:

```r
thermo <- c(553, 552, 567, 579, 550, 541, 537, 553, 552,
            546, 538, 553, 581, 539, 529)

thermo_df <- data.frame(
  Life = thermo,
  ObsNo = seq_along(thermo)
)
```

### Step C — Summary statistics

Always print:

```r
get_stats <- function(x) {
  data.frame(
    n = length(x),
    Mean = mean(x),
    Var = var(x),
    Std_Dev = sd(x),
    Std_Error = sd(x) / sqrt(length(x)),
    Median = median(x)
  ) %>% mutate(across(everything(), ~round(., 4)))
}
```

For known-`sigma` problems, also print known `sigma` and known standard error.

### Step D — Assumption checks

If the problem asks to check normality, include both:
1. `shapiro.test(x)`
2. Q-Q plot via `car::qqPlot(x)` or `ggplot(...)+stat_qq()+stat_qq_line()`

For small samples, explicitly state:

```r
cat("Normality comment: With small n, Shapiro-Wilk has low power; use it with the Q-Q plot.\n")
```

Do **not** overclaim normality. Say “no strong evidence against normality” when `p > alpha`.

### Step E — Hypothesis test

Always show:
- `H0`
- `H1`
- `alpha`
- test statistic
- P-value
- decision
- short conclusion in the words of the problem

Example style:

```r
cat("H0: mu <= 540\n")
cat("H1: mu > 540\n")
cat("Decision:", if(p_value < alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
cat("Conclusion:", if(p_value < alpha)
  "There is evidence that the mean life exceeds 540 hours.\n" else
  "There is insufficient evidence that the mean life exceeds 540 hours.\n")
```

### Step F — Confidence interval

Show both manual calculation and package cross-check when possible.

For one-sided intervals:
- Lower bound for `H1: mu > mu0`: `[LCL, Inf)`
- Upper bound for `H1: mu < mu0`: `(-Inf, UCL]`

Use teacher-style interval printing:

```r
cat("Confidence Interval:", "[", LCL, ", Inf)\n")
cat("Confidence Interval:", "(-Inf,", UCL, "]\n")
```

### Step G — Power, beta, sample size

When asked for `beta`, compute `beta = 1 - power`.

Use clear comments:

```r
# beta is the probability of failing to reject H0 when the true mean is mu_true.
```

For sample size, use `ceiling()` and verify by printing power or beta at `n_req - 1` and `n_req`:

```r
cat("\nPower at n =", n_req - 1, ":", power_at_n_minus_1, "\n")
cat("Power at n =", n_req, ":", power_at_n, "\n")
```

This mirrors the teacher’s sample-size verification style.

### Step H — Visualizations

Use plots only when helpful or requested:
- Normality: Q-Q plot + histogram/density.
- Tests: null distribution with rejection region.
- Power: power curve with target line.
- Intervals: plot estimate and CI/PI/TI endpoints.

Save plots with simple names:

```r
ggsave("plots/ex4_54_normality.png", width = 7, height = 5, dpi = 300)
```

---

## 5. Shared Helper Functions to Include

Include a “Shared Helper Functions” section near the top of `homework1.R`.

### 5.1 Summary statistics

```r
get_stats <- function(x) {
  data.frame(
    n = length(x),
    Mean = mean(x),
    Var = var(x),
    Std_Dev = sd(x),
    Std_Error = sd(x) / sqrt(length(x)),
    Median = median(x)
  ) %>% mutate(across(everything(), ~round(., 4)))
}
```

### 5.2 Known-variance z-test power

```r
Pwr.z.test <- function(n, delta, sigma, alpha, alt = "two.sided") {
  m <- delta / (sigma / sqrt(n))
  if (alt == "two.sided") {
    return(1 - pnorm(qnorm(1 - alpha/2) - m) +
             pnorm(qnorm(alpha/2) - m))
  } else if (alt == "greater") {
    return(1 - pnorm(qnorm(1 - alpha) - m))
  } else {
    return(pnorm(qnorm(alpha) - m))
  }
}
```

### 5.3 Known-variance z-test sample size

```r
SplSz.z.test <- function(delta, sigma, alpha, pwr, side = 2) {
  ceiling(((qnorm(1 - alpha/side) + qnorm(pwr)) * sigma / abs(delta))^2)
}
```

### 5.4 Known-variance mean CI sample size

```r
SplSz.z.CI <- function(E, sigma, conf.level, side = 2) {
  ceiling((qnorm(1 - (1 - conf.level)/side) * sigma / E)^2)
}
```

### 5.5 Unknown-variance t-test power

Use either `pwr::pwr.t.test()` or this noncentral t implementation:

```r
Pwr.t.test.custom <- function(n, delta, sigma, alpha, alt = "two.sided") {
  df <- n - 1
  ncp <- delta / (sigma / sqrt(n))
  if (alt == "two.sided") {
    return(1 - pt(qt(1 - alpha/2, df), df, ncp) +
             pt(qt(alpha/2, df), df, ncp))
  } else if (alt == "greater") {
    return(1 - pt(qt(1 - alpha, df), df, ncp))
  } else {
    return(pt(qt(alpha, df), df, ncp))
  }
}
```

For unknown-variance sample size, use an iterative search:

```r
find_min_n_t <- function(delta, sigma, alpha, target_power,
                         alt = "two.sided", n_start = 2, n_max = 10000) {
  for (n in n_start:n_max) {
    pwr <- Pwr.t.test.custom(n, delta, sigma, alpha, alt)
    if (pwr >= target_power) return(n)
  }
  stop("No sample size found up to n_max.")
}
```

### 5.6 Chi-square power for standard deviation tests

```r
Pwr.chisq.test <- function(n, r, alpha, alt = "two.sided") {
  df <- n - 1
  if (alt == "two.sided") {
    return(1 - pchisq(qchisq(1 - alpha/2, df) / r^2, df) +
             pchisq(qchisq(alpha/2, df) / r^2, df))
  } else if (alt == "greater") {
    return(1 - pchisq(qchisq(1 - alpha, df) / r^2, df))
  } else {
    return(pchisq(qchisq(alpha, df) / r^2, df))
  }
}
```

### 5.7 Traditional Wald CI for one proportion

```r
prop_wald_ci <- function(x, n, conf_level = 0.95, side = "two.sided") {
  phat <- x / n
  alpha <- 1 - conf_level
  se <- sqrt(phat * (1 - phat) / n)

  if (side == "two.sided") {
    z <- qnorm(1 - alpha/2)
    return(c(phat - z * se, phat + z * se))
  } else if (side == "lower") {
    z <- qnorm(conf_level)
    return(c(phat - z * se, Inf))
  } else {
    z <- qnorm(conf_level)
    return(c(-Inf, phat + z * se))
  }
}
```

### 5.8 Agresti-Coull CI

```r
agresti_coull_ci <- function(x, n, conf_level = 0.95) {
  alpha <- 1 - conf_level
  z <- qnorm(1 - alpha/2)
  n_tilde <- n + z^2
  p_tilde <- (x + z^2 / 2) / n_tilde
  se_tilde <- sqrt(p_tilde * (1 - p_tilde) / n_tilde)
  c(p_tilde - z * se_tilde, p_tilde + z * se_tilde)
}
```

### 5.9 Prediction interval for one future normal observation

```r
prediction_interval_normal <- function(x, conf_level = 0.95) {
  n <- length(x)
  xbar <- mean(x)
  s <- sd(x)
  alpha <- 1 - conf_level
  crit <- qt(c(alpha/2, 1 - alpha/2), df = n - 1)
  se_pred <- s * sqrt(1 + 1/n)
  xbar + crit * se_pred
}
```

---

## 6. Exercise-Specific Requirements

### Exercise 4-42

Use:
- data: `553, 552, 567, 579, 550, 541, 537, 553, 552, 546, 538, 553, 581, 539, 529`
- known `sigma = 20`
- `mu0 = 540`
- `alpha = 0.05`
- one-sided alternative: `H1: mu > 540`

Required outputs:
1. z statistic.
2. fixed-level decision.
3. P-value.
4. beta when true mean is `560`.
5. sample size so beta does not exceed `0.10` when true mean is `560`.
6. 95% one-sided lower CI.
7. conclusion using the CI.

### Exercise 4-44

Use Exercise 4-42’s known `sigma = 20`.

Required:
- `conf_level = 0.95`
- margin of error `E = 5`
- compute `n = ceiling((z * sigma / E)^2)`

### Exercise 4-54

Use:
- data: `23.01, 22.22, 22.04, 22.62, 22.59`
- `mu0 = 22.5`
- `alpha = 0.05`
- two-sided alternative: `H1: mu != 22.5`

Required:
1. t test via `t.test`.
2. P-value approach.
3. normality check via Shapiro-Wilk and Q-Q plot.
4. 95% CI.
5. sample size to detect true mean `22.75` with power at least `0.9`, using sample SD as `sigma`.

### Exercise 4-59

Use:
- data: `9.099, 9.174, 9.327, 9.377, 8.471, 9.575, 9.514, 8.928, 8.800, 8.920, 9.913, 8.306`
- `mu0 = 9`
- `alpha = 0.05`
- one-sided alternative: `H1: mu < 9`

Required:
1. normality check.
2. t test and decision.
3. 95% one-sided upper confidence bound.
4. use bound to test the hypothesis.
5. sample size to detect true mean `8.8` with probability at least `0.95`, using sample SD.

### Exercise 4-65

Use:
- data: `18.0, 30.7, 19.8, 27.1, 22.3, 18.8, 31.8, 23.4, 21.2, 27.9, 31.9, 27.1, 25.0, 24.7, 26.9, 21.8, 29.2, 34.8, 26.7, 31.6`
- `mu0 = 25`
- `alpha = 0.01`
- one-sided alternative: `H1: mu > 25`

Required:
1. t test.
2. P-value.
3. normality check.
4. power if true mean is `27`.
5. sample size to detect true mean `27.5` with power at least `0.9`.
6. one-sided lower confidence bound.

Important:
- The PDF says “mean diameter” in part (e), but the problem context is rainfall. Preserve a note:
  `# Note: The assignment text says "mean diameter"; context indicates this should be mean rainfall.`

### Exercise 4-71

Use:
- `n = 51`
- `s = 0.37`
- `sigma0 = 0.35`
- `alpha = 0.05`
- `H0: sigma = 0.35`
- `H1: sigma != 0.35`

Required:
1. state normal population assumption.
2. chi-square test statistic: `(n - 1) * s^2 / sigma0^2`.
3. two-sided P-value.
4. 95% CI for `sigma`.
5. use CI to test the hypothesis.

### Exercise 4-75

Use:
- `n = 30`
- `x = 11`
- `p0 = 0.25`
- `alpha = 0.10`
- one-sided alternative: `H1: p > 0.25`

Required:
1. one-proportion z test.
2. beta when true `p = 0.35`.
3. required sample size if beta should equal / not exceed `0.10`.
4. 90% traditional lower confidence bound.
5. use confidence bound to test.
6. required sample size for error on `p` less than `0.02` with at least 95% confidence, using initial estimate `phat = 11/30`.

### Exercise 4-76

Use:
- `n = 50`
- `x = 18`
- `p0 = 0.3`
- `alpha = 0.05`
- two-sided alternative: `H1: p != 0.3`

Required:
1. one-proportion z test.
2. P-value.
3. 95% two-sided traditional CI.
4. explain CI-based hypothesis test.
5. sample size using preliminary `phat = 18/50` for error `< 0.02`.
6. conservative sample size using `p = 0.5`.

### Exercise 4-89

Use Exercise 4-76 data:
- `n = 50`
- `x = 18`
- `conf_level = 0.95`

Required:
1. 95% Agresti-Coull two-sided CI.
2. compare with traditional CI from Exercise 4-76.
3. explicitly state that Agresti-Coull uses adjusted sample size and adjusted point estimate.

### Exercise 4-95

Use Exercise 4-59 diode data.

Required:
1. 99% prediction interval for one future diode.
2. normal tolerance interval including 99% of diodes with 99% confidence.

Use:

```r
tolerance::normtol.int(diode_values, alpha = 0.01, P = 0.99, side = 2)
```

For prediction interval use manual formula:

```r
xbar <- mean(x)
s <- sd(x)
n <- length(x)
alpha <- 0.01
crit <- qt(c(alpha/2, 1 - alpha/2), df = n - 1)
PI <- xbar + crit * s * sqrt(1 + 1/n)
```

---

## 7. Output Format Required

For every exercise, use this exact console report pattern:

```r
cat("\n====================================================\n")
cat(" EXERCISE 4-42: THERMOCOUPLE LIFE\n")
cat("====================================================\n")
cat("H0: mu <= 540\n")
cat("H1: mu > 540\n")
cat(sprintf("alpha = %.2f\n", alpha))
cat(sprintf("Sample size n = %d\n", n))
cat(sprintf("Sample mean = %.4f\n", xbar))
cat(sprintf("Test statistic = %.4f\n", z0))
cat(sprintf("P-value = %.4f\n", p_value))
cat("Decision:", if(p_value < alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
cat("Conclusion: ...\n")
cat("====================================================\n")
```

Do not only return raw R objects. The teacher’s output PDFs show both executed code and labeled console output; labeled output makes grading easier.

---

## 8. Plotting Standards

Use plots as supporting evidence, not decoration.

Preferred teacher-like visuals:
- histogram with density scale and normal overlay
- Q-Q plot
- boxplot with jitter
- run chart with mean line
- null distribution / rejection-region visualization
- power curve with target power line

Examples:

```r
ggplot(df, aes(x = value)) +
  geom_histogram(aes(y = after_stat(density)), bins = 6,
                 fill = "steelblue", color = "white") +
  stat_function(fun = dnorm,
                args = list(mean = mean(df$value), sd = sd(df$value)),
                color = "firebrick", linewidth = 1) +
  labs(title = "Density vs. Normal", x = "Value", y = "Density")
```

```r
ggplot(power_df, aes(x = delta, y = power, color = as.factor(n))) +
  geom_line(linewidth = 1) +
  geom_hline(yintercept = target_power, linetype = "dashed", color = "red") +
  labs(title = "Power Curves", x = expression(delta), y = "Power",
       color = "Sample Size (n)")
```

Save plots if the script is meant to be submitted:

```r
dir.create("plots", showWarnings = FALSE)
ggsave("plots/ex4_54_normality.png", width = 7, height = 5, dpi = 300)
```

---

## 9. Statistical Correctness Rules

1. Never confuse `sigma` with `s`.
   - Known variance section: use known `sigma`.
   - Unknown variance section: use sample `s`.

2. Do not use two-sided tests when the exercise asks for one-sided tests.

3. When computing one-sided confidence bounds:
   - `H1: mu > mu0` pairs naturally with a lower bound `[LCL, Inf)`.
   - `H1: mu < mu0` pairs naturally with an upper bound `(-Inf, UCL]`.

4. For proportions:
   - Use `phat = x / n`.
   - Traditional CI means Wald CI unless the problem specifically asks for Agresti-Coull.
   - Use Agresti-Coull only for Exercise 4-89, and compare against the traditional CI.

5. For Exercise 4-71:
   - The chi-square inference on `sigma` assumes the population is normally distributed.
   - The CI for `sigma` is the square root of the CI for `sigma^2`.

6. For Exercise 4-95:
   - Prediction interval is for one future observation.
   - Tolerance interval is for a population coverage proportion with a confidence level.
   - Do not confuse PI with CI.

7. Always use `ceiling()` for required sample size.

8. Verify sample-size calculations by checking both `n_req - 1` and `n_req`.

---

## 10. Boundaries and Things Not to Do

Do not:
- change any assignment data value;
- silently “fix” the PDF typo `mean diameter` without a note;
- use Python, Excel, or online calculators for the final computations;
- submit only final numeric answers without R code;
- over-engineer a package, Shiny app, or interactive dashboard;
- hide intermediate values;
- suppress warnings without explaining why;
- use random simulation where an exact formula is expected, except as an optional visualization or cross-check;
- add unrelated modern methods unless clearly labeled as cross-checks and not used as the final answer.

---

## 11. Commands

Recommended commands:

```bash
Rscript homework1.R > homework1_output.txt
```

Optional formatting:

```r
styler::style_file("homework1.R")
```

Expected generated files:

```text
homework1.R
homework1_output.txt
plots/
```

---

## 12. Final Self-Check Before Returning Code

Before finalizing any solution, verify:

- [ ] Every exercise from 4-42 to 4-95 is included.
- [ ] Every number from the problem statement is copied correctly.
- [ ] `alpha`, `conf_level`, `n`, `x`, `sigma`, `s`, `mu0`, and `p0` are explicitly defined.
- [ ] Each hypothesis test states `H0`, `H1`, test statistic, P-value, decision, and conclusion.
- [ ] Each CI/PI/TI prints endpoints with labels.
- [ ] Every sample-size result uses `ceiling()`.
- [ ] Every requested normality check includes both Shapiro-Wilk and Q-Q plot.
- [ ] The code runs from a clean R session.
- [ ] The output is readable in R Console format.
- [ ] Plots, if generated, are saved under `plots/`.

---

## 13. Preferred Voice in Comments

Comments should be clear and course-aligned:

Good:

```r
# beta is the probability of failing to reject H0 when the true mean is 560.
# Use the sample standard deviation as the estimate of sigma, as requested.
# Compare the confidence bound with the null value to reach the same decision.
```

Avoid:

```r
# AI-generated stuff
# magic happens here
# probably okay
```

Never mention AI generation, ChatGPT, Claude, Codex, or model names in submitted code.
