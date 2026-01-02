# 📱 Snappie Mobile App - TODO List

> **Status**: 🚧 Development Phase  
> **Last Updated**: 2026-01-03  
> **Priority**: 🔴 Critical | 🟡 High | 🟢 Medium | ⚪ Low

---

## 🔴 CRITICAL - Bug Fixes dari QC

### 1. Like & Comment - Server Exception
- [ ] **Fix Like Functionality**
  - [ ] Debug server exception pada like/unlike
  - [ ] Periksa endpoint URL dan request body format
  - [ ] Periksa authentication header
  - [ ] Implementasi optimistic UI update
  - [ ] Location: `home_controller.dart`, `post_repository.dart`

- [ ] **Fix Comment System**
  - [ ] Debug server exception pada create comment
  - [ ] Periksa endpoint dan payload format
  - [ ] Test dengan Postman/Insomnia dulu
  - [ ] Location: `post_detail_view.dart`, `post_repository.dart`

### 2. Mission Upload Failed
- [ ] **Fix Upload Foto Check-in**
  - [ ] Debug Cloudinary upload error
  - [ ] Periksa file size limit
  - [ ] Periksa Cloudinary credentials di .env
  - [ ] Test upload ke Cloudinary secara terpisah
  - [ ] Handle permission kamera dengan benar
  - [ ] Location: `mission_controller.dart`, `cloudinary_service.dart`

### 3. Profile RenderSliver Error
- [ ] **Fix Sliver Widget Error**
  - [ ] Debug error "RenderSliver" di profile controller
  - [ ] Periksa Obx() yang return null
  - [ ] Pastikan sliver widget di context yang benar
  - [ ] Periksa height constraint issues
  - [ ] Location: `profile_view.dart`, `profile_controller.dart`

### 4. Error Sanitization
- [ ] **Jangan Expose Error ke UI**
  - [ ] Buat helper function untuk sanitize error messages
  - [ ] Gunakan generic message: "Terjadi kesalahan, silakan coba lagi"
  - [ ] Log technical error untuk debugging saja
  - [ ] Update semua catch blocks di controllers
  - [ ] Location: All controllers and views

### 5. Language Switch Not Working
- [ ] **Fix Fitur Ganti Bahasa**
  - [ ] Debug easy_localization setup
  - [ ] Pastikan `context.setLocale()` dipanggil dengan benar
  - [ ] Test apakah app perlu restart setelah ganti bahasa
  - [ ] Periksa locale files (en.json, id.json)
  - [ ] Location: `language_view.dart`, `main.dart`

---

## 🟡 HIGH PRIORITY - Feature Implementation

### 1. PostCard - More Button
- [ ] **Implement More Button Actions**
  - [ ] Hapus Post (jika owner)
  - [ ] Report Post/User
  - [ ] Ikuti/Berhenti mengikuti pengguna
  - [ ] Salin link post
  - [ ] Bagikan post
  - [ ] Location: `post_card.dart`, `home_controller.dart`

### 2. Notifikasi - Dummy Data
- [ ] **Implement Real Notifications**
  - [ ] Buat `NotificationController`
  - [ ] Integrasikan dengan gamification response dari backend
  - [ ] Parse conditional response untuk notifikasi
  - [ ] Implement pagination
  - [ ] Tambah filter (read/unread)
  - [ ] Mark as read functionality
  - [ ] Location: `notifications_view.dart`, new `notification_controller.dart`

### 3. Reactive Data Refresh
- [ ] **Auto-update setelah Create/Update**
  - [ ] Refresh post list setelah create post berhasil
  - [ ] Refresh comments setelah submit comment
  - [ ] Gunakan callback atau `ever()` listener
  - [ ] Implement optimistic updates
  - [ ] Location: `home_controller.dart`, `post_detail_view.dart`

### 4. Registrasi - Place Value & Food Type Limit
- [ ] **Fix Limit 3 Selection**
  - [ ] Tambah feedback visual saat user pilih lebih dari 3
  - [ ] Show snackbar/toast dengan pesan jelas
  - [ ] Disable chip secara visual setelah 3 dipilih
  - [ ] Location: `register_view.dart`, `onboarding_controller.dart`

### 5. Fitur Pilih Bingkai
- [ ] **Implement Frame Selection**
  - [ ] Buat UI untuk pilih bingkai foto
  - [ ] Gunakan assets dari `assets/images/frames/`
  - [ ] Apply frame ke foto sebelum upload
  - [ ] Preview frame sebelum konfirmasi
  - [ ] Location: `mission_photo_preview_view.dart`

---

## 🟢 MEDIUM PRIORITY - UI/UX Fixes

### 1. Loading State Widget
- [ ] **Perbaiki Loading Widget**
  - [ ] Gunakan asset loading yang sudah disediakan
  - [ ] Test tampilan loading di berbagai screen
  - [ ] Pastikan konsisten di semua halaman
  - [ ] Location: `_state_widgets/loading_state_widget.dart`

### 2. SearchBar Responsive Size
- [ ] **Fix Responsive SearchBar**
  - [ ] Gunakan MediaQuery untuk adaptive sizing
  - [ ] Set min/max height constraints
  - [ ] Gunakan LayoutBuilder untuk responsive
  - [ ] Test di berbagai ukuran layar
  - [ ] Location: `search_bar_widget.dart`

### 3. Chip Item Text Terpotong
- [ ] **Fix Chip Text Overflow**
  - [ ] Kurangi horizontal padding
  - [ ] Gunakan FittedBox atau perkecil font size
  - [ ] Atau buat chip lebih lebar dengan Wrap widget
  - [ ] Location: Filter chips di `explore_view.dart`, `register_view.dart`

### 4. Review Display - Warna Berantakan
- [ ] **Fix Review Color Scheme**
  - [ ] Review color scheme di review cards
  - [ ] Konsistenkan warna dengan design system
  - [ ] Pastikan contrast ratio cukup
  - [ ] Location: `reviews_view.dart`, `place_detail_view.dart`

### 5. PostCard - Fullscreen Image Error
- [ ] **Fix Fullscreen Image Viewer**
  - [ ] Handle URL image null atau invalid
  - [ ] FullscreenImageViewer handle error dengan baik
  - [ ] Pastikan GestureDetector terpasang di semua gambar
  - [ ] Location: `post_card.dart`, `fullscreen_image_viewer.dart`

### 6. Comment Scroll Issue
- [ ] **Fix Comment Section Scroll**
  - [ ] Debug scroll behavior di comment section
  - [ ] Fix SingleChildScrollView conflict dengan parent scroll
  - [ ] Scroll ke comment terbaru setelah submit
  - [ ] Location: `post_detail_view.dart`

### 7. Halaman Kupon
- [ ] **Fix Kupon Display**
  - [ ] Review dan fix tampilan halaman kupon
  - [ ] Pastikan data kupon ditampilkan dengan benar
  - [ ] Location: `rewards_view.dart`, `coins_history_view.dart`

### 8. Tampilan Tantangan
- [ ] **Improve Challenges UI**
  - [ ] Perbaiki tampilan halaman tantangan
  - [ ] Sesuaikan dengan design yang diinginkan
  - [ ] Note: Reset progress tiap hari adalah tugas backend
  - [ ] Location: `challenges_view.dart`

### 9. Image Caching
- [ ] **Cache Remote Assets**
  - [ ] Implement caching untuk gambar dari remote
  - [ ] Gunakan cached_network_image package
  - [ ] Hindari fetch ulang setiap buka halaman
  - [ ] Location: `create_post_view.dart`, image widgets

### 10. Gunakan Asset & Icon yang Disediakan
- [ ] **Audit Asset Usage**
  - [ ] Review semua icon yang digunakan
  - [ ] Ganti dengan asset yang sudah disediakan
  - [ ] Konsistenkan icon style di seluruh app
  - [ ] Location: All views

---

## ⚪ LOW PRIORITY - Testing & Polish

### 1. Halaman Penghargaan
- [ ] **Test Achievements View**
  - [ ] Manual testing dengan real data
  - [ ] Pastikan semua state (loading, empty, error) work
  - [ ] Location: `achievements_view.dart`

### 2. Post Detail dari Tersimpan
- [ ] **Konsistenkan Navigation**
  - [ ] Pastikan PostCard di semua halaman navigate ke PostDetailView
  - [ ] Gunakan postId yang sama
  - [ ] Location: `saved_posts_view.dart`, `profile_view.dart`

---

## 🔧 INFRASTRUCTURE

### 1. Error Handling Infrastructure
- [ ] **Create Error Handler Utility**
  - [ ] Buat centralized error handler
  - [ ] Mapping error code ke user-friendly message
  - [ ] Log error untuk debugging
  - [ ] Location: `core/helpers/error_handler.dart`

### 2. Image Caching Infrastructure
- [ ] **Setup Cached Network Image**
  - [ ] Configure cache settings
  - [ ] Set max cache size
  - [ ] Implement cache clearing
  - [ ] Location: `core/services/image_cache_service.dart`

---

## 📋 NOTES

### QC Feedback Summary
1. Registrasi: Limit 3 place value/food type tidak ada feedback
2. Notifikasi: 100% dummy data
3. Reactive data: Tidak auto-refresh setelah create/update
4. PostCard more button: Tidak fungsional
5. Fullscreen image: Beberapa tidak bisa dibuka
6. Like & Comment: Server exception
7. Error exposure: Technical error muncul ke UI
8. Image caching: Tidak ada cache untuk remote images
9. SearchBar: Ukuran tidak responsive
10. Chip text: Terpotong
11. Review colors: Berantakan
12. Loading widget: Tidak pakai asset yang disediakan
13. Mission upload: Tidak bisa upload
14. Comment scroll: Tidak scroll dengan benar
15. Profile error: RenderSliver error
16. Kupon page: Display salah
17. Achievements: Belum di-test
18. Challenges: Tampilan perlu diperbaiki (reset backend)
19. Pilih bingkai: Belum implement
20. Ganti bahasa: Tidak bisa

### Prioritas Perbaikan
| Priority | Issue | Impact |
|----------|-------|--------|
| 🔴 Critical | Like & Comment Server Error | Core feature broken |
| 🔴 Critical | Mission Upload Failed | Feature blocked |
| 🔴 Critical | Profile RenderSliver Error | Crash/Error |
| 🔴 Critical | Error Sanitization | Bad UX |
| 🔴 Critical | Language Switch | Feature broken |
| 🟡 High | PostCard More Button | Missing functionality |
| 🟡 High | Reactive Data Refresh | Stale data |
| 🟡 High | Notifikasi Implementation | Dummy data |
| 🟡 High | Frame Selection | Missing feature |
| 🟢 Medium | Loading State Widget | Visual polish |
| 🟢 Medium | SearchBar Responsive | UI issue |
| 🟢 Medium | Chip Text Truncation | UI issue |
| 🟢 Medium | Review Colors | Visual issue |

### Estimated Timeline
- **Critical Issues**: 1-2 weeks
- **High Priority**: 1-2 weeks
- **Medium Priority**: 1 week
- **Low Priority**: Ongoing

---

## 📊 Progress Tracking

### Completed ✅
- [x] Article card widget implementation
- [x] Article API integration
- [x] Fixed API data type mismatch

### In Progress 🚧
- [ ] Fix critical bugs dari QC feedback

### Blocked ⛔
- [ ] Challenges daily reset (waiting for backend)

---

**Last Review**: 2026-01-03  
**Next Review**: Daily until critical bugs fixed
