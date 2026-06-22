# 📋 長者智慧用藥辨識 App — 團隊進度追蹤表

> 此檔案由邱靖喻（PM）每日維護，記錄全組進度、套件變更、潛在衝突點。
> 每次重大merge後請更新此檔案。

---

## 🗂️ 一、檔案owner速查表

| 資料夾/檔案 | Owner | 其他人可否碰 |
|------------|-------|------------|
| `lib/theme/` | 邱靖喻 | ❌ 禁止 |
| `lib/widgets/` | 邱靖喻 | ❌ 禁止（可新增不可刪改既有） |
| `lib/navigation/` | 邱靖喻 | ❌ 禁止 |
| `lib/models/` | 邱靖喻 | ❌ 禁止 |
| `lib/pages/camera/` | 邱靖喻 | ❌ 禁止 |
| `lib/services/ocr/` | 邱靖喻 | ❌ 禁止 |
| `lib/services/gemini/` | 邱靖喻 | ❌ 禁止 |
| `main.dart` | 邱靖喻 | ❌ 禁止 |
| `pubspec.yaml` | 邱靖喻 | ❌ 禁止（需要套件請告知PM） |
| `android/build.gradle.kts` | 邱靖喻 | ❌ 禁止（JVM版本設定） |
| `android/app/build.gradle.kts` | 邱靖喻 | ❌ 禁止 |
| `android/app/src/main/AndroidManifest.xml` | 邱靖喻 | ❌ 禁止 |
| `lib/database/db_helper.dart` | 邱靖喻（schema統一管理） | ❌ 禁止（需要新table請告知PM） |
| `lib/repositories/medicine_repository.dart` | 組員A | ❌ 其他人禁止 |
| `lib/pages/medicine/` | 組員A | ❌ 其他人禁止 |
| `lib/pages/history/` | 組員A | ❌ 其他人禁止 |
| `lib/pages/reminder/` | 組員B | ❌ 其他人禁止 |
| `lib/services/notification/` | 組員B | ❌ 其他人禁止 |
| `lib/services/tts/` | 組員B | ❌ 其他人禁止 |
| `lib/services/line/` | 組員B | ❌ 其他人禁止 |
| `lib/repositories/reminder_repository.dart` | 組員B（新檔案） | ❌ 其他人禁止 |
| `lib/pages/gallery/` | 組員C | ❌ 其他人禁止 |
| `lib/pages/settings/` | 組員C | ❌ 其他人禁止 |
| `lib/firebase/` | 組員C | ❌ 其他人禁止 |
| `lib/services/analytics/` | 組員C | ❌ 其他人禁止 |
| `lib/pages/dashboard/` | 組員C | ❌ 其他人禁止 |

---

## 📦 二、目前 pubspec.yaml 套件清單（截至本次更新）

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  camera: ^0.11.0
  image_picker: ^1.2.2
  google_mlkit_text_recognition: ^0.15.0
  sqflite: ^2.4.2
  path: ^1.9.1
  path_provider: ^2.1.5
  intl: ^0.20.2
  http: ^1.2.0
  uuid: ^4.5.2
  flutter_tts: ^4.1.1
  flutter_local_notifications: ^18.0.0
  timezone: ^0.9.0
  firebase_core: ^3.0.0
  cloud_firestore: ^5.0.0
```

⚠️ **重要**：`flutter_timezone` 已於 [日期] 移除（造成JVM版本衝突，且確認無程式碼使用）

**新增套件流程**：任何人需要新套件，請在群組告知PM，由PM統一加入並測試build後再通知全組pull。

---

## ⚙️ 三、已知的版本/環境設定（避免重複踩坑）

| 設定項目 | 數值 | 說明 |
|---------|------|------|
| Java版本 | 17 | 統一用JVM Toolchain方式設定 |
| Kotlin版本 | 17 | 透過`android/build.gradle.kts`的subprojects+afterEvaluate強制統一 |
| compileSdk | flutter.compileSdkVersion | 跟隨Flutter版本 |
| minSdk | flutter.minSdkVersion | 跟隨Flutter版本 |
| Flutter SDK路徑 | `C:\flutter` | ⚠️ 不可用含中文字的路徑，會造成Gradle build失敗 |
| 專案路徑 | `C:\projects\elderly_medication_app` | ⚠️ 不可用含中文字的路徑（例如使用者資料夾名稱） |
| core library desugaring | 已開啟 | `flutter_local_notifications`需要 |

**如果新增套件後又出現「Inconsistent JVM Target」錯誤**：
不要自己亂改，請截圖完整錯誤訊息回報PM，由PM在`android/build.gradle.kts`統一處理。

---

## 🗄️ 四、資料庫 Schema（db_helper.dart，PM管理）

```sql
-- 藥品表
CREATE TABLE medicines (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT,
  dosage TEXT,
  frequency TEXT,
  timing TEXT,  -- JSON array string
  notice TEXT,
  startDate TEXT,
  endDate TEXT,
  imagePath TEXT,
  createdAt TEXT NOT NULL,
  indication TEXT DEFAULT ''
);

-- 提醒表
CREATE TABLE reminders (
  id TEXT PRIMARY KEY,
  medicineId TEXT NOT NULL,
  time TEXT NOT NULL,
  repeatType TEXT NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (medicineId) REFERENCES medicines(id)
);

-- 服藥紀錄表
CREATE TABLE dose_logs (
  id TEXT PRIMARY KEY,
  medicineId TEXT NOT NULL,
  scheduledTime TEXT NOT NULL,
  takenTime TEXT,
  status TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (medicineId) REFERENCES medicines(id)
);
```

**若需要新增欄位或table**：請告知PM，不要自己改`db_helper.dart`，避免跟其他人的schema版本對不上。

---

## ✅ 五、目前已完成且可使用的功能

- [x] 拍攝辨識（相機/相簿選圖 → OCR → Gemini解析 → 顯示結果）
- [x] 辨識結果頁（含適應症、打卡按鈕UI、播報按鈕UI）
- [x] 紀錄頁（顯示歷史紀錄、依日期分組、手動新增藥物功能含資料庫存取）
- [x] 藥品詳細頁（含打卡功能，已串接DoseLog寫入資料庫）
- [x] 相簿頁（手機相簿選圖、拍攝紀錄Tab）
- [x] 設定頁UI（完全對齊設計稿，雙行清單項目）
- [x] 底部導覽（5個Tab全部可切換）
- [x] Modal彈窗UI（提醒/聯絡人視窗樣式）

---

## ⏳ 六、規格書(SPEC.md)有規劃但尚未完成的功能

- [ ] 提醒功能完整串接（藥物選擇、存入reminders table、清單真實讀取）— **組員B進行中**
- [ ] 彈窗（畫面7/8）正確觸發時機確認 — **組員B進行中**
- [ ] TTS語音播報是否真正發聲待驗證
- [ ] LINE通知是否真正可發送待驗證
- [ ] 設定頁所有功能串接（使用者資訊、聯絡人、語言、登出）— **組員C進行中**
- [ ] Dashboard匿名健康趨勢分析頁面內容
- [ ] Firebase是否真正寫入資料待驗證
- [ ] 多語言切換機制
- [ ] 使用者登入系統

---

## 📅 七、每日進度日誌

> 格式：日期 / 負責人 / 完成內容 / 修改檔案 / 風險提示

### 2026-06-XX（請每天更新）

**邱靖喻**
- 完成：[填入今日完成事項]
- 修改檔案：[列出檔案]
- 風險提示：[若有可能影響他人的事項]

**組員A**
- 完成：
- 修改檔案：
- 風險提示：

**組員B**
- 完成：
- 修改檔案：
- 風險提示：

**組員C**
- 完成：
- 修改檔案：
- 風險提示：

---

## ⚠️ 八、Merge前檢查清單（PM專用）

每次要merge某人的branch前，請執行：

```bash
git fetch origin
git diff origin/develop origin/feature/member-X --name-only
```

檢查清單：
- [ ] 確認所有變更檔案都在該成員的owner範圍內
- [ ] 若有越界檔案，先還原：`git checkout origin/develop -- 檔案路徑`
- [ ] 確認沒有動到 `pubspec.yaml`（除非PM自己操作）
- [ ] 確認沒有動到 `android/` 下的設定檔
- [ ] 確認沒有commit `.vscode/` 等個人化設定檔
- [ ] merge後立即跑一次 `flutter run` 確認沒有build錯誤
- [ ] merge成功後更新本文件的「每日進度日誌」區塊

---

## 🔧 九、常見問題排查記錄（避免重複debug）

| 問題 | 原因 | 解決方式 |
|------|------|---------|
| Gradle找不到Flutter SDK | 路徑含中文字 | 確認Flutter SDK裝在`C:\flutter`，專案在`C:\projects\` |
| local.properties路徑亂碼 | Flutter自動重新產生時讀到舊PATH環境變數 | 確認系統PATH裡只有一個正確的flutter/bin路徑 |
| Inconsistent JVM Target | 套件本身Java/Kotlin版本與專案不一致 | 已在`android/build.gradle.kts`用Toolchain方式統一，新增套件若又出現此問題請告知PM |
| flutter_local_notifications編譯失敗 | 缺少core library desugaring | 已在`android/app/build.gradle.kts`開啟，無需再處理 |
| ADB無線連線斷線頻繁 | 無線偵錯不穩定 | 建議改用USB線連接，較穩定 |
| Chrome網頁版相機顯示CameraAccessDenied | 瀏覽器沒給相機權限，非程式碼問題 | 手機真機測試不會有此問題 |

---

*最後更新：請PM每次更新內容時手動填寫日期*
