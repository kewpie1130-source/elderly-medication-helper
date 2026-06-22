# 長者智慧用藥管理系統

以 Flutter 開發的長者用藥管理 App，可拍攝或選取藥袋圖片，透過 OCR 辨識用藥文字，並將整理後的資料儲存在 SQLite 本機資料庫。

## 功能

- 拍照辨識藥袋
- 相簿選圖辨識
- OCR 文字辨識
- SQLite 本機儲存
- 用藥提醒
- 服藥紀錄

## 安裝方式

```bash
flutter pub get
flutter run
```

Windows 使用者若帳號路徑包含非 ASCII 字元，建議使用英文路徑的 Flutter SDK、Android SDK 與 Pub Cache。

## 目前進度

### 已完成

- 相簿選圖
- 拍照
- OCR
- SQLite
- Reminder
- History

### 開發中

- Gemini 藥物解析
- 後台資料分析
- UI 優化
