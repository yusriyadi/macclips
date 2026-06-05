# TRD — Clipboard Manager macOS

## 1. Ringkasan Teknis
Clipboard Manager v1 adalah aplikasi macOS native berbasis **SwiftUI** dengan komponen **AppKit** untuk integrasi sistem. Aplikasi berjalan sebagai utility background app, memonitor clipboard secara terus-menerus, menyimpan histori lokal, dan menampilkan floating panel kecil saat dipanggil via hotkey global `Command+Shift+V`.

## 2. Arsitektur Tingkat Tinggi
### Komponen utama
- **App Bootstrap**: inisialisasi lifecycle, service registry, dan activation policy.
- **Hotkey Service**: registrasi dan penanganan `Command+Shift+V`.
- **Clipboard Monitor**: memantau `NSPasteboard.general.changeCount`.
- **History Store**: menyimpan item clipboard lokal dan menjalankan retention policy.
- **Search Engine**: melakukan filter dan ranking hasil pencarian.
- **Floating Panel UI**: menampilkan search bar, list hasil, preview, dan aksi selection.
- **Paste Coordinator**: menaruh item terpilih ke clipboard lalu memicu paste.

## 3. Strategi UI
- Gunakan `NSPanel` floating yang di-host oleh SwiftUI.
- Panel harus bisa menerima input keyboard segera setelah dibuka.
- Panel menutup saat item dipilih, saat user menekan Escape, atau saat app kehilangan konteks yang relevan.
- Fokus default saat panel terbuka ada di search bar.

## 4. Lifecycle Aplikasi
- App berjalan dengan activation policy utility/accessory sehingga tidak mengganggu workspace user.
- Monitoring clipboard aktif selama app berjalan.
- App tidak mengandalkan login item pada v1; jika user menutup app, capture berhenti sampai app dibuka lagi.

## 5. Clipboard Monitoring
### Mekanisme
- Poll `NSPasteboard.general.changeCount` secara periodik.
- Saat `changeCount` berubah, baca isi clipboard terbaru.
- Simpan item baru hanya jika payload valid dan berbeda dari item terakhir yang tersimpan.

### Tipe yang didukung
- `text/plain`
- `image` dari clipboard

### Pencegahan loop
- Setelah app melakukan paste atau menulis clipboard untuk selection terpilih, monitor harus memasang suppression window agar perubahan clipboard yang berasal dari aksi app sendiri tidak direkam sebagai item baru.

## 6. Model Data
### Entitas utama: `ClipboardItem`
- `id`: UUID
- `kind`: text / image
- `contentHash`: hash untuk deduplication
- `createdAt`: waktu item pertama kali direkam
- `lastSeenAt`: waktu terakhir item ini muncul lagi di clipboard
- `sourceAppName`: nama aplikasi asal jika tersedia
- `previewText`: potongan teks untuk list/search
- `textValue`: isi teks untuk item text
- `imageData`: data image ter-normalisasi untuk item image
- `thumbnailData`: preview kecil untuk list

### Catatan penyimpanan image
- Image disimpan lokal sebagai data binary ter-normalisasi.
- Thumbnail disimpan terpisah agar list tetap ringan dan cepat dirender.

## 7. Persistence
### Rekomendasi implementasi
- Gunakan **Core Data** dengan persistent store **SQLite** di Application Support.
- Semua data tinggal di device.
- Retention policy menghapus item paling lama saat jumlah item melewati 500.

### Retention behavior
- Simpan **500 item terbaru**.
- Jika item yang sama muncul lagi, update `lastSeenAt` dan dorong item itu ke posisi paling atas tanpa membuat duplikat baru.

## 8. Search and Ranking
### Search scope
- Cocokkan query terhadap:
  - `textValue`
  - `previewText`
  - `sourceAppName`
  - label tipe item

### Ranking
1. Exact prefix match
2. Contains match
3. Recency

### Out of scope search
- OCR image search
- Semantic search

## 9. Hotkey Service
- Register `Command+Shift+V` secara global.
- Jika app sedang aktif, hotkey tetap membuka panel yang sama.
- Jika hotkey gagal diregistrasi, app harus memberi error yang jelas pada log dan state internal.

## 10. Paste Pipeline
### Urutan aksi
1. User memilih item di floating panel.
2. App menyiapkan item terpilih sebagai clipboard sistem.
3. App memicu paste ke aplikasi aktif.
4. App memasang suppression window untuk mencegah re-capture.
5. Panel ditutup setelah aksi selesai atau gagal dengan aman.

### Requirement macOS
- Karena app melakukan auto-paste, implementasi memerlukan akses **Accessibility permission** untuk memicu event keyboard paste secara programmatic.

## 11. Permission dan Privasi
- V1 tidak butuh akun.
- V1 tidak butuh sync.
- V1 harus menjelaskan bahwa app menyimpan histori clipboard secara lokal di device.
- Jika permission Accessibility belum diberikan, app harus menampilkan status yang bisa dipahami user dan menonaktifkan auto-paste sampai permission tersedia.

## 12. Edge Cases
- Clipboard berisi item yang tidak didukung: abaikan dengan aman.
- Clipboard image sangat besar: simpan versi normalisasi dan thumbnail agar performa tetap stabil.
- User memilih item saat app target tidak menerima paste: tampilkan failure state yang aman tanpa crash.
- App menulis ke clipboard sendiri: suppression window mencegah item duplikat.

## 13. Failure Handling
- Jika hotkey gagal, app tetap berjalan dan log error.
- Jika clipboard read gagal, app skip siklus tersebut dan lanjut monitoring.
- Jika persist gagal, app tidak boleh crash; tampilkan state error internal dan lanjut mencoba pada siklus berikutnya.
- Jika paste gagal, item tetap tersedia di history dan user tetap bisa copy manual.

## 14. Non-Goals Teknis
- Tidak ada sync/backend pada v1.
- Tidak ada OCR.
- Tidak ada plugin atau extensibility layer pada v1.
