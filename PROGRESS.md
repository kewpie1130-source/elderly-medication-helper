# 📋 用藥小幫手 App（原長者智慧用藥辨識App）— 團隊進度追蹤表

> 此檔案由邱靖喻（PM）維護。
> **重要：本次更新包含完整的session歷史，供之後開新對話/額度重置後接續使用。**
> 最後更新：2026-06-23（深夜場session，含核心流程大改造+多項bug修復）

---

## 🎯 App 基本資訊（已確定）

```
App正式名稱：用藥小幫手
（原本暫稱「長者智慧用藥辨識App」，已正式更名）

待辦：尚未設計App Icon、尚未做啟動封面頁(Splash畫面)
```

---

## 🗂️ 一、檔案owner速查表

| 資料夾/檔案 | Owner | 其他人可否碰 |
|------------|-------|------------|
| `lib/theme/` | 邱靖喻 | ❌ 禁止 |
| `lib/widgets/` | 邱靖喻 | ❌ 禁止 |
| `lib/navigation/` | 邱靖喻 | ❌ 禁止 |
| `lib/models/` | 邱靖喻 | ❌ 禁止 |
| `lib/pages/camera/` | 邱靖喻 | ❌ 禁止 |
| `lib/services/ocr/` | 邱靖喻 | ❌ 禁止 |
| `lib/services/gemini/` | 邱靖喻 | ❌ 禁止 |
| `main.dart` | 邱靖喻 | ❌ 禁止 |
| `pubspec.yaml` | 邱靖喻 | ❌ 禁止 |
| `android/build.gradle.kts` | 邱靖喻 | ❌ 禁止 |
| `android/app/build.gradle.kts` | 邱靖喻 | ❌ 禁止 |
| `android/app/src/main/AndroidManifest.xml` | 邱靖喻 | ❌ 禁止 |
| `lib/database/db_helper.dart` | 邱靖喻（schema統一管理） | ❌ 禁止 |
| `lib/repositories/medicine_repository.dart` | 組員A | ❌ 禁止（但邱靖喻多次代修bug） |
| `lib/pages/medicine/` | 組員A | ❌ 禁止（邱靖喻代修溢出問題） |
| `lib/pages/history/` | 組員A→邱靖喻接手大改 | ⚠️ 已大幅改造（批次系統） |
| `lib/pages/reminder/` | 組員B | ❌ 禁止（邱靖喻多次代修） |
| `lib/services/notification/` | 組員B | ❌ 禁止（邱靖喻加exact alarm權限） |
| `lib/services/tts/` | 組員B | ❌ 禁止 |
| `lib/services/line/` | 組員B | ❌ 禁止 |
| `lib/repositories/reminder_repository.dart` | 組員B | ❌ 禁止 |
| `lib/pages/gallery/` | 組員C | ❌ 禁止 |
| `lib/pages/settings/` | 組員C | ❌ 禁止（待確認進度） |
| `lib/firebase/` | 組員C | ❌ 禁止 |
| `lib/services/analytics/` | 組員C | ❌ 禁止 |
| `lib/pages/dashboard/` | 組員C | ❌ 禁止（尚未實作） |
| 後台分析網頁(獨立HTML demo) | 邱靖喻 | 完全獨立於App，不影響Flutter專案 |

---

## ⚙️ 二、環境設定基準（已驗證穩定，不要再亂動）

```
✅ Java版本：21（電腦實際安裝版本，不是17）
✅ android/build.gradle.kts 設定：
   subprojects { afterEvaluate {
     compileOptions(Java 21) 
     + KotlinCompile(JVM_21) 
   }}
   ← Java跟Kotlin必須放在同一個afterEvaluate裡同時設定，
     否則會被套件覆蓋造成版本衝突
✅ 資料庫存取：path_provider的getApplicationDocumentsDirectory()
   ⚠️ 這個方式在Flutter Web平台會完全失敗(MissingPluginException)，
      sqflite功能只能用Android手機/模擬器測試，不能用Chrome網頁測試！
✅ FAB heroTag已設定避免衝突：
   gallery_page.dart: heroTag: 'gallery_fab'
   history_page.dart: heroTag: 'history_fab'
✅ AndroidManifest.xml 權限清單：
   INTERNET, SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM, 
   CAMERA, READ_EXTERNAL_STORAGE(maxSdk32), READ_MEDIA_IMAGES
```

---

## 📦 三、MedicineModel 完整欄位（已確定基準版本）

```dart
final String id;
final String name;
final String type;
final String dosage;
final String frequency;
final List<String> timing;       // 例如 ["早餐後","晚餐後"]
final String notice;
final String indication;          // 適應症，3961d5a加入
final String startDate;
final String endDate;
final String imagePath;
final String createdAt;
final String batchId;             // 批次ID，2d6af13加入，預設值''
```

## medicines table 完整欄位

```sql
CREATE TABLE medicines (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT,
  dosage TEXT,
  frequency TEXT,
  timing TEXT,
  notice TEXT,
  startDate TEXT,
  endDate TEXT,
  imagePath TEXT,
  createdAt TEXT NOT NULL,
  indication TEXT DEFAULT '',
  batchId TEXT DEFAULT ''
)

CREATE TABLE reminders (
  id TEXT PRIMARY KEY,
  medicineId TEXT NOT NULL,
  time TEXT NOT NULL,
  repeatType TEXT NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (medicineId) REFERENCES medicines(id)
)

CREATE TABLE dose_logs (
  id TEXT PRIMARY KEY,
  medicineId TEXT NOT NULL,
  scheduledTime TEXT NOT NULL,
  takenTime TEXT,
  status TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (medicineId) REFERENCES medicines(id)
)
```

---

## ✅ 四、本次session完整完成清單（2026-06-23深夜場）

### 核心OCR/拍照流程大改造
```
✅ Gemini service改成回傳List<MedicineModel>，支援一張圖辨識多種藥品
   （prompt要求回傳JSON陣列，並有容錯：若還是回傳單一物件也能處理）
✅ camera_page.dart過濾掉name為空的無效辨識結果
✅ 加入batchId概念：一次拍照辨識的所有藥品，共用同一個batchId(UUID)
✅ 流程改造：拍照辨識 → 確認頁（不會馬上存資料庫）→ 
   按「確認加入紀錄」才存入 → 之後才問是否設置提醒
✅ MedicinePlaceholderPage改成接收List<MedicineModel>，
   支援多筆藥品左右切換顯示（上一種/下一種按鈕+小圓點指示器）
✅ 每筆藥都各自有打卡和TTS播報功能
✅ 設置提醒彈窗(ReminderModal)選「是」後，正確導航到ReminderPage
   （不是之前那種直接排程10秒測試通知的方式）
```

### 重大Bug修復
```
✅ 【今日最大發現】修正getAllMedicines()完全沒有讀取batchId欄位的bug
   → 這個bug讓batchId功能從一開始就失效，紀錄頁永遠無法正確分組
   → 已在 medicine_repository.dart 修正，加上:
     batchId: maps[i]['batchId'] as String? ?? '',
✅ 修正FloatingActionButton Hero標籤衝突
   （gallery_page.dart和history_page.dart的FAB用同樣預設tag，
   導致頁面切換動畫崩潰，使用者點擊後流程會卡住）
✅ 修正exact_alarms_not_permitted錯誤：
   - AndroidManifest.xml加入SCHEDULE_EXACT_ALARM、USE_EXACT_ALARM權限
   - notification_service.dart的initialize()加入
     androidPlugin.requestExactAlarmsPermission()呼叫
✅ 修正medicine_detail_page.dart打卡/播報按鈕文字溢出
   （用Flexible包Text + overflow: ellipsis）
```

### 提醒頁(reminder_page.dart)改造
```
✅ initState()移除自動觸發ReminderModal的邏輯
   （之前會跟camera_page.dart流程重複觸發兩次彈窗）
✅ 「儲存」按鈕改成：直接排程真實通知（用使用者選的實際時間），
   不再觸發ReminderModal/ContactModal（這些只該在拍照流程出現一次）
✅ 加入滑動刪除功能（Dismissible + 確認對話框）
✅ 進入頁面時，若有傳入medicineName，會自動在下拉選單預選對應藥物
```

### 紀錄頁(history_page.dart)大改造
```
✅ 新增MedicineBatch類別，依batchId把藥品分組成「批次」
✅ 紀錄頁改成顯示「批次卡片」而非「單筆藥品卡片」
   （一次拍照辨識多種藥→顯示一條"XX等N種藥品"，點進去看清單）
✅ 新增_BatchDetailPage簡易清單頁（點擊批次卡片進入，
   列出該批次所有藥品，點個別藥品進MedicineDetailPage）
✅ FloatingActionButton簡化為純+號圖示（移除"手動新增"文字）
✅ 移除AppBar多餘的重新整理按鈕
```

---

## ⏳ 五、待處理問題完整清單（按優先序，含原始編號對照）

> 以下編號沿用Cassy自己整理的清單，方便對照

### 🔴 進行中/下一步要做（額度恢復後優先）

**【B2 - 提醒常用時段多選+自動預選】（討論到一半，額度用盡，已暫停）**
```
設計確認（已跟Cassy討論定案）：
1. 常駐顯示4個時段按鈕：早餐後/午餐後/晚餐後/睡前
2. 改成「多選」模式（不是單選），可以勾選1個或多個
3. 進入提醒頁時，根據該藥物的timing欄位（例如["早餐後","晚餐後"]），
   自動預先勾選對應的時段按鈕
4. 按「儲存」時，若勾選多個時段，要分別建立「多筆」ReminderModel
   （一個時段=一筆提醒記錄）

技術現況確認：
- ReminderPage目前建構子只有 `final String? medicineName`，
  沒有接收完整MedicineModel或timing資訊
- 需要改成接收完整MedicineModel（或額外傳入timing: List<String>），
  這樣才能讀到該藥的服用時段資訊來自動預選

下一步具體要做：
1. 修改ReminderPage建構子，新增可選參數接收完整MedicineModel或timing
2. camera_page.dart的_showReminderPrompt()要改成傳入完整藥物資訊
   （目前只傳medicineName字串）
3. reminder_page.dart的常駐時段按鈕從單選改多選（用Set<TimeOfDay>或
   Set<String>記錄已選時段）
4. initState()或載入藥物後，根據timing自動勾選對應按鈕
5. 儲存邏輯改成迴圈，每個勾選的時段都建立一筆ReminderModel並寫入資料庫
```

### 🟡 已知問題清單（編號對照Cassy原始記錄）

```
1. 多藥品TTS播報方式 → 跟問題20一起處理
   現況：辨識完成只播報摘要"已辨識出N種藥品"，
   每筆藥各自有播報按鈕可手動播放
   待優化：希望滑到新藥品時自動播報該藥名（除非使用者手動關閉）
   且喇叭按鈕太多處重複，應整合成更簡潔的單一邏輯

3. 字體不換行/系統字體適應問題
   待處理：使用者系統字體設定變大時，App文字也會跟著放大造成排版跑掉
   建議方案：考慮用FittedBox或AutoSizeText套件讓文字自動縮放

4. 按鈕文字溢出全面檢查（問題23也是這個）
   已修：camera_page.dart的MedicinePlaceholderPage按鈕、
        medicine_detail_page.dart的打卡/播報按鈕
   待查：reminder_page.dart可能也有類似問題（之前log有看到
        "RenderFlex overflowed by 17/40 pixels"但確切位置待查），
        以及其他尚未檢查過的頁面

8. 用藥歷史紀錄手動新增按鈕只要+號 → ✅ 已完成

9. 統一用藥時間設定+療程到期自動關閉提醒
   現況：上面B2就是這個功能的具體實作方案
   額外延伸：若藥品有填寫療程天數，到期後應自動將該提醒enabled設false
   （目前MedicineModel沒有療程天數欄位，只有startDate/endDate字串，
   需要額外設計怎麼從這兩個日期算出"是否已過期"並自動關閉提醒）

10. 相簿載入要先問是否辨識
    現況：相簿選圖直接視為要辨識
    待處理：選圖後應該先跳"是否要辨識這張圖片？"確認彈窗，
    且選的圖片要存到拍攝紀錄清單顯示

11. 拍攝紀錄要顯示拍過的照片
    現況：目前拍照/選圖辨識完成後，照片沒有被存到本機顯示在相簿頁
    待處理：需要存圖片路徑到本機，並在gallery_page.dart的
    「拍攝紀錄」Tab顯示縮圖列表

12. 移除相簿裡多餘拍攝按鈕
    現況：gallery_page.dart目前有一個額外的相機FAB按鈕
    待處理：直接刪除，因為底部導覽已經有獨立的拍攝Tab

13. 大頭貼直接點擊更換
    現況：設定頁有獨立的"更改大頭貼"文字按鈕
    待處理：移除這個按鈕文字，改成直接點擊大頭貼圖片本身
    跳出選單（拍照/從相簿選）

14. 設定頁按鈕沒反應，需確認C同學進度
    現況：上次確認過設定頁四個功能（使用者資訊/聯絡人/語言/登出）
    都還沒真正串接互動邏輯
    待處理：需要再次確認C同學是否已經做了基礎架構，
    若沒有由PM直接接手做簡易版本

15. UI整體排版美化
    現況：核心功能都做完後，整體視覺需要再精修留白、比例、配色一致性

16. 紀錄頁需要刪除功能
    現況：提醒頁已經有滑動刪除（這次session做的），
    但「用藥歷史紀錄」頁（history_page.dart的批次卡片）
    還沒有刪除功能
    待處理：加上類似的滑動刪除或長按刪除，
    注意：刪除一個批次時，要同時刪除該batchId下的所有藥品記錄

17. App啟動時間 → 已回答：Debug模式正常較慢，Release build會快很多

18. App名稱「用藥小幫手」+ Icon + 啟動封面頁
    現況：App名稱已確定為「用藥小幫手」
    待處理：
    - 設計App Icon（手機桌面看到的方形圖示）
    - 設計啟動封面頁（開啟App時先顯示品牌封面，再進入拍攝頁）
```

---

## 🔧 六、常見問題排查記錄（避免重複debug，這次session新增大量內容）

| 問題 | 原因 | 解決方式 |
|------|------|---------|
| Gradle找不到Flutter SDK | 路徑含中文字 | Flutter SDK裝在`C:\flutter`，專案在`C:\projects\` |
| Inconsistent JVM Target反覆出現 | 套件本身Java/Kotlin版本設定不一致，且要用afterEvaluate確保最後生效 | android/build.gradle.kts的subprojects裡，Java跟Kotlin設定要放在**同一個**afterEvaluate區塊內同時執行 |
| Java版本要用17還是21 | 取決於電腦實際安裝的JDK版本 | 用`java -version`確認，本機是21，所以全部統一用21（不是Flutter官方常見教學的17） |
| Web版測試sqflite完全失敗(MissingPluginException) | path_provider的getApplicationDocumentsDirectory()在Web平台不支援 | **資料庫相關功能必須用Android手機/模擬器測試，不能用Chrome網頁版** |
| 手機USB完全無法偵測 | 可能是USB線只能充電不能傳輸資料，或連接模式設定錯誤 | 改用無線偵錯(adb pair + adb connect)，每次IP/Port可能會變，需要重新配對 |
| 無線adb連線經常斷線、IP/Port常變動 | 無線偵錯本身不穩定 | 每次斷線重新执行`adb pair [IP:PORT] [配對碼]`再`adb connect [IP:PORT]`，配對碼有效時間很短要快速輸入 |
| FloatingActionButton Hero標籤衝突("multiple heroes share same tag") | 多個頁面的FAB都用預設heroTag，導致頁面切換動畫崩潰 | 每個用FAB的頁面都要設定**獨立**的`heroTag`字串 |
| 批次分組功能完全沒用，所有batchId都是空字串 | **getAllMedicines()手動建構MedicineModel時忘記讀取batchId欄位** | 這是這次session找到的最隱密的bug，務必在類似的"資料庫讀取"方法裡，逐一核對是否每個欄位都有對應讀取，不能只看`insert`方法對不對 |
| 定時排程通知失敗：exact_alarms_not_permitted | Android 12+對精確鬧鐘是特殊權限，需要使用者手動授權 | AndroidManifest加`SCHEDULE_EXACT_ALARM`+`USE_EXACT_ALARM`權限，並在NotificationService初始化時呼叫`androidPlugin.requestExactAlarmsPermission()` |
| 相機初始化失敗:CameraAccessDenied | adb shell pm clear清除App資料時，連同系統權限授權記錄一起清掉了 | 清除資料庫測試後，記得到手機設定重新允許相機權限，且要真正完全關閉App重啟才會生效（不能只是Hot Reload） |
| Gemini API錯誤429 | 短時間內測試拍照次數過多，超過免費版API請求頻率限制 | 等待10-15分鐘讓額度恢復，或檢查 https://aistudio.google.com/app/apikey 確認額度狀態 |
| 一直亂碼/未知藥品 | OCR辨識品質不穩定+name為空時UI顯示fallback文字 | 已在camera_page.dart加入過濾邏輯，name為空的辨識結果直接捨棄，不會顯示在結果裡 |
| 終端機顯示`R`指令出現PowerShell錯誤 | 那個終端機session已經不是`flutter run`的互動模式了（已經斷線結束） | 重新執行完整的`flutter run -d [device] --dart-define=...`指令，不能單獨打`R`字母 |
| VS Code左下角顯示"1 unsaved" | 純粹是編輯器層面有檔案沒按存檔，跟git/編譯無關 | 檢查分頁標籤上有圓點(●)的檔案，按Ctrl+S存檔 |
| 用adb pair配對總是失敗 | 配對碼/QR碼的有效時間很短，動作太慢就過期 | 重新點手機「使用配對碼配對裝置」拿到新的配對碼後，立刻執行adb pair指令，不要拖延 |

---

## ⚠️ 七、Merge前檢查清單（PM專用，沿用之前版本）

每次要merge某人的branch前：
```bash
git fetch origin
git diff origin/develop origin/feature/member-X --name-only
```

檢查清單：
- [ ] 確認所有變更檔案都在該成員的owner範圍內
- [ ] 若有越界檔案，先還原：`git checkout origin/develop -- 檔案路徑`
- [ ] 確認沒有動到`pubspec.yaml`（除非PM自己操作）
- [ ] 確認沒有動到`android/`下的設定檔
- [ ] merge後立即跑一次`flutter run`確認沒有build錯誤
- [ ] merge成功後更新本文件

**⚠️ 本次session特別教訓**：曾經三次發現組員的branch有大規模越界（動到20+個不該動的檔案，甚至出現整個多餘的`elder_medicine_app/`資料夾），代表組員可能用了有問題的git操作方式（如錯誤的rebase/reset）。**建議之後請組員直接貼程式碼內容給PM，由PM代為寫入檔案，完全避免讓組員自己操作git分支**，這是目前驗證過最安全可靠的協作方式。

---

## 📅 八、距離截止日剩餘時間

```
截止日：7月3日
本次session時間：2026-06-23（深夜場）
```

---

## 🔑 九、重要設定值記錄（避免遺失）

```
Gemini API Key: AIzaSyB5NM1_W1eal9Ug4eVxiBLvVn4nbj05XGg
（注意：今天測試過多已觸發429限流，需確認額度恢復狀況）

專案路徑：C:\projects\elderly_medication_app（正確，不要用C:\Users\靖喻\elderly_medication_app舊路徑）
Flutter SDK路徑：C:\flutter
Android Package Name：com.example.elderly_medication_app

常用測試指令：
flutter run -d [裝置IP:PORT] --dart-define=GEMINI_API_KEY=AIzaSyB5NM1_W1eal9Ug4eVxiBLvVn4nbj05XGg

清除App資料指令（測試新schema時用）：
& "C:\Users\靖喻\AppData\Local\Android\Sdk\platform-tools\adb.exe" shell pm clear com.example.elderly_medication_app
⚠️ 清除後記得重新允許相機權限，且要完全關閉App重新啟動

adb路徑：
C:\Users\靖喻\AppData\Local\Android\Sdk\platform-tools\adb.exe
```

---

*最後更新：2026-06-23 深夜場session結束，等待Codex額度恢復後接續B2功能開發*
