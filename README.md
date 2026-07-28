# TaskFlow

TaskFlow is a mobile productivity app focused on smart task planning, fast capture, and clear daily execution.

## Stack
- Flutter (Dart)

## Status
In active development.

## Web Deploy

The app can be deployed to Vercel as a Flutter web app.

1. Connect the GitHub repo to Vercel.
2. Keep the default framework detection.
3. Use `vercel.json` from this repo for the build command and static output directory.
4. Vercel will run `scripts/vercel-build.sh`, install Flutter, and publish `build/web`.

Notes:
- The web build uses the current web fallback storage, so it is suitable for demos and review.
- If you want production-grade persistence on web, we should add a web sync backend next.
