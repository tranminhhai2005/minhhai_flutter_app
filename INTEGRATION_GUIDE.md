# 📋 Hướng Dẫn Tích Hợp Tính Năng Mới

## 1️⃣ Thêm Recently Played vào Home Screen

Tìm `lib/screens/home_screen.dart` và thêm:

```dart
import '../screens/recently_played_widget.dart';

// Trong build() method của HomeScreen, thêm vào Column:
Column(
  children: [
    // ... các widget khác ...
    const RecentlyPlayedWidget(),  // ← Thêm dòng này
    // ... các widget khác ...
  ],
)
```

---

## 2️⃣ Tính Năng Đã Có Sẵn Trong PlayerScreen

### EQ Button
- ✅ Đã thêm button "🎛 EQ" bên cạnh "⏱ Timer"
- ✅ Bấm vào → Mở EqualizerScreen

### Sleep Timer Button  
- ✅ Đã thêm button "⏱ Timer"
- ✅ Bấm vào → Hiển thị dialog chọn thời gian

---

## 3️⃣ Dark Mode Đã Hoạt Động

### Ở ProfileScreen
```
Profile → Kéo xuống → 🌙 Dark Mode → Bật/tắt switch
```

### Cách hoạt động
1. Thay đổi theme từ profile
2. Tất cả screen tự động áp dụng theme mới
3. Theme được lưu, giữ lại khi mở lại app

---

## 4️⃣ Recently Played Tự Động Hoạt Động

- ✅ Mỗi khi phát bài → Tự động lưu vào recently played
- ✅ Không cần làm gì thêm
- ✅ Hiển thị 10 bài gần nhất

---

## 5️⃣ Tính Năng Có Thể Thêm Sau

### Download Button trong PlayerScreen
```dart
// Thêm vào PlayerScreen appBar actions
IconButton(
  icon: Icon(_isDownloaded ? Icons.done : Icons.download),
  onPressed: () {
    // Gọi DownloadHelper để tải bài
  },
)
```

### Lyrics Screen
```dart
// Tạo lyrics_screen.dart
// Hiển thị lời bài hát theo timeline
```

---

## 📝 Files Chính

| File | Chức Năng |
|------|----------|
| `theme_provider.dart` | Quản lý theme sáng/tối |
| `recently_played_helper.dart` | Lưu/lấy danh sách phát gần đây |
| `download_helper.dart` | Quản lý bài tải xuống |
| `equalizer_helper.dart` | Cài đặt EQ + presets |
| `sleep_timer_helper.dart` | Quản lý hẹn giờ |
| `recently_played_widget.dart` | Widget hiển thị gần đây |
| `equalizer_screen.dart` | Màn hình điều chỉnh EQ |

---

## ✅ Checklist Triển Khai

- [x] Dark Mode (Profile → Switch)
- [x] Recently Played (Home Screen → Widget)
- [x] EQ Screen (Player → Button)
- [x] Sleep Timer (Player → Button)
- [x] Equalizer Presets (6 tùy chọn)
- [ ] Download Feature (Cần File I/O)
- [ ] Lyrics Karaoke (Cần JSON lyrics)
- [ ] Offline Mode (Kết hợp Download + Local Player)

---

## 🚀 Test Checklist

Để kiểm tra tính năng:

1. **Recently Played**
   - [ ] Mở app, phát 3 bài
   - [ ] Về Home, thấy các bài vừa phát
   - [ ] Bấm vào bài → Phát

2. **Dark Mode**
   - [ ] Profile → Bật Dark Mode
   - [ ] Màn hình chuyển sang tối
   - [ ] Tắt app, mở lại → Vẫn tối

3. **EQ**
   - [ ] Phát bài
   - [ ] Bấm EQ → Mở EqualizerScreen
   - [ ] Điều chỉnh Bass/Treble/Vocal
   - [ ] Chọn preset → Áp dụng

4. **Sleep Timer**
   - [ ] Phát bài
   - [ ] Bấm Timer → Chọn 10 phút
   - [ ] Chờ (hoặc mock) → Nhạc dừng

---

Bạn đã sẵn sàng cho những tính năng cao cấp! 🎉
