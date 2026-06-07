---
title: Homework Assignments 3 - PDF 完整擷取與 HackMD 版
tags: statistics, simple-linear-regression, PDF-extraction, homework
---

# Homework Assignments 3｜PDF 完整擷取與 HackMD Canvas 版

[TOC]

## 0. 擷取結論與校對說明

本文件是根據 `Homework Assignments 3.pdf` 重新進行逐頁檢查後整理出的 HackMD 可渲染版本。PDF 共 **3 頁**，主要包含兩題統計學作業：Exercise **6-5** 與 Exercise **6-11**，主題為 **simple linear regression**。

:::warning
前一次擷取稿「大致正確」，但我不會說它完全無誤。重新比對 PDF 圖像頁面與 PDF 文字層後，發現以下需要修正或補強的地方：

1. Page 2 的 PDF 文字層把 $\beta_0$、$\beta_1$ 錯誤解析成 `~o`、`~1`；實際圖像顯示為 $\beta_0$、$\beta_1$。
2. Page 2 的 PDF 文字層把 $\alpha$ 錯誤解析成 `ex`；實際圖像顯示為 $\alpha$。
3. Page 2 的 PDF 文字層把 `CIs` 容易誤讀成 `Cls`；實際圖像與語意應為 **CIs**。
4. Page 2 的 (d) 旁有一個藍色校訂註記：PDF annotations 顯示有 **StrikeOut** 與 **Caret insertion**，插入內容為 `the estimated`。因此原始印刷句是 “Find the standard error of the slope and intercept coefficients.”；若套用註記，修訂意圖應為 “Find the standard error of the estimated slope and intercept coefficients.”
5. Page 3 的 PDF 文字層把 `2.1` 解析成 `2 .1`；實際圖像為 **2.1**。
:::

## 1. 文件結構總覽

| 頁面 | 題號 | 內容定位 | 關鍵資訊 |
|---:|---:|---|---|
| 1 | 6-5 | 題目背景與資料表 | concrete compressive strength $x$ 與 intrinsic permeability $y$，共 **15** 筆資料 |
| 2 | 6-5 | 小題 (a) 到 (k) | 完整 simple linear regression 分析需求 |
| 3 | 6-11 | 小題 (a) 到 (d) | 沿用 Exercise 6-5，在 $x_0 = 2.1$ 時計算 mean response、99% CI、99% PI |

## 2. 圖像與版面資訊分析

### Page 1 圖像資訊

- 左上角題號為綠色 **6-5.**。
- 正文引用期刊 *Concrete Research*，期刊名在圖像中以斜體呈現。
- 題目提到文章標題為 “Near Surface Characteristics of Concrete: Intrinsic Permeability,”，期刊卷號為 **Vol. 41**，年份為 **1989**。
- 表格使用淺綠色表頭，欄位分成左右兩組：
  - 左組：Strength $x$、Permeability $y$
  - 右組：Strength $x$、Permeability $y$
- 左組有 **8** 筆資料，右組有 **7** 筆資料，合計 **15** 筆觀測值。
- 頁面左下角有頁碼 **1**。
- 頁面右下角有綠色頁尾文字：**EXERCISES FOR SECTION 6-2**。

### Page 2 圖像資訊

- 內容為 Exercise 6-5 的小題 **(a)** 到 **(k)**。
- 小題 (d) 附近有藍色 PDF 校訂註記，位置在 “the slope” 附近。
- PDF annotation metadata 顯示：
  - 一個 **StrikeOut** annotation，位於小題 (d) 的 `the` 附近。
  - 一個 **Caret** insertion annotation，內容為 `the estimated`。
- 因此小題 (d) 可分成兩種版本：
  - **原始印刷文字**：Find the standard error of the slope and intercept coefficients.
  - **套用校訂註記後的文字**：Find the standard error of the estimated slope and intercept coefficients.
- 頁面左下角有頁碼 **2**。
- 頁面右下角有綠色頁尾文字：**EXERCISES FOR SECTION 6-2**。

### Page 3 圖像資訊

- 左上角題號為綠色 **6-11.**。
- 題目要求沿用 Exercise 6-5 的 data 與 simple linear regression model。
- 指定 strength 為 **2.1**。
- 要求計算：mean permeability、99% confidence interval、99% prediction interval，並比較兩個 interval 的相對寬度。
- 頁面左下角有頁碼 **3**。
- 頁面右下角有綠色頁尾文字：**EXERCISES FOR SECTION 6-2**。

## 3. Page 1 完整文字擷取

### 3.1 正文

**6-5.** An article in *Concrete Research* (“Near Surface Characteristics of Concrete: Intrinsic Permeability,” Vol. 41, 1989) presented data on compressive strength $x$ and intrinsic permeability $y$ of various concrete mixes and cures. The following data are consistent with those reported.

### 3.2 原始表格重建

| Strength $x$ | Permeability $y$ | Strength $x$ | Permeability $y$ |
|---:|---:|---:|---:|
| 3.1 | 33.0 | 2.4 | 35.7 |
| 4.5 | 31.0 | 3.5 | 31.9 |
| 3.4 | 34.9 | 1.3 | 37.3 |
| 2.5 | 35.6 | 3.0 | 33.8 |
| 2.2 | 36.1 | 3.3 | 32.8 |
| 1.2 | 39.0 | 3.2 | 31.6 |
| 5.3 | 30.1 | 1.8 | 37.7 |
| 4.8 | 31.2 |  |  |

**EXERCISES FOR SECTION 6-2**

## 4. Page 2 完整文字擷取

### 4.1 Exercise 6-5 小題

**(a)** Estimate the intercept $\beta_0$ and slope $\beta_1$ regression coefficients. Write the estimated regression line.

**(b)** Compute the residuals.

**(c)** Compute $SS_E$ and estimate the variance.

**(d)** Find the standard error of the slope and intercept coefficients.

:::info
Page 2 的 (d) 有 PDF 校訂註記。若套用該註記，(d) 可讀作：

**(d, annotated)** Find the standard error of the estimated slope and intercept coefficients.
:::

**(e)** Show that $SS_T = SS_R + SS_E$.

**(f)** Compute the coefficient of determination, $R^2$. Comment on the value.

**(g)** Use a $t$-test to test for significance of the intercept and slope coefficients at $\alpha = 0.05$. Give the $P$-values of each and comment on your results.

**(h)** Construct the ANOVA table and test for significance of regression using the $P$-value. Comment on your results and their relationship to your results in part **(g)**.

**(i)** Construct 95% CIs on the intercept and slope. Comment on the relationship of these CIs and your findings in parts **(g)** and **(h)**.

**(j)** Perform model adequacy checks. Do you believe the model provides an adequate fit?

**(k)** Compute the sample correlation coefficient and test for its significance at $\alpha = 0.05$. Give the $P$-value and comment on your results and their relationship to your results in parts **(g)** and **(h)**.

**EXERCISES FOR SECTION 6-2**

## 5. Page 3 完整文字擷取

**6-11.** Consider the data and simple linear regression model in Exercise 6-5.

**(a)** Find the mean permeability given that the strength is **2.1**.

**(b)** Compute a 99% CI on this mean response.

**(c)** Compute a 99% PI on a future observation when the strength is equal to **2.1**.

**(d)** What do you notice about the relative size of these two intervals? Which is wider and why?

**EXERCISES FOR SECTION 6-2**

## 6. Canonical Dataset：Exercise 6-5 資料整理

下表將 Page 1 左右兩欄的資料依照原始閱讀順序整理成單一資料表，共 **15** 筆觀測值。

| Observation | Strength $x$ | Permeability $y$ |
|---:|---:|---:|
| 1 | 3.1 | 33.0 |
| 2 | 4.5 | 31.0 |
| 3 | 3.4 | 34.9 |
| 4 | 2.5 | 35.6 |
| 5 | 2.2 | 36.1 |
| 6 | 1.2 | 39.0 |
| 7 | 5.3 | 30.1 |
| 8 | 4.8 | 31.2 |
| 9 | 2.4 | 35.7 |
| 10 | 3.5 | 31.9 |
| 11 | 1.3 | 37.3 |
| 12 | 3.0 | 33.8 |
| 13 | 3.3 | 32.8 |
| 14 | 3.2 | 31.6 |
| 15 | 1.8 | 37.7 |

## 7. 作業要求拆解

### 7.1 Exercise 6-5 的統計任務

Exercise 6-5 要求以 compressive strength $x$ 作為 explanatory variable，以 intrinsic permeability $y$ 作為 response variable，建立 simple linear regression model：

$$
y = \beta_0 + \beta_1 x + \varepsilon
$$

需完成的項目包括：

| 小題 | 任務 | 對應統計概念 |
|---:|---|---|
| (a) | 估計 $\beta_0$、$\beta_1$，寫出 estimated regression line | Least squares estimation |
| (b) | 計算 residuals | Residual analysis |
| (c) | 計算 $SS_E$ 並估計 variance | Error sum of squares、$\hat{\sigma}^2$ |
| (d) | 找出 slope 與 intercept 估計係數的 standard error | Standard error of coefficients |
| (e) | 證明 $SS_T = SS_R + SS_E$ | ANOVA decomposition |
| (f) | 計算 $R^2$ 並評論 | Coefficient of determination |
| (g) | 對 intercept 與 slope 係數做 $t$-test，$\alpha = 0.05$ | Individual coefficient significance |
| (h) | 建立 ANOVA table，並用 $P$-value 測試 regression significance | Overall regression test |
| (i) | 建立 intercept 與 slope 的 95% CIs | Confidence intervals for coefficients |
| (j) | 進行 model adequacy checks | Linearity、normality、constant variance、outliers/influence |
| (k) | 計算 sample correlation coefficient 並檢定，$\alpha = 0.05$ | Correlation and significance test |

### 7.2 Exercise 6-11 的統計任務

Exercise 6-11 沿用 Exercise 6-5 的資料與 simple linear regression model，指定：

$$
x_0 = 2.1
$$

需完成的項目包括：

| 小題 | 任務 | 對應統計概念 |
|---:|---|---|
| (a) | 求 strength 為 2.1 時的 mean permeability | Estimated mean response $\hat{\mu}_{Y|x_0}$ |
| (b) | 計算該 mean response 的 99% CI | Confidence interval for mean response |
| (c) | 計算 strength = 2.1 時 future observation 的 99% PI | Prediction interval |
| (d) | 比較 99% CI 與 99% PI 的寬度 | PI 通常比 CI 寬，因為包含單一未來觀測誤差 |

## 8. 為什麼 Page 2 的 ANOVA 與 slope t-test 會互相呼應

在 simple linear regression 中，整體 regression significance 的 ANOVA $F$-test 與 slope 係數 $\beta_1$ 的雙尾 $t$-test 具有等價關係：

$$
F = t^2
$$

因此 Exercise 6-5 的 part **(g)** 與 part **(h)** 對 slope/regression significance 的結論應該一致。part **(k)** 的 sample correlation coefficient significance test，在 simple linear regression 中也會與 slope 的顯著性測試呈現一致結論。

## 9. Raw PDF Text Layer（保留解析痕跡，供校對）

以下是 PDF 文字層的原始抽取版本。這一節刻意保留部分解析瑕疵，例如 `~o`、`~1`、`ex`、`2 .1` 等，以方便追溯；正式作業請以上方 HackMD 正規化版本為準。

<details>
<summary>Page 1 raw text layer</summary>

```text
1
6 ... 5. 
An article in Concrete Research ("Near Surface 
Characteristics of Concrete: Intrinsic Permeability," Vol. 41, 
1989) presented data on compressive strength x and intrinsic 
permeability y of various concrete mixes and cures. The fol-
lowing data are consistent with those reported. 
Strength 
Permeability 
Strength 
Permeability 
X 
y 
X 
y 
3.1 
33.0 
2.4 
35.7 
4.5 
31.0 
3.5 
31.9 
3.4 
34.9 
1.3 
37.3 
2.5 
35.6 
3.0 
33.8 
2.2 
36.1 
3.3 
32.8 
1.2 
39.0 
3.2 
31.6 
5.3 
30.1 
1.8 
37.7 
4.8 
31.2 
EXERCISES FOR SECTION 6--2 
```

</details>

<details>
<summary>Page 2 raw text layer</summary>

```text
2
(a) Estimate the intercept ~o and slope ~1 regression coeffi-
cients. Write the estimated regression line. 
(b) Compute the residuals. 
( c) Compute SSE and estimate the variance. 
( d) Find the standard error of the slope and intercept coefficients. 
(e) Show that SSr =SSR + SSE· 
( f) Compute the coefficient of determination, R2 . Comment 
on the value. 
(g) Use a t-test to test for significance of the intercept and 
slope coefficients at ex =0.05. Give the P-values of each 
and comment on your results. 
(h) Construct the ANOVA table and test for significance of 
regression using the P-value. Comment on your results 
and their relationship to your results in part (g). 
(i) Construct 95% Cls on the intercept and slope. Comment 
on the relationship of these Cls and your findings in parts 
(g) and (h). 
(j) Perform model adequacy checks. Do you believe the 
model provides an adequate fit? 
(k) Compute the sample correlation coefficient and test for its 
significance at ex =0.05. Give the P-value and comment 
on your results and their relationship to your results in 
parts (g) and (h). 
EXERCISES FOR SECTION 6--2 
```

</details>

<details>
<summary>Page 3 raw text layer</summary>

```text
3
6 ... 11. 
Consider the data and simple linear regression model 
in Exercise 6-5. 
(a) Find the mean permeability given that the strength is 2.1. 
(b) Compute a 99% CI on this mean response. 
( c) Compute a 99% PI on a future observation when the 
strength is equal to 2 .1. 
( d) What do you notice about the relative size of these two 
intervals? Which is wider and why? 
EXERCISES FOR SECTION 6--2 
```

</details>

## 10. HackMD 使用注意事項

本檔案採用 HackMD 友善格式：

- 使用第一個 H1 標題作為文件標題。
- 使用 `[TOC]` 產生目錄。
- 使用 Markdown table 呈現資料表。
- 使用 `$...$` 呈現 inline math。
- 使用 `$$...$$` 呈現 block math。
- 使用 `:::info` 與 `:::warning` 呈現提示區塊。
- 不嵌入本機圖片路徑，避免貼到 HackMD 後圖片失效。

## 11. 最終可直接使用的資料 CSV

```csv
observation,x,y
1,3.1,33.0
2,4.5,31.0
3,3.4,34.9
4,2.5,35.6
5,2.2,36.1
6,1.2,39.0
7,5.3,30.1
8,4.8,31.2
9,2.4,35.7
10,3.5,31.9
11,1.3,37.3
12,3.0,33.8
13,3.3,32.8
14,3.2,31.6
15,1.8,37.7
```

## 12. 最終確認清單

- [x] Page 1 題號、正文、期刊資訊、15 筆資料、頁尾已擷取。
- [x] Page 2 小題 (a) 到 (k) 已擷取。
- [x] Page 2 的藍色校訂註記已納入說明。
- [x] Page 3 題號與小題 (a) 到 (d) 已擷取。
- [x] PDF 文字層解析錯誤已標記並以圖像內容校正。
- [x] 表格已整理成 HackMD 可渲染 Markdown table。
- [x] 數學符號已改為 HackMD/MathJax 可渲染格式。
