import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_model.dart';
import '../models/game_to_play_model.dart';
import '../services/freetogame_api_service.dart';

class GameRepository {
  GameRepository({
    required SupabaseClient supabaseClient,
    required FreeToGameApiService apiService,
  })  : _client = supabaseClient,
        _apiService = apiService;

  final SupabaseClient _client;
  final FreeToGameApiService _apiService;

  Future<List<GameModel>> fetchFreeGames({
    String? category,
    String? platform,
    String? sortBy,
  }) {
    return _apiService.fetchGames(
      category: category,
      platform: platform,
      sortBy: sortBy,
    );
  }

  Future<void> cacheGame(GameModel game) async {
    await _client.from('games').upsert(game.toJson());
  }

  Future<void> saveGameToPlay(GameToPlayModel savedGame) async {
    await _client.from('games_to_play').insert(savedGame.toJson());
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
}
