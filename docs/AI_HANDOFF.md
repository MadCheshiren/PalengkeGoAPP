# PalengkeGo AI Handoff

Last updated: 2026-06-13

This file is intentionally short. Earlier versions contained stale frontend audit findings and old global-state assumptions.

For current guidance, use:

- `README.md`
- `docs/REFACTOR_HANDOFF.md`
- `docs/ARCHITECTURE_REFACTOR.md`
- `docs/BACKEND_ARCHITECTURE.md`
- `docs/QA_PIPELINE.md`

## Current Baseline

Before backend work or major refactors, run:

```powershell
flutter pub get
flutter analyze
flutter test --coverage
flutter build apk --debug
```

Expected current baseline:

- analyzer clean;
- tests pass;
- debug APK builds;
- CI workflow exists at `.github/workflows/flutter-ci.yml`.

## Important Rules

- Do not use Firebase Data Connect unless the budget decision changes.
- Use Firebase for operational app data.
- Use Supabase Postgres for recipe joins and recommendations.
- Do not call Firebase, Supabase, or PayMongo directly from widgets.
- Do not put PayMongo secret keys, Firebase service accounts, Supabase service role keys, or webhook secrets in Flutter source.
- Do not replace working dynamic frontend flows with static demo content.
- Keep backend access behind repositories and Riverpod providers.
- Commit `pubspec.lock`.
- Stage carefully; the worktree may contain many unrelated changes.
