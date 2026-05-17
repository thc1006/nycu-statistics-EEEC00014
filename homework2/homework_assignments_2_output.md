# Homework Assignments 2: Final Answers

> Chapter 5 Decision Making for Two Samples，全部 10 題 (5-3、5-5、5-9、5-17、
> 5-24、5-41、5-59、5-69、5-71、5-73)。數值統一四捨五入到小數第三位。
> 共用的 R helper、Console snapshot 與 power curve / Q-Q 圖見 `homework_assignments_2.R`、
> `homework_assignments_2_output.txt`、`figures/`。

---

## Exercise 5-3: Bottle Filling Machines

1. **Problem type**：兩獨立樣本平均數，已知變異數的雙尾 z 檢定。
2. **Parameter of interest**：$\Delta = \mu_1 - \mu_2$。
3. **Hypotheses**：$H_0: \mu_1 = \mu_2$；$H_1: \mu_1 \neq \mu_2$。
4. **Assumptions**：兩台機台填裝量近似常態，且 $\sigma_1 = 0.020$、$\sigma_2 = 0.025$ 已知。
5. **Core calculations**：
   - $\bar{x}_1 = 16.015$、$\bar{x}_2 = 16.005$，$\bar{x}_1 - \bar{x}_2 = 0.010$。
   - $SE_0 = \sqrt{0.020^2/10 + 0.025^2/10} = 0.010$。
   - $z_0 = (0.010 - 0) / 0.010 = 0.988$。
6. **(a) P-value / 決策**：雙尾 $P = 2[1 - \Phi(0.988)] = 0.323$。$P > 0.05$，**FAIL TO REJECT $H_0$**。
7. **(b) Power at $\delta = 0.04$**：$\text{power} = 0.977$，$\beta = 0.023$。
8. **(c) 95% CI for $\mu_1 - \mu_2$**：$(-0.010,\; 0.030)$，0 落在區間內，與 (a) 一致。
9. **(d) Sample size**：要 $\beta = 0.01$、$\delta = 0.04$、$\alpha = 0.05$，
   $n = \lceil(z_{0.025} + z_{0.01})^2 (\sigma_1^2 + \sigma_2^2) / \delta^2\rceil = \mathbf{12}$ 每組
   ($n=11$ 時 power $= 0.986$，$n=12$ 時 power $= 0.991$ 過關)。
10. **Practical interpretation**：兩台機台在 $\alpha=0.05$ 下沒有顯著差異，CI 也涵蓋 0；
    但只要把樣本提高到每組 12，就能用 1% 的型 II 誤差偵測到 0.04 oz 的平均差。

---

## Exercise 5-5: Solid-Fuel Propellant Burning Rates

1. **Problem type**：兩獨立樣本平均數、已知共通標準差的雙尾 z 檢定。
2. **Parameter of interest**：$\Delta = \mu_1 - \mu_2$（單位 cm/s）。
3. **Hypotheses**：$H_0: \mu_1 = \mu_2$；$H_1: \mu_1 \neq \mu_2$。
4. **Assumptions**：兩種推進劑燃燒速率近似常態，且 $\sigma_1 = \sigma_2 = 3\ \text{cm/s}$ 已知；
   $n_1 = n_2 = 20$。
5. **Core calculations**：
   - $\bar{x}_1 = 18.020$、$\bar{x}_2 = 24.370$，$\bar{x}_1 - \bar{x}_2 = -6.350$。
   - $SE_0 = \sqrt{9/20 + 9/20} = 0.949$。
   - $z_0 = -6.350 / 0.949 = -6.693$。
6. **(a)(b) Decision / P-value**：雙尾 $P = 2[1 - \Phi(6.693)] \approx 0$ (印出 $0.000$)；
   $|z_0| = 6.693 > z_{0.025} = 1.96$，**REJECT $H_0$**。
7. **(c) Beta at $\delta = 2.5$**：$\text{power} = 0.750$、$\beta = 0.250$。
8. **(d) 95% CI for $\mu_1 - \mu_2$**：$(-8.209,\; -4.491)$；整個區間落在 0 左邊，
   印證推進劑 2 的平均燃燒速率明顯高於推進劑 1。
9. **Practical interpretation**：在 $\alpha = 0.05$ 下，兩種推進劑的平均燃燒速率
   顯著不同；推進劑 2 平均比推進劑 1 快約 6.350 cm/s。

---

## Exercise 5-9: Sample Size for Estimating $\mu_1 - \mu_2$

1. **Problem type**：兩獨立樣本平均數的「估計樣本數」（已知 $\sigma$，雙尾 CI 寬度設計）。
2. **Parameter of interest**：$\mu_1 - \mu_2$。
3. **Setting**：$\sigma_1 = \sigma_2 = 3$、equal $n$、$E < 4$ cm/s、99% confidence。
4. **Formula**：$n = \left\lceil \dfrac{z_{0.005}^2 (\sigma_1^2 + \sigma_2^2)}{E^2}\right\rceil$。
5. **Calculation**：$z_{0.005} = 2.576$，$n = \lceil (2.576^2 \cdot 18) / 16 \rceil = \lceil 7.464 \rceil = \mathbf{8}$ 每組。
6. **Interpretation**：兩種推進劑各需要 8 顆樣本，才能在 99% 信心下把
   $\mu_1 - \mu_2$ 的估計誤差壓在 4 cm/s 內。

---

## Exercise 5-17: Single vs Dual Spindle Saw

1. **Problem type**：兩獨立樣本平均數、未知但相等變異數的 pooled t 檢定。
2. **Parameter of interest**：$\mu_{\text{single}} - \mu_{\text{double}}$。
3. **Hypotheses**：$H_0: \mu_{\text{single}} = \mu_{\text{double}}$；
   $H_1: \mu_{\text{single}} \neq \mu_{\text{double}}$。
4. **Assumptions**：兩個母體都近似常態、變異數相等；$n_1 = n_2 = 15$。
5. **Core calculations**：
   - $s_p = \sqrt{\dfrac{14 \cdot 7.895^2 + 14 \cdot 8.612^2}{28}} = 8.261$。
   - $SE = s_p \sqrt{1/15 + 1/15} = 3.017$。
   - $t_0 = (66.385 - 45.278) / 3.017 = 6.997$，$df = 28$。
6. **(a) P-value / 決策**：$P = 2 \cdot P(T_{28} > 6.997) \approx 1.31 \times 10^{-7}$。
   $P < 0.05$，**REJECT $H_0$**。
7. **(b) 95% CI**：$t_{0.025, 28} = 2.048$，
   $CI = 21.107 \pm 2.048 \times 3.017 = (14.928,\; 27.286)$；整個區間 $> 0$，
   跟 (a) 一致。
8. **(c) Sample size**：要 $\beta \le 0.1$、$\delta = 15$、$\alpha = 0.05$，雙尾
   pooled t，用 `power.t.test(delta = 15, sd = 8.261, sig.level = 0.05, power = 0.9)`，
   $n = \mathbf{8}$ 每組 ($n=7$ 時 power $= 0.876$，$n=8$ 時 power $= 0.921$ 過關)。
9. **Practical interpretation**：single 製程的 backside chipouts 平均明顯大於 double
   製程，差距大約落在 14.9 到 27.3 個單位之間；若要在實務上偵測 15 個單位的差距，
   每組只需要 8 顆樣本就夠。

---

## Exercise 5-24: Plastic Gear Suppliers

1. **Problem type**：兩獨立樣本平均數、未知且不相等變異數的 Welch t 檢定。
2. **Parameter of interest**：$\mu_2 - \mu_1$（supplier 2 − supplier 1，foot-pounds）。
3. **Hypotheses**：
   - **(a)** $H_0: \mu_1 = \mu_2$；$H_1: \mu_2 > \mu_1$。
   - **(b)** $H_0: \mu_2 - \mu_1 = 25$；$H_1: \mu_2 - \mu_1 > 25$。
4. **Assumptions**：兩母體近似常態，變異數不假設相等；$n_1 = 10$、$n_2 = 16$。
5. **Core calculations**：
   - $\bar{x}_2 - \bar{x}_1 = 32.200$。
   - $SE_W = \sqrt{22.5^2/10 + 21^2/16} = 8.842$。
   - Welch-Satterthwaite $df = 18.226$。
6. **(a) decision**：$t_0 = 32.200 / 8.842 = 3.642$，$P = 1 - F_{T_{18.226}}(3.642) = 0.001$。
   $P < 0.05$，**REJECT $H_0$**：有證據說 supplier 2 平均更高。
7. **(b) decision**：$t_0 = (32.200 - 25)/8.842 = 0.814$，$P = 0.213$。
   $P > 0.05$，**FAIL TO REJECT $H_0$**：資料還不夠強到能宣稱「至少高 25 foot-pounds」。
8. **(c) 95% CI for $\mu_2 - \mu_1$**：$t_{0.025, 18.226} = 2.099$，
   $CI = 32.200 \pm 2.099 \times 8.842 = (13.639,\; 50.761)$。
   25 在 CI 內，與 (b) 結論一致；25 在區間靠下半邊，意思是「至少 25」這個說法
   在資料下其實還是有可能的，只是統計上沒到顯著拒絕的力道。
9. **Practical interpretation**：supplier 2 的齒輪平均衝擊強度明顯高於 supplier 1，
   差距大概落在 13.6 到 50.8 foot-pounds；但要堅定主張「高 25 以上」資料還不夠。

---

## Exercise 5-41: Paired Coding Times

1. **Problem type**：12 個程式員配對 t；資料為「在兩種設計語言下」coding time。
2. **Parameter of interest**：$\mu_D = E(\text{Lang1} - \text{Lang2})$（分鐘）。
3. **Hypotheses (implicit for (a) CI)**：$H_0: \mu_D = 0$ vs $H_1: \mu_D \neq 0$。
4. **Assumptions**：差值 $D_i = \text{Lang1}_i - \text{Lang2}_i$ 近似常態。
5. **Core calculations**：
   - $\bar{x}_D = 0.667$、$s_D = 2.964$、$SE_D = 0.856$、$df = 11$。
   - $t_{0.025, 11} = 2.201$。
6. **(a) 95% CI**：$CI = 0.667 \pm 2.201 \times 0.856 = (-1.217,\; 2.550)$，
   0 落在 CI 裡 ⇒ 沒有夠強的證據說某種語言比較快。
7. **(b) Normality**：Shapiro-Wilk $W = 0.962$、$p = 0.807$；Q-Q plot
   (`figures/5-41_diff_qqplot.png`) 上 12 個點都貼在參考帶內，常態假設可以接受。
8. **Power / sample size**：題目沒要求。
9. **Practical interpretation**：兩種設計語言在 95% 信心下沒有顯著的平均 coding
   time 差距；差值的常態性也夠好，配對 t 的推論可以信。

---

## Exercise 5-59: Equality of Two Variances (Gear Data)

1. **Problem type**：兩母體變異數比較，雙尾 F 檢定。
2. **Parameter of interest**：$\sigma_1^2 / \sigma_2^2$。
3. **Hypotheses**：$H_0: \sigma_1^2 = \sigma_2^2$；$H_1: \sigma_1^2 \neq \sigma_2^2$。
4. **Assumptions**：兩母體近似常態；$s_1 = 22.5$、$n_1 = 10$；$s_2 = 21$、$n_2 = 16$。
5. **Core calculations**：
   - $f_0 = 22.5^2 / 21^2 = 1.148$。
   - $df = (9, 15)$。
   - 雙尾 P-value $= 2 \min\{P(F_{9,15} \le 1.148),\; 1 - P(F_{9,15} \le 1.148)\} = 0.781$。
   - 臨界值：$F_{0.025, 9, 15} = 0.265$、$F_{0.975, 9, 15} = 3.123$，$f_0$ 落在中間。
6. **P-value / decision**：$P = 0.781 \gg 0.05$，**FAIL TO REJECT $H_0$**。
7. **95% CI for $\sigma_1^2 / \sigma_2^2$**：$(0.368,\; 4.327)$，1 在 CI 裡。
8. **Power / sample size**：題目沒要求。
9. **Practical interpretation**：兩家 supplier 的衝擊強度變異數沒有顯著差異，
   印證 5-24 用 Welch t（不假設變異數相等）依然是穩妥的做法。

---

## Exercise 5-69: Rollover Rates (Two Proportions)

1. **Problem type**：兩母體比例，單尾 z 檢定。
2. **Parameter of interest**：$p_A - p_B$。
3. **Hypotheses**：$H_0: p_A = p_B$；$H_1: p_A > p_B$。
4. **Assumptions**：兩組為獨立隨機樣本、大樣本下用常態近似；
   $n_A = n_B = 100$、$x_A = 35$、$x_B = 25$。
   助教校正：(b)、(c) 的 $p_A = 0.4$、$p_B = 0.25$ 是 $H_1$ 下的真實 $p$，
   跟前面的估計值 $\hat p_A = 0.35$、$\hat p_B = 0.25$ 是兩件事。
5. **Core calculations**：
   - $\hat{p}_A = 0.350$、$\hat{p}_B = 0.250$、$\hat{p}_A - \hat{p}_B = 0.100$。
   - $\bar{p} = (35+25)/200 = 0.300$、$\bar{q} = 0.700$。
   - $SE_0 = \sqrt{0.300 \cdot 0.700 \cdot (1/100 + 1/100)} = 0.065$。
   - $z_0 = 0.100 / 0.065 = 1.543$。
6. **(a) P-value / decision**：$P = 1 - \Phi(1.543) = 0.061$。$P > 0.05$，
   **FAIL TO REJECT $H_0$**：在 $\alpha = 0.05$ 下，目前的證據還不足以說 A 廠
   翻覆率比 B 廠高。
7. **(b) Power**（在 $H_1$ 下 $p_A=0.4$, $p_B=0.25$，$n=100$ 每組，$\alpha = 0.05$）：
   $\text{power} = 0.735$，$\beta = 0.265$。
8. **(c) Sample size**：需要 $\text{power} \ge 0.90$、$\delta = p_A - p_B = 0.15$、
   $\alpha = 0.05$；以
   $n = \left\lceil \dfrac{[z_{0.05}\sqrt{2\bar p \bar q} + z_{0.10}\sqrt{p_A q_A + p_B q_B}]^2}{(p_A - p_B)^2} \right\rceil$
   算得 $n = \mathbf{166}$ 每組，所以 $n = 100$ **不夠**（在 100 時 power 才 0.735）。
9. **Practical interpretation**：目前資料不足以拒絕「A、B 翻覆率相同」，
   但這跟「A 真的沒比較高」是兩回事；要在 $p_A = 0.4$、$p_B = 0.25$ 下有 90% 把握
   偵測到差距，得補到 166 場事故。

---

## Exercise 5-71: 95% Lower Bound on $p_A - p_B$

1. **Problem type**：兩母體比例差的單邊（lower）信賴下界。
2. **Parameter of interest**：$p_A - p_B$。
3. **Setting**：沿用 5-69 資料，95% 一邊下界，使用傳統 Wald 形式。
4. **Formula**：$\text{LB} = (\hat p_A - \hat p_B) - z_{0.05} \cdot \widehat{SE}$，
   其中 $\widehat{SE} = \sqrt{\hat p_A \hat q_A / n_A + \hat p_B \hat q_B / n_B}$。
5. **Calculation**：
   - $\widehat{SE} = \sqrt{0.35 \cdot 0.65 / 100 + 0.25 \cdot 0.75 / 100} = 0.064$。
   - $\text{LB} = 0.100 - 1.645 \cdot 0.064 = -0.006$。
6. **Result**：95% one-sided lower bound $= [-0.006,\; 1]$。
7. **Interpretation**：下界微微落在 0 以下，跟 5-69(a) 邊界 P-value (0.061)
   完全一致：在 95% 信心下，沒辦法斷言 $p_A > p_B$。
8. **Decimal precision**：所有數值四捨五入到第三位。
9. **Practical interpretation**：用 LB 來看，「A 比 B 翻覆率高最多 100%，最少
   -0.6 個百分點」，最低限度離 0 太近，很難下「A 廠車比較危險」的結論。

---

## Exercise 5-73: New CI (Plus-Four / Agresti-Caffo)

1. **Problem type**：兩母體比例差的單邊下界，採 plus-four 修正。
2. **Setting**：$\tilde n_i = n_i + 2$、$\tilde x_i = x_i + 1$，每組各加一顆成功一顆失敗。
3. **Formula**：
   $\tilde p_i = \dfrac{x_i + 1}{n_i + 2}$，$\widetilde{SE} = \sqrt{\sum \tilde p_i \tilde q_i / \tilde n_i}$，
   $\text{LB}_{\text{new}} = (\tilde p_A - \tilde p_B) - z_{0.05} \cdot \widetilde{SE}$。
4. **Calculation**：
   - $\tilde n = (102, 102)$、$\tilde x = (36, 26)$。
   - $\tilde p_A = 0.353$、$\tilde p_B = 0.255$、$\tilde p_A - \tilde p_B = 0.098$。
   - $\widetilde{SE} = 0.064$。
   - $\text{LB}_{\text{new}} = 0.098 - 1.645 \cdot 0.064 = -0.007$。
5. **Comparison**：傳統 LB = $-0.006$、new LB = $-0.007$，差距 $-0.001$。
6. **Conclusion**：plus-four 把點估計往 0.5 拉一點，標準誤略增，所以下界比傳統
   Wald 稍微保守一些；不過兩者都跨過 0，定性結論完全相同（沒法在 95% 信心下
   斷言 $p_A > p_B$）。
7. **Why use plus-four**：在 $n$ 不大或 $\hat p$ 接近 0 / 1 時，plus-four 的實際
   涵蓋率比 Wald 更接近名目水準（Brown, Cai & DasGupta 2001 的經典結果），
   所以這次雖然差距不明顯，作為兩比例差的「新 CI」依然值得跟傳統 Wald 並列。
