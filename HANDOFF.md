# Project Handoff - Ponderada 04

This document summarizes the project context, current implementation state, technical decisions, and next improvements. It is intended to help another Codex session continue the work without needing the full previous conversation.

## Project Context

This is a college mobile development assignment called **Atividade Ponderada 4**.

The required application must be a real mobile app, not only a responsive web app. It must include:

- Mobile implementation using Flutter, Kotlin, SwiftUI or another mobile technology.
- More than two screens.
- Functional navigation.
- Backend integration.
- Database persistence.
- Consumption of an external API.
- Notification system.
- Native sharing feature.
- Use of at least one mobile hardware feature.
- Organized and coherent UI.
- Basic loading/error handling.
- Minimal documentation.
- Functional demo/video.
- Public GitHub repository.

The chosen project idea is a mobile app for helping users find good free games to play.

Working concept:

```text
FreeGame Finder
```

Problem:

```text
Users want to find good games to play, but do not want to pay and do not want to waste time searching manually.
```

Solution:

```text
A mobile app that recommends free-to-play games using the FreeToGame API, lets users save games they want to play, and later uses an LLM to recommend or guess games in an Akinator-like flow.
```

## Main Functional Scope

The app should let users:

- Create/login to an account.
- View free games from the FreeToGame API.
- See game details.
- Save games to a personal "games to play" list.
- Mark saved games with statuses like `interested`, `playing`, `finished`, `dropped`.
- Use a profile screen with a photo taken from the phone camera.
- Share a game through the native mobile sharing sheet.
- Receive local notifications.
- Use an AI/LLM recommendation flow later.

The AI feature should not invent games. It should receive candidate games from the FreeToGame API and choose/recommend from those real games.

## External API

The app uses the FreeToGame API:

```text
https://www.freetogame.com/api-doc
```

Important endpoints:

```text
GET https://www.freetogame.com/api/games
GET https://www.freetogame.com/api/games?category=shooter&platform=pc
GET https://www.freetogame.com/api/games?sort-by=popularity
GET https://www.freetogame.com/api/filter?tag=3d.mmorpg.fantasy.pvp
GET https://www.freetogame.com/api/game?id=540
```

Local API sample files were generated under:

```text
api_samples/
```

The script used to regenerate them is:

```text
scripts/test_freetogame_api.ps1
```

Run it from the repo root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test_freetogame_api.ps1
```

Current sample results from previous test:

- `games_all.json`: 411 games.
- `games_shooter_pc.json`: 117 games.
- `games_browser_strategy.json`: 46 games.
- `games_sorted_popularity.json`: 411 games.
- `games_filtered_tags.json`: 88 games.
- `game_detail_540.json`: detail response for Overwatch.

## Backend Decision

The backend is **Supabase**.

Supabase is being used for:

- Auth.
- Postgres database.
- Storage for profile photos.
- RLS policies.
- Future Edge Function for the LLM API call.

No separate Express/NestJS backend is planned for now.

Recommended architecture:

```text
Flutter app
  -> Repositories/services inside Flutter
  -> Supabase Auth/Database/Storage
  -> FreeToGame API
  -> Supabase Edge Function later for LLM
```

Reason:

- Supabase satisfies the assignment backend requirement.
- FreeToGame does not need a secret key, so it can be called directly from Flutter.
- LLM APIs require secret keys, so the LLM should be called through a backend/Edge Function later.

## Supabase Database

The database has these tables:

```text
profiles
games
games_to_play
recommendation_sessions
```

Purpose:

```text
profiles
= app-specific user profile data

games
= cached game catalog/details from FreeToGame

games_to_play
= user's saved games list

recommendation_sessions
= saved AI recommendation/Akinator sessions
```

Important constraints/policies:

- `profiles.id` references `auth.users.id`.
- `games.id` is the FreeToGame game ID.
- `games_to_play.user_id` references `profiles.id`.
- `games_to_play.game_id` references `games.id`.
- `recommendation_sessions.user_id` references `profiles.id`.
- `games_to_play(user_id, game_id)` is unique, so the same user cannot save the same game twice.
- RLS is enabled.
- Users can only access their own profile, saved games, and recommendation sessions.
- Authenticated users can read/insert/update cached games.

Backend documentation exists here:

```text
docs/supabase_backend.md
```

## Supabase Storage

A bucket should exist or be created:

```text
avatars
```

Recommended profile image flow:

```text
User takes photo with phone camera
-> app uploads image to Supabase Storage
-> path: {user_id}/avatar.jpg
-> app gets public URL
-> app updates profiles.avatar_url
```

The database should store the image URL/path, not the image binary itself.

## Flutter App State

Flutter app folder:

```text
app/
```

The app was created with Flutter and currently has a starter structure:

```text
app/lib/
  main.dart
  core/
    supabase_config.dart
  models/
    profile_model.dart
    game_model.dart
    game_to_play_model.dart
    recommendation_session_model.dart
  services/
    freetogame_api_service.dart
    storage_service.dart
    notification_service.dart
  repositories/
    auth_repository.dart
    profile_repository.dart
    game_repository.dart
    recommendation_repository.dart
  screens/
    auth/
    games/
    home/
    profile/
    recommendation/
  widgets/
```

Packages added to `pubspec.yaml`:

```yaml
supabase_flutter
http
image_picker
share_plus
flutter_local_notifications
```

`main.dart` currently contains:

- Conditional Supabase initialization.
- `AppRoutes`.
- `GameFinderApp`.
- Temporary placeholder screens.
- Bottom navigation.
- Shared UI widgets.

Important note:

```text
main.dart is currently too large and should be split into separate files next.
```

The current large `main.dart` was intentional as a first working navigation base, but should not remain that way.

## Current Validation

The following validation passed previously:

```powershell
dart format lib\main.dart test\widget_test.dart
flutter analyze --no-pub
```

Result:

```text
No issues found.
```

The default Flutter test was replaced with a smoke test for the current app.

## Android/Gradle Fix Already Applied

The app uses `flutter_local_notifications`, which required Android core library desugaring.

This was fixed in:

```text
app/android/app/build.gradle.kts
```

Added:

```kotlin
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

## Windows/Android Studio Setup Notes

On Windows, Flutter plugins require symlink support.

If this error appears:

```text
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

Run:

```powershell
start ms-settings:developers
```

Then enable **Developer Mode**.

Other useful commands:

```powershell
flutter doctor
flutter doctor --android-licenses
flutter pub get
flutter devices
flutter run
```

Open this folder in Android Studio:

```text
ponderada_04/app
```

Do not open only the repo root if Android Studio does not detect the Flutter project.

## Supabase Runtime Configuration

Supabase config is read from Dart defines:

```dart
String.fromEnvironment('SUPABASE_URL')
String.fromEnvironment('SUPABASE_ANON_KEY')
```

Run with:

```powershell
flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

The code currently initializes Supabase only if both values are non-empty, so the placeholder app can run before Supabase is configured.

## Firelink Coding Style Requirement

Very important:

All Dart/Flutter code from this point onward should follow the user's requested learning/style base:

```text
https://firelink-library.github.io/mobile/flutter/dart-intro
```

The user explicitly requested:

```text
"tudo de dart que vc fizer eu quero que vc tome base isso ... este firelink e as outras paginas deste firelink com as coisas de dart, sempre use ele"
```

Interpretation:

- Use clear, beginner-friendly Dart/Flutter structure.
- Prefer explicit classes and typed code.
- Keep code readable and close to common Flutter teaching patterns.
- Avoid overly abstract architecture.
- Avoid code that looks AI-generated or unnecessarily clever.
- Make the code look like a human student/project author wrote it carefully.
- Prefer simple repositories/services over complex dependency injection.
- Keep comments minimal and useful.
- Use descriptive names.
- Split files logically.
- Keep `main.dart` small.
- Use Material widgets in a straightforward way.

Before making future Dart/Flutter edits, consult the Firelink pages if the topic is Dart/Flutter syntax, widgets, state, navigation or project organization.

## Code Style and Architecture Adjustment

The user observed that the current Flutter code can look too AI-generated or too polished/abstract for a student assignment.

Future changes should make the app feel more like a human student project based on the Firelink Flutter material:

- Keep code simple and direct.
- Avoid adding architecture layers before they are useful.
- Prefer readable screen code over overly generic reusable components.
- Avoid making every small UI piece a separate abstraction unless it clearly helps.
- Use natural, app-specific names instead of template-like names where possible.
- Keep comments short and practical, only when they explain a real decision.
- Do not make the code look like a production architecture demo.

Important decision for the Discover/Home screen:

```text
Keep calling the FreeToGame API directly from HomeScreen through FreeToGameApiService.
```

Reason:

- FreeToGame does not require a secret API key.
- The Discover screen only needs public game data.
- Calling the API directly is easier to understand for the assignment.
- Adding `GameRepository` between HomeScreen and FreeToGameApiService makes this specific flow look unnecessarily abstract right now.

Recommended current Discover flow:

```text
HomeScreen
  -> FreeToGameApiService
  -> FreeToGame /api/games
  -> GameModel list
  -> GameCard
```

Use `GameRepository` mainly for Supabase-related game actions, such as:

- saving a game to the user's list;
- loading saved games;
- caching/upserting game data in the `games` table if needed.

## Important Collaboration Preference

The user asked:

```text
"sempre fale como vc irá fazer e como eu posso fazer antes de fazer qualquer coisa"
```

So before modifying files, explain:

1. What will be done.
2. Why it will be done.
3. How the user could do it manually.
4. Then make the change if appropriate.

## Recommended Next Improvements

### 1. Split `main.dart`

Move code into:

```text
lib/app/app_routes.dart
lib/app/game_finder_app.dart
lib/screens/auth/login_screen.dart
lib/screens/auth/register_screen.dart
lib/screens/home/home_screen.dart
lib/screens/games/games_to_play_screen.dart
lib/screens/recommendation/recommendation_screen.dart
lib/screens/profile/profile_screen.dart
lib/widgets/app_shell.dart
lib/widgets/auth_scaffold.dart
lib/widgets/empty_state.dart
lib/widgets/placeholder_card.dart
lib/widgets/section_header.dart
```

Then keep `main.dart` small:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Supabase initialization
  runApp(const GameFinderApp());
}
```

### 2. Build real login/register UI

Connect:

```text
LoginScreen -> AuthRepository.signIn
RegisterScreen -> AuthRepository.signUp + ProfileRepository.upsertProfile
```

Include basic loading/error states.

### 3. Build Home with FreeToGame API

Connect:

```text
HomeScreen -> GameRepository.fetchFreeGames
```

Show:

- Loading.
- Error.
- Empty state.
- Game cards.
- Filter controls for platform/category.

### 4. Build Game Detail Screen

Needed for the main user flow.

It should:

- Display game image/title/description/details.
- Fetch details with `FreeToGameApiService.fetchGameDetails`.
- Let the user save the game.
- Let the user share the game with `share_plus`.

### 5. Save Game to Supabase

When saving:

1. Upsert the game into `games`.
2. Insert into `games_to_play`.
3. Handle duplicate save constraint gracefully.

### 6. Build Games To Play Screen

Connect:

```text
GamesToPlayScreen -> GameRepository.fetchMyGamesToPlay
```

Eventually join saved games with game details from `games`.

### 7. Build Profile + Camera Upload

Use:

```text
image_picker
StorageService
ProfileRepository.updateAvatarUrl
```

This satisfies the mobile hardware requirement.

### 8. Notifications

Use `flutter_local_notifications`.

Simple demo use case:

```text
After the user saves a game, show/schedule a local notification:
"You saved a new game to try later."
```

Or:

```text
Daily reminder to discover a free game.
```

### 9. LLM Recommendation Flow

Do this later, after the base app works.

Recommended architecture:

```text
Flutter RecommendationScreen
-> Supabase Edge Function recommend-games
-> LLM API
-> save result in recommendation_sessions
```

Do not put LLM API keys in Flutter.

The LLM should receive candidate games from FreeToGame and return structured JSON like:

```json
{
  "recommended_games": [
    {
      "game_id": 540,
      "title": "Overwatch",
      "reason": "It matches your preference for fast competitive team-based matches.",
      "confidence": 90
    }
  ]
}
```

### 10. README

Update project README with:

- Problem.
- Solution.
- Tech stack.
- Supabase setup.
- How to run.
- FreeToGame API usage.
- Features checklist.

## Suggested Commit Names

Recent work could be committed as:

```bash
git commit -m "Set up Flutter structure and Supabase backend docs"
```

or:

```bash
git commit -m "Add Flutter navigation scaffold"
```

Future split of `main.dart`:

```bash
git commit -m "Split Flutter app scaffold into screens and widgets"
```

## Current Priority

The best next task is:

```text
Refactor main.dart into separate app, screen and widget files.
```

This should be done before adding more functionality, because adding real API/auth logic into the current large `main.dart` will make the app harder to maintain.
