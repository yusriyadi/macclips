# Implementation Plan — Clipboard Manager macOS

## 1. Tujuan Eksekusi
Membangun aplikasi clipboard history macOS SwiftUI yang mampu memantau clipboard background, menyimpan history lokal untuk text dan image, membuka floating search panel via `Command+Shift+V`, lalu mengembalikan item terpilih ke clipboard dan mempaste ke app aktif.

## 2. Milestone 1 — Fondasi Aplikasi
### Deliverables
- App bootstrap macOS SwiftUI + AppKit bridge
- Activation policy utility/accessory
- Service container sederhana untuk dependency internal
- Logging dan state dasar aplikasi

### Acceptance criteria
- App bisa launch tanpa UI utama yang mengganggu.
- App siap menerima hotkey dan clipboard monitoring.

## 3. Milestone 2 — Clipboard Capture
### Deliverables
- `ClipboardMonitor`
- Parser untuk text dan image
- Deduplication via content hash
- Suppression window untuk aksi internal app

### Acceptance criteria
- Text yang disalin muncul di history.
- Image yang disalin muncul di history.
- Item duplikat tidak bertambah terus-menerus.
- Aksi paste internal tidak memicu loop capture.

## 4. Milestone 3 — Persistence Layer
### Deliverables
- Core Data model/schema untuk `ClipboardItem`
- Retention policy 500 item
- Basic CRUD untuk save, fetch, delete, prune

### Acceptance criteria
- History tetap ada setelah app ditutup dan dibuka lagi.
- Data lama otomatis dipangkas saat melewati 500 item.
- Query history tetap cepat untuk daftar terbaru.

## 5. Milestone 4 — Hotkey dan Floating Panel
### Deliverables
- Global hotkey service
- Floating `NSPanel` host untuk SwiftUI
- Search bar dengan focus otomatis
- List hasil history dengan preview text/image

### Acceptance criteria
- `Command+Shift+V` membuka panel dari aplikasi apa pun.
- Panel tampil sebagai dialog kecil yang tidak mengambil ruang besar.
- User bisa mengetik dan memfilter item secara real-time.

## 6. Milestone 5 — Selection dan Auto-Paste
### Deliverables
- Selection handler
- Clipboard write pipeline
- Paste coordinator berbasis Accessibility permission
- Success/failure feedback yang aman

### Acceptance criteria
- Saat item dipilih, clipboard sistem diperbarui.
- App berhasil memicu paste ke app aktif.
- Jika permission belum tersedia, app menampilkan status yang jelas.

## 7. Milestone 6 — Polishing dan Stabilization
### Deliverables
- Empty state
- Error state
- Loading state ringan
- Keyboard shortcuts dasar di panel
- Performance pass untuk list dan thumbnail image

### Acceptance criteria
- App tetap responsif saat history mendekati 500 item.
- Panel tetap nyaman dipakai dengan keyboard-only workflow.

## 8. Interface Antar Komponen
### ClipboardMonitor
- Input: clipboard changeCount/poll tick
- Output: `ClipboardItemCandidate`

### HistoryStore
- Input: candidate dari monitor
- Output: item tersimpan, daftar history, hasil search

### HotkeyService
- Input: register hotkey command
- Output: event buka panel

### FloatingPanelController
- Input: open/close/search/query/selection
- Output: user selection event

### PasteCoordinator
- Input: item terpilih
- Output: clipboard write + paste action + suppression state

## 9. Test Plan
### Unit tests
- Deduplication hash
- Retention/pruning logic
- Search ranking
- Suppression window behavior

### Integration tests
- Text clipboard capture
- Image clipboard capture
- History persistence across relaunch
- Hotkey open panel
- Selection to paste pipeline

### Manual verification
- Copy text, buka panel, cari, pilih, paste
- Copy image, buka panel, pilih, paste
- Verifikasi tidak ada duplikasi saat paste internal
- Verifikasi panel bisa ditutup dengan Escape

## 10. Implementation Constraints
- V1 hanya macOS
- V1 local-only storage
- V1 tidak memasukkan OCR/sync/account
- V1 fokus pada reliability dan speed lebih dulu daripada fitur tambahan
