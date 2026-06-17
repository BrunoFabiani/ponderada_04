param(
    [string]$OutputDir = "api_samples"
)

$ErrorActionPreference = "Stop"

$baseUrl = "https://www.freetogame.com/api"

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

function Save-ApiResponse {
    param(
        [string]$Name,
        [string]$Url
    )

    Write-Host "Request: $Url"

    try {
        $response = Invoke-RestMethod -Uri $Url -Method Get
        $filePath = Join-Path $OutputDir "$Name.json"

        $response | ConvertTo-Json -Depth 20 | Set-Content -Path $filePath -Encoding UTF8

        if ($response -is [array]) {
            Write-Host "Saved: $filePath ($($response.Count) items)"
        }
        else {
            Write-Host "Saved: $filePath"
        }
    }
    catch {
        Write-Host "Failed: $Name"
        Write-Host $_.Exception.Message
    }

    Write-Host ""
}

Save-ApiResponse `
    -Name "games_all" `
    -Url "$baseUrl/games"

Save-ApiResponse `
    -Name "games_shooter_pc" `
    -Url "$baseUrl/games?category=shooter&platform=pc"

Save-ApiResponse `
    -Name "games_browser_strategy" `
    -Url "$baseUrl/games?category=strategy&platform=browser"

Save-ApiResponse `
    -Name "games_sorted_popularity" `
    -Url "$baseUrl/games?sort-by=popularity"

Save-ApiResponse `
    -Name "games_filtered_tags" `
    -Url "$baseUrl/filter?tag=3d.mmorpg.fantasy.pvp"

Save-ApiResponse `
    -Name "game_detail_540" `
    -Url "$baseUrl/game?id=540"

Write-Host "Done. Open the JSON files in: $OutputDir"
