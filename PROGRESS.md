# 📋 用藥小幫手 App — 團隊進度追蹤表（交接版）

> **這是對話切換前的完整交接記錄，新對話開始時請先讀完這份文件再繼續。**
> 最後更新：第二天session結束前緊急記錄

---

## 🚨 立即要做的事（新對話開場就要處理）

```
我剛才給了Codex這個指令，正在等待回應：

【任務】暫時把reminder_page.dart裡的通知排程邏輯註解掉，
測試是否是zonedSchedule()造成「按儲存後完全黑屏卡死」的問題

具體指令內容：
把這段（在"儲存"按鈕onPressed裡）：
// 排程真正的本地通知，用使用者實際選擇的時間
final now = DateTime.now();
var scheduledDateTime = tz.TZDateTime(...);
if (scheduledDateTime.isBefore(...)) {...}
await _notificationService.zonedSchedule(...);

用 /* */ 整段註解起來，只留insertReminder()繼續執行。

新對話開始時，請先問使用者「Codex剛才回報的內容是什麼」，
拿到回報後：
1. 確認有沒有編譯錯誤
2. 確認後commit："debug: 暫時停用通知排程測試黑屏問題根源"
3. 重新flutter run測試，按儲存看是否還黑屏
4. 若不再黑屏 → 確認問題出在zonedSchedule()或
   requestExactAlarmsPermission()，需要進一步排查通知權限
   邏輯（可能是Android系統權限對話框跟Flutter UI層衝突）
5. 若還是黑屏 → 問題在別的地方，需要重新排查
   （懷疑方向：Navigator.pop()本身、或ReminderRepository.insertReminder()）
```

---

## ⚠️ 重大安全事件（已處理，務必記住）

```
今天發現：Gemini API Key被寫在PROGRESS.md裡，
這個repo是PUBLIC的，Google安全掃描系統偵測到並標記該Key為「警告」，
導致該Key開始出現403錯誤（被拒絕）。

已完成處理：
✅ 從PROGRESS.md移除所有明文API Key
✅ 使用者已經自己去Google AI Studio建立了新Key

⚠️ 重要規則（之後絕對要遵守）：
- 永遠不要把API Key寫進任何會commit的檔案
- 只能在執行flutter run指令時用--dart-define帶入
- 新Key目前只存在使用者自己的筆記，沒有寫入任何檔案
```

---

## 📦 App基本資訊

```
App正式名稱：用藥小幫手
Package name: com.example.elderly_medication_app
專案路徑：C:\projects\elderly_medication_app（注意：不是C:\Users\靖喻\elderly_medication_app舊路徑）
GitHub repo: kewpie1130-source/elderly-medication-helper（注意：這是PUBLIC repo，不要寫入任何機密資訊）
branch: develop
deadline: 7月3日，使用者希望這個禮拜日（約還有幾天）完成主要demo流程
```

---

## ✅ 第二天session完整完成清單（按時間順序）

```
1. ✅ 紀錄頁自動刷新bug修正（GlobalKey<HistoryPageState>機制，
   切到紀錄Tab時主動呼叫loadHistoryData()）
2. ✅ Gemini prompt強化：即使OCR沒寫適應症/副作用，
   也要求根據藥名醫學知識主動推斷填寫
3. ✅ 相簿頁移除多餘拍攝FAB
4. ✅ 相簿頁移除"支援JPG、PNG"提示文字
5. ✅ 相簿頁Tab文字優化："手機相簿載入"→"選取照片"
6. ✅ 相簿頁圖片改成持久化儲存（用path_provider存到本機
   gallery_images/目錄，重開App不會消失）
   ⚠️ 但這次儲存沒有區分"相簿選的"跟"拍照拍的"來源，
   全部混在同一個目錄、同一個"拍攝紀錄"Tab顯示
   → 這個是下面"待處理問題27"的根因
7. ✅ 設定頁大頭貼改成直接點擊CircleAvatar更換
   （GestureDetector+showModalBottomSheet選拍照/相簿）
8. ✅ 設定頁四個項目全部加上互動（使用者資訊編輯、
   聯絡人LINE ID編輯、語言選擇、登出確認）
9. ✅ 紀錄頁批次卡片加入Dismissible滑動刪除（含確認對話框，
   刪除會連同該batchId下所有藥品一起刪除，
   新增了MedicineRepository.deleteMedicine()方法）
10. ✅ 補回medicine_detail_page.dart的適應症(indication)顯示
    （之前被組員A誤判"規格書未定義"而刪除，這是重要bug修復）
11. ✅【重大bug】修正settings_page.dart使用者資訊對話框崩潰問題
    - 第一輪修正：取消按鈕加上Navigator.pop(ctx, null)，
      controller.dispose()後加mounted檢查
    - 第二輪修正（更關鍵）：完全移除controller.dispose()呼叫，
      因為dispose時機過早導致
      "'_dependents.isEmpty': is not true"崩潰
12. ✅ Gemini API加入自動重試機制：
    針對503(服務不可用)和429(請求過多)錯誤，
    最多重試3次，每次間隔1.5秒
13. ✅ 安全性修正：移除PROGRESS.md明文API Key
14. ⏳【進行中，等Codex回報】提醒頁儲存後黑屏問題排查
    - 已知：完全黑屏卡死，連返回鍵都沒反應
    - 已知：Console沒有任何錯誤訊息或Exception
    - 已知：單純進入提醒頁不會黑屏，只有按"儲存"才會
    - 已嘗試：在showSnackBar和Navigator.pop()之間加600ms延遲
      → 沒有解決問題
    - 目前嘗試：把zonedSchedule()通知排程整段註解掉測試
      （這是新對話開場要先確認結果的任務）
```

---

## 🟡 待處理問題完整清單（按發現順序編號，最新狀態）

```
1.  多藥品TTS播報優化（單一喇叭+滑到新藥自動播報）→ 未處理
3.  字體不換行/系統字體適應 → 未處理
4.  按鈕文字溢出全面檢查（reminder_page.dart可能還有）→ 部分處理
    （已修camera_page.dart、medicine_detail_page.dart的按鈕，
    reminder_page.dart本身可能還有未查的位置）
9.  療程到期自動關閉提醒 → 未處理
15. UI整體排版美化 → 未處理（有ChatGPT生成的UI設計參考圖，
    色彩系統跟現有AppTheme一致，可採用但不整頁重做，
    採"微調套用"策略）
18. App Icon+啟動封面頁 → 未處理（有設計圖參考：
    綠色愛心+藥丸圖案，App名稱"用藥小幫手"）

【B2 - 提醒常用時段多選+自動預選】（一直沒開始實作，設計已確認）
具體設計：
- 常駐顯示4個時段按鈕：早餐後/午餐後/晚餐後/睡前
- 改成多選模式（不是單選），可勾選1個或多個
- 進入提醒頁時，根據該藥物的timing欄位
  （例如["早餐後","晚餐後"]）自動預先勾選對應按鈕
- 按"儲存"時，若勾選多個時段，要分別建立多筆ReminderModel
技術現況：
- ReminderPage建構子目前只有`final String? medicineName`，
  沒有接收完整MedicineModel或timing
- 需要先改建構子接收完整藥物資訊，
  camera_page.dart的_showReminderPrompt()也要跟著改

22. 紀錄頁批次卡片+日期分組視覺優化 → 未處理
    （目前已有"今日/本週/更早"分組，可以視覺上優化更醒目）

23. ✅ 已解決：藥品詳情頁適應症顯示
24. 部分解決：相簿頁照片持久化已完成，但來源沒分流（見問題27）
25. 已確認：設定頁拍照黑屏只是短暫視覺閃爍，功能正常，優先級低

26. ⏳ 進行中：提醒頁儲存後完全黑屏卡死（見上方"立即要做的事"）

27. 🆕 相簿頁兩個Tab需要重新設計（完整需求）：
    【選取照片Tab】顯示「所有曾經從手機相簿選取過的圖片」歷史紀錄，
    含日期標示，可點擊放大瀏覽（像看相簿），
    且保留"從相簿選取照片"按鈕供繼續新增
    【拍攝紀錄Tab】顯示「所有透過App首頁相機拍攝」的照片
    （不是從相簿選的），自動存取、含日期、可點擊放大瀏覽
    
    技術上需要：
    - 區分儲存目錄：相簿選的存到一個資料夾，
      camera_page.dart拍的存到另一個資料夫
    - camera_page.dart目前完全沒有"拍照後存圖片"的邏輯，
      需要新增（拍照辨識流程中順手存一份圖片）
    - 兩個Tab的GridView改成都從各自對應目錄讀取
    - 需要新增一個簡單的圖片預覽/放大頁面（兩個Tab共用）

新增問題21已完成（相簿Tab文字優化，併入清單7）
```

---

## ⚙️ 環境設定基準（不要再亂動，已驗證穩定）

```
✅ Java版本：21
✅ android/build.gradle.kts：Java+Kotlin設定要放在同一個afterEvaluate裡
✅ 資料庫存取只能用Android手機測試，不能用Chrome網頁版
✅ FAB heroTag：gallery_fab、history_fab已設定避免衝突
✅ AndroidManifest.xml權限：
   INTERNET, SCHEDULE_EXACT_ALARM, USE_EXACT_ALARM,
   CAMERA, READ_EXTERNAL_STORAGE(maxSdk32), READ_MEDIA_IMAGES
✅ NotificationService.initialize()已加入
   androidPlugin.requestExactAlarmsPermission()呼叫
```

## MedicineModel完整欄位（最新版）

```dart
final String id, name, type, dosage, frequency;
final List<String> timing;
final String notice, indication;  // indication=適應症
final String startDate, endDate, imagePath, createdAt, batchId;
```

## 資料庫schema（medicines table含batchId、indication欄位，已確認正確運作）

---

## 🔧 重要bug修復記錄（新對話若遇到類似問題，先查這裡）

```
| 問題 | 原因 | 解法 |
|------|------|------|
| getAllMedicines()讀不到batchId | 手動建構Model時忘記讀該欄位 | 加上 batchId: maps[i]['batchId'] as String? ?? '' |
| FAB Hero標籤衝突 | 多頁面FAB用同預設tag | 每頁設定唯一heroTag字串 |
| exact_alarms_not_permitted | Android12+特殊權限 | Manifest加權限+呼叫requestExactAlarmsPermission() |
| TextField/Controller dispose崩潰 | dispose時機過早，"_dependents.isEmpty"錯誤 | 直接移除controller.dispose()呼叫，不手動dispose比崩潰風險更安全 |
| API Key 403錯誤 | Key寫在public repo被Google掃描偵測 | 永遠不寫入任何commit的檔案，只能用--dart-define帶入 |
| Gemini 429/503錯誤 | 短時間請求過多/服務暫時不穩 | 加自動重試機制(最多3次，間隔1.5秒) |
| 提醒頁按儲存後黑屏卡死 | ⏳尚未確定，懷疑跟zonedSchedule()或通知權限對話框有關 | 進行中，已嘗試delay無效，現在測試註解通知排程 |
```

---

## 🔑 常用指令記錄

```
清除App資料（測試新schema用）：
& "C:\Users\靖喻\AppData\Local\Android\Sdk\platform-tools\adb.exe" shell pm clear com.example.elderly_medication_app

無線連線（每次IP/Port可能變動）：
& "C:\Users\靖喻\AppData\Local\Android\Sdk\platform-tools\adb.exe" pair [IP:配對Port] [配對碼]
& "C:\Users\靖喻\AppData\Local\Android\Sdk\platform-tools\adb.exe" connect [IP:連線Port]

執行App（記得用新的、沒洩露過的API Key）：
flutter run -d [裝置IP:PORT] --dart-define=GEMINI_API_KEY=[使用者自己保管的新Key]

確認git安全目錄（避免dubious ownership警告）：
git config --global --add safe.directory C:/projects/elderly_medication_app
```

---

## 📌 給新對話的開場指引

```
1. 先詢問使用者：「Codex針對'註解通知排程測試黑屏'這個任務的回報是什麼？」
2. 根據回報結果判斷：
   - 若黑屏消失 → 問題確定在通知排程相關，
     進一步排查zonedSchedule()或Android權限對話框
   - 若黑屏依舊 → 問題在別處，建議排查Navigator.pop()
     或ReminderRepository.insertReminder()是否有問題
3. 解決黑屏問題後，視時間狀況決定是否要做：
   - 問題27（相簿頁來源分流，中等工作量）
   - B2功能（提醒多選時段，中等工作量）
   - 或直接著手UI美化+App Icon（demo前最後階段該做的事）
4. 使用者目標是本週日完成demo，請持續關注時間進度，
   優先確保核心流程（拍照→辨識→紀錄→提醒）100%穩定不崩潰，
   視覺美化和次要功能可以視剩餘時間決定要不要做
```

---

*交接完成，新對話請從這份文件開始接續*
