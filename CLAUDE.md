# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an Xcode project — primary development happens inside Xcode. **Minimum deployment target: iOS 17** (required for `ContentUnavailableView`; iOS 16 is sufficient if you replace that with a custom empty state).

```bash
# Build
xcodebuild -project "Smart FinPlan.xcodeproj" -scheme "Smart FinPlan" \
  -destination "platform=iOS Simulator,name=iPhone 16" build

# Run unit tests
xcodebuild test -project "Smart FinPlan.xcodeproj" -scheme "Smart FinPlan" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:"Smart FinPlanTests"

# Run a single test
xcodebuild test -project "Smart FinPlan.xcodeproj" -scheme "Smart FinPlan" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:"Smart FinPlanTests/Smart_FinPlanTests/example"

# Run UI tests
xcodebuild test -project "Smart FinPlan.xcodeproj" -scheme "Smart FinPlan" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:"Smart FinPlanUITests"
```

> **Important:** After creating new `.swift` files on disk, you must add them to the Xcode project in the IDE (drag into the Project Navigator, or File → Add Files). Xcode's `.pbxproj` does not auto-discover files.

## Architecture

**Stack:** SwiftUI + Swift Charts + Combine + UserDefaults. No third-party dependencies. Core Data scaffold (`Persistence.swift`, `.xcdatamodeld`) is retained but unused.

### Data Flow

```
PlanInputView  ──binds──▶  FinancialPlannerViewModel  ──@EnvironmentObject──▶  HomeView
                              │  Combine pipeline                                   │
                              │  (CombineLatest4 + debounce)                       │
                              ▼                                                     ▼
                         UserDefaults                                    SummaryHeaderView
                         (persist inputs)                                PortfolioCardView (×3)
                                                                         CompoundChartView
```

### Key Files

| File | Role |
|---|---|
| `Models/PortfolioModels.swift` | `PortfolioType` enum (rates, colors, SF Symbols), `YearlyDataPoint`, `PortfolioProjection` structs |
| `ViewModels/FinancialPlannerViewModel.swift` | All financial math; owns inputs as `@Published`; Combine pipeline saves & recalculates on change |
| `Views/HomeView.swift` | Dashboard tab; delegates to three components |
| `Views/PlanInputView.swift` | Plan tab; Form with Steppers + currency TextFields + read-only rate reference |
| `Views/Components/SummaryHeaderView.swift` | Goal amount + years-to-retire card |
| `Views/Components/PortfolioCardView.swift` | Per-portfolio row (icon, tagline, monthly contribution) |
| `Views/Components/CompoundChartView.swift` | Grouped bar chart via `Charts`; y-axis labels formatted as $K/$M |
| `ContentView.swift` | `TabView` root; creates `FinancialPlannerViewModel` as `@StateObject` and injects it |

### Financial Math

All math is in `FinancialPlannerViewModel`:

- **Future value of lump sum:** `FV = PV × (1 + r)^n`
- **PMT (monthly contribution):** `PMT = FV × r / ((1 + r)^n − 1)` — standard future-value annuity formula
- Portfolio rates: Conservative 5%, Moderate 8%, Aggressive 12% (annual, compounded monthly)
- Chart samples every 5 years for timelines > 10 yrs, every 1 year otherwise

### Tests

- Unit tests (`Smart FinPlanTests/`) use **Swift Testing** (`import Testing`, `@Test`, `#expect`).
- UI tests (`Smart FinPlanUITests/`) use **XCTest** + `XCUIApplication`.
