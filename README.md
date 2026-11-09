# My Meds!

A simple, private medication list app. Your data stays on your device.

---

<p align="center">
<img width="18%" alt="5" src="https://github.com/user-attachments/assets/c3b535c5-4600-4d9b-8258-369b4911ee5a" />
<img width="18%" alt="4" src="https://github.com/user-attachments/assets/05d6c687-8ebf-4bb0-b331-d3f4d66b1086" />
<img width="18%" alt="3" src="https://github.com/user-attachments/assets/cfe1ef0b-41db-485c-a26a-3d3875240722" />
<img width="18%" alt="2" src="https://github.com/user-attachments/assets/65f17bcb-c83b-497c-8894-1d70dfd3319f" />
<img width="18%" alt="1" src="https://github.com/user-attachments/assets/87c1150d-c22b-4533-bc7a-e6ca8be35a9c" />
</p>

---

## Why My Meds?

Most medication apps are either too complex or send your data to external services.  
**My Meds** was created for people who just want a simple, secure way to track their meds.  
The app has over **7,000 downloads** on the iOS App Store!

## Tech Stack

An [Expo](https://expo.dev) app (SDK 58, React Native, TypeScript) with native iOS UI through Expo Router and `@expo/ui` SwiftUI views.

**iOS only.** My Meds 2.0 runs on iPhone with iOS 17 or later, in portrait. Android is no longer supported. The last Flutter build is tagged `flutter-final`.

## Features

- Search for meds using the FDA NDC API
- Add, edit, and delete meds, stored in SQLite on your device
- Several profiles, each with its own medication list
- Add photos of your medications
- Export your list to a PDF to share

The only data that leaves your device is what you type into the FDA search field. There are no analytics or crash-reporting SDKs.

## Download

- **iOS:** [My Meds on the App Store](https://apps.apple.com/us/app/my-meds-personal-meds-list/id6475703887)

## Architecture Overview

- **Routes** live in `src/app/`. Each tab has its own native stack.
- **Data** (`src/data/`): synchronous SQLite is the single source of truth. The UI renders one immutable snapshot, rebuilt after every write, and data changes only through commands in `commands.ts`.
- **Migrations only add** to the 1.2.0 database, so a 1.2.0 build can still open it after a rollback.
- **Pure logic** sits in `src/domain/`, `src/fda/` and `src/export/`, and is covered by unit tests that run in Node.

## Development Setup

1. Clone the repo and install dependencies with `npm install`.
2. Generate the native project and run it in a simulator with `npm run ios`. Xcode is required. Native projects are generated and not committed.
3. Before committing, run `npm run check` for the typecheck, lint and tests.

Builds are made locally with Xcode. See [the 2.0 release checklist](docs/release-2.0-qa.md).
