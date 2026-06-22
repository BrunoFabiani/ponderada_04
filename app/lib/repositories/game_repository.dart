import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_model.dart';
import '../models/game_to_play_model.dart';

class GameRepository {
  GameRepository({
    required SupabaseClient supabaseClient,
  }) : _client = supabaseClient;

  final SupabaseClient _client;

  Future<void> cacheGame(GameModel game) async {
    await _client.from('games').upsert(game.toJson());
  }

  Future<void> saveGameToPlay(GameToPlayModel savedGame) async {
    await _client.from('games_to_play').insert(savedGame.toJson());
  }

  Future<void> saveFreeGame({
    required String userId,
    required GameModel game,
  }) async {
    await cacheGame(game);

    await saveGameToPlay(
      GameToPlayModel(
        userId: userId,
        gameId: game.id,
      ),
    );
  }

  Future<List<GameToPlayModel>> fetchMyGamesToPlay(String userId) async {
    final data = await _client
        .from('games_to_play')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data
        .map((item) => GameToPlayModel.fromJson(item))
        .toList();
  }

  Future<List<GameModel>> fetchMySavedGames(String userId) async {
    final savedGames = await _client
        .from('games_to_play')
        .select('game_id')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final List<int> gameIds = savedGames
        .map((item) => item['game_id'] as int)
        .toList();

    if (gameIds.isEmpty) {
      return [];
    }

    final gamesData = await _client
        .from('games')
        .select()
        .inFilter('id', gameIds);

    final List<GameModel> games = gamesData
        .map((item) => GameModel.fromJson(item))
        .toList();

    games.sort((GameModel first, GameModel second) {
      return gameIds.indexOf(first.id).compareTo(gameIds.indexOf(second.id));
    });

    return games;
  }
}
