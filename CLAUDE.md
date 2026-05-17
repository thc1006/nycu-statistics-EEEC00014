# EEEC00014 統計學作業 — 專案層級指示

每份作業放在 `homeworkN/` 子資料夾下，具體實作規範請看該資料夾內的
`AGENTS.md` 與 `CLAUDE.md`。本檔僅放跨作業共通的規則。

## 共通規則（適用所有作業）

1. **程式碼風格**：要像人類寫的、不要 AI-perfect。命名一致、邏輯清楚、
   流程自然。不要在不需要的地方塞最新炫技語法，不要一直 refactor。
2. **註解語言**：台灣繁體中文口語。註解不得長於程式碼本身。
3. **答案精度**：依該作業 `AGENTS.md` 的規定（Homework 1 是四位小數）。
4. **列印格式**：最終輸出符合 A4，方便交件列印。
5. **commit 訊息**：嚴禁任何 AI 署名（包括但不限於
   `Generated with Claude Code`、`Co-Authored-By: Claude`、🤖、
   `ChatGPT`、`Codex`、`Anthropic`...）。
6. **Push 政策**：預設只 commit，**不可 push**。除非使用者當下明確說
   「推上遠端」之類的指令才執行。
7. **Bug 處理**：遇到 BUG 時要一步步分析 log 或 stack trace，不要囫圇
   吞棗、亂改一通。

## 進入特定作業時

當在 `homework1/` 或之後的 `homeworkN/` 工作時，該資料夾內的
`AGENTS.md` 是「實作層級的權威來源」，含資料、檢定方向、樣本數公式、
helper functions 等具體規範。