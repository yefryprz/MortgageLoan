# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-08-31

### Added

- **NVIDIA AI Advisory Integration:** Integrated NVIDIA AI chat completion client (`NvidiaService`) with structured JSON reasoning for smart loan analysis, risk assessment, and negotiation advice.
- **Modular Repository Architecture:** Introduced specialized Hive repository classes (`LoanRepository`, `CompoundInterestRepository`, `AiAnalysisRepository`, `AdRepository`, `AppDataRepository`) for persistent storage.
- **Pure Financial Calculators:** Added isolated, 100% testable mathematical calculation utilities (`LoanCalculator`, `CompoundInterestCalculator`, `LoanSimulationCalculator`).
- **Obfuscated Secrets Management:** Integrated `envied` compile-time obfuscation for secure API key and environment configuration (`Env`).
- **Custom UI Components:** Added `CustomSlider` with custom thumb and track styling for seamless rate and term adjustments.
- **Automated Unit Testing Suite:** Created unit tests covering financial calculators, domain models, caching services, and repository layers.
- **Architecture & AI Developer Guide:** Added `AGENTS.md` containing architectural standards, coding conventions, and testing guidelines.

### Changed

- **Unlimited AI Advisory:** Removed daily rate limits for AI evaluations, enabling unlimited scenario analyses.
- **Strict Static Analysis:** Enforced strict typing rules (`strict-casts`, `strict-inference`, `strict-raw-types`) in `analysis_options.yaml`.
- **Target Android SDK:** Upgraded Android `targetSdkVersion` to 36 for modern platform compatibility.
- **Screen & Logic Decoupling:** Refactored all UI screens to consume data through repositories and utility calculators.
- **File Naming Conventions:** Renamed models to standard `snake_case` (e.g. `loan_model.dart`).

### Removed

- **Legacy Storage Helper:** Removed obsolete monolithic `hive.dart` file in favor of domain repositories.

## [2.0.0] - 2026-03-07

### Added

- **AI-Powered Financial Advisor:** Integrated OpenRouter API to provide intelligent loan analysis, tailored financial recommendations, and forecasting.
- **Simulation History:** Implemented Hive local storage to save user simulated scenarios and their corresponding AI analysis results.
- **Yearly Compound Breakdown:** Added an interactive yearly chart page using `fl_chart` to visualize principal, interest, and compound interest breakdown over time.
- **Internationalization & Currency Data Model:** Included a smart country data model to handle currency selection and dynamically format large money entries automatically in text inputs.
- **Analytics Service:** Integrated Firebase Analytics to log user events and usage metrics seamlessly across the app.
- **Centralized Ad Management:** Added a new cache service, `AdHelper`, and `InterstitialAdHelper` utilities to streamline AdMob banner and interstitial ad logic cross-platform.
- **JSON Serialization:** Added models (`Freezed`/`json_serializable`) for robust AI analysis responses and prompts schema.

### Changed

- **Amortization UI:** Redesigned the amortization schedule UI for a much clearer visualization of the table.
- **App Navigation Builder:** Modernized the application drawer UI, adding active route highlighting and disabling the edge drag gesture where appropriate for better UX.
- **Ad Configuration:** Refactored all ad-handling configurations, configuring AdMob Services out of hardcoded variables to improve app safety.
- **App Configuration Ecosystem:** Bumped Android `minSdkVersion`, updated iOS `Info.plist` project settings, and upgraded Core Firebase and Google Mobile Ads dependencies.

### Fixed

- **AppBundle Build Issue (Android):** Upgraded Android Gradle Plugin (AGP) to `8.7.2` and Gradle Wrapper to `8.9` to fix R8 compilation errors with `Kotlin 2.1.0`.
- **Release Signing:** Corrected the path in `key.properties` for the `.jks` Keystore to allow successful production `appbundle` builds to Google Play.

### Removed

- **Outdated Widgets:** Removed old history card widgets and default flutter counter widget test that became obsolete after the UI restructuring and new features.

## [1.1.13] - 2025-XX-XX

- Previously released version details.
