# 🌕 Moons - Material 3 Expense & Income Tracker

**Moons** is an expressive, offline-first personal finance application built with Flutter and Material 3 Expressive design tokens. It combines celestial aesthetic styling with powerful budgeting, transaction analytics, savings goals, and everyday financial utility tools.

---

## ✨ Features

### 🌟 Expressive Material 3 UI
- **Dual Celestial Themes**: Celestial Dark (Obsidian night with starlight indigo accents) and Moonlit Light.
- **Fluid Visual Hierarchy**: Curved cards, tactile floating action button, animated bottom sheets, and responsive typography.
- **Dynamic Color Harmony**: Semantic financial colors (Emerald green for income, Radiant Rose for expenses).

### 📊 Cash Flow & Expense Tracking
- **Celestial Balance Hero**: Real-time net flow, savings rate score, and account breakdowns.
- **Timeframe Filters**: Instantly switch between *Today*, *This Week*, *This Month*, and *All Time*.
- **Wallets & Accounts**: Support for Cash, Bank Accounts, Credit Cards, and E-Wallets.
- **Categorization**: 16+ expressive category presets with custom icons and color schemes.
- **Search & Activity Log**: Real-time search by title, note, or category with swipe-to-delete.

### 📈 Visual Analytics
- **Category Donut Chart**: Custom-painted donut graphic showing exact spending distribution and percentages.
- **Income vs. Expense Comparative Bar**: Instant visual ratio of earnings vs spending.
- **Ranked Category Breakdown**: Linear progress indicators highlighting top expense categories.
- **Smart Insights**: Contextual financial health tips based on current savings rate and highest expenditures.

### 🛠️ Built-in Financial Tools
1. **Moon Budgets (Budget Planner)**: Set monthly spending caps for individual categories with real-time warning indicators when exceeding 80% or 100%.
2. **Moon Vaults (Savings Goals)**: Create target savings goals (e.g. Travel, Emergency Fund, Tech upgrades) with progress tracking and quick fund deposit modals.
3. **Loan & EMI Calculator**: Interactive principal, interest rate, and tenure sliders calculating monthly installments and total payable interest.
4. **Multi-Currency Converter**: Real-time reference currency exchange calculator for world currencies (USD, EUR, GBP, JPY, INR, CAD, AUD, CHF).

### ⚙️ Preferences & Data Management
- Multi-currency selector ($, €, £, ¥, ₹, ₩, ₱, etc.).
- Full offline persistence via `shared_preferences`.
- One-tap JSON backup export to clipboard.
- Pre-populated starter demo transactions out of the box.

---

## 🚀 How to Build & Run

### 1. Run in Development Mode
```bash
flutter pub get
flutter run
```

### 2. Build the Android APK Locally
If you have Flutter and the Android SDK on your machine:
```bash
flutter build apk --release
```
The compiled APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## ☁️ Automated Cloud APK Build (GitHub Actions)
You don't need a heavy local Android SDK setup to compile an APK!

1. Push this project to your GitHub repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit for Moons app"
   git remote add origin https://github.com/YOUR_USERNAME/moons.git
   git push -u origin main
   ```
2. The included workflow `.github/workflows/build_apk.yml` will automatically build the release APK on GitHub's cloud runners.
3. Go to the **Actions** tab on your GitHub repository, click on the latest workflow run, and download the `Moons-Release-APK` zip containing the ready-to-install `.apk` directly to your Android device!
