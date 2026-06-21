import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/recommendation_session_model.dart';

class RecommendationRepository {
  RecommendationRepository(this._client);

  final SupabaseClient _client;

  Future<void> saveSession(RecommendationSessionModel session) async {
    await _client.from('recommendation_sessions').insert(session.toJson());
  }

  Future<List<RecommendationSessionModel>> fetchMySessions(String userId) async {
    final data = await _client
        .from('recommendation_sessions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return data
        .map((item) => RecommendationSessionModel.fromJson(item))
        .toList();
  }
}
