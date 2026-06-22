import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_recommendation_model.dart';

class AiRecommendationService {
  AiRecommendationService(this._client);

  final SupabaseClient _client;

  Future<List<GameRecommendationModel>> recommendGames(String prompt) async {
    final response = await _client.functions.invoke(
      'recommend-games',
      body: {'prompt': prompt},
    );

    final data = response.data as Map<String, dynamic>;
    final recommendations = data['recommendations'] as List<dynamic>;

    return recommendations
        .map(
          (item) =>
              GameRecommendationModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
