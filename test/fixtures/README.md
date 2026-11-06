# 1.2.0 database fixtures

Both files were produced by the real My Meds 1.2.0 build running in the iOS simulator.

- `v1-fresh.db`: the database 1.2.0 creates on first launch ("Default Profile" with the install date as DOB).
- `v1-seeded.db`: the same database after rows were inserted with sqlite3, using the
  schema 1.2.0 created. It covers several profiles, FDA-style names (including unknown
  brand and generic placeholders and a name edited into three lines), "Dosage type" notes,
  a dosage with a trailing space, free-text dosages, photos that are present, missing and
  stored as `''`, and an orphaned medication.

Tests copy these files to a temporary directory and never modify them in place.
