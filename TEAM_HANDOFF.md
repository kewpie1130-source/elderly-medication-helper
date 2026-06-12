# 團隊整合版交接說明

目前團隊測試與後續開發基準分支：

```text
feature/integration-dose-session
```

此分支暫時由整合負責人維護。請不要直接推送到此分支，也不要直接把它合併到 `main`。

## 1. 載入目前進度

第一次下載專案：

```bash
git clone https://github.com/kewpie1130-source/elderly-medication-helper.git
cd elderly-medication-helper
git fetch origin
git switch -c feature/integration-dose-session --track origin/feature/integration-dose-session
flutter pub get
flutter run
```

已經下載過專案：

```bash
git status
git fetch origin
git switch feature/integration-dose-session
git pull --ff-only origin feature/integration-dose-session
flutter pub get
flutter run
```

執行 `git switch` 或 `git pull` 前，請先確認 `git status`。若有尚未提交的修改，先提交到自己的功能分支，或使用 `git stash` 暫存，不要直接覆蓋。

Windows 帳號或專案路徑含中文時，Android 建置工具可能失敗。建議使用英文路徑的 Flutter SDK、Pub Cache，必要時將專案映射到英文磁碟代號後執行。

## 2. 增加或刪減資料，避免衝突

每位組員都從整合基準建立自己的分支：

```bash
git fetch origin
git switch feature/integration-dose-session
git pull --ff-only origin feature/integration-dose-session
git switch -c feature/<姓名或代號>-<功能名稱>
```

修改完成後：

```bash
dart format lib test
flutter analyze
git add <本次修改的檔案>
git commit -m "feat: 簡短描述"
git push -u origin feature/<姓名或代號>-<功能名稱>
```

再建立 Pull Request，目標分支選：

```text
feature/integration-dose-session
```

協作規則：

- 不直接推送到 `feature/integration-dose-session`。
- 不使用 `git add -A`，只加入自己本次負責的檔案。
- 不修改或刪除其他組員建立的 model、repository、service，除非 PR 有說明原因。
- 不自行更動 `lib/main.dart`、`pubspec.yaml`、SQLite schema 或共用 model；需要更動時先在群組告知整合負責人。
- 刪除資料欄位或資料表前，先提出 migration 與舊資料處理方式。
- PR 前先同步整合分支；有衝突時在自己的功能分支處理，不要在整合分支直接解衝突。
- 不提交 `build/`、`.dart_tool/`、本機 Pub Cache、APK、執行紀錄或只有換行變化的 generated plugin 檔案。

## 3. 目前整合版內容

- OCR 拍照與相簿選圖流程。
- OCR 結果整理及 Gemini 結果頁導覽。
- SQLite 本機資料庫 `smart_medication.db`。
- 本機藥物新增、刪除、讀取與清除測試資料。
- 今日用藥提醒與逐項服藥紀錄。
- SQLite 用藥時段 `dose_sessions` 與品項紀錄 `dose_item_logs`。
- 「開始本時段用藥打卡」入口及完成後鎖定。
- 用藥紀錄頁。
- Dashboard 首頁入口與底部「分析」導覽。
- 設定頁顯示 SQLite 資料庫名稱與目前藥物筆數。

目前 Dashboard 的圖表資料仍由 `ChartService.getMockAnalytics()` 產生，是示範資料，不代表 SQLite 真實統計。

## 4. 暫時不要做的項目

目前 `origin/main` 與 `feature/integration-dose-session` 已經分岔。`main` 含有其他組員的 Firebase、Gemini 與共同資料結構提交，整合分支則含有 OCR、SQLite、Dashboard 與用藥場次提交。

在整合負責人完成兩邊差異整理前：

- 不要把 `feature/integration-dose-session` 直接合併到 `main`。
- 不要把 `main` 整批 merge 到自己的功能分支後再推回整合分支。
- 不要重做 Firebase 初始化、Gemini 核心串接或共同 Data Model。
- 不要把 Dashboard 改成讀取真實 SQLite/Firebase 資料，先等分析欄位與資料來源確認。
- 不要修改 `dose_sessions`、`dose_item_logs` 的欄位名稱或狀態值。
- 不要同時重構主導覽、資料庫與 UI；每個 PR 只處理一個明確功能。

可以先進行：

- 依現有畫面做手動測試並回報重現步驟。
- 為目前 repository、parser 與 model 補單元測試。
- 在自己的功能分支改善單一頁面的無障礙文字、錯誤提示或空資料狀態。

下一個整合節點是：整合負責人先把 `origin/main` 的 Firebase、Gemini、共同 Data Model 與目前 SQLite 用藥場次逐項比對，確定保留的 model、資料來源與導覽後，再通知組員開始真實 Dashboard、雲端同步及通知功能。
