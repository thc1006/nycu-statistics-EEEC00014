# =============================================================================
# Homework Assignments 2  ----  Chapter 5 Decision Making for Two Samples
# Exercises: 5-3, 5-5, 5-9, 5-17, 5-24, 5-41, 5-59, 5-69, 5-71, 5-73
# =============================================================================

## ---- init ----
# --- 1. Setup ---------------------------------------------------------------
# 老師 R 範例都用 pacman 統一載套件，這邊照辦
if (!require(pacman)) install.packages("pacman", repos = "https://cloud.r-project.org")
pacman::p_load(HH, BSDA, ggplot2, purrr, dplyr, car, tibble, tidyr)

# 圖通通丟到 figures/，沒資料夾就先開
dir.create("figures", showWarnings = FALSE)

# 跟 console 一樣的標題分隔線，方便對版
print_header <- function(title) {
  cat("\n============================================================\n")
  cat(" ", title, "\n", sep = "")
  cat("============================================================\n")
}
print_subhead <- function(title) {
  cat(sprintf("\n--- %s ---\n", title))
}

# 全班預設四捨五入到第三位小數，這支腳本通用
fmt3 <- function(x) formatC(x, format = "f", digits = 3)


# --- 2. Reusable Functions -------------------------------------------------

# 兩樣本（含單樣本）的 z 檢定 power，這邊 sigma 可吃單一值或長度 2 向量
# delta 已經吃「真實平均差 - 虛無值」，所以呼叫端要自己算好
Pwr.z.test <- function(n, delta, sigma, alpha, alt = "two.sided") {
  # n 跟 sigma 都可以是長度 2 的向量；若只給一個就當兩組相同
  if (length(n) == 1)     n     <- rep(n,     2)
  if (length(sigma) == 1) sigma <- rep(sigma, 2)
  se <- sqrt(sum(sigma^2 / n))
  m  <- delta / se
  if (alt == "two.sided") {
    return(1 - pnorm(qnorm(1 - alpha/2) - m) + pnorm(qnorm(alpha/2) - m))
  } else if (alt == "greater") {
    return(1 - pnorm(qnorm(1 - alpha) - m))
  } else {
    return(pnorm(qnorm(alpha) - m))
  }
}

# 兩樣本 z 檢定的「等樣本數」公式：sigma 可吃單一或向量
# 課本第 5-2 節公式：n = (z_{a/side} + z_{pwr})^2 * (sigma1^2 + sigma2^2) / delta^2
SplSz.z.test <- function(delta, sigma, alpha, pwr, side = 2) {
  if (length(sigma) == 1) sigma <- rep(sigma, 2)
  ceiling(((qnorm(1 - alpha/side) + qnorm(pwr))^2 * sum(sigma^2)) / delta^2)
}

# 兩樣本 z 區間估計的等樣本數：CI 寬要 <= 2E
# n = (z_{(1-conf)/side} * sqrt(sigma1^2 + sigma2^2) / E)^2
SplSz.z.CI <- function(E, sigma, conf.level, side = 2) {
  if (length(sigma) == 1) sigma <- rep(sigma, 2)
  ceiling((qnorm(1 - (1 - conf.level)/side))^2 * sum(sigma^2) / E^2)
}

# Pooled t 的 power 直接走 stats::power.t.test，介面跟老師範例一致
# delta 是真平均差，sigma 是 pooled SD 的估計值
Pwr.t.test <- function(n, delta, sigma, alpha, alt = "two.sided") {
  side <- if (alt == "two.sided") "two.sided" else "one.sided"
  power.t.test(n         = n,
               delta     = abs(delta),
               sd        = sigma,
               sig.level = alpha,
               type      = "two.sample",
               alternative = side)$power
}

# 兩比例的標準誤、調整估計值（Agresti-Caffo plus-four）一次包好，呼叫端拿去組
TwoPropStats <- function(x, n) {
  phat       <- x / n
  qhat       <- 1 - phat
  phat.diff  <- -diff(phat)               # p1 - p2
  phat.p     <- sum(x) / sum(n)           # pooled point estimate
  qhat.p     <- 1 - phat.p
  se.p       <- sqrt(phat.p * qhat.p * sum(1 / n))   # pooled SE (for null test)
  sehat      <- sqrt(sum(phat * qhat / n))           # unpooled SE (for CI)
  # plus-four / Agresti-Caffo
  ntilde     <- n + 2
  xtilde     <- x + 1
  ptilde     <- xtilde / ntilde
  qtilde     <- 1 - ptilde
  ptilde.diff <- -diff(ptilde)
  setilde    <- sqrt(sum(ptilde * qtilde / ntilde))
  list(phat = phat, qhat = qhat, phat.diff = phat.diff,
       phat.p = phat.p, qhat.p = qhat.p, se.p = se.p, sehat = sehat,
       ntilde = ntilde, xtilde = xtilde, ptilde = ptilde,
       qtilde = qtilde, ptilde.diff = ptilde.diff, setilde = setilde)
}

# 兩比例檢定的 power（課本第 5-6 節公式，已知 pA、pB）
# 拒絕域用 pooled SE，power 在 H1 下用 unpooled SE
Pwr.prop2.test <- function(n, pA, pB, alpha, alt = "greater") {
  if (length(n) == 1) n <- rep(n, 2)
  p_bar  <- (n[1]*pA + n[2]*pB) / sum(n)
  q_bar  <- 1 - p_bar
  se0    <- sqrt(p_bar * q_bar * sum(1 / n))
  se1    <- sqrt(pA*(1-pA)/n[1] + pB*(1-pB)/n[2])
  d      <- pA - pB
  if (alt == "greater") {
    return(1 - pnorm((qnorm(1 - alpha) * se0 - d) / se1))
  } else if (alt == "less") {
    return(pnorm((qnorm(alpha) * se0 - d) / se1))
  } else {
    return(1 - pnorm(( qnorm(1 - alpha/2) * se0 - d) / se1)
           +     pnorm((-qnorm(1 - alpha/2) * se0 - d) / se1))
  }
}

# 兩比例的「等樣本數」近似公式
SplSz.prop2.test <- function(pA, pB, alpha, pwr, side = 2) {
  d <- pA - pB
  p_bar <- (pA + pB) / 2
  q_bar <- 1 - p_bar
  z_a <- qnorm(1 - alpha/side)
  z_b <- qnorm(pwr)
  num <- z_a * sqrt(2 * p_bar * q_bar) + z_b * sqrt(pA*(1-pA) + pB*(1-pB))
  ceiling((num / d)^2)
}

# 描述統計小工具，順便壓三位小數方便看
get_stats <- function(x) {
  data.frame(
    n         = length(x),
    Mean      = mean(x),
    Var       = var(x),
    Std_Dev   = sd(x),
    Std_Error = sd(x) / sqrt(length(x)),
    Median    = median(x)
  ) %>% mutate(across(everything(), ~ round(., 3)))
}

# Q-Q + 直方圖一次存（給 5-41 paired diff 用）
# x_label 走具體的軸名，避免印出 "Value" 這種沒資訊量的字
save_normality_plots <- function(x, title_tag, file_prefix, x_label = "Value") {
  df <- data.frame(value = x)
  sw <- shapiro.test(x)
  sw_sub <- sprintf("Shapiro-Wilk: W = %.3f, p = %.3f", sw$statistic, sw$p.value)
  stats_sub <- sprintf("n = %d, x_bar = %.3f, s = %.3f",
                       length(x), mean(x), sd(x))
  p_qq <- ggplot(df, aes(sample = value)) +
    stat_qq(color = "steelblue", size = 2.4) +
    stat_qq_line(color = "firebrick", linewidth = 0.9) +
    labs(title = paste("Normal Q-Q Plot:", title_tag),
         subtitle = sw_sub,
         x = "Theoretical normal quantiles",
         y = paste0("Sample quantiles of ", x_label)) +
    theme_minimal(base_size = 13) +
    theme(plot.title    = element_text(face = "bold"),
          axis.title    = element_text(face = "bold"))
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
         x = x_label, y = "Density") +
    theme_minimal(base_size = 13) +
    theme(plot.title    = element_text(face = "bold"),
          axis.title    = element_text(face = "bold"))
  ggsave(paste0("figures/", file_prefix, "_qq.png"),
         p_qq, width = 7.5, height = 5.2, dpi = 220)
  ggsave(paste0("figures/", file_prefix, "_hist.png"),
         p_hist, width = 7.5, height = 5.2, dpi = 220)
}


## ---- ex5_03 ----
# =============================================================================
# EXERCISE 5-3: Bottle Filling Machines  (Section 5-2)
# 兩台機台、已知 sigma1 = 0.020, sigma2 = 0.025；雙尾、alpha = 0.05
# =============================================================================
print_header("EXERCISE 5-3: BOTTLE FILLING MACHINES")

# 題目資料原樣 hard-code，每組 10 筆
Machine1 <- c(16.03, 16.01,
              16.04, 15.96,
              16.05, 15.98,
              16.05, 16.02,
              16.02, 15.99)

Machine2 <- c(16.02, 16.03,
              15.97, 16.04,
              15.96, 16.02,
              16.01, 16.01,
              15.99, 16.00)

params <- list(sigma  = c(0.020, 0.025),
               n      = c(length(Machine1), length(Machine2)),
               Delta0 = 0,
               alpha  = 0.05,
               conf.level = 0.95)

# --- 1. Basic Stats ---
print_subhead("Sample summary")
print(get_stats(Machine1))
print(get_stats(Machine2))

# 老師常用括號賦值，順手把 xbar、se0、z0 印出來
(xbar  <- c(mean(Machine1), mean(Machine2)))
(se0   <- sqrt(sum(params$sigma^2 / params$n)))
(z0    <- (xbar[1] - xbar[2] - params$Delta0) / se0)

# --- 2. (a) P-value 雙尾 ---
print_subhead("(a) Two-sided z-test (known variances)")
PVal <- 2 * (1 - pnorm(abs(z0)))
cat("H0: mu1  = mu2\n")
cat("H1: mu1 != mu2\n")
cat(sprintf("xbar     = (%.3f, %.3f)\n", xbar[1], xbar[2]))
cat(sprintf("xbar.diff = %.3f\n", xbar[1] - xbar[2]))
cat(sprintf("se0      = %.3f\n",  se0))
cat(sprintf("z0       = %.3f\n",  z0))
cat(sprintf("P-value  = %.3f\n",  PVal))
cat("Decision: ",
    if (PVal < params$alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")

# 套件交叉驗證：BSDA::z.test 走的是同一條路
zchk <- BSDA::z.test(Machine1, Machine2,
                     sigma.x = params$sigma[1],
                     sigma.y = params$sigma[2],
                     alternative = "two.sided",
                     conf.level  = params$conf.level)
cat(sprintf("[BSDA::z.test]  z = %.3f, p = %.3f\n",
            zchk$statistic, zchk$p.value))

# --- 3. (b) Power for true diff = 0.04 ---
print_subhead("(b) Power for true |mu1 - mu2| = 0.04 (alpha = 0.05)")
delta_b <- 0.04
pwr_b   <- Pwr.z.test(n = params$n, delta = delta_b,
                      sigma = params$sigma, alpha = params$alpha,
                      alt = "two.sided")
cat(sprintf("delta    = %.3f\n", delta_b))
cat(sprintf("Power    = %.3f\n", pwr_b))
cat(sprintf("Beta     = %.3f\n", 1 - pwr_b))

# --- 4. (c) 95% CI for mu1 - mu2 ---
print_subhead("(c) 95% Confidence Interval for mu1 - mu2")
(CritVal <- qnorm(1 - params$alpha/2))
CI <- c((xbar[1] - xbar[2]) - CritVal * se0,
        (xbar[1] - xbar[2]) + CritVal * se0)
cat(sprintf("CI = (%.3f , %.3f)\n", CI[1], CI[2]))
cat(sprintf("[BSDA::z.test CI] (%.3f , %.3f)\n",
            zchk$conf.int[1], zchk$conf.int[2]))

# --- 5. (d) Sample size for beta = 0.01, alpha = 0.05, delta = 0.04 ---
print_subhead("(d) Equal n so that beta = 0.01 when |mu1 - mu2| = 0.04")
n_req <- SplSz.z.test(delta = 0.04, sigma = params$sigma,
                      alpha = params$alpha, pwr = 0.99, side = 2)
# n_req - 1 跟 n_req 兩個點的 power 都印，方便驗證
pw_m1 <- Pwr.z.test(n_req - 1, delta = 0.04, sigma = params$sigma,
                    alpha = params$alpha, alt = "two.sided")
pw_n  <- Pwr.z.test(n_req,     delta = 0.04, sigma = params$sigma,
                    alpha = params$alpha, alt = "two.sided")
cat(sprintf("Required n (each group) = %d\n", n_req))
cat(sprintf("Power at n-1 (%d) = %.3f , beta = %.3f\n",
            n_req - 1, pw_m1, 1 - pw_m1))
cat(sprintf("Power at n   (%d) = %.3f , beta = %.3f\n",
            n_req,     pw_n,  1 - pw_n))


## ---- ex5_03_plot ----
# Power curve：以 delta 為 x 軸
pwr_grid <- tibble(
  delta = seq(0, 0.10, length.out = 200)
) %>% mutate(
  power = Pwr.z.test(params$n, delta, params$sigma, params$alpha, "two.sided")
)
p_pwr_5_3 <- ggplot(pwr_grid, aes(delta, power)) +
  geom_line(color = "steelblue", linewidth = 1.1) +
  geom_hline(yintercept = 0.99, linetype = "dashed", color = "firebrick") +
  geom_vline(xintercept = 0.04, linetype = "dotted",  color = "darkgreen") +
  annotate("text", x = 0.042, y = 0.45, label = "delta = 0.04",
           color = "darkgreen", hjust = 0, size = 4) +
  annotate("text", x = 0.08, y = 0.965, label = "target power = 0.99",
           color = "firebrick", hjust = 0, size = 4) +
  scale_y_continuous(breaks = seq(0, 1, 0.25), limits = c(0, 1.02)) +
  labs(title = "Ex 5-3 Two-sample z-test power curve",
       subtitle = "known sigma1 = 0.020, sigma2 = 0.025; n1 = n2 = 10; alpha = 0.05",
       x = expression(paste("True difference  |", mu[1] - mu[2], "|  (oz)")),
       y = expression(paste("Power  = 1 - ", beta))) +
  theme_minimal(base_size = 13) +
  theme(plot.title  = element_text(face = "bold"),
        axis.title  = element_text(face = "bold"))
ggsave("figures/5-3_power_curve.png", p_pwr_5_3,
       width = 7.5, height = 5.0, dpi = 220)


## ---- ex5_05 ----
# =============================================================================
# EXERCISE 5-5: Solid-Fuel Propellants  (Section 5-2)
# 已知 sigma1 = sigma2 = 3 cm/s; n1 = n2 = 20; xbar1 = 18.02, xbar2 = 24.37
# =============================================================================
print_header("EXERCISE 5-5: SOLID-FUEL PROPELLANT BURNING RATES")

# 只有 summary 給；不過 BSDA::zsum.test 剛好吃 summary
xbar  <- c(18.02, 24.37)
sigma <- c(3, 3)
n     <- c(20, 20)
alpha <- 0.05

(se0 <- sqrt(sum(sigma^2 / n)))
(z0  <- (xbar[1] - xbar[2]) / se0)

# --- (a)(b) fixed-level + P-value ---
print_subhead("(a)(b) Two-sided z-test, alpha = 0.05")
(CritVal <- qnorm(1 - alpha/2))
PVal <- 2 * (1 - pnorm(abs(z0)))
cat("H0: mu1  = mu2\n")
cat("H1: mu1 != mu2\n")
cat(sprintf("se0     = %.3f\n", se0))
cat(sprintf("z0      = %.3f\n", z0))
cat(sprintf("CritVal = +/- %.3f\n", CritVal))
cat(sprintf("P-value = %.3f\n", PVal))
cat("Decision: ",
    if (PVal < alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
# BSDA::zsum.test 提供同樣的結果，可比對
zsum_chk <- BSDA::zsum.test(mean.x = xbar[1], sigma.x = sigma[1], n.x = n[1],
                            mean.y = xbar[2], sigma.y = sigma[2], n.y = n[2],
                            alternative = "two.sided", conf.level = 1 - alpha)
cat(sprintf("[BSDA::zsum.test]  z = %.3f, p = %.3f\n",
            zsum_chk$statistic, zsum_chk$p.value))

# --- (c) beta when true diff = 2.5 cm/s ---
print_subhead("(c) Beta when true mu1 - mu2 = 2.5 cm/s")
delta_c <- 2.5
pwr_c   <- Pwr.z.test(n = n, delta = delta_c, sigma = sigma,
                      alpha = alpha, alt = "two.sided")
cat(sprintf("delta = %.3f\n",  delta_c))
cat(sprintf("Power = %.3f\n",  pwr_c))
cat(sprintf("Beta  = %.3f\n",  1 - pwr_c))

# --- (d) 95% CI for mu1 - mu2 ---
print_subhead("(d) 95% CI for mu1 - mu2")
CI <- c((xbar[1] - xbar[2]) - CritVal * se0,
        (xbar[1] - xbar[2]) + CritVal * se0)
cat(sprintf("CI = (%.3f , %.3f)\n", CI[1], CI[2]))
cat(sprintf("[zsum.test CI]   (%.3f , %.3f)\n",
            zsum_chk$conf.int[1], zsum_chk$conf.int[2]))


## ---- ex5_05_plot ----
# Beta 區域圖：H0 跟 H1 兩條常態，beta 對應沒被拒絕的部分
# 拿真實 delta = 2.5 的設定畫，能看出 power=0.75 的幾何意義
beta_grid <- seq(-3, 6, length.out = 600)
beta_df <- tibble(
  d        = beta_grid,
  null     = dnorm(beta_grid, mean = 0,       sd = se0),
  alt      = dnorm(beta_grid, mean = 2.5,     sd = se0)
)
crit_lo <- -CritVal * se0
crit_hi <-  CritVal * se0
# 在 H1 下沒被拒絕的區間就是 beta
shade_df <- beta_df %>%
  filter(d >= crit_lo, d <= crit_hi) %>%
  mutate(ymin = 0)
p_beta_5_5 <- ggplot(beta_df, aes(d)) +
  geom_area(aes(y = alt), data = shade_df,
            fill = "orange", alpha = 0.45) +
  geom_line(aes(y = null), color = "steelblue", linewidth = 1) +
  geom_line(aes(y = alt),  color = "firebrick", linewidth = 1) +
  geom_vline(xintercept = c(crit_lo, crit_hi),
             linetype = "dashed", color = "gray30") +
  annotate("text", x = 0,   y = 0.5, label = "H0: mu1 - mu2 = 0",
           color = "steelblue", size = 4, hjust = 0.5) +
  annotate("text", x = 2.5, y = 0.5, label = "H1: mu1 - mu2 = 2.5",
           color = "firebrick", size = 4, hjust = 0.5) +
  annotate("text", x = 1.0, y = 0.12,
           label = sprintf("beta region\n(area = %.3f)", 1 - pwr_c),
           color = "darkorange3", size = 3.8, hjust = 0.5) +
  labs(title = "Ex 5-5 Two-sample z-test: beta region at true delta = 2.5",
       subtitle = "sigma = 3 cm/s, n1 = n2 = 20, alpha = 0.05; two-sided",
       x = expression(paste("Sample mean difference  ",
                            bar(x)[1] - bar(x)[2], "  (cm/s)")),
       y = "Density") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"))
ggsave("figures/5-5_beta_region.png", p_beta_5_5,
       width = 7.8, height = 5.0, dpi = 220)


## ---- ex5_09 ----
# =============================================================================
# EXERCISE 5-9: Sample size for estimating mu1 - mu2  (Section 5-2)
# 沿用 5-5：sigma1 = sigma2 = 3; equal n; E = 4 cm/s; 99% confidence
# =============================================================================
print_header("EXERCISE 5-9: SAMPLE SIZE FOR DIFFERENCE IN MEANS")

E <- 4
sigma <- c(3, 3)
conf.level <- 0.99
n_each <- SplSz.z.CI(E = E, sigma = sigma, conf.level = conf.level, side = 2)

# 跟手算公式對一下：n = ((z_{0.005})^2 * (sigma1^2 + sigma2^2)) / E^2
z_half <- qnorm(1 - (1 - conf.level)/2)
manual <- (z_half^2 * sum(sigma^2)) / E^2
cat(sprintf("Confidence level = %.3f\n", conf.level))
cat(sprintf("Margin of error E = %.0f cm/s\n", E))
cat(sprintf("sigma = (%.0f, %.0f)\n", sigma[1], sigma[2]))
cat(sprintf("z_{0.005} = %.3f\n", z_half))
cat(sprintf("Formula value = %.3f -> ceiling = %d (per group)\n",
            manual, n_each))


## ---- ex5_17 ----
# =============================================================================
# EXERCISE 5-17: Single vs Dual Spindle Saw  (Section 5-3)
# Pooled t (假設變異數相同); n1 = n2 = 15
# xbar_s = 66.385, s_s = 7.895;  xbar_d = 45.278, s_d = 8.612
# =============================================================================
print_header("EXERCISE 5-17: SINGLE vs DUAL SPINDLE SAW")

n     <- c(15, 15)
xbar  <- c(66.385, 45.278)   # single, double
s     <- c(7.895, 8.612)
alpha <- 0.05

# Pooled SD 跟自由度，老師範例都會印
(s_p <- sqrt(((n[1]-1)*s[1]^2 + (n[2]-1)*s[2]^2) / (sum(n) - 2)))
(se  <- s_p * sqrt(sum(1/n)))
(t0  <- (xbar[1] - xbar[2]) / se)
df  <- sum(n) - 2

# --- (a) Two-sided P-value ---
print_subhead("(a) Two-sided pooled t-test")
PVal <- 2 * (1 - pt(abs(t0), df))
cat("H0: mu_single  = mu_double\n")
cat("H1: mu_single != mu_double\n")
cat(sprintf("s_p     = %.3f\n", s_p))
cat(sprintf("se      = %.3f\n", se))
cat(sprintf("t0      = %.3f\n", t0))
cat(sprintf("df      = %d\n",   df))
cat(sprintf("P-value = %.3g\n", PVal))   # 太小就用科學記號
cat("Decision: ",
    if (PVal < alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
# 拿 BSDA::tsum.test 對結果
tsum_chk <- BSDA::tsum.test(mean.x = xbar[1], s.x = s[1], n.x = n[1],
                            mean.y = xbar[2], s.y = s[2], n.y = n[2],
                            var.equal = TRUE, alternative = "two.sided",
                            conf.level = 1 - alpha)
cat(sprintf("[BSDA::tsum.test]  t = %.3f, df = %.0f, p = %.3g\n",
            tsum_chk$statistic, tsum_chk$parameter, tsum_chk$p.value))

# --- (b) 95% two-sided CI ---
print_subhead("(b) 95% CI for mu_single - mu_double")
CritVal <- qt(1 - alpha/2, df)
CI <- c((xbar[1] - xbar[2]) - CritVal * se,
        (xbar[1] - xbar[2]) + CritVal * se)
cat(sprintf("t_{0.025, %d} = %.3f\n", df, CritVal))
cat(sprintf("CI = (%.3f , %.3f)\n", CI[1], CI[2]))
cat(sprintf("[tsum.test CI]   (%.3f , %.3f)\n",
            tsum_chk$conf.int[1], tsum_chk$conf.int[2]))

# --- (c) Sample size for beta <= 0.10 when delta = 15 ---
print_subhead("(c) Equal n so that beta <= 0.10 when |mu1 - mu2| = 15")
# 拿 pooled s_p 當 sigma 估計，alpha=0.05，目標 power=0.9，雙尾
# power.t.test() 給 n 是「每組」樣本數，不用再除 2
spl_5_17 <- power.t.test(delta = 15, sd = s_p, sig.level = alpha,
                         power = 0.90, type = "two.sample",
                         alternative = "two.sided")
n_req <- ceiling(spl_5_17$n)
pw_m1 <- Pwr.t.test(n_req - 1, delta = 15, sigma = s_p, alpha = alpha)
pw_n  <- Pwr.t.test(n_req,     delta = 15, sigma = s_p, alpha = alpha)
cat(sprintf("sigma estimate (= s_p) = %.3f\n", s_p))
cat(sprintf("power.t.test raw n     = %.3f -> ceiling = %d (per group)\n",
            spl_5_17$n, n_req))
cat(sprintf("Power at n-1 (%d) = %.3f , beta = %.3f\n",
            n_req - 1, pw_m1, 1 - pw_m1))
cat(sprintf("Power at n   (%d) = %.3f , beta = %.3f\n",
            n_req,     pw_n,  1 - pw_n))


## ---- ex5_17_plot ----
# t 分布拒絕區圖：df=28, 雙尾 alpha=0.05，順手把觀察到的 t0 也標出來
t_grid <- seq(-8, 8, length.out = 700)
t_df_plot <- tibble(t = t_grid, dens = dt(t_grid, df))
crit_t <- qt(1 - alpha/2, df)
reject_lo <- t_df_plot %>% filter(t <= -crit_t)
reject_hi <- t_df_plot %>% filter(t >=  crit_t)
p_t_5_17 <- ggplot(t_df_plot, aes(t, dens)) +
  geom_area(data = reject_lo, fill = "firebrick", alpha = 0.45) +
  geom_area(data = reject_hi, fill = "firebrick", alpha = 0.45) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_vline(xintercept = c(-crit_t, crit_t),
             linetype = "dashed", color = "gray30") +
  geom_vline(xintercept = t0, linetype = "solid",
             color = "darkgreen", linewidth = 1) +
  annotate("text", x = -crit_t, y = 0.35,
           label = sprintf("-t_{0.025, 28}\n= %.3f", -crit_t),
           color = "firebrick", size = 3.8, hjust = 1.05) +
  annotate("text", x = crit_t,  y = 0.35,
           label = sprintf("t_{0.025, 28}\n= %.3f", crit_t),
           color = "firebrick", size = 3.8, hjust = -0.05) +
  annotate("text", x = t0, y = 0.18,
           label = sprintf("observed t0\n= %.3f", t0),
           color = "darkgreen", size = 3.8, hjust = -0.05) +
  labs(title = "Ex 5-17 Pooled t-test: rejection regions and observed t0",
       subtitle = "df = 28, two-sided alpha = 0.05",
       x = "t statistic", y = "Density") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"))
ggsave("figures/5-17_t_rejection.png", p_t_5_17,
       width = 7.8, height = 5.0, dpi = 220)


## ---- ex5_24 ----
# =============================================================================
# EXERCISE 5-24: Plastic Gear Impact Strength  (Section 5-3)
# Welch t (變異數不等); n1 = 10, xbar1 = 289.30, s1 = 22.5
#                       n2 = 16, xbar2 = 321.50, s2 = 21
# =============================================================================
print_header("EXERCISE 5-24: PLASTIC GEAR SUPPLIERS")

n      <- c(10, 16)
xbar   <- c(289.30, 321.50)   # supplier 1, supplier 2
s      <- c(22.5, 21)
alpha  <- 0.05

# Welch SE 跟 Welch-Satterthwaite df
(se_W <- sqrt(s[1]^2/n[1] + s[2]^2/n[2]))
df_W  <- (s[1]^2/n[1] + s[2]^2/n[2])^2 /
         ((s[1]^2/n[1])^2 / (n[1]-1) + (s[2]^2/n[2])^2 / (n[2]-1))

# --- (a) one-sided test: supplier 2 higher than supplier 1 ---
print_subhead("(a) One-sided Welch t-test, H1: mu2 > mu1")
# 直接寫成 mu2 - mu1 - 0 比較好讀
t0_a <- ((xbar[2] - xbar[1]) - 0) / se_W
PVal_a <- 1 - pt(t0_a, df_W)
cat("H0: mu1 = mu2  (delta = mu2 - mu1 = 0)\n")
cat("H1: mu2 > mu1  (delta > 0)\n")
cat(sprintf("se (Welch)   = %.3f\n", se_W))
cat(sprintf("df (Welch)   = %.3f\n", df_W))
cat(sprintf("t0           = %.3f\n", t0_a))
cat(sprintf("P-value      = %.3f\n", PVal_a))
cat("Decision: ",
    if (PVal_a < alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
# tsum.test 對一遍
tsum_a <- BSDA::tsum.test(mean.x = xbar[2], s.x = s[2], n.x = n[2],
                          mean.y = xbar[1], s.y = s[1], n.y = n[1],
                          var.equal = FALSE,
                          alternative = "greater", conf.level = 1 - alpha)
cat(sprintf("[BSDA::tsum.test]  t = %.3f, df = %.3f, p = %.3f\n",
            tsum_a$statistic, tsum_a$parameter, tsum_a$p.value))

# --- (b) Test mu2 - mu1 >= 25 ---
print_subhead("(b) Test claim mu2 - mu1 >= 25 (Welch t)")
# 主張要靠資料「站得住腳」，就把它放在 H1
Delta0 <- 25
t0_b <- ((xbar[2] - xbar[1]) - Delta0) / se_W
PVal_b <- 1 - pt(t0_b, df_W)
cat("H0: mu2 - mu1  = 25\n")
cat("H1: mu2 - mu1  > 25\n")
cat(sprintf("observed diff = %.3f\n", xbar[2] - xbar[1]))
cat(sprintf("t0           = %.3f\n", t0_b))
cat(sprintf("P-value      = %.3f\n", PVal_b))
cat("Decision: ",
    if (PVal_b < alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
cat("Interpretation: 沒有夠強的證據說『supplier 2 比 supplier 1 平均多 25 foot-pounds 以上』。\n")

# --- (c) 95% CI for mu2 - mu1 ---
print_subhead("(c) 95% CI for mu2 - mu1")
CritVal <- qt(1 - alpha/2, df_W)
CI <- c((xbar[2] - xbar[1]) - CritVal * se_W,
        (xbar[2] - xbar[1]) + CritVal * se_W)
cat(sprintf("t_{0.025, %.2f} = %.3f\n", df_W, CritVal))
cat(sprintf("CI for mu2 - mu1 = (%.3f , %.3f)\n", CI[1], CI[2]))
# 用 CI 回答 (b)：25 在區間裡 -> 不拒絕
cat(sprintf("Is 25 inside the CI? %s -> %s\n",
            ifelse(CI[1] <= 25 && 25 <= CI[2], "Yes", "No"),
            ifelse(CI[1] <= 25 && 25 <= CI[2],
                   "consistent with (b): FAIL TO REJECT",
                   "would REJECT H0 in (b)")))


## ---- ex5_24_plot ----
# CI 圖：把點估計 + 95% CI + 兩條參考線 (0 與 25) 畫在同一條 X 軸上
ci_df_5_24 <- tibble(
  label = "mu2 - mu1",
  est   = xbar[2] - xbar[1],
  lo    = CI[1],
  hi    = CI[2]
)
p_ci_5_24 <- ggplot(ci_df_5_24, aes(y = label)) +
  geom_vline(xintercept = 0,  linetype = "dashed", color = "gray40") +
  geom_vline(xintercept = 25, linetype = "dotdash", color = "firebrick",
             linewidth = 0.8) +
  geom_segment(aes(x = lo, xend = hi, yend = label),
               linewidth = 2, color = "steelblue") +
  geom_point(aes(x = est), size = 4.5, color = "navy") +
  geom_text(aes(x = est, label = sprintf("%.3f", est)),
            vjust = -1.2, size = 4, color = "navy") +
  geom_text(aes(x = lo, label = sprintf("%.3f", lo)),
            vjust = 2.2, size = 3.6, color = "gray30") +
  geom_text(aes(x = hi, label = sprintf("%.3f", hi)),
            vjust = 2.2, size = 3.6, color = "gray30") +
  annotate("text", x = 0,  y = 0.6, label = "0 (test in (a))",
           color = "gray30",   size = 3.6, hjust = -0.05) +
  annotate("text", x = 25, y = 0.6, label = "25 (test in (b))",
           color = "firebrick", size = 3.6, hjust = -0.05) +
  scale_x_continuous(breaks = c(0, 10, 20, 25, 30, 40, 50)) +
  labs(title = "Ex 5-24 Welch 95% CI for mu2 - mu1, with H0 boundaries",
       subtitle = "n1 = 10, n2 = 16; Welch df = 18.226; SE = 8.842",
       x = "Difference in mean impact strength (foot-pounds)", y = NULL) +
  theme_minimal(base_size = 13) +
  theme(plot.title  = element_text(face = "bold"),
        axis.title  = element_text(face = "bold"),
        axis.text.y = element_text(face = "bold", size = 12))
ggsave("figures/5-24_ci_forest.png", p_ci_5_24,
       width = 8.5, height = 4.2, dpi = 220)


## ---- ex5_41 ----
# =============================================================================
# EXERCISE 5-41: Coding Time, Two Design Languages  (Section 5-4)
# 12 個程式員、配對 t；Coding.diff = Lang1 - Lang2
# =============================================================================
print_header("EXERCISE 5-41: PAIRED CODING TIMES (TWO DESIGN LANGUAGES)")

Lang1 <- c(17, 16, 21, 14, 18, 24, 16, 14, 21, 23, 13, 18)
Lang2 <- c(18, 14, 19, 11, 23, 21, 10, 13, 19, 24, 15, 20)

# 方向：取 Lang1 - Lang2，表示「語言 1 比語言 2 多用多少分鐘」
Coding.diff <- Lang1 - Lang2
n_p <- length(Coding.diff)
df_p <- n_p - 1
alpha <- 0.05

print_subhead("Summary of paired differences (Lang1 - Lang2)")
print(get_stats(Coding.diff))

# --- (a) 95% CI on mean paired difference ---
print_subhead("(a) 95% CI on mean(Lang1 - Lang2)")
t_paired <- t.test(Lang1, Lang2, paired = TRUE, conf.level = 1 - alpha)
xbar_d <- mean(Coding.diff)
sd_d   <- sd(Coding.diff)
se_d   <- sd_d / sqrt(n_p)
CritVal <- qt(1 - alpha/2, df_p)
CI <- c(xbar_d - CritVal * se_d, xbar_d + CritVal * se_d)
cat(sprintf("xbar_d (Lang1 - Lang2) = %.3f\n", xbar_d))
cat(sprintf("s_d                    = %.3f\n", sd_d))
cat(sprintf("se_d                   = %.3f\n", se_d))
cat(sprintf("t_{0.025, %d}           = %.3f\n", df_p, CritVal))
cat(sprintf("95%% CI = (%.3f , %.3f)\n", CI[1], CI[2]))
cat(sprintf("[t.test CI]  (%.3f , %.3f)\n",
            t_paired$conf.int[1], t_paired$conf.int[2]))
# 0 在 CI 裡嗎？順手做一下整體解釋
if (CI[1] <= 0 && 0 <= CI[2]) {
  cat("Interpretation: 0 落在 95% CI 內，沒有證據說兩種語言的平均 coding time 不同。\n")
} else {
  cat("Interpretation: 0 落在 95% CI 之外，有證據說兩種語言平均 coding time 不同。\n")
}

# --- (b) Normality of the differences ---
print_subhead("(b) Normality check on the paired differences")
(sw_p <- shapiro.test(Coding.diff))
cat("差值的常態假設用 Shapiro-Wilk + Q-Q plot 一起看，圖見 figures/。\n")

## ---- ex5_41_plot ----
# 配對差值的常態性檢查圖：Q-Q + 直方圖（save_normality_plots 已封裝）
save_normality_plots(Coding.diff,
                     "Ex 5-41 Coding.diff",
                     "5-41_diff",
                     x_label = "Coding.diff = Lang1 - Lang2 (minutes)")
# qqPlot 來自 car，老師範例常用
png("figures/5-41_diff_qqplot.png", width = 1100, height = 800, res = 150)
car::qqPlot(Coding.diff,
            main = "Ex 5-41: paired diff Q-Q plot",
            ylab = "Coding.diff (Lang1 - Lang2)")
invisible(dev.off())


## ---- ex5_59 ----
# =============================================================================
# EXERCISE 5-59: Equality of Two Variances  (Section 5-5)
# 沿用 5-24：s1 = 22.5, n1 = 10; s2 = 21, n2 = 16; 雙尾 alpha = 0.05
# =============================================================================
print_header("EXERCISE 5-59: F-TEST FOR EQUAL VARIANCES (GEAR DATA)")

n     <- c(10, 16)
s     <- c(22.5, 21)
alpha <- 0.05

(f0 <- s[1]^2 / s[2]^2)
df  <- c(n[1] - 1, n[2] - 1)

# 雙尾 P-value：兩端取小的乘 2
PVal <- 2 * min(pf(f0, df[1], df[2]), 1 - pf(f0, df[1], df[2]))
# 兩個臨界值，幫 grader 看
f_low  <- qf(    alpha/2, df[1], df[2])
f_high <- qf(1 - alpha/2, df[1], df[2])

print_subhead("Two-sided F-test, alpha = 0.05")
cat("H0: sigma1^2  = sigma2^2\n")
cat("H1: sigma1^2 != sigma2^2\n")
cat(sprintf("f0      = s1^2 / s2^2 = %.3f\n", f0))
cat(sprintf("df      = (%d, %d)\n", df[1], df[2]))
cat(sprintf("F_{0.025, %d, %d} = %.3f , F_{0.975, %d, %d} = %.3f\n",
            df[1], df[2], f_low, df[1], df[2], f_high))
cat(sprintf("P-value = %.3f\n", PVal))
cat("Decision: ",
    if (PVal < alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")

# 也順手丟 95% CI for sigma1^2 / sigma2^2
LB <- (s[1]^2 / s[2]^2) / qf(1 - alpha/2, df[1], df[2])
UB <- (s[1]^2 / s[2]^2) / qf(    alpha/2, df[1], df[2])
cat(sprintf("95%% CI for sigma1^2 / sigma2^2 = (%.3f , %.3f)\n", LB, UB))
cat("1 落在 CI 裡 -> 跟 P-value 結論一致（不拒絕兩變異數相等）。\n")


## ---- ex5_59_plot ----
# F(9, 15) 分布 + 雙尾拒絕區 + f0 標記
f_grid <- seq(0.001, 6, length.out = 700)
f_df_plot <- tibble(f = f_grid, dens = df(f_grid, df[1], df[2]))
rej_lo_f <- f_df_plot %>% filter(f <= f_low)
rej_hi_f <- f_df_plot %>% filter(f >= f_high)
p_f_5_59 <- ggplot(f_df_plot, aes(f, dens)) +
  geom_area(data = rej_lo_f, fill = "firebrick", alpha = 0.45) +
  geom_area(data = rej_hi_f, fill = "firebrick", alpha = 0.45) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_vline(xintercept = c(f_low, f_high),
             linetype = "dashed", color = "gray30") +
  geom_vline(xintercept = f0, linetype = "solid",
             color = "darkgreen", linewidth = 1) +
  # 三個標籤往畫面右上半排，避開曲線、彼此也不重疊
  annotate("text", x = 2.4, y = 0.78,
           label = sprintf("F_{0.025, 9, 15} = %.3f  (left dashed line)", f_low),
           color = "firebrick", size = 4, hjust = 0) +
  annotate("text", x = 2.4, y = 0.68,
           label = sprintf("F_{0.975, 9, 15} = %.3f  (right dashed line)", f_high),
           color = "firebrick", size = 4, hjust = 0) +
  annotate("text", x = 2.4, y = 0.58,
           label = sprintf("observed f0 = %.3f  (solid green line)", f0),
           color = "darkgreen", size = 4, hjust = 0) +
  # tick 拆成整數，避免 1.00 跟 1.15 擠在一起
  scale_x_continuous(breaks = c(0, 1, 2, 3, 4, 5, 6),
                     limits = c(0, 6)) +
  labs(title = "Ex 5-59 Two-sided F-test: rejection regions and observed f0",
       subtitle = "df = (9, 15), alpha = 0.05; f0 = s1^2 / s2^2 = 1.148",
       x = "F statistic", y = "Density") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"))
ggsave("figures/5-59_f_rejection.png", p_f_5_59,
       width = 8.5, height = 5.0, dpi = 220)


## ---- ex5_69 ----
# =============================================================================
# EXERCISE 5-69: Vehicle Rollover Rates  (Section 5-6)
# Two proportions; n = c(100, 100); x = c(35, 25)
# 助教校正：(b)(c) 的 pA = 0.4, pB = 0.25 是 H1 下的 p（power / sample size 用）
# =============================================================================
print_header("EXERCISE 5-69: ROLLOVER RATES (TWO PROPORTIONS)")

n     <- c(100, 100)
x     <- c(35, 25)
alpha <- 0.05

st <- TwoPropStats(x, n)

# --- (a) One-sided test: pA > pB ---
print_subhead("(a) One-sided two-proportion z-test (P-value approach)")
(z0    <- st$phat.diff / st$se.p)
(PVal  <- 1 - pnorm(z0))
cat("H0: pA  = pB\n")
cat("H1: pA  > pB\n")
cat(sprintf("phat.A   = %.3f , phat.B   = %.3f\n", st$phat[1], st$phat[2]))
cat(sprintf("phat.p   = %.3f , se.p     = %.3f\n", st$phat.p, st$se.p))
cat(sprintf("z0       = %.3f\n", z0))
cat(sprintf("P-value  = %.3f\n", PVal))
cat("Decision: ",
    if (PVal < alpha) "REJECT H0" else "FAIL TO REJECT H0", "\n")
# prop.test 對結果（correct = FALSE 才能跟 z 公式對到）
pchk <- prop.test(x, n, alternative = "greater", correct = FALSE)
cat(sprintf("[prop.test]  chi^2 = %.3f, p = %.3f\n",
            pchk$statistic, pchk$p.value))

# --- (b) Power at alpha = 0.05, pA = 0.4, pB = 0.25 (H1 下) ---
print_subhead("(b) Power assuming pA = 0.4, pB = 0.25 (H1)")
pA_b <- 0.40
pB_b <- 0.25
pwr_b <- Pwr.prop2.test(n = n, pA = pA_b, pB = pB_b,
                        alpha = alpha, alt = "greater")
cat(sprintf("Under H1: pA = %.2f, pB = %.2f -> pA - pB = %.2f\n",
            pA_b, pB_b, pA_b - pB_b))
cat(sprintf("Power = %.3f , beta = %.3f\n", pwr_b, 1 - pwr_b))

# --- (c) 樣本數夠不夠 ---
print_subhead("(c) Is n = 100 each enough for power >= 0.90?")
n_req <- SplSz.prop2.test(pA = pA_b, pB = pB_b,
                          alpha = alpha, pwr = 0.90, side = 1)
pwr_at100 <- Pwr.prop2.test(n = c(100, 100), pA = pA_b, pB = pB_b,
                            alpha = alpha, alt = "greater")
cat(sprintf("Required n (each group) = %d\n", n_req))
cat(sprintf("Power at current n = 100 each: %.3f\n", pwr_at100))
cat("結論：n=100 還沒到 0.9 power，按公式得補到 ", n_req, " 每組才夠。\n", sep = "")


## ---- ex5_69_plot ----
# Power 對「每組樣本數」的關係圖：把現有 n=100 跟需要的 n=166 都標出來
n_grid <- seq(30, 250, by = 2)
pwr_grid_5_69 <- tibble(
  n_each = n_grid,
  power  = vapply(n_grid,
                  function(nn) Pwr.prop2.test(c(nn, nn),
                                              pA = pA_b, pB = pB_b,
                                              alpha = alpha, alt = "greater"),
                  numeric(1))
)
p_pwr_5_69 <- ggplot(pwr_grid_5_69, aes(n_each, power)) +
  geom_line(color = "steelblue", linewidth = 1.1) +
  geom_hline(yintercept = 0.90, linetype = "dashed", color = "firebrick") +
  geom_vline(xintercept = 100,   linetype = "dotted",  color = "darkgreen") +
  geom_vline(xintercept = n_req, linetype = "dotted",  color = "purple") +
  geom_point(aes(x = 100,   y = pwr_at100), color = "darkgreen", size = 3) +
  geom_point(aes(x = n_req, y = 0.90),      color = "purple",    size = 3) +
  annotate("text", x = 100, y = pwr_at100 - 0.08,
           label = sprintf("n = 100,\npower = %.3f", pwr_at100),
           color = "darkgreen", size = 3.8, hjust = 1.05) +
  annotate("text", x = n_req, y = 0.82,
           label = sprintf("n = %d for\npower >= 0.90", n_req),
           color = "purple", size = 3.8, hjust = -0.05) +
  scale_y_continuous(breaks = seq(0, 1, 0.1), limits = c(0, 1.02)) +
  labs(title = "Ex 5-69 Two-proportion test: power vs per-group sample size",
       subtitle = "Under H1: pA = 0.40, pB = 0.25; alpha = 0.05; one-sided",
       x = "Per-group sample size  n",
       y = expression(paste("Power  = 1 - ", beta))) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"))
ggsave("figures/5-69_power_vs_n.png", p_pwr_5_69,
       width = 8.0, height = 5.0, dpi = 220)


## ---- ex5_71 ----
# =============================================================================
# EXERCISE 5-71: 95% Lower Bound on pA - pB  (Section 5-6)
# 沿用 5-69 資料；Wald 一邊下界
# =============================================================================
print_header("EXERCISE 5-71: 95% LOWER CONFIDENCE BOUND FOR pA - pB")

n  <- c(100, 100)
x  <- c(35, 25)
alpha <- 0.05
st <- TwoPropStats(x, n)

LB <- st$phat.diff - qnorm(1 - alpha) * st$sehat
cat(sprintf("phat.diff = %.3f , sehat = %.3f\n", st$phat.diff, st$sehat))
cat(sprintf("z_{0.05}  = %.3f\n", qnorm(1 - alpha)))
cat(sprintf("Lower bound LB = phat.diff - z_{0.05} * sehat = %.3f\n", LB))
cat(sprintf("95%% one-sided lower bound : [ %.3f , 1 ]\n", LB))
# 解釋
if (LB > 0) {
  cat("LB > 0 -> 至少 95% 信心保證 pA > pB；和 5-69(a) 結論一致。\n")
} else {
  cat("LB <= 0 -> 0 還在區間裡，沒有 95% 信心斷言 pA > pB；跟 5-69(a) 邊界 P-value 一致。\n")
}


## ---- ex5_73 ----
# =============================================================================
# EXERCISE 5-73: Plus-Four (Agresti-Caffo) Lower Bound  (Section 5-6)
# 沿用 5-69 資料；ntilde = n + 2, xtilde = x + 1
# =============================================================================
print_header("EXERCISE 5-73: NEW CI (PLUS-FOUR / AGRESTI-CAFFO)")

n  <- c(100, 100)
x  <- c(35, 25)
alpha <- 0.05
st <- TwoPropStats(x, n)

LB_new <- st$ptilde.diff - qnorm(1 - alpha) * st$setilde
# 對照 5-71 的傳統下界
LB_trad <- st$phat.diff - qnorm(1 - alpha) * st$sehat

cat(sprintf("ntilde = (%d, %d)\n", st$ntilde[1], st$ntilde[2]))
cat(sprintf("xtilde = (%d, %d)\n", st$xtilde[1], st$xtilde[2]))
cat(sprintf("ptilde     = (%.3f, %.3f)\n", st$ptilde[1], st$ptilde[2]))
cat(sprintf("ptilde.diff = %.3f , setilde = %.3f\n",
            st$ptilde.diff, st$setilde))
cat(sprintf("New lower bound LB_new  = %.3f\n", LB_new))
cat(sprintf("Traditional bound LB    = %.3f (from 5-71)\n", LB_trad))
cat(sprintf("Difference (new - trad) = %.3f\n", LB_new - LB_trad))
cat("解讀：plus-four 把 (x, n) 換成 (x+1, n+2)，等於各組多 1 顆成功 1 顆失敗，\n")
cat("       ptilde 更靠近 0.5，setilde 微幅變大，下界比傳統 Wald 略保守。\n")


## ---- ex5_73_plot ----
# 把兩條單邊下界畫成水平線段，0 標一條垂直參考
lb_df <- tibble(
  method = factor(c("Traditional Wald (5-71)",
                    "Plus-four / Agresti-Caffo (5-73)"),
                  levels = c("Traditional Wald (5-71)",
                             "Plus-four / Agresti-Caffo (5-73)")),
  point  = c(st$phat.diff,  st$ptilde.diff),
  lb     = c(LB_trad,       LB_new)
)
p_lb <- ggplot(lb_df, aes(y = method)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "firebrick") +
  geom_segment(aes(x = lb, xend = point, yend = method),
               linewidth = 1.8, color = "steelblue") +
  geom_point(aes(x = point), size = 4, color = "navy") +
  geom_point(aes(x = lb),    size = 3.6, color = "darkorange3") +
  geom_text(aes(x = lb, label = sprintf("LB = %.3f", lb)),
            color = "darkorange3", vjust = -1.4, size = 4) +
  geom_text(aes(x = point, label = sprintf("point = %.3f", point)),
            color = "navy", vjust = -1.4, hjust = 0.5, size = 4) +
  # 左右各保留留白，避免 labels 被切掉
  scale_x_continuous(breaks = seq(-0.05, 0.15, 0.025),
                     limits = c(-0.03, 0.135),
                     expand = expansion(mult = 0.04)) +
  labs(title = "Ex 5-71 vs 5-73: 95% one-sided lower bound on pA - pB",
       subtitle = "Both bounds straddle 0, so neither can conclude pA > pB at 95% confidence",
       x = expression(paste(p[A], " - ", p[B], "  (percentage points)")),
       y = NULL) +
  theme_minimal(base_size = 13) +
  theme(plot.title  = element_text(face = "bold"),
        axis.title  = element_text(face = "bold"),
        axis.text.y = element_text(face = "bold", size = 11),
        plot.margin = margin(10, 18, 10, 10))
ggsave("figures/5-71-73_lb_compare.png", p_lb,
       width = 9.0, height = 4.2, dpi = 220)


# =============================================================================
# 結束
# =============================================================================
cat("\n============================================================\n")
cat(" All Chapter 5 exercises completed.\n")
cat("============================================================\n")
