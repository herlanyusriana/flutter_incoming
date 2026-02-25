# Container Inspection App

Aplikasi mobile Flutter untuk inspeksi container pada sistem Material Incoming. Terhubung ke backend Laravel via REST API (Sanctum token auth).

## Fitur

- Login dengan email atau username
- Daftar arrival yang pending inspection
- Inspeksi container (foto 6 sisi, seal, damage)
- Inspeksi arrival-level

## Setup

1. Clone repo:
   ```bash
   git clone https://github.com/herlanyusriana/flutter_incoming.git
   cd flutter_incoming
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Konfigurasi API base URL di `lib/config.dart`:
   ```dart
   const String kApiBaseUrl = 'https://incoming.nooneasku.online';
   ```

4. Run:
   ```bash
   flutter run
   ```

## Build APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## API Endpoints

Semua endpoint (kecuali login) memerlukan header `Authorization: Bearer <token>`.

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| POST | `/api/auth/login` | Login (field: `login`, `password`) |
| POST | `/api/auth/logout` | Logout |
| GET | `/api/arrivals/pending-inspection` | Arrival pending inspeksi |
| GET | `/api/arrivals/{id}/inspection` | Detail inspeksi arrival |
| POST | `/api/arrivals/{id}/inspection` | Simpan inspeksi arrival |
| GET | `/api/arrivals/{id}/containers` | Daftar container per arrival |
| GET | `/api/containers/{id}/inspection` | Detail inspeksi container |
| POST | `/api/containers/{id}/inspection` | Simpan inspeksi container |
