# SubKill — Project Status

> Last updated: 2026-03-09

## Overview
- **App**: SubKill — Subscription Tracker
- **Tagline**: "The subscription tracker that doesn't charge a subscription"
- **Price**: $4.99 one-time purchase
- **Revenue Target**: $1,000+/month (286 sales/month)
- **Stack**: Swift 6.0, SwiftUI, SwiftData, iOS 17+, MVVM with @Observable

## Project Locations
| Location | Purpose |
|----------|---------|
| `/Users/klause/ai-workspace/income/SubKill/SubKill/` | Xcode project (build here) |
| `/Users/klause/ai-workspace/income/SubKill/SubKill/SubKill/` | Main app source code |
| `/Users/klause/ai-workspace/income/SubKill/SubKill/SubKillWidget/` | Widget extension source |
| `/Users/klause/ai-workspace/income/devclean/SubKill/` | Git-tracked backup |
| `/Users/klause/ai-workspace/income/devclean/SubKillWidget/` | Widget backup |

## Build Commands
```bash
# Build main app
cd /Users/klause/ai-workspace/income/SubKill/SubKill
xcodebuild -scheme SubKill -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Build widget
xcodebuild -scheme SubKillWidgetExtension -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run in simulator
xcodebuild -scheme SubKill -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
xcrun simctl boot "iPhone 17 Pro"
xcrun simctl install booted path/to/SubKill.app
xcrun simctl launch booted com.klause.SubKill
```

## Progress Tracker

### Phase 1: Core App — COMPLETE
| Task | Status | File(s) |
|------|--------|---------|
| Subscription model (SwiftData) | ✅ | `Models/Subscription.swift` |
| Known services (40+ presets) | ✅ | `Models/KnownService.swift` |
| Shared data for widgets | ✅ | `Models/SharedData.swift` |
| Haptic service (CoreHaptics) | ✅ | `Services/HapticService.swift` |
| Sound service | ✅ | `Services/SoundService.swift` |
| Notification service | ✅ | `Services/NotificationService.swift` |
| Export service (CSV) | ✅ | `Services/ExportService.swift` |
| Dashboard ViewModel | ✅ | `ViewModels/DashboardViewModel.swift` |
| Dashboard view | ✅ | `Views/Dashboard/DashboardView.swift` |
| Subscription detail view | ✅ | `Views/Dashboard/SubscriptionDetailView.swift` |
| Add subscription view | ✅ | `Views/AddSubscription/AddSubscriptionView.swift` |
| Edit subscription view | ✅ | `Views/AddSubscription/EditSubscriptionView.swift` |
| Statistics view (Charts) | ✅ | `Views/Statistics/StatisticsView.swift` |
| Settings view | ✅ | `Views/Settings/SettingsView.swift` |
| Tip Jar view (StoreKit) | ✅ | `Views/Settings/TipJarView.swift` |
| Onboarding (4 pages) | ✅ | `Views/Onboarding/OnboardingView.swift` |
| Water tank animation | ✅ | `Views/Components/DrainTankView.swift` |
| Cancel animation (confetti) | ✅ | `Views/Components/CancelAnimationView.swift` |
| Subscription row | ✅ | `Views/Components/SubscriptionRowView.swift` |
| Empty state view | ✅ | `Views/Components/EmptyStateView.swift` |
| Quick stats bar | ✅ | `Views/Components/QuickStatsBar.swift` |
| Share card view | ✅ | `Views/Components/ShareCardView.swift` |
| Smart insights | ✅ | `Views/Components/InsightsCardView.swift` |
| Theme / design system | ✅ | `Extensions/Theme.swift` |
| Color hex extension | ✅ | `Extensions/Color+Hex.swift` |
| App entry point | ✅ | `App/SubKillApp.swift` |

### Phase 2: Xcode & Build — COMPLETE
| Task | Status |
|------|--------|
| Xcode project created | ✅ |
| All files added to project | ✅ |
| Build succeeds (main app) | ✅ |
| Build succeeds (widget) | ✅ |
| Runs in simulator | ✅ |

### Phase 3: Widget & Polish — COMPLETE
| Task | Status | Details |
|------|--------|---------|
| Widget Extension created | ✅ | SubKillWidgetExtension target |
| App Groups configured | ✅ | `group.com.klause.SubKill` on both targets |
| Small widget | ✅ | Total monthly + active count + daily cost |
| Medium widget | ✅ | Totals + top 3 drains |
| Large widget | ✅ | Totals + next renewal + top 3 ranked |
| App icon | ✅ | Cyan water drop + coral X on navy BG |
| Accent color | ✅ | Electric cyan (#00D4FF) |
| Smart Insights | ✅ | 7 insight types (biggest drain, duplicates, etc.) |
| Search bar | ✅ | Filters active subscriptions |
| Sort options (5 modes) | ✅ | Renewal, price high/low, name, newest |
| CSV export | ✅ | Full data export from Settings |

### Phase 4: App Store Prep — IN PROGRESS
| Task | Status | Details |
|------|--------|---------|
| Privacy Policy | ✅ | `docs/privacy-policy.html` — ready to host |
| App Store description | ✅ | `docs/app-store-listing.md` — full ASO |
| Keywords (EN-US) | ✅ | 99/100 chars optimized |
| Keywords (ES-MX cross-locale) | ✅ | Extra US keywords via Spanish locale |
| Screenshot captions (ASO) | ✅ | 6 captions with OCR keywords |
| Host privacy policy | ⬜ | Need: GitHub Pages / Netlify |
| Support email | ⬜ | Need: subkill@klause.dev or alternative |
| App Store screenshots | ⬜ | 6 screenshots for 6.7" and 6.1" |
| StoreKit IAP in App Store Connect | ⬜ | 3 tip products |
| TestFlight build | ⬜ | Upload + internal testing |
| Submit for review | ⬜ | After TestFlight |

### Phase 5: Post-Launch (v1.1+)
| Task | Status |
|------|--------|
| Live Activity / Dynamic Island | ⬜ |
| StandBy mode widget | ⬜ |
| Yearly Wrapped (Spotify-style) | ⬜ |
| Apple Search Ads campaign | ⬜ |
| ProductHunt launch | ⬜ |
| Reddit marketing | ⬜ |
| Localization (Hebrew, German, etc.) | ⬜ |
| iCloud sync | ⬜ |

## Architecture

```
SubKill/
├── App/
│   └── SubKillApp.swift          # Entry point, RootView, ContentView (TabView)
├── Models/
│   ├── Subscription.swift         # @Model + BillingCycle, SubCategory, AppCurrency enums
│   ├── KnownService.swift         # 40+ preset services
│   └── SharedData.swift           # WidgetData, SharedDataManager (App Groups)
├── ViewModels/
│   └── DashboardViewModel.swift   # @Observable, sort/search/filter/insights
├── Services/
│   ├── HapticService.swift        # CoreHaptics custom patterns
│   ├── SoundService.swift         # System sounds
│   ├── NotificationService.swift  # Local notifications
│   └── ExportService.swift        # CSV export
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift    # Main screen (tank + insights + search + lists)
│   │   └── SubscriptionDetailView.swift
│   ├── AddSubscription/
│   │   ├── AddSubscriptionView.swift  # Quick pick + manual entry
│   │   └── EditSubscriptionView.swift
│   ├── Statistics/
│   │   └── StatisticsView.swift   # Charts, donut, top 5, fun facts
│   ├── Settings/
│   │   ├── SettingsView.swift     # Prefs, export, share, rate, tip jar
│   │   └── TipJarView.swift       # StoreKit tips
│   ├── Onboarding/
│   │   └── OnboardingView.swift   # 4-page intro
│   └── Components/
│       ├── DrainTankView.swift    # Water tank animation (wow factor)
│       ├── CancelAnimationView.swift  # Smash + confetti + particles
│       ├── InsightsCardView.swift # Smart spending insights
│       ├── SubscriptionRowView.swift
│       ├── EmptyStateView.swift
│       ├── QuickStatsBar.swift
│       └── ShareCardView.swift
├── Extensions/
│   ├── Theme.swift                # Design system (colors, gradients, shadows)
│   └── Color+Hex.swift
├── Resources/
│   └── Sounds/                    # (placeholder for custom sounds)
└── docs/
    ├── privacy-policy.html        # Ready to host
    └── app-store-listing.md       # Full ASO listing

SubKillWidget/
├── SubKillWidget.swift            # Provider + Small/Medium/Large views
├── SubKillWidgetBundle.swift      # Widget bundle entry point
├── Color+Hex.swift                # Shared with main app
└── SharedData.swift               # Shared with main app
```

## Key Decisions Log
| Date | Decision | Reasoning |
|------|----------|-----------|
| 2026-03-08 | One-time $4.99 pricing | Anti-subscription positioning, ironic appeal |
| 2026-03-08 | SwiftData (not Core Data) | Modern, simpler API, iOS 17+ anyway |
| 2026-03-08 | No backend/cloud | Privacy-first, simpler architecture |
| 2026-03-08 | 40+ known services | Quick onboarding, reduces friction |
| 2026-03-08 | Water tank as core metaphor | Visual impact, emotional connection to money drain |
| 2026-03-09 | App Groups for widget | Standard iOS widget communication pattern |
| 2026-03-09 | Cross-locale ASO (ES-MX) | Doubles US keyword coverage for free |
| 2026-03-09 | Programmatic app icon | CoreGraphics Swift script, reproducible |

## Revenue Tracking
| Month | Sales | Revenue | Notes |
|-------|-------|---------|-------|
| — | — | — | Not yet launched |
