# REELHOUSE — Movie Explorer Web App

> *"Every film, one reel at a time"*

A vintage 35mm physical cinema themed Movie Explorer web application built with Flutter Web. Demonstrates responsive layouts, navigation, animations, state management (Provider), custom themes, and input validation.

---

## Live Demo & Documentation

- **Live Web Application**: [https://moulendrabalaji.github.io/reelhouse-movie-explorer/](https://moulendrabalaji.github.io/reelhouse-movie-explorer/)
- **Documentation Report (PDF)**: [`docs/Reelhouse_Documentation_Report.pdf`](docs/Reelhouse_Documentation_Report.pdf)
- **GitHub Repository**: [https://github.com/MoulendraBalaji/reelhouse-movie-explorer](https://github.com/MoulendraBalaji/reelhouse-movie-explorer)

---

## Features & Highlights

- **Cinema Visual Design**: Celluloid Black (`#0E0C0A`), Booth Brown (`#1A1611`), Projector Amber (`#FFB020`), Bone paper (`#F2E8D5`), and Ticket Red (`#D7263D`).
- **Offline Typography**: Bundled TrueType fonts (`Bebas Neue`, `Fraunces`, `Space Mono`) with zero external CDN dependencies.
- **Signature Motion System**: Hand-crafted kinematic widgets including Iris Shutter transitions, SMPTE Projector Countdown Leader, Ken Burns hero carousel, floating dust particles, 3D tilt poster cards, ticket tearing watchlist animation, clapperboard critique submission, and mechanical odometer counters.
- **State Management**: Reactive state architecture with `Provider` (`MovieProvider`, `WatchlistProvider`, `SearchProvider`, `ThemeProvider`, `AuthProvider`, `ReviewsProvider`, `SettingsProvider`).
- **Responsive Layout**: Fluid layouts across desktop, tablet, and mobile screens with adaptive top navigation tabs and mobile drawer.
- **Dual Themes**: Midnight Screening (dark mode) and Matinee (warm paper light mode) with instant toggle and local persistence.
- **Resilient Data Layer**: TMDB API integration with automatic offline fallback to 42 bundled films (`assets/data/movies.json`).

---

## Project Architecture

```
lib/
├── core/                  # Router, responsive breakpoints, constants, validators
├── data/                  # TMDB repository, offline fallback catalog, local storage
├── models/                # Domain models (Movie, CastMember, Review, UserProfile)
├── providers/             # State management providers (Movie, Watchlist, Theme, etc.)
├── screens/               # Screens (Home, Explore, Search, Detail, Watchlist, Profile, About)
├── theme/                 # Design tokens, motion curves, typography, themes
└── widgets/               # Reusable cinema widgets & signature animations
```

---

## Getting Started

### Prerequisites
- Flutter SDK (3.x or higher, Web enabled)
- Google Chrome or any modern web browser

### 1. Clone & Install
```bash
git clone https://github.com/MoulendraBalaji/reelhouse-movie-explorer.git
cd reelhouse-movie-explorer
flutter pub get
```

### 2. Run Locally
```bash
# Run with bundled offline movie catalog
flutter run -d chrome

# Optional: Run with live TMDB API key
flutter run -d chrome --dart-define=TMDB_KEY=your_api_key_here
```

### 3. Build for Production Web
```bash
flutter build web --release --base-href "/reelhouse-movie-explorer/"
```

### 4. Run Tests & Analyzer
```bash
flutter analyze
flutter test
```

---

## Documentation Report

A formal 25-page project documentation report is provided in `docs/`:
- **PDF Report**: [`docs/Reelhouse_Documentation_Report.pdf`](docs/Reelhouse_Documentation_Report.pdf)
- **Generator Script**: `python docs/generate_report.py`
- **Report Configuration**: `docs/report_config.yaml`

---

## Attribution

Film data and posters provided courtesy of [The Movie Database (TMDB)](https://www.themoviedb.org/). This product uses the TMDB API but is not endorsed or certified by TMDB.
