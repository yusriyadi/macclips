# PRD — Clipboard Manager macOS

## 1. Latar Belakang
User sering perlu mengambil kembali teks atau gambar yang baru saja disalin, tapi clipboard sistem macOS hanya menyimpan satu item terakhir. Akibatnya, user kehilangan konteks, sering bolak-balik antar aplikasi, dan membuang waktu untuk menyalin ulang item yang sudah lewat.

## 2. Tujuan Produk
- Menyediakan riwayat clipboard lokal untuk **text** dan **image**.
- Memberikan akses cepat lewat shortcut global `Command+Shift+V`.
- Memungkinkan user mencari dan memilih item clipboard dari dialog kecil yang ringan.
- Mengembalikan item terpilih ke clipboard lalu langsung melakukan paste ke aplikasi aktif.

## 3. Target User
- Knowledge worker yang sering berpindah antar aplikasi.
- Developer, writer, designer, dan operator yang sering menyalin teks atau gambar.
- User macOS yang butuh akses cepat tanpa membuka aplikasi penuh.

## 4. Masalah yang Diselesaikan
- Clipboard sistem hanya menyimpan satu item terakhir.
- Riwayat clipboard sering tersebar di banyak aplikasi atau belum tersedia sama sekali.
- User butuh cara cepat untuk menemukan item lama tanpa mengganggu alur kerja.

## 5. Solusi Produk
App berjalan di background, memantau perubahan clipboard, menyimpan riwayat lokal, lalu menampilkan floating panel kecil saat user menekan `Command+Shift+V`. Panel ini menyediakan pencarian dan daftar item terbaru. Saat item dipilih, app menaruh item itu ke clipboard aktif dan mempaste ke aplikasi yang sedang fokus.

## 6. Ruang Lingkup V1
### In scope
- macOS-only
- SwiftUI UI dengan AppKit bridge untuk kebutuhan sistem
- Global hotkey `Command+Shift+V`
- Floating search panel
- Capture **text** dan **image**
- Local-only storage
- Always-on background capture selama app berjalan
- Retention policy: **500 item terbaru**
- Auto-paste setelah item dipilih

### Out of scope
- Sync antar device
- Login/account system
- Cloud backup
- OCR untuk search image
- Web, Windows, atau Linux client
- Analytics/telemetry

## 7. User Stories
- Sebagai user, saya ingin menekan shortcut dan langsung melihat riwayat clipboard saya.
- Sebagai user, saya ingin mencari item clipboard dengan cepat.
- Sebagai user, saya ingin memilih teks atau gambar lama tanpa membuka banyak aplikasi.
- Sebagai user, saya ingin item terpilih langsung dipaste ke tempat saya bekerja.

## 8. UX Flow Utama
1. User menekan `Command+Shift+V`.
2. Floating panel muncul di depan aplikasi aktif.
3. User mengetik di search bar.
4. Daftar item difilter secara real-time.
5. User memilih satu item.
6. App menyalin item itu ke clipboard sistem.
7. App memicu paste ke aplikasi aktif.
8. Panel menutup dan user kembali bekerja.

## 9. Prinsip Produk
- Cepat: waktu buka panel dan waktu pencarian harus terasa instan.
- Ringkas: interface hanya menampilkan elemen yang dibutuhkan untuk memilih item.
- Privat: semua data tetap di device.
- Tidak mengganggu: app tetap diam di background sampai dipanggil.

## 10. Success Metrics
- User dapat membuka panel dari shortcut tanpa hambatan.
- User dapat menemukan item clipboard dalam beberapa detik.
- User berhasil paste item terpilih tanpa perlu copy manual ulang.
- App tetap stabil saat memantau clipboard dalam waktu lama.

