# =============================================================================
# Homework Assignments 1  ----  Chapter 4 Single-Sample Inference
# Exercises: 4-42, 4-44, 4-54, 4-59, 4-65, 4-71, 4-75, 4-76, 4-89, 4-95
# =============================================================================

## ---- init ----
# --- 1. Setup ----------------------------------------------------------------
# 包管理用 pacman，看看哪幾顆要載
if (!require(pacman)) install.packages("pacman", repos = "https://cloud.r-project.org")
pacman::p_load(tidyverse, car, BSDA, tolerance, ggpubr)

# 圖會丟到 plots/，沒資料夾就建
dir.create("plots", showWarnings = FALSE)

# 簡單的標題分隔線，跟老師 console 風格一致
print_header <- function(title) {
  cat("\n====================================================\n")
  cat(" ", title, "\n", sep = "")
  cat("====================================================\n")
}

print_subhead <- function(title) {
  cat(sprintf("\n--- %s ---\n", title))
}

# --- 2. Shared Helper Functions ---------------------------------------------

# 描述統計量，順便四捨五入
get_stats <- function(x) {
  data.frame(
    n         = length(x),
    Mean      = mean(x),
    Var       = var(x),
    Std_Dev   = sd(x),
    Std_Error = sd(x) / sqrt(length(x)),
    Median    = median(x)
  ) %>% mutate(across(everything(), ~round(., 4)))
}

# 已知 sigma 的 z 檢定 power
Pwr.z.test <- function(n, delta, sigma, alpha, alt = "two.sided") {
  m <- delta / (sigma / sqrt(n))
  if (alt == "two.sided") {
    1 - pnorm(qnorm(1 - alpha/2) - m) + pnorm(qnorm(alpha/2) - m)
  } else if (alt == "greater") {
    1 - pnorm(qnorm(1 - alpha) - m)
  } else {
    pnorm(qnorm(alpha) - m)
  }
}

# 已知 sigma 的 z 檢定樣本數
SplSz.z.test <- function(delta, sigma, alpha, pwr, side = 2) {
  ceiling(((qnorm(1 - alpha/side) + qnorm(pwr)) * sigma / abs(delta))^2)
}

# 已知 sigma 估平均數的 CI 樣本數 (margin of error 公式)
SplSz.z.CI <- function(E, sigma, conf_level, side = 2) {
  ceiling((qnorm(1 - (1 - conf_level)/side) * sigma / E)^2)
}

# 未知 sigma 的 t 檢定 power，用 noncentral t
Pwr.t.test.custom <- function(n, delta, sigma, alpha, alt = "two.sided") {
  df  <- n - 1
  ncp <- delta / (sigma / sqrt(n))
  if (alt == "two.sided") {
    1 - pt(qt(1 - alpha/2, df), df, ncp) + pt(qt(alpha/2, df), df, ncp)
  } else if (alt == "greater") {
    1 - pt(qt(1 - alpha, df), df, ncp)
  } else {
    pt(qt(alpha, df), df, ncp)
  }
}

# 迭代找最小 n，t 版本
find_min_n_t <- function(delta, sigma, alpha, target_power,
                         alt = "two.sided", n_start = 2, n_max = 5000) {
  for (n in n_start:n_max) {
    pw <- Pwr.t.test.custom(n, delta, sigma, alpha, alt)
    if (pw >= target_power) return(n)
  }
  stop("找不到符合條件的樣本數")
}

# 卡方檢定的 power (對 sigma 做檢定用)
Pwr.chisq.test <- function(n, r, alpha, alt = "two.sided") {
  df <- n - 1
  if (alt == "two.sided") {
    1 - pchisq(qchisq(1 - alpha/2, df) / r^2, df) +
      pchisq(qchisq(alpha/2, df) / r^2, df)
  } else if (alt == "greater") {
    1 - pchisq(qchisq(1 - alpha, df) / r^2, df)
  } else {
    pchisq(qchisq(alpha, df) / r^2, df)
  }
}

# 傳統 (Wald) 比例 CI
prop_wald_ci <- function(x, n, conf_level = 0.95, side = "two.sided") {
  phat  <- x / n
  alpha <- 1 - conf_level
  se    <- sqrt(phat * (1 - phat) / n)
  if (side == "two.sided") {
    z <- qnorm(1 - alpha/2)
    c(phat - z * se, phat + z * se)
  } else if (side == "lower") {
    z <- qnorm(conf_level)
    c(phat - z * se, Inf)
  } else {
    z <- qnorm(conf_level)
    c(-Inf, phat + z * se)
  }
}

# Agresti-Coull CI
agresti_coull_ci <- function(x, n, conf_level = 0.95) {
  alpha    <- 1 - conf_level
  z        <- qnorm(1 - alpha/2)
  n_tilde  <- n + z^2
  p_tilde  <- (x + z^2 / 2) / n_tilde
  se_tilde <- sqrt(p_tilde * (1 - p_tilde) / n_tilde)
  c(p_tilde - z * se_tilde, p_tilde + z * se_tilde)
}

# 一筆未來觀測的常態預測區間
prediction_interval_normal <- function(x, conf_level = 0.95) {
  n     <- length(x)
  xbar  <- mean(x)
  s     <- sd(x)
  alpha <- 1 - conf_level
  crit  <- qt(c(alpha/2, 1 - alpha/2), df = n - 1)
  xbar + crit * s * sqrt(1 + 1/n)
}

# Q-Q plot + 直方圖一起存，順便把 Shapiro-Wilk 結果與描述統計打到副標題
save_normality_plots <- function(x, title_tag, file_prefix) {
  df <- data.frame(value = x)
  sw <- shapiro.test(x)
  sw_sub <- sprintf("Shapiro-Wilk: W = %.4f, p = %.4f", sw$statistic, sw$p.value)
  stats_sub <- sprintf("n = %d, x_bar = %.4f, s = %.4f",
                       length(x), mean(x), sd(x))
  # Q-Q：點 + 理論直線 + Shapiro-Wilk 註解
  p_qq <- ggplot(df, aes(sample = value)) +
    stat_qq(color = "steelblue", size = 2.2) +
    stat_qq_line(color = "firebrick", linewidth = 0.8) +
    labs(title = paste("Normal Q-Q Plot:", title_tag),
         subtitle = sw_sub,
         x = "Theoretical Quantiles", y = "Sample Quantiles") +
    theme_minimal(base_size = 12)
  # 直方圖：n 太小 (<= 6) 用較少 bin，順便加 rug 把每筆觀測點都標出來
  bins_used <- if (length(x) <= 6) 4 else max(5, min(10, ceiling(log2(length(x)) + 1)))
  p_hist <- ggplot(df, aes(x = value)) +
    geom_histogram(aes(y = after_stat(density)),
                   bins = bins_used,
                   fill = "steelblue", color = "white", alpha = 0.85) +
    geom_rug(color = "navyblue", sides = "b", length = unit(0.04, "npc")) +
    stat_function(fun = dnorm,
                  args = list(mean = mean(x), sd = sd(x)),
                  color = "firebrick", linewidth = 1) +
    labs(title = paste("Histogram with Normal Curve:", title_tag),
         subtitle = stats_sub,
         x = "Value", y = "Density") +
    theme_minimal(base_size = 12)
  ggsave(paste0("plots/", file_prefix, "_qq.png"),
         p_qq,   width = 6.5, height = 4.5, dpi = 200)
  ggsave(paste0("plots/", file_prefix, "_hist.png"),
         p_hist, width = 6.5, height = 4.5, dpi = 200)
}

## ---- ex42 ----
# =============================================================================
# EXERCISE 4-42: Thermocouple Life (Section 4-4)
# 已知 sigma=20, n=15, mu0=540, alpha=0.05, H1: mu > 540
# =============================================================================
print_header("EXERCISE 4-42: THERMOCOUPLE LIFE")

# 原始資料，照題目 hard-code，不可改
thermo <- c(553, 552, 567, 579, 550, 541, 537, 553, 552,
            546, 538, 553, 581, 539, 529)

params_42 <- list(mu0 = 540, sigma = 20, alpha = 0.05, n = length(thermo))

print_subhead("Summary statistics")
print(get_stats(thermo))
cat(sprintf("Known sigma = %.4f\n", params_42$sigma))
cat(sprintf("Known SE    = %.4f\n", params_42$sigma / sqrt(params_42$n)))

# (a) z 檢定，one-sided greater
print_subhead("(a)(b) One-sided z-test, P-value approach")
(xbar     <- mean(thermo))
(se_42    <- params_42$sigma / sqrt(params_42$n))
(z0_42    <- (xbar - params_42$mu0) / se_42)
(p_42     <- 1 - pnorm(z0_42))
crit_42   <- qnorm(1 - params_42$alpha)

cat("H0: mu <= 540\n")
cat("H1: mu >  540\n")
cat(sprintf("alpha       = %.2f\n", params_42$alpha))
cat(sprintf("xbar        = %.4f\n", xbar))
cat(sprintf("z0          = %.4f\n", z0_42))
cat(sprintf("z critical  = %.4f\n", crit_42))
cat(sprintf("P-value     = %.4f\n", p_42))
cat("Decision: ",
    if (p_42 < params_42$alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
cat("Conclusion: ",
    if (p_42 < params_42$alpha)
      "There is evidence that mean life exceeds 540 hours.\n"
    else
      "Insufficient evidence that mean life exceeds 540 hours.\n")

# 套件交叉驗證
zchk_42 <- BSDA::z.test(thermo, mu = params_42$mu0,
                        sigma.x = params_42$sigma,
                        alternative = "greater")
cat(sprintf("[Cross-check BSDA::z.test]  z = %.4f, p = %.4f\n",
            zchk_42$statistic, zchk_42$p.value))

# (c) Beta，當真實 mu = 560
print_subhead("(c) Beta when true mu = 560")
# 拒絕門檻換算成 xbar 比較直觀
xbar_crit_42 <- params_42$mu0 + crit_42 * se_42
mu_true_42   <- 560
(beta_42c    <- pnorm((xbar_crit_42 - mu_true_42) / se_42))
power_42c    <- 1 - beta_42c
cat(sprintf("xbar critical = %.4f\n", xbar_crit_42))
cat(sprintf("beta          = %.4f\n", beta_42c))
cat(sprintf("power         = %.4f\n", power_42c))

# (d) 要 beta <= 0.10 需要的 n
print_subhead("(d) Sample size so beta <= 0.10 when true mu = 560")
delta_42d <- mu_true_42 - params_42$mu0
n_req_42d <- SplSz.z.test(delta = delta_42d, sigma = params_42$sigma,
                           alpha = params_42$alpha, pwr = 0.90, side = 1)
pw_minus  <- Pwr.z.test(n_req_42d - 1, delta_42d, params_42$sigma,
                        params_42$alpha, alt = "greater")
pw_at     <- Pwr.z.test(n_req_42d,     delta_42d, params_42$sigma,
                        params_42$alpha, alt = "greater")
cat(sprintf("Required n         = %d\n", n_req_42d))
cat(sprintf("Power at n-1 (%2d) = %.4f , beta = %.4f\n",
            n_req_42d - 1, pw_minus, 1 - pw_minus))
cat(sprintf("Power at n   (%2d) = %.4f , beta = %.4f\n",
            n_req_42d,     pw_at,    1 - pw_at))

# (e) 95% one-sided lower CI on mu
print_subhead("(e) 95% one-sided lower CI on mean life")
LCL_42 <- xbar - crit_42 * se_42
cat(sprintf("LCL = %.4f\n", LCL_42))
cat(sprintf("CI : [ %.4f , Inf )\n", LCL_42))

# (f) 用 CI 做檢定
print_subhead("(f) Test the hypothesis using the CI in (e)")
cat(sprintf("LCL = %.4f, mu0 = %d => ", LCL_42, params_42$mu0))
if (LCL_42 > params_42$mu0) {
  cat("LCL > 540, the null value lies outside the CI, reject H0.\n")
} else {
  cat("LCL <= 540, the null value lies inside the CI, do not reject H0.\n")
}

# Power curve 視覺化
power_grid_42 <- tibble(
  mu_true = seq(540, 580, length.out = 200)
) %>% mutate(
  power = Pwr.z.test(params_42$n, mu_true - params_42$mu0,
                     params_42$sigma, params_42$alpha, alt = "greater")
)
p_pow_42 <- ggplot(power_grid_42, aes(mu_true, power)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_hline(yintercept = 0.90, linetype = "dashed", color = "firebrick") +
  geom_vline(xintercept = 560, linetype = "dotted",  color = "darkgreen") +
  labs(title = "Ex 4-42 Power curve",
       subtitle = "known σ = 20, n = 15, α = 0.05",
       x = "True mean life", y = "Power") +
  theme_minimal(base_size = 12)
ggsave("plots/ex4_42_power_curve.png", p_pow_42,
       width = 6.5, height = 4.5, dpi = 200)


## ---- ex44 ----
# =============================================================================
# EXERCISE 4-44: Sample size for estimating the mean (Section 4-4)
# 沿用 4-42 的 sigma = 20，要 95% 信賴、誤差 < 5 小時
# =============================================================================
print_header("EXERCISE 4-44: SAMPLE SIZE FOR MEAN LIFE")

E_44       <- 5
sigma_44   <- 20
conf_44    <- 0.95
n_44       <- SplSz.z.CI(E = E_44, sigma = sigma_44,
                         conf_level = conf_44, side = 2)

cat(sprintf("Confidence level   = %.2f\n", conf_44))
cat(sprintf("Margin of error E  = %.0f\n", E_44))
cat(sprintf("sigma              = %.0f\n", sigma_44))
cat(sprintf("Required sample n  = %d\n", n_44))
# 用公式手算對一下
z_44 <- qnorm(1 - (1 - conf_44)/2)
cat(sprintf("Manual: ((z * sigma)/E)^2 = ((%.4f * %d)/%d)^2 = %.4f -> ceiling = %d\n",
            z_44, sigma_44, E_44, (z_44 * sigma_44 / E_44)^2, n_44))


## ---- ex54 ----
# =============================================================================
# EXERCISE 4-54: Interior Temperature  (Section 4-5)
# 未知 sigma, n=5, mu0=22.5, alpha=0.05, H1: mu != 22.5
# =============================================================================
print_header("EXERCISE 4-54: INTERIOR TEMPERATURE")

temp_int <- c(23.01, 22.22, 22.04, 22.62, 22.59)
params_54 <- list(mu0 = 22.5, alpha = 0.05, n = length(temp_int))

print_subhead("Summary statistics")
print(get_stats(temp_int))

# (b) 常態性檢查
print_subhead("(b) Normality check  (Shapiro-Wilk + Q-Q plot)")
(sw_54 <- shapiro.test(temp_int))
cat("樣本數很小，Shapiro-Wilk power 不高，需要搭配 Q-Q plot 一起看。\n")
save_normality_plots(temp_int, "Ex 4-54 Interior Temperature", "ex4_54")
cat("Plots saved: plots/ex4_54_qq.png, plots/ex4_54_hist.png\n")

# (a) t 檢定，雙尾
print_subhead("(a) Two-sided t-test")
t_54 <- t.test(temp_int, mu = params_54$mu0, alternative = "two.sided",
               conf.level = 0.95)
xbar_54 <- mean(temp_int)
s_54    <- sd(temp_int)
se_54   <- s_54 / sqrt(params_54$n)
t0_54   <- (xbar_54 - params_54$mu0) / se_54
p_54    <- 2 * (1 - pt(abs(t0_54), df = params_54$n - 1))

cat("H0: mu  = 22.5\n")
cat("H1: mu != 22.5\n")
cat(sprintf("xbar     = %.4f\n", xbar_54))
cat(sprintf("s        = %.4f\n", s_54))
cat(sprintf("t0       = %.4f\n", t0_54))
cat(sprintf("df       = %d\n",   params_54$n - 1))
cat(sprintf("P-value  = %.4f\n", p_54))
cat("Decision: ",
    if (p_54 < params_54$alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
cat(sprintf("[t.test cross-check]  t = %.4f, p = %.4f\n",
            t_54$statistic, t_54$p.value))

# (c) 95% CI
print_subhead("(c) 95% CI for mean interior temperature")
CI_54 <- as.numeric(t_54$conf.int)
cat(sprintf("CI = (%.4f , %.4f)\n", CI_54[1], CI_54[2]))

# (d) 樣本數，要 power >= 0.9 偵測 mu=22.75
print_subhead("(d) Sample size for power >= 0.9, true mu = 22.75")
delta_54d  <- 22.75 - params_54$mu0
sigma_54d  <- s_54
n_req_54d  <- find_min_n_t(delta = delta_54d, sigma = sigma_54d,
                            alpha = params_54$alpha,
                            target_power = 0.90, alt = "two.sided")
pw_minus54 <- Pwr.t.test.custom(n_req_54d - 1, delta_54d, sigma_54d,
                                params_54$alpha, alt = "two.sided")
pw_at_54   <- Pwr.t.test.custom(n_req_54d,     delta_54d, sigma_54d,
                                params_54$alpha, alt = "two.sided")
cat(sprintf("delta       = %.4f, sigma (=s) = %.4f\n", delta_54d, sigma_54d))
cat(sprintf("Required n  = %d\n", n_req_54d))
cat(sprintf("Power at n-1 (%d) = %.4f\n", n_req_54d - 1, pw_minus54))
cat(sprintf("Power at n   (%d) = %.4f\n", n_req_54d,     pw_at_54))


## ---- ex59 ----
# =============================================================================
# EXERCISE 4-59: Diode Breakdown Voltage (Section 4-5)
# n=12, mu0=9, alpha=0.05, H1: mu < 9
# =============================================================================
print_header("EXERCISE 4-59: DIODE BREAKDOWN VOLTAGE")

diode_v <- c(9.099, 9.174, 9.327, 9.377, 8.471, 9.575,
             9.514, 8.928, 8.800, 8.920, 9.913, 8.306)

params_59 <- list(mu0 = 9, alpha = 0.05, n = length(diode_v))

print_subhead("Summary statistics")
print(get_stats(diode_v))

# (a) 常態性
print_subhead("(a) Normality check")
(sw_59 <- shapiro.test(diode_v))
save_normality_plots(diode_v, "Ex 4-59 Diode Voltage", "ex4_59")
cat("Plots saved: plots/ex4_59_qq.png, plots/ex4_59_hist.png\n")

# (b) t 檢定，one-sided less
print_subhead("(b) One-sided t-test, H1: mu < 9")
t_59      <- t.test(diode_v, mu = params_59$mu0, alternative = "less",
                    conf.level = 0.95)
xbar_59   <- mean(diode_v)
s_59      <- sd(diode_v)
se_59     <- s_59 / sqrt(params_59$n)
t0_59     <- (xbar_59 - params_59$mu0) / se_59
p_59      <- pt(t0_59, df = params_59$n - 1)

cat(sprintf("xbar    = %.4f\n", xbar_59))
cat(sprintf("s       = %.4f\n", s_59))
cat(sprintf("t0      = %.4f\n", t0_59))
cat(sprintf("df      = %d\n",   params_59$n - 1))
cat(sprintf("P-value = %.4f\n", p_59))
cat("Decision: ",
    if (p_59 < params_59$alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
cat(sprintf("[t.test cross-check]  t = %.4f, p = %.4f\n",
            t_59$statistic, t_59$p.value))

# (c) 95% one-sided upper bound
print_subhead("(c) 95% one-sided upper confidence bound")
UCL_59 <- xbar_59 + qt(1 - params_59$alpha, df = params_59$n - 1) * se_59
cat(sprintf("UCL = %.4f\n", UCL_59))
cat(sprintf("CI : ( -Inf , %.4f ]\n", UCL_59))

# (d) 用 UCL 做檢定
print_subhead("(d) Test using the upper bound from (c)")
cat(sprintf("UCL = %.4f, mu0 = %d => ", UCL_59, params_59$mu0))
if (UCL_59 < params_59$mu0) {
  cat("UCL < 9, mu0 lies outside the CI, reject H0.\n")
} else {
  cat("UCL >= 9, mu0 lies inside the CI, do not reject H0.\n")
}

# (e) 樣本數要 power >= 0.95, 偵測 mu=8.8
print_subhead("(e) Sample size for power >= 0.95, true mu = 8.8")
delta_59e <- 8.8 - params_59$mu0
sigma_59e <- s_59
n_req_59e <- find_min_n_t(delta = delta_59e, sigma = sigma_59e,
                           alpha = params_59$alpha,
                           target_power = 0.95, alt = "less")
pw_minus59 <- Pwr.t.test.custom(n_req_59e - 1, delta_59e, sigma_59e,
                                params_59$alpha, alt = "less")
pw_at_59   <- Pwr.t.test.custom(n_req_59e,     delta_59e, sigma_59e,
                                params_59$alpha, alt = "less")
cat(sprintf("delta = %.4f, sigma (=s) = %.4f\n", delta_59e, sigma_59e))
cat(sprintf("Required n = %d\n", n_req_59e))
cat(sprintf("Power at n-1 (%d) = %.4f\n", n_req_59e - 1, pw_minus59))
cat(sprintf("Power at n   (%d) = %.4f\n", n_req_59e,     pw_at_59))


## ---- ex65 ----
# =============================================================================
# EXERCISE 4-65: Cloud Seeding Rainfall (Section 4-5)
# n=20, mu0=25, alpha=0.01, H1: mu > 25
# Note: 題目 (e) 寫 mean diameter，但全題討論的是 rainfall，疑似誤植
# =============================================================================
print_header("EXERCISE 4-65: CLOUD SEEDING RAINFALL")

rain <- c(18.0, 30.7, 19.8, 27.1, 22.3, 18.8, 31.8, 23.4, 21.2, 27.9,
          31.9, 27.1, 25.0, 24.7, 26.9, 21.8, 29.2, 34.8, 26.7, 31.6)

params_65 <- list(mu0 = 25, alpha = 0.01, n = length(rain))

print_subhead("Summary statistics")
print(get_stats(rain))

# (b) 常態性 (先看圖再做 t test)
print_subhead("(b) Normality check")
(sw_65 <- shapiro.test(rain))
save_normality_plots(rain, "Ex 4-65 Cloud Seeding Rainfall", "ex4_65")
cat("Plots saved: plots/ex4_65_qq.png, plots/ex4_65_hist.png\n")

# (a) t 檢定，one-sided greater
print_subhead("(a) One-sided t-test, P-value")
t_65    <- t.test(rain, mu = params_65$mu0, alternative = "greater",
                  conf.level = 0.99)
xbar_65 <- mean(rain)
s_65    <- sd(rain)
se_65   <- s_65 / sqrt(params_65$n)
t0_65   <- (xbar_65 - params_65$mu0) / se_65
p_65    <- 1 - pt(t0_65, df = params_65$n - 1)
cat(sprintf("xbar     = %.4f\n", xbar_65))
cat(sprintf("s        = %.4f\n", s_65))
cat(sprintf("t0       = %.4f\n", t0_65))
cat(sprintf("df       = %d\n",   params_65$n - 1))
cat(sprintf("P-value  = %.4f\n", p_65))
cat("Decision: ",
    if (p_65 < params_65$alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
cat(sprintf("[t.test cross-check]  t = %.4f, p = %.4f\n",
            t_65$statistic, t_65$p.value))

# (c) Power, true mu = 27
print_subhead("(c) Power if true mu = 27")
delta_65c <- 27 - params_65$mu0
pw_65c    <- Pwr.t.test.custom(params_65$n, delta_65c, s_65,
                                params_65$alpha, alt = "greater")
cat(sprintf("delta = %.4f, sigma (=s) = %.4f\n", delta_65c, s_65))
cat(sprintf("Power = %.4f, beta = %.4f\n", pw_65c, 1 - pw_65c))

# (d) 樣本數，要 power >= 0.9，true mu = 27.5
print_subhead("(d) Sample size for power >= 0.9, true mu = 27.5")
delta_65d  <- 27.5 - params_65$mu0
n_req_65d  <- find_min_n_t(delta = delta_65d, sigma = s_65,
                            alpha = params_65$alpha,
                            target_power = 0.90, alt = "greater")
pw_minus65 <- Pwr.t.test.custom(n_req_65d - 1, delta_65d, s_65,
                                params_65$alpha, alt = "greater")
pw_at_65   <- Pwr.t.test.custom(n_req_65d,     delta_65d, s_65,
                                params_65$alpha, alt = "greater")
cat(sprintf("Required n = %d\n", n_req_65d))
cat(sprintf("Power at n-1 (%d) = %.4f\n", n_req_65d - 1, pw_minus65))
cat(sprintf("Power at n   (%d) = %.4f\n", n_req_65d,     pw_at_65))

# (e) 一邊下界 CI 解釋
# 題目寫 mean diameter，但脈絡是 rainfall，這邊照題目敘述但加註
print_subhead("(e) One-sided lower confidence bound for mean rainfall")
cat("Note: The textbook says 'mean diameter' in part (e); the context indicates ")
cat("this should be 'mean rainfall'. We answer for mean rainfall.\n")
LCL_65e <- xbar_65 - qt(1 - params_65$alpha, df = params_65$n - 1) * se_65
cat(sprintf("LCL = %.4f\n", LCL_65e))
cat(sprintf("CI : [ %.4f , Inf )\n", LCL_65e))
cat(sprintf("Compare LCL with mu0 = %d: ", params_65$mu0))
if (LCL_65e > params_65$mu0) {
  cat("LCL > 25, reject H0 -- supports the claim.\n")
} else {
  cat("LCL <= 25, do not reject H0.\n")
}


## ---- ex71 ----
# =============================================================================
# EXERCISE 4-71: Titanium Alloy Standard Deviation (Section 4-6)
# n=51, s=0.37, sigma0=0.35, alpha=0.05, two-sided
# =============================================================================
print_header("EXERCISE 4-71: TITANIUM ALLOY SIGMA TEST")

# 題目只給 summary，沒有原始資料，hard-code 即可
n_71      <- 51
s_71      <- 0.37
sigma0_71 <- 0.35
alpha_71  <- 0.05
df_71     <- n_71 - 1

cat("假設母體近似常態分配，這個 chi-square test 才有效。\n")

# (a)(b) 卡方統計量、P-value
print_subhead("(a)(b) Chi-square test")
chi0_71   <- (n_71 - 1) * s_71^2 / sigma0_71^2
# 雙尾 P-value 取 2 * min(left, right)
p_left    <- pchisq(chi0_71, df_71)
p_right   <- 1 - pchisq(chi0_71, df_71)
p_71      <- 2 * min(p_left, p_right)

cat("H0: sigma  = 0.35\n")
cat("H1: sigma != 0.35\n")
cat(sprintf("chi0    = %.4f\n", chi0_71))
cat(sprintf("df      = %d\n",   df_71))
cat(sprintf("P-value = %.4f\n", p_71))
cat(sprintf("Critical: chi^2_{0.025,%d} = %.4f, chi^2_{0.975,%d} = %.4f\n",
            df_71, qchisq(0.975, df_71), df_71, qchisq(0.025, df_71)))
cat("Decision: ",
    if (p_71 < alpha_71) "REJECT H0" else "FAIL TO REJECT H0", "\n")

# (c) 95% CI for sigma
# 先做 sigma^2 的 CI 再開根號
print_subhead("(c) 95% two-sided CI for sigma")
LCL_var <- (n_71 - 1) * s_71^2 / qchisq(1 - alpha_71/2, df_71)
UCL_var <- (n_71 - 1) * s_71^2 / qchisq(    alpha_71/2, df_71)
LCL_sd  <- sqrt(LCL_var)
UCL_sd  <- sqrt(UCL_var)
cat(sprintf("CI for sigma^2 : (%.4f , %.4f)\n", LCL_var, UCL_var))
cat(sprintf("CI for sigma   : (%.4f , %.4f)\n", LCL_sd,  UCL_sd))

# (d) 用 CI 做檢定
print_subhead("(d) Test the hypothesis using the CI")
cat(sprintf("Is sigma0 = %.2f inside (%.4f, %.4f)? ", sigma0_71, LCL_sd, UCL_sd))
if (sigma0_71 >= LCL_sd && sigma0_71 <= UCL_sd) {
  cat("Yes => do not reject H0.\n")
} else {
  cat("No  => reject H0.\n")
}


## ---- ex75 ----
# =============================================================================
# EXERCISE 4-75: Van Rollover Proportion (Section 4-7)
# n=30, x=11, p0=0.25, alpha=0.10, H1: p > 0.25
# =============================================================================
print_header("EXERCISE 4-75: VAN ROLLOVER PROPORTION")

n_75    <- 30
x_75    <- 11
p0_75   <- 0.25
alpha_75 <- 0.10
phat_75 <- x_75 / n_75

cat(sprintf("phat = %d / %d = %.4f\n", x_75, n_75, phat_75))

# (a) z 檢定
print_subhead("(a) One-proportion z-test, H1: p > 0.25")
se0_75 <- sqrt(p0_75 * (1 - p0_75) / n_75)
z0_75  <- (phat_75 - p0_75) / se0_75
p_75   <- 1 - pnorm(z0_75)
cat(sprintf("z0      = %.4f\n", z0_75))
cat(sprintf("P-value = %.4f\n", p_75))
cat("Decision: ",
    if (p_75 < alpha_75) "REJECT H0" else "FAIL TO REJECT H0", "\n")
# 套件交叉驗證 (correct=FALSE 不做連續性修正)
ptest_75 <- prop.test(x_75, n_75, p = p0_75, alternative = "greater",
                       correct = FALSE)
cat(sprintf("[prop.test cross-check]  chi^2 = %.4f, p = %.4f\n",
            ptest_75$statistic, ptest_75$p.value))

# (b) Beta，true p = 0.35
print_subhead("(b) Beta when true p = 0.35")
# 在 H0 下找臨界 phat
phat_crit <- p0_75 + qnorm(1 - alpha_75) * se0_75
true_p    <- 0.35
se_true   <- sqrt(true_p * (1 - true_p) / n_75)
beta_75b  <- pnorm((phat_crit - true_p) / se_true)
cat(sprintf("phat critical = %.4f\n", phat_crit))
cat(sprintf("beta          = %.4f\n", beta_75b))

# (c) 樣本數要 beta = 0.10
print_subhead("(c) Sample size so beta = 0.10 when true p = 0.35")
z_alpha <- qnorm(1 - alpha_75)
z_beta  <- qnorm(1 - 0.10)
num_75  <- z_alpha * sqrt(p0_75*(1-p0_75)) + z_beta * sqrt(true_p*(1-true_p))
n_75c   <- ceiling((num_75 / (true_p - p0_75))^2)
cat(sprintf("Required n = %d\n", n_75c))

# (d) 90% one-sided lower bound
print_subhead("(d) 90% traditional one-sided lower confidence bound")
LCB_75 <- prop_wald_ci(x_75, n_75, conf_level = 0.90, side = "lower")[1]
cat(sprintf("LCB = %.4f\n", LCB_75))
cat(sprintf("CI : [ %.4f , 1 ]\n", LCB_75))

# (e) 用 LCB 做檢定
print_subhead("(e) Test using the lower bound")
cat(sprintf("LCB = %.4f vs p0 = %.2f => ", LCB_75, p0_75))
if (LCB_75 > p0_75) {
  cat("LCB > 0.25, reject H0 -- claim supported.\n")
} else {
  cat("LCB <= 0.25, do not reject H0.\n")
}

# (f) 樣本數要誤差 < 0.02，95% confident，用 phat = 11/30
print_subhead("(f) Sample size for E < 0.02, 95% confidence, phat = 11/30")
z_95   <- qnorm(0.975)
n_75f  <- ceiling(z_95^2 * phat_75 * (1 - phat_75) / 0.02^2)
cat(sprintf("Using phat = %.4f, required n = %d\n", phat_75, n_75f))


## ---- ex76 ----
# =============================================================================
# EXERCISE 4-76: Helmet Damage Proportion (Section 4-7)
# n=50, x=18, p0=0.3, alpha=0.05, H1: p != 0.3
# =============================================================================
print_header("EXERCISE 4-76: HELMET DAMAGE PROPORTION")

n_76    <- 50
x_76    <- 18
p0_76   <- 0.30
alpha_76 <- 0.05
phat_76 <- x_76 / n_76

cat(sprintf("phat = %d / %d = %.4f\n", x_76, n_76, phat_76))

# (a)(b) z 檢定 + P-value
print_subhead("(a)(b) Two-sided z-test")
se0_76 <- sqrt(p0_76 * (1 - p0_76) / n_76)
z0_76  <- (phat_76 - p0_76) / se0_76
p_76   <- 2 * (1 - pnorm(abs(z0_76)))
cat(sprintf("z0      = %.4f\n", z0_76))
cat(sprintf("P-value = %.4f\n", p_76))
cat("Decision: ",
    if (p_76 < alpha_76) "REJECT H0" else "FAIL TO REJECT H0", "\n")
# 套件交叉驗證
ptest_76 <- prop.test(x_76, n_76, p = p0_76, alternative = "two.sided",
                       correct = FALSE)
cat(sprintf("[prop.test cross-check]  chi^2 = %.4f, p = %.4f\n",
            ptest_76$statistic, ptest_76$p.value))

# (c) 95% two-sided traditional CI
print_subhead("(c) 95% two-sided traditional CI")
CI_76 <- prop_wald_ci(x_76, n_76, conf_level = 0.95, side = "two.sided")
cat(sprintf("CI = (%.4f , %.4f)\n", CI_76[1], CI_76[2]))
cat(sprintf("Is p0 = %.2f inside the CI? ", p0_76))
if (p0_76 >= CI_76[1] && p0_76 <= CI_76[2]) {
  cat("Yes => fail to reject H0 (consistent with the test).\n")
} else {
  cat("No  => reject H0.\n")
}

# (d) 樣本數要 E < 0.02，用 phat = 18/50
print_subhead("(d) Sample size for E < 0.02, 95% conf., using phat = 18/50")
z95_76 <- qnorm(0.975)
n_76d  <- ceiling(z95_76^2 * phat_76 * (1 - phat_76) / 0.02^2)
cat(sprintf("Using phat = %.4f, required n = %d\n", phat_76, n_76d))

# (e) 保守樣本數，用 p = 0.5
print_subhead("(e) Conservative sample size using p = 0.5")
n_76e <- ceiling(z95_76^2 * 0.5 * 0.5 / 0.02^2)
cat(sprintf("Using p = 0.50, required n = %d\n", n_76e))


## ---- ex89 ----
# =============================================================================
# EXERCISE 4-89: Agresti-Coull CI vs Traditional (Section 4-7)
# 用 4-76 的資料: n=50, x=18, 95% confidence
# =============================================================================
print_header("EXERCISE 4-89: AGRESTI-COULL CI")

ac_89 <- agresti_coull_ci(x_76, n_76, conf_level = 0.95)

# Agresti-Coull 是把 (x, n) 換成 (x + z^2/2, n + z^2)
z_89   <- qnorm(0.975)
n_t_89 <- n_76 + z_89^2
p_t_89 <- (x_76 + z_89^2 / 2) / n_t_89

cat("Agresti-Coull 用調整過的樣本數和點估計來建立 CI，這是和傳統 Wald CI 的核心差別。\n")
cat(sprintf("Adjusted n_tilde = %.4f\n", n_t_89))
cat(sprintf("Adjusted p_tilde = %.4f\n", p_t_89))
cat(sprintf("Agresti-Coull CI : (%.4f , %.4f)\n", ac_89[1], ac_89[2]))
cat(sprintf("Traditional CI   : (%.4f , %.4f)\n", CI_76[1], CI_76[2]))
cat(sprintf("Width comparison : AC width = %.4f, traditional width = %.4f\n",
            ac_89[2] - ac_89[1], CI_76[2] - CI_76[1]))


## ---- ex95 ----
# =============================================================================
# EXERCISE 4-95: Prediction & Tolerance Interval (Section 4-8)
# 沿用 4-59 的二極體資料，99% PI 與 99% / 99% TI
# =============================================================================
print_header("EXERCISE 4-95: PI AND TOLERANCE INTERVAL")

# (a) 99% PI for one future observation
print_subhead("(a) 99% Prediction Interval for one future diode")
PI_95 <- prediction_interval_normal(diode_v, conf_level = 0.99)
cat(sprintf("xbar = %.4f, s = %.4f, n = %d\n",
            mean(diode_v), sd(diode_v), length(diode_v)))
cat(sprintf("PI = (%.4f , %.4f)\n", PI_95[1], PI_95[2]))
cat("PI 的標的是『下一筆觀測值』，比 CI 寬一些是正常的。\n")

# (b) Tolerance interval, 99% population coverage with 99% confidence
print_subhead("(b) 99%/99% two-sided normal tolerance interval")
TI_95 <- tolerance::normtol.int(diode_v, alpha = 0.01, P = 0.99, side = 2)
print(TI_95)
cat(sprintf("\nTI = (%.4f , %.4f)\n",
            TI_95$`2-sided.lower`, TI_95$`2-sided.upper`))
cat("TI 是希望涵蓋『母體中 99% 的個體』，而不是平均數，所以會比 PI 再寬一點。\n")

# 視覺化 PI / TI / CI 三者
ci_95 <- t.test(diode_v, conf.level = 0.99)$conf.int
intervals_df <- tibble(
  type   = c("99% CI for mean", "99% PI", "99% / 99% TI"),
  lower  = c(ci_95[1], PI_95[1], TI_95$`2-sided.lower`),
  upper  = c(ci_95[2], PI_95[2], TI_95$`2-sided.upper`)
) %>% mutate(width = upper - lower)
print(intervals_df)

p_intvl <- ggplot(intervals_df, aes(y = fct_inorder(type))) +
  geom_segment(aes(x = lower, xend = upper, yend = type),
               linewidth = 1.5, color = "steelblue") +
  geom_point(aes(x = lower), size = 3, color = "firebrick") +
  geom_point(aes(x = upper), size = 3, color = "firebrick") +
  geom_vline(xintercept = mean(diode_v), linetype = "dashed",
             color = "darkgreen") +
  labs(title = "Ex 4-95: CI, PI, and Tolerance Interval (diode voltage)",
       x = "Breakdown voltage", y = NULL) +
  theme_minimal(base_size = 12)
ggsave("plots/ex4_95_intervals.png", p_intvl,
       width = 7, height = 4, dpi = 200)
cat("Plot saved: plots/ex4_95_intervals.png\n")


# =============================================================================
# 結束
# =============================================================================
cat("\n====================================================\n")
cat(" All exercises completed.\n")
cat("====================================================\n")
