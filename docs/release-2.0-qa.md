# My Meds 2.0 release checklist

Run this on a real iPhone through TestFlight before releasing. The goal is to prove that someone with real data on the live App Store build can update without losing anything.

## Before you start

- [ ] Use an iPhone that has the **live App Store 1.2.0** installed with real data: more than one profile, medications with photos, and FDA-search entries.
- [ ] Note down each profile, how many medications it has, and which ones have photos.
- [ ] In `app.json`, check the version is 2.0.0 and raise the build number above any build already uploaded.

## Build and upload

1. `npm run check` and `npx expo-doctor` both pass.
2. `npm run prebuild`, then open `ios/MyMeds.xcworkspace` in Xcode.
3. Choose Any iOS Device, then Product > Archive, and upload through the Organizer.
4. Install from TestFlight **over** the App Store build. Do not delete the app first, because that deletes its data.

## The upgrade

- [ ] The app opens without an error screen.
- [ ] Every profile is on Switch. The first profile by name is active.
- [ ] Every medication is present, with the same name, dosage and notes.
- [ ] Every photo shows. Tapping one in the form opens it full screen.

## On a real device only

These could not be tested in a simulator.

- [ ] Take Photo opens the camera, and the photo attaches to the medication.
- [ ] The first Take Photo asks for permission. After refusing it, the next attempt offers Open Settings.
- [ ] Save a new photo and time it. It should feel quick.
- [ ] Share the PDF to Mail or Messages and confirm it arrives and opens.
- [ ] Printing the PDF gives US Letter pages.
- [ ] Double-tap a full-screen photo at normal finger speed. It zooms in, and again zooms back out. In the simulator this was only exercised with taps about 350 ms apart.

## If you have an iPhone on iOS 17

The rewrite could not be run on iOS 17, because Xcode 27.1 does not offer that simulator.

- [ ] Go through every tab.
- [ ] Swipe to delete and long-press a row on Home.
- [ ] Add a medication and confirm the sheet, checkmark and cancel button look right.
- [ ] Search for a drug.

## Everyday flows, quickly

- [ ] Add a medication manually. It appears on Home in sorted order.
- [ ] Search for a drug, pick a result, and save it.
- [ ] Edit a medication. Leaving with unsaved changes asks first.
- [ ] Delete by swiping, and by long-pressing.
- [ ] Edit the profile, including clearing the date of birth.
- [ ] Add a profile, switch to it, and relaunch. It is still active.
- [ ] Delete a profile. The alert states the right number of medications.
- [ ] Turn on Airplane Mode and search. The offline message appears.
- [ ] Try it in dark mode and at the largest text size, with VoiceOver on for a few screens.

## Phased release

- [ ] In App Store Connect, turn on **phased release** for 2.0.
- [ ] iPhone 8, 8 Plus and X can't run iOS 17, so they stay on 1.2.0.
- [ ] Don't change the medication table or rewrite saved values until the rollout is complete. A 1.2.0 build has to be able to open the data if 2.0 is pulled.

## If 2.0 has to be pulled

Pause the phased release, then ship a build made from the `flutter-final` tag with a higher build number. In testing, the 1.2.0 app opened data that 2.0 had migrated and showed everything. The original database is also kept as `CombinedDatabase.v1.bak` in the app's Documents folder.
