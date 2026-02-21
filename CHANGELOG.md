# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.3] - 2026-02-21
### Added
- Notifikasi real dari server: sistem notifikasi kini terhubung ke API dengan dukungan tandai semua sudah dibaca
- Artikel carousel di feed: artikel muncul otomatis setelah postingan ke-3 di beranda
- Katalog reward: halaman reward menampilkan daftar hadiah yang bisa ditukar dengan koin beserta stok dan syaratnya
- Gamifikasi pada review: pencapaian dan tantangan kini bisa terbuka saat mengirim review tempat
- Panduan tab (tab tour): tampilan overlay panduan navigasi tab muncul otomatis setelah registrasi pertama kali
- Toast notifikasi saat tantangan selesai diselesaikan
- Mahkota peringkat (emas/perak/perunggu) pada tampilan leaderboard
- Ikon tantangan dinamis berdasarkan jenis aksi (check-in, post, review, dll)

### Changed
- Bingkai avatar profil kini reaktif — berubah langsung tanpa perlu reload halaman
- Username saat registrasi cukup minimal 8 karakter (validasi disederhanakan)
- Status loading login dan registrasi kini terpisah, tidak saling mempengaruhi
- Halaman profil dimigrasi ke komponen ScaffoldFrame yang konsisten
- TncView dipindah ke modul auth, locale aplikasi dibatasi hanya Bahasa Indonesia
- Semua snackbar dialihkan ke komponen AppSnackbar yang seragam

### Fixed
- Field list (food_type, place_value) dari backend yang datang sebagai string kini diperbaiki otomatis
- Model UserSettings, PostUser, dan AchievementModel mendapat field baru yang sempat hilang (frameUrl, criteriaAction, criteriaTarget)
- NetworkImageWidget kini menerapkan borderRadius di semua kondisi (loading, error, berhasil)

## [1.2.2] - 2026-02-03
### Added
- Sistem Poin & Level: Dapatkan poin dan naik level dengan mengunjungi tempat-tempat baru!
- Misi Harian: Selesaikan misi untuk mendapatkan reward ekstra
- Review Tempat: Sekarang kamu bisa menulis review dan berbagi pengalaman
- Ranking Pengguna: Lihat peringkatmu dibandingkan pengguna lain
- Detail Tempat Lengkap: Informasi lokasi yang lebih detail dan menarik

## [1.2.1] - 2026-01-15
### Changed
- Better first impression dengan improved splash screen
- Smoother user experience dengan loading overlays
- Cleaner UI dengan refined component styling
- Modern design consistency across the app

## [1.2.0] - 2026-01-01
### Changed
- Major redesign of place detail dan review system
- Enhanced profile features dengan improved challenge dan coins tracking
- Streamlined mission flow dengan better forms dan validation
### Improved
- Performance optimizations across the app

## [1.1.3] - 2025-12-15
### Added
- UI improvements untuk onboarding dan login flow
- Profile frame selection feature
### Improved
- Better error handling dan user feedback
- Improved notification system dengan search dan filter

## [1.1.2] - 2025-12-01
### Fixed
- Like & Comment: Sekarang berfungsi lebih lancar tanpa gangguan
- Upload Mission: Proses upload foto menjadi lebih stabil
- Profil: Tampilan profil sudah diperbaiki dan tidak lag lagi
### Changed
- Pesan Error: Pesan error sekarang lebih mudah dipahami
### Added
- Menu Postingan: Hapus postingan, lapor konten, ikuti/unikuti pengguna, bagikan link postingan
- Notifikasi: Sistem notifikasi baru dengan pencarian dan filter
- Pilihan Bingkai Foto: Sekarang Anda bisa memilih bingkai untuk foto untuk avatar

## [1.1.1] - 2025-11-15
### Added
- Onboarding: Panduan pengenalan saat pertama membuka aplikasi
- Pilih Bahasa: Tersedia Indonesia & English
### Improved
- Scroll Lebih Mulus: Semua halaman detail lebih responsif
- Pull to Refresh: Tarik ke bawah untuk refresh di lebih banyak halaman
- Tampilan Lebih Konsisten: UI seragam di seluruh aplikasi
- Performa Lebih Cepat: Aplikasi lebih ringan dan responsif

## [1.1.0] - 2025-11-01
### Added
- Initial APK release