# =============================================================================
# Homework Assignments 3
# Exercise 6-5 and Exercise 6-11
# Section 6-2 Simple Linear Regression
# =============================================================================

## ---- init ----
# --- 1. Setup ---
# 照老師 Chapter 6 範例用 pacman 統一載套件
if (!require(pacman)) install.packages("pacman", repos = "https://cloud.r-project.org")
# rgl 是 3D 繪圖用的，這題 simple linear regression 用不到，所以不載
pacman::p_load(broom, car, ggfortify, ggplot2, goftest, HH, lmtest, mgcv,
               nortest, olsrr, patchwork)

# 圖丟到 figures/
dir.create("figures", showWarnings = FALSE)

# 本題照助教規定：數值算到第三位、答案四捨五入到第三位
fmt3 <- function(x) formatC(x, format = "f", digits = 3)

print_header <- function(title) {
  cat("\n============================================================\n")
  cat(" ", title, "\n", sep = "")
  cat("============================================================\n")
}
print_subhead <- function(title) {
  cat(sprintf("\n--- %s ---\n", title))
}


# =========================================================================
# CASE: SIMPLE LINEAR REGRESSION ANALYSIS
# =========================================================================

## ---- data ----
# --- 2. Input the actual dataset from Exercise 6-5 ---
# 資料照題目原樣 hard-code，15 筆，順序不可改
strength <- c(3.1, 4.5, 3.4, 2.5, 2.2, 1.2, 5.3, 4.8,
              2.4, 3.5, 1.3, 3.0, 3.3, 3.2, 1.8)
permeability <- c(33.0, 31.0, 34.9, 35.6, 36.1, 39.0, 30.1, 31.2,
                  35.7, 31.9, 37.3, 33.8, 32.8, 31.6, 37.7)

# response 是 permeability，explanatory 是 strength
(Concrete <- data.frame(
  strength = strength,
  permeability = permeability
))
print_subhead("Summary of the Concrete data")
summary(Concrete)


## ---- fit ----
# --- 3. Fit the simple linear regression model ---
# 主模型：permeability ~ strength
(lm.Concrete <- lm(permeability ~ strength, Concrete))
model_summary <- summary(lm.Concrete)
print(model_summary)
# olsrr 的整合報表，老師範例會印
ols_regress(permeability ~ strength, Concrete)


## ---- ex6_5_abcd ----
# --- 4. Exercise 6-5(a)-(d): estimates, residuals, SSE, variance, SEs ---
print_header("EXERCISE 6-5 (a)-(d)")

# (a) 截距、斜率與回歸線
b <- coef(lm.Concrete)
cat("(a) Estimated regression line\n")
cat(sprintf("beta0_hat = %.3f , beta1_hat = %.3f\n", b[1], b[2]))
cat(sprintf("yhat = %.3f + (%.3f) * x\n", b[1], b[2]))

# (b) 殘差表，題目要求看得到每一筆，不能只給圖
(Residual_df <- data.frame(
  Observation  = 1:nrow(Concrete),
  strength     = Concrete$strength,
  permeability = Concrete$permeability,
  fitted       = round(fitted(lm.Concrete), 3),
  residual     = round(resid(lm.Concrete), 3)
))

# (c) SSE 與變異數估計 (MSE)
SSE <- sum(resid(lm.Concrete)^2)
MSE <- SSE / lm.Concrete$df.residual          # variance 的估計值 sigma^2_hat
cat(sprintf("\n(c) SSE = %.3f\n", SSE))
cat(sprintf("    df (residual) = %d\n", lm.Concrete$df.residual))
cat(sprintf("    sigma^2_hat (MSE) = %.3f\n", MSE))
cat(sprintf("    residual standard error sigma_hat = %.3f\n", sqrt(MSE)))

# (d) 兩個估計係數的 standard error（套校訂註記讀作 "estimated" 係數）
se_coef <- model_summary$coefficients[, "Std. Error"]
cat(sprintf("\n(d) SE(beta0_hat) = %.3f\n", se_coef[1]))
cat(sprintf("    SE(beta1_hat) = %.3f\n", se_coef[2]))


## ---- ex6_5_efgh ----
# --- 5. Exercise 6-5(e)-(h): ANOVA, R-squared, t-tests, F-test ---
print_header("EXERCISE 6-5 (e)-(h)")

# (e) 證明 SST = SSR + SSE
ybar <- mean(Concrete$permeability)
SST <- sum((Concrete$permeability - ybar)^2)
SSR <- sum((fitted(lm.Concrete) - ybar)^2)
cat("(e) Sum-of-squares decomposition\n")
cat(sprintf("SST = %.3f\n", SST))
cat(sprintf("SSR = %.3f\n", SSR))
cat(sprintf("SSE = %.3f\n", SSE))
cat(sprintf("SSR + SSE = %.3f  (應該等於 SST = %.3f)\n", SSR + SSE, SST))

# (f) 判定係數 R^2
R2 <- model_summary$r.squared
cat(sprintf("\n(f) R^2 = %.3f\n", R2))
cat(sprintf("    亦即 strength 解釋了 permeability 約 %.1f%% 的變異。\n", 100 * R2))

# (g) 截距與斜率的 t 檢定 (alpha = 0.05)
print_subhead("(g) t-tests for intercept and slope, alpha = 0.05")
print(model_summary$coefficients)
t_tab <- model_summary$coefficients
cat(sprintf("intercept: t = %.3f, p = %.3g\n", t_tab[1, 3], t_tab[1, 4]))
cat(sprintf("slope    : t = %.3f, p = %.3g\n", t_tab[2, 3], t_tab[2, 4]))
cat("兩個 p-value 都 < 0.05，截距與斜率都顯著。\n")

# (h) ANOVA table + regression F 檢定
print_subhead("(h) ANOVA table")
(aov_tab <- anova(lm.Concrete))
Fstat <- aov_tab[1, "F value"]
Fp    <- aov_tab[1, "Pr(>F)"]
cat(sprintf("F = %.3f, p = %.3g\n", Fstat, Fp))
# 對照：simple linear regression 裡 F 應該等於 slope t 的平方
cat(sprintf("檢查 F = t^2 ? F = %.3f, t_slope^2 = %.3f\n",
            Fstat, t_tab[2, 3]^2))


## ---- ex6_5_i ----
# --- 6. Exercise 6-5(i): coefficient confidence intervals ---
print_header("EXERCISE 6-5 (i): 95% CIs for intercept and slope")
(ci_coef <- confint(lm.Concrete, level = 0.95))
cat(sprintf("95%% CI for beta0: [%.3f , %.3f]\n", ci_coef[1, 1], ci_coef[1, 2]))
cat(sprintf("95%% CI for beta1: [%.3f , %.3f]\n", ci_coef[2, 1], ci_coef[2, 2]))
cat("兩個 CI 都不含 0，跟 (g)(h) 的顯著結論一致。\n")


## ---- ex6_5_j ----
# --- 7. Exercise 6-5(j): model adequacy checks ---
print_header("EXERCISE 6-5 (j): model adequacy checks")

# 殘差的常態性、等變異、離群、影響點一起看
print_subhead("Breusch-Pagan test (constant variance)")
print(ols_test_breusch_pagan(lm.Concrete))
print_subhead("Normality tests on residuals")
print(ols_test_normality(lm.Concrete))
print_subhead("Outlier test (studentized residuals, Bonferroni)")
print(outlierTest(lm.Concrete))
print_subhead("Influence measures summary")
print(summary(influence.measures(lm.Concrete)))

# 標準 lm 四連圖存成 png
png("figures/6-5j_lm_diagnostics.png", width = 1500, height = 1200, res = 170)
opar <- par(mfrow = c(2, 2), oma = c(0, 0.3, 1.3, 0))
plot(lm.Concrete)
par(opar)
invisible(dev.off())


## ---- ex6_5_k ----
# --- 8. Exercise 6-5(k): correlation coefficient and test ---
print_header("EXERCISE 6-5 (k): sample correlation and test")
(r_xy <- cor(Concrete$strength, Concrete$permeability))
ct <- cor.test(Concrete$strength, Concrete$permeability)
print(ct)
cat(sprintf("r = %.3f\n", r_xy))
cat(sprintf("correlation t = %.3f, p = %.3g\n", ct$statistic, ct$p.value))
# 三個檢定在 simple linear regression 應該同一個結論、同一個 p
cat(sprintf("檢查 r^2 = R^2 ? r^2 = %.3f, R^2 = %.3f\n", r_xy^2, R2))


## ---- ex6_11 ----
# --- 9. Exercise 6-11: mean response, 99% CI, 99% PI at x0 = 2.1 ---
print_header("EXERCISE 6-11: prediction at strength x0 = 2.1")

(newdata <- data.frame(strength = 2.1))

# 注意：predict 用具名參數比較不會踩到位置參數的雷（df 跟 level 容易搞錯）
# (a) 點估計 mean response
pred_fit <- predict(lm.Concrete, newdata)
cat(sprintf("(a) mean permeability at x0 = 2.1 : %.3f\n", pred_fit))

# (b) 99% CI on the mean response
pred_ci <- predict(lm.Concrete, newdata, interval = "confidence", level = 0.99)
cat(sprintf("(b) 99%% CI  : [%.3f , %.3f]\n", pred_ci[2], pred_ci[3]))

# (c) 99% PI on a future observation
pred_pi <- predict(lm.Concrete, newdata, interval = "prediction", level = 0.99)
cat(sprintf("(c) 99%% PI  : [%.3f , %.3f]\n", pred_pi[2], pred_pi[3]))

# (d) 比較寬度
w_ci <- pred_ci[3] - pred_ci[2]
w_pi <- pred_pi[3] - pred_pi[2]
cat(sprintf("(d) CI width = %.3f , PI width = %.3f\n", w_ci, w_pi))
cat("PI 比 CI 寬，因為 PI 除了平均反應的估計誤差，還多加了單一未來觀測的隨機誤差。\n")


# =============================================================================
# Figures (ggplot)：軸標都給單位、標題粗體，方便列印閱讀
# =============================================================================

## ---- fig_scatter ----
# 散布圖 + 回歸線 + 95% 信賴帶
p_scatter <- ggplot(Concrete, aes(strength, permeability)) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE,
              color = "steelblue", fill = "steelblue", alpha = 0.15) +
  geom_point(size = 2.6, color = "navy") +
  labs(title = "Ex 6-5 Concrete: permeability vs strength",
       subtitle = sprintf("yhat = %.3f + (%.3f) x ,  R^2 = %.3f",
                          b[1], b[2], R2),
       x = "Compressive strength  x",
       y = "Intrinsic permeability  y") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"))
ggsave("figures/6-5_scatter_fit.png", p_scatter,
       width = 7.5, height = 5.0, dpi = 220)

## ---- fig_resid ----
# 殘差對 fitted：看有沒有曲度或喇叭口
resid_df <- data.frame(fitted = fitted(lm.Concrete),
                       residual = resid(lm.Concrete))
p_resid <- ggplot(resid_df, aes(fitted, residual)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "firebrick") +
  geom_point(size = 2.6, color = "navy") +
  labs(title = "Ex 6-5(j) Residuals vs fitted values",
       x = "Fitted permeability  yhat",
       y = "Residual  (y - yhat)") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"))

## ---- fig_qq ----
# 殘差 Q-Q：看常態假設
p_qq <- ggplot(resid_df, aes(sample = residual)) +
  stat_qq(size = 2.6, color = "navy") +
  stat_qq_line(color = "firebrick", linewidth = 0.9) +
  labs(title = "Ex 6-5(j) Normal Q-Q plot of residuals",
       x = "Theoretical normal quantiles",
       y = "Sample residual quantiles") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"))
# 兩張並排存一張，省版面
ggsave("figures/6-5j_resid_qq.png", p_resid + p_qq,
       width = 11, height = 4.6, dpi = 220)

## ---- fig_pred ----
# 6-11：把 99% CI 跟 99% PI 沿著 x 畫出來，x0 = 2.1 標出來
grid_x <- data.frame(strength = seq(min(strength), max(strength), length.out = 100))
ci_band <- as.data.frame(predict(lm.Concrete, grid_x,
                                 interval = "confidence", level = 0.99))
pi_band <- as.data.frame(predict(lm.Concrete, grid_x,
                                 interval = "prediction", level = 0.99))
band_df <- data.frame(
  strength = grid_x$strength,
  fit  = ci_band$fit,
  ci_lwr = ci_band$lwr, ci_upr = ci_band$upr,
  pi_lwr = pi_band$lwr, pi_upr = pi_band$upr
)
p_pred <- ggplot(band_df, aes(strength)) +
  geom_ribbon(aes(ymin = pi_lwr, ymax = pi_upr),
              fill = "orange", alpha = 0.20) +
  geom_ribbon(aes(ymin = ci_lwr, ymax = ci_upr),
              fill = "steelblue", alpha = 0.30) +
  geom_line(aes(y = fit), color = "steelblue", linewidth = 1) +
  geom_point(data = Concrete, aes(strength, permeability),
             size = 2.2, color = "navy") +
  geom_vline(xintercept = 2.1, linetype = "dotted", color = "darkgreen") +
  annotate("point", x = 2.1, y = pred_fit, color = "firebrick", size = 3) +
  annotate("text", x = 2.1, y = pred_fit + 1.5,
           label = sprintf("x0 = 2.1\nyhat = %.3f", pred_fit),
           color = "firebrick", size = 4, hjust = 0.5) +
  labs(title = "Ex 6-11 99% CI (inner, blue) and 99% PI (outer, orange)",
       subtitle = "PI band is wider because it adds single-observation random error",
       x = "Compressive strength  x",
       y = "Intrinsic permeability  y") +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"),
        axis.title = element_text(face = "bold"))
ggsave("figures/6-11_ci_pi_band.png", p_pred,
       width = 7.8, height = 5.0, dpi = 220)


# =============================================================================
cat("\n============================================================\n")
cat(" All Chapter 6 exercises completed.\n")
cat("============================================================\n")
