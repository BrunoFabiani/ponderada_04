# FreeToGame API samples

Use this folder to store local JSON samples returned by the FreeToGame API.

Run from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\test_freetogame_api.ps1
```

The script creates these files:

- `games_all.json`: all games.
- `games_shooter_pc.json`: PC shooter games.
- `games_browser_strategy.json`: browser strategy games.
- `games_sorted_popularity.json`: games sorted by popularity.
- `games_filtered_tags.json`: games filtered by multiple tags.
- `game_detail_540.json`: detailed data for one game, including description, minimum requirements and screenshots.

Useful API docs:

https://www.freetogame.com/api-doc
