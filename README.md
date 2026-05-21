# Mega — Restaurant SaaS (Flutter)

A cross-platform Flutter app for managing a restaurant: analytics, live orders, menu, tables, reservations, staff, billing, and a **customer-facing QR menu** for table ordering.

**Repository:** [github.com/mdimamhosen/FlutterMegaProject](https://github.com/mdimamhosen/FlutterMegaProject)

---

## What you get out of the box

The app ships with **in-memory mock data** (demo restaurant *La Parisienne Bistro*). You can log in, click around, and try every screen **without Firebase or any API keys**.

If Firebase is configured and initializes successfully, auth and Firestore sync are used instead; if not, the app falls back to mock data automatically.

| Area | What it does |
|------|----------------|
| **Analytics** | Dashboard charts and KPIs |
| **Live Orders** | Order queue and status |
| **Menu Designer** | Categories and menu items |
| **Table Tracking** | Table status, waiter assignment, QR codes |
| **Bookings** | Reservations |
| **Staff List** | Team and roles |
| **Stripe Billing** | Subscription plans (UI demo) |
| **Settings** | Theme (light/dark) and workspace options |

---

## Prerequisites

Install these before cloning:

1. **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (stable channel recommended)
2. **Git**
3. A device or emulator:
   - **Windows / macOS / Linux** — desktop run works well for development
   - **Android** — Android Studio + emulator or USB device
   - **Chrome** — `flutter run -d chrome` (some features like camera/QR may differ)

Check your setup:

```bash
flutter doctor
```

Fix anything marked with ❌ before continuing.

**This project uses Dart SDK `^3.11.1`** (see `pubspec.yaml`). Use a recent Flutter release that includes that SDK.

---

## Quick start (recommended for first run)

```bash
# 1. Clone the repo
git clone https://github.com/mdimamhosen/FlutterMegaProject.git
cd FlutterMegaProject

# 2. Install dependencies
flutter pub get

# 3. See available devices
flutter devices

# 4. Run the app (pick your device id from the list above)
flutter run
```

On **Windows**, if you only have one desktop target:

```bash
flutter run -d windows
```

On **Chrome**:

```bash
flutter run -d chrome
```

The app opens on the **login** screen. Use the demo accounts below.

---

## Demo login (mock mode)

Mock login matches **email only** (any password with 6+ characters works; the form defaults to `password123`).

| Role | Email | Quick-login button on login screen |
|------|-------|-------------------------------------|
| Owner | `owner@mega.com` | Owner |
| Kitchen | `jacques@mega.com` | Kitchen |
| Waiter | `alex@mega.com` | Waiter |

Other seeded users (same password convention): `sarah@mega.com` (manager).

After login you land on **Analytics**. Use the left sidebar (or bottom nav on small screens) to switch sections.

You can also **register** a new owner/restaurant from `/register` — that creates data in mock storage (or Firebase if configured).

---

## Customer QR menu (no login)

Guests can open the ordering UI without staff login. Route pattern:

```
/menu/table/:tableId/:tableNumber
```

**Example** (mock table T-01):

```
/menu/table/table-1/T-01
```

**How to try it locally**

1. Log in as owner → **Table Tracking**
2. Open a table’s **QR** dialog (encodes a production-style URL)
3. For local testing, either:
   - Manually navigate in the app using the route above (e.g. temporary deep link / router push), or
   - Run on web and open:  
     `http://localhost:<port>/menu/table/table-1/T-01`  
     (port is shown in the terminal when you `flutter run -d chrome`)

Mock table IDs: `table-1` … `table-5` (numbers `T-01` … `T-05`).

---

## Project structure

```
lib/
├── main.dart                 # App entry, Firebase init (optional)
├── core/
│   ├── network/              # DatabaseService (mock + Firebase)
│   ├── routing/router.dart   # go_router routes & auth guard
│   └── theme/                # Light/dark theme, Riverpod provider
└── features/
    ├── auth/                 # Login, register
    ├── dashboard/            # Shell + navigation
    ├── analytics/
    ├── order/                # Staff orders + customer menu
    ├── menu/
    ├── table/
    ├── reservation/
    ├── workspace/            # Staff, settings
    └── billing/
```

**Stack:** Flutter, **Riverpod**, **go_router**, **Firebase** (optional), **fl_chart**, **qr_flutter**, **mobile_scanner**, and related UI packages — see `pubspec.yaml`.

---

## Useful commands

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install / update packages |
| `flutter run` | Run debug build |
| `flutter run -d windows` | Run on Windows desktop |
| `flutter run -d chrome` | Run in browser |
| `flutter analyze` | Static analysis / lints |
| `flutter test` | Run widget tests |
| `flutter clean` | Clear build cache if builds act weird |

---

## Optional: Firebase backend

Firebase is **not required** for local demo use. `main.dart` calls `Firebase.initializeApp()` inside a try/catch; failure is ignored and mock data is used.

To wire up a real backend later:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android / iOS / Web apps and download config files
3. Use FlutterFire CLI (recommended):

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

4. Enable **Email/Password** auth and create **Firestore** collections (`users`, `orders`, `tables`, etc.) aligned with `lib/core/network/database_service.dart`

Until those files exist in the repo, assume **mock mode** for day-to-day development.

---

## Troubleshooting

**`flutter` not found**  
Add Flutter’s `bin` folder to your PATH, then open a new terminal.

**No devices listed**  
- Windows: `flutter config --enable-windows-desktop` then `flutter doctor`  
- Android: start an emulator from Android Studio  
- Physical phone: enable USB debugging and run `flutter devices`

**Build errors after pulling latest**  

```bash
flutter clean
flutter pub get
flutter run
```

**Login works but data looks empty**  
Confirm you’re using a seeded email (`owner@mega.com`, etc.). Custom register flow creates a new empty restaurant.

**Hot reload not applying**  
Press `r` in the terminal running `flutter run`, or `R` for hot restart.

---

## Contributing / notes for collaborators

- Default branch: `main`
- Do not commit API keys, `google-services.json`, or `GoogleService-Info.plist` unless the team agrees on a shared dev project
- Run `flutter analyze` before opening a PR
- The app title in UI: **Mega SaaS Restaurant System**

---

## License

Private / educational use unless the repository owner specifies otherwise. Ask the maintainer before redistributing.
