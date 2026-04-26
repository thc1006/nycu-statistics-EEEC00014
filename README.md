# NYCU Statistics — Homework Assignments 1

陽明交大 EEEC00014《統計學》Homework 1。內容是 Montgomery
*Applied Statistics and Probability for Engineers* 第 4 章 Decision Making for
a Single Sample 共 10 題（4-42、4-44、4-54、4-59、4-65、4-71、4-75、4-76、4-89、4-95），
涵蓋已知/未知 σ 的平均數推論、$\sigma$ 的 χ² 推論、單一比例（含 Wald
與 Agresti-Coull）以及預測/容忍區間。

## 專案結構

```
.
├── homework1.R              # 解題主腳本（10 題 + 共用 helper functions）
├── homework1.Rmd            # A4 PDF 報告排版來源
├── homework1.pdf            # 最終列印輸出（A4，41 頁）
├── homework1_output.txt     # Console 輸出快照
├── plots/                   # 常態檢查、power curve、區間比較圖
├── Dockerfile               # 重現環境（R 4.4.1 + tidyverse + LaTeX + Noto CJK）
├── AGENTS.md                # 作業實作規範（authoritative）
├── CLAUDE.md                # 專案層級的協作指示
├── Homework_Assignments_1.md   # 題目原文校對版（HackMD 風格）
├── Homework Assignments_1.pdf  # 題目原始 PDF
└── LICENSE
```

## 重現步驟

```bash
# 1. 建 image（rocker/verse 4.4.1 + texlive-* + Noto CJK + R 套件）
docker build -t hw1-r:1.2 .

# 2. 跑腳本，產出 homework1_output.txt 與 plots/
docker run --rm -v "$(pwd):/work" -w /work hw1-r:1.2 \
  bash -lc 'Rscript homework1.R > homework1_output.txt'

# 3. 渲染 A4 PDF
docker run --rm -v "$(pwd):/work" -w /work hw1-r:1.2 \
  bash -lc 'Rscript -e "rmarkdown::render(\"homework1.Rmd\", output_file=\"homework1.pdf\")"'
```

Windows + Git Bash 上請在 docker 指令前加 `MSYS_NO_PATHCONV=1`，否則路徑會被改寫。

## 題目對照表

| 題 | 章節 | 主題 |
|---:|---|---|
| 4-42 | 4-4 | 已知 σ 的單尾 z 檢定、β、樣本數、單尾下界 CI |
| 4-44 | 4-4 | 已知 σ 估平均數的樣本數 |
| 4-54 | 4-5 | 雙尾 t 檢定、常態檢查、CI、power 樣本數 |
| 4-59 | 4-5 | 單尾 t 檢定、單尾上界 CI、power 樣本數 |
| 4-65 | 4-5 | 單尾 t 檢定、power、樣本數、單尾下界 CI |
| 4-71 | 4-6 | $\sigma$ 的 χ² 檢定與 CI |
| 4-75 | 4-7 | 單一比例單尾檢定、β、樣本數、單尾下界 CI |
| 4-76 | 4-7 | 單一比例雙尾檢定、傳統 CI、樣本數 |
| 4-89 | 4-7 | Agresti-Coull CI 與 Wald CI 比較 |
| 4-95 | 4-8 | 預測區間 (PI) 與容忍區間 (TI) |

## 套件交叉驗證

| 任務 | 主算法 | 交叉驗證套件 |
|---|---|---|
| 已知 σ z-test | 手算公式 | `BSDA::z.test` |
| t-test | `t.test()` | 手算 |
| 常態檢查 | `shapiro.test` + Q-Q plot | — |
| t 檢定的 power | 自製 noncentral-t (`Pwr.t.test.custom`) | — |
| χ² for σ | 手算 `pchisq`/`qchisq` | — |
| 比例 z-test | 手算公式 | `prop.test(..., correct = FALSE)` |
| Tolerance interval | 手算 PI + `tolerance::normtol.int` | — |
