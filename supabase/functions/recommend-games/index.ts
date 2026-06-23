import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

type FreeToGameGame = {
  id: number;
  title: string;
  thumbnail?: string;
  short_description?: string;
  game_url?: string;
  genre?: string;
  platform?: string;
  publisher?: string;
  developer?: string;
  release_date?: string;
  freetogame_profile_url?: string;
};

type GameRecommendation = {
  game_id: number;
  reason: string;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, apiKey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export default {
  fetch: withSupabase({ auth: ["publishable", "secret"] }, async (req) => {
    if (req.method === "OPTIONS") {
      return new Response("ok", { headers: corsHeaders });
    }

    if (req.method !== "POST") {
      return jsonResponse({ error: "Method not allowed." }, 405);
    }

    try {
      const { prompt } = await req.json();

      if (typeof prompt !== "string" || prompt.trim().length === 0) {
        return jsonResponse({ error: "Prompt is required." }, 400);
      }

      const providerApiKey = getProviderApiKey();
      if (!providerApiKey) {
        return jsonResponse(
          { error: "Recommendation provider key is not configured." },
          500,
        );
      }

      const providerUrl = getProviderUrl();
      if (!providerUrl) {
        return jsonResponse(
          { error: "Recommendation provider URL is not configured." },
          500,
        );
      }

      const candidates = await fetchCandidateGames();
      const recommendations = await recommendGames({
        providerApiKey,
        model: getProviderModel(),
        providerUrl: providerUrl,
        prompt: prompt.trim(),
        candidates,
      });

      const gamesById = new Map(candidates.map((game) => [game.id, game]));

      const results = recommendations
        .map((recommendation) => {
          const game = gamesById.get(recommendation.game_id);
          if (!game) return null;

          return {
            game,
            reason: recommendation.reason,
          };
        })
        .filter((item) => item !== null);

      return jsonResponse({ recommendations: results });
    } catch (error) {
      console.error(error);
      return jsonResponse(
        {
          error: "Could not recommend games.",
          details: error instanceof Error ? error.message : String(error),
        },
        500,
      );
    }
  }),
};

async function fetchCandidateGames(): Promise<FreeToGameGame[]> {
  const response = await fetch(
    "https://www.freetogame.com/api/games?sort-by=popularity",
  );

  if (!response.ok) {
    throw new Error(`FreeToGame request failed: ${response.status}`);
  }

  const games = await response.json() as FreeToGameGame[];
  return games.slice(0, 120);
}

async function recommendGames({
  providerApiKey,
  model,
  providerUrl,
  prompt,
  candidates,
}: {
  providerApiKey: string;
  model: string;
  providerUrl: string;
  prompt: string;
  candidates: FreeToGameGame[];
}): Promise<AiRecommendation[]> {
  const compactGames = candidates.map((game) => ({
    id: game.id,
    title: game.title,
    genre: game.genre,
    platform: game.platform,
    short_description: game.short_description,
  }));

  const response = await fetch(providerUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${providerApiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      messages: [
        {
          role: "system",
          content:
            "You recommend free-to-play games. Only recommend games from the candidate list. Do not invent games. Return exactly 3 recommendations.",
        },
        {
          role: "user",
          content: JSON.stringify({
            user_preference: prompt,
            candidate_games: compactGames,
          }),
        },
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "game_recommendations",
          strict: true,
          schema: {
            type: "object",
            additionalProperties: false,
            required: ["recommendations"],
            properties: {
              recommendations: {
                type: "array",
                minItems: 3,
                maxItems: 3,
                items: {
                  type: "object",
                  additionalProperties: false,
                  required: ["game_id", "reason"],
                  properties: {
                    game_id: {
                      type: "integer",
                      description: "The id of a game from candidate_games.",
                    },
                    reason: {
                      type: "string",
                      description:
                        "A short reason explaining why this game fits the user preference.",
                    },
                  },
                },
              },
            },
          },
        },
      },
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(
      `Recommendation request failed: ${response.status} ${errorBody}`,
    );
  }

  const data = await response.json();
  const outputText = getChatCompletionText(data);

  if (typeof outputText !== "string") {
    throw new Error("Recommendation response did not include message content.");
  }

  const parsed = JSON.parse(outputText) as {
    recommendations: GameRecommendation[];
  };

  return parsed.recommendations;
}

function getProviderApiKey(): string | undefined {
  return Deno.env.get("RECOMMENDATION_API_KEY");
}

function getProviderModel(): string {
  return Deno.env.get("RECOMMENDATION_MODEL") ?? "llama-3.3-70b-versatile";
}

function getProviderUrl(): string | undefined {
  return Deno.env.get("RECOMMENDATION_API_URL");
}

function getChatCompletionText(data: unknown): string | null {
  if (typeof data !== "object" || data === null) {
    return null;
  }

  const responseData = data as {
    choices?: Array<{
      message?: {
        content?: unknown;
      };
    }>;
  };

  const content = responseData.choices?.[0]?.message?.content;
  return typeof content === "string" ? content : null;
}

function jsonResponse(body: unknown, status = 200): Response {
  return Response.json(body, {
    status,
    headers: corsHeaders,
  });
}
