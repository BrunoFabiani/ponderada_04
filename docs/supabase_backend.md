# Supabase Backend Map

This project uses Supabase as the backend. Supabase replaces a traditional backend with controllers/routes for most operations:

- Auth: user sign up, login and session management.
- Database: profiles, games, saved games and AI recommendation sessions.
- Storage: profile photos uploaded from the mobile camera.
- Edge Functions: future LLM recommendation endpoint.

The Flutter app should organize calls through services/repositories, but these are the backend operations the app will use.

## Base Resources

```text
Supabase Project URL: https://YOUR_PROJECT_ID.supabase.co
Database schema: public
Storage bucket: avatars
```

Do not commit secret keys. The Flutter app should only use the Supabase URL and anon public key.

## Auth Operations

### Sign Up

Creates a user in Supabase Auth.

```text
Resource: Supabase Auth
Action: signUp
Used by: Register screen
```

Input:

```json
{
  "email": "user@email.com",
  "password": "password"
}
```

After sign up, the app should create a row in `profiles`.

### Login

Authenticates an existing user.

```text
Resource: Supabase Auth
Action: signInWithPassword
Used by: Login screen
```

Input:

```json
{
  "email": "user@email.com",
  "password": "password"
}
```

### Logout

Ends the current user session.

```text
Resource: Supabase Auth
Action: signOut
Used by: Profile/settings screen
```

## Database Operations

### Profiles

Table:

```text
public.profiles
```

Purpose:

Stores app-specific user data.

Fields:

```text
id uuid
username text
avatar_url text
created_at timestamptz
updated_at timestamptz
```

Operations:

```text
Create profile
Read current profile
Update username
Update avatar_url after photo upload
```

RLS rule:

```text
User can only access profile where profiles.id = auth.uid()
```

Example insert:

```json
{
  "id": "AUTH_USER_ID",
  "username": "Bruno",
  "avatar_url": null
}
```

### Games

Table:

```text
public.games
```

Purpose:

Caches games returned by the FreeToGame API.

Fields:

```text
id int
title text
thumbnail text
short_description text
game_url text
genre text
platform text
publisher text
developer text
release_date date
freetogame_profile_url text
details jsonb
created_at timestamptz
updated_at timestamptz
```

Operations:

```text
Read cached games
Insert game from FreeToGame API
Update cached game details
Filter by genre/platform
```

RLS rule:

```text
Authenticated users can read, insert and update cached games.
```

Example insert:

```json
{
  "id": 540,
  "title": "Overwatch",
  "thumbnail": "https://www.freetogame.com/g/540/thumbnail.jpg",
  "short_description": "A hero-focused first-person team shooter from Blizzard Entertainment.",
  "game_url": "https://www.freetogame.com/open/overwatch",
  "genre": "Shooter",
  "platform": "PC (Windows)",
  "publisher": "Activision Blizzard",
  "developer": "Blizzard Entertainment",
  "release_date": "2022-10-04",
  "freetogame_profile_url": "https://www.freetogame.com/overwatch"
}
```

### Games To Play

Table:

```text
public.games_to_play
```

Purpose:

Stores the games each user saved to their personal list.

Fields:

```text
id uuid
user_id uuid
game_id int
status text
priority int
user_notes text
source text
created_at timestamptz
updated_at timestamptz
```

Operations:

```text
Save game to list
List current user's saved games
Update status: interested, playing, finished, dropped
Update priority
Update notes
Remove saved game
```

RLS rule:

```text
User can only access rows where games_to_play.user_id = auth.uid()
```

Constraint:

```text
unique(user_id, game_id)
```

This prevents the same user from saving the same game twice.

Example insert:

```json
{
  "user_id": "AUTH_USER_ID",
  "game_id": 540,
  "status": "interested",
  "priority": 4,
  "user_notes": "Recommended by AI because I like team shooters.",
  "source": "freetogame"
}
```

### Recommendation Sessions

Table:

```text
public.recommendation_sessions
```

Purpose:

Stores AI recommendation or Akinator-style sessions.

Fields:

```text
id uuid
user_id uuid
mode text
user_input jsonb
candidate_games jsonb
ai_response jsonb
created_at timestamptz
```

Operations:

```text
Create recommendation session
List current user's recommendation history
Delete recommendation session
```

RLS rule:

```text
User can only access rows where recommendation_sessions.user_id = auth.uid()
```

Valid modes:

```text
recommendation
akinator
```

Example insert:

```json
{
  "user_id": "AUTH_USER_ID",
  "mode": "recommendation",
  "user_input": {
    "platform": "pc",
    "genres": ["shooter"],
    "play_style": "competitive",
    "session_length": "short"
  },
  "candidate_games": [
    {
      "id": 540,
      "title": "Overwatch",
      "genre": "Shooter",
      "platform": "PC (Windows)"
    }
  ],
  "ai_response": {
    "recommended_games": [
      {
        "game_id": 540,
        "title": "Overwatch",
        "reason": "It matches your preference for fast competitive team-based matches.",
        "confidence": 90
      }
    ]
  }
}
```

## Storage Operations

### Profile Avatar Upload

Bucket:

```text
avatars
```

Purpose:

Stores profile photos captured with the phone camera.

Path convention:

```text
{user_id}/avatar.jpg
```

Example:

```text
9d8f1c2a-0000-0000-0000-000000000000/avatar.jpg
```

Flow:

```text
Take photo with camera
Upload file to avatars/{user_id}/avatar.jpg
Get public URL
Update profiles.avatar_url
```

RLS/storage policy:

```text
User can upload/update/delete only files inside their own user_id folder.
Authenticated users can read avatar images.
```

## External API

### FreeToGame Games List

```text
GET https://www.freetogame.com/api/games
```

Used by:

```text
Home/recommendation screen
```

### FreeToGame Filtered Games

```text
GET https://www.freetogame.com/api/games?category=shooter&platform=pc
GET https://www.freetogame.com/api/filter?tag=3d.mmorpg.fantasy.pvp
```

Used by:

```text
Recommendation flow before calling AI
```

### FreeToGame Game Details

```text
GET https://www.freetogame.com/api/game?id=540
```

Used by:

```text
Game detail screen
```

The full detail response can be stored in `games.details`.

## Future Edge Function

### Recommend Games

This endpoint should be added later to keep the LLM API key outside the Flutter app.

```text
POST /functions/v1/recommend-games
```

Input:

```json
{
  "mode": "recommendation",
  "user_input": {
    "platform": "pc",
    "genres": ["shooter"],
    "play_style": "competitive"
  },
  "candidate_games": [
    {
      "id": 540,
      "title": "Overwatch",
      "genre": "Shooter",
      "platform": "PC (Windows)",
      "short_description": "A hero-focused first-person team shooter from Blizzard Entertainment."
    }
  ]
}
```

Output:

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

After receiving the output, the app should save the full session in `recommendation_sessions`.

## Suggested Flutter Organization

```text
lib/
  core/
    supabase_config.dart
  models/
    profile.dart
    game.dart
    game_to_play.dart
    recommendation_session.dart
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
    login_screen.dart
    home_screen.dart
    game_detail_screen.dart
    games_to_play_screen.dart
    recommendation_screen.dart
    profile_screen.dart
```
