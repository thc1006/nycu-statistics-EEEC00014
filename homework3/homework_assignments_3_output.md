# Homework Assignments 3: Final Answers

> Chapter 6 Simple Linear Regression，Exercise 6-5 與 6-11。資料為混凝土
> compressive strength ($x$) 對 intrinsic permeability ($y$)，共 15 筆。
> 依助教規定：過程數值算到第三位、最終答案四捨五入到第三位。每小題附上對應的
> R 指令與計算結果。
>
> 模型：$y = \beta_0 + \beta_1 x + \varepsilon$，以 `lm(permeability ~ strength)` 配適。

---

## Exercise 6-5

### (a) Estimate $\beta_0$ and $\beta_1$, write the regression line

R 指令：`lm(permeability ~ strength, Concrete)` → `coef()`。

- $\hat\beta_0 = 40.554$、$\hat\beta_1 = -2.123$。
- 估計回歸線：$\hat y = 40.554 - 2.123\,x$。

解釋：strength 每增加 1 單位，平均 permeability 下降約 2.123 單位（負斜率，符合散布圖趨勢）。

### (b) Compute the residuals

R 指令：`resid(lm.Concrete)`、`fitted(lm.Concrete)`。殘差 $e_i = y_i - \hat y_i$：

| Obs | $x$ | $y$ | $\hat y$ | residual |
|---:|---:|---:|---:|---:|
| 1 | 3.1 | 33.0 | 33.972 | -0.972 |
| 2 | 4.5 | 31.0 | 30.999 | 0.001 |
| 3 | 3.4 | 34.9 | 33.335 | 1.565 |
| 4 | 2.5 | 35.6 | 35.246 | 0.354 |
| 5 | 2.2 | 36.1 | 35.883 | 0.217 |
| 6 | 1.2 | 39.0 | 38.006 | 0.994 |
| 7 | 5.3 | 30.1 | 29.301 | 0.799 |
| 8 | 4.8 | 31.2 | 30.362 | 0.838 |
| 9 | 2.4 | 35.7 | 35.458 | 0.242 |
| 10 | 3.5 | 31.9 | 33.123 | -1.223 |
| 11 | 1.3 | 37.3 | 37.794 | -0.494 |
| 12 | 3.0 | 33.8 | 34.184 | -0.384 |
| 13 | 3.3 | 32.8 | 33.547 | -0.747 |
| 14 | 3.2 | 31.6 | 33.759 | -2.159 |
| 15 | 1.8 | 37.7 | 36.732 | 0.968 |

### (c) Compute $SS_E$ and estimate the variance

R 指令：`SSE <- sum(resid(lm.Concrete)^2)`、`MSE <- SSE / df.residual`。

- $SS_E = 13.999$，自由度 $n - 2 = 13$。
- 變異數估計 $\hat\sigma^2 = MSE = SS_E / 13 = 1.077$。
- 殘差標準誤 $\hat\sigma = \sqrt{MSE} = 1.038$。

### (d) Standard error of the estimated slope and intercept

R 指令：`summary(lm.Concrete)$coefficients[, "Std. Error"]`。

- $SE(\hat\beta_0) = 0.751$。
- $SE(\hat\beta_1) = 0.231$。

### (e) Show that $SS_T = SS_R + SS_E$

R 指令：`SST <- sum((y - ybar)^2)`、`SSR <- sum((fitted - ybar)^2)`。

- $SS_T = 104.757$、$SS_R = 90.759$、$SS_E = 13.999$。
- $SS_R + SS_E = 90.759 + 13.999 = 104.757 = SS_T$。分解成立（僅四捨五入層級差異）。

### (f) Coefficient of determination $R^2$

R 指令：`summary(lm.Concrete)$r.squared`。

- $R^2 = 0.866$。
- 解釋：strength 約能解釋 permeability 86.6% 的總變異，配適度相當高。

### (g) $t$-tests for intercept and slope at $\alpha = 0.05$

R 指令：`summary(lm.Concrete)$coefficients`。

| coefficient | estimate | SE | $t$ | $P$-value |
|---|---:|---:|---:|---:|
| intercept $\beta_0$ | 40.554 | 0.751 | 54.004 | $1.107\times10^{-16}$ |
| slope $\beta_1$ | -2.123 | 0.231 | -9.181 | $4.805\times10^{-7}$ |

- 假設：$H_0: \beta_j = 0$ vs $H_1: \beta_j \neq 0$，$\alpha = 0.05$。
- 兩個 $P$-value 都遠小於 0.05，**reject $H_0$**：截距與斜率都顯著，strength 對 permeability 有顯著線性效應。

### (h) ANOVA table and regression $F$-test

R 指令：`anova(lm.Concrete)`。

| Source | DF | Sum Sq | Mean Sq | $F$ | $P$-value |
|---|---:|---:|---:|---:|---:|
| Regression (strength) | 1 | 90.759 | 90.759 | 84.285 | $4.805\times10^{-7}$ |
| Residual | 13 | 13.999 | 1.077 | | |
| Total | 14 | 104.757 | | | |

- 假設：$H_0: \beta_1 = 0$ vs $H_1: \beta_1 \neq 0$。$F = 84.285$，$P = 4.805\times10^{-7} < 0.05$，**reject $H_0$**。
- 與 (g) 的關係：$F = 84.285 = (-9.181)^2 = t_{\text{slope}}^2$，兩者本質等價，結論一致（回歸顯著）。

### (i) 95% CIs for intercept and slope

R 指令：`confint(lm.Concrete, level = 0.95)`。

| coefficient | 95% CI |
|---|---:|
| intercept $\beta_0$ | $[38.931,\ 42.176]$ |
| slope $\beta_1$ | $[-2.623,\ -1.624]$ |

- 兩個 CI 都不包含 0，與 (g)、(h) 的「顯著」結論一致：CI 不含 0 等價於該係數在 $\alpha = 0.05$ 下顯著。

### (j) Model adequacy checks

用到的 R：`plot(lm.Concrete)`（四連圖）、`ols_test_breusch_pagan`、`ols_test_normality`、`outlierTest`、`influence.measures`。

- **線性 (linearity)**：殘差對 fitted 散布大致圍繞 0、無明顯曲度，線性假設可接受（見圖 `6-5j_resid_qq.png` 左）。
- **常態性 (normality)**：Q-Q 圖點貼合參考線；Shapiro-Wilk $p = 0.843$、Anderson-Darling $p = 0.801$、KS $p = 0.961$ 都不拒絕常態。Cramer-von Mises $p = 0.006$ 是唯一例外，但多數檢定與 Q-Q 圖一致支持常態，整體可接受。
- **等變異 (constant variance)**：Breusch-Pagan $\chi^2 = 0.086$、$p = 0.770$，不拒絕「變異數恆定」。
- **離群 (outliers)**：`outlierTest` 最大 studentized residual 在 Obs 14（$r = -2.584$），Bonferroni $p = 0.359$，不算顯著離群。
- **影響點 (influence)**：`influence.measures` 標記 Obs 7（高 leverage，hat $= 0.322$）與 Obs 14 的 cov.ratio 偏離，但 Cook's distance 都 < 0.5，影響有限。
- **結論**：因 $n = 15$ 偏小，不過度宣稱；綜合各項診斷，模型對這組資料提供了**足夠 (adequate)** 的配適。

### (k) Sample correlation coefficient and test at $\alpha = 0.05$

R 指令：`cor(...)`、`cor.test(...)`。

- 樣本相關係數 $r = -0.931$（強負相關）。
- 檢定 $H_0: \rho = 0$：$t = -9.181$、$df = 13$、$P = 4.805\times10^{-7} < 0.05$，**reject $H_0$**。
- 與 (g)、(h) 的關係：$t = -9.181$ 與 slope 的 $t$ 完全相同、$P$ 也相同；且 $r^2 = 0.866 = R^2$。在 simple linear regression 中，slope $t$ 檢定、回歸 ANOVA $F$ 檢定、相關係數檢定三者結論一致。

---

## Exercise 6-11

沿用 6-5 的資料與模型，指定 $x_0 = 2.1$。R 用具名參數 `predict(..., interval=, level=0.99)`，避免位置參數把 `df` 跟 `level` 搞混。

### (a) Mean permeability at strength = 2.1

R 指令：`predict(lm.Concrete, data.frame(strength = 2.1))`。

- $\hat\mu_{Y\mid x_0=2.1} = 40.554 - 2.123 \times 2.1 = 36.095$。

### (b) 99% CI on the mean response

R 指令：`predict(..., interval = "confidence", level = 0.99)`。

- 99% CI：$[35.059,\ 37.131]$，寬度 $2.073$。

### (c) 99% PI on a future observation at strength = 2.1

R 指令：`predict(..., interval = "prediction", level = 0.99)`。

- 99% PI：$[32.802,\ 39.388]$，寬度 $6.586$。

### (d) Relative size of the two intervals

- PI 寬度 $6.586$ > CI 寬度 $2.073$，**PI 明顯比 CI 寬**。
- 原因：CI 只涵蓋「平均反應 $\mu_{Y\mid x_0}$」的估計不確定性；PI 還要再加上單一未來觀測本身的隨機誤差 $\varepsilon$。多了 $\hat\sigma^2$ 這一項，所以區間更寬。圖見 `figures/6-11_ci_pi_band.png`（內藍帶為 CI、外橘帶為 PI）。
