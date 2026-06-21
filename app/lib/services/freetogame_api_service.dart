import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/game_model.dart';

class FreeToGameApiService {
  FreeToGameApiService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://www.freetogame.com/api';

  final http.Client _client;

  Future<List<GameModel>> fetchGames({
    String? category,
    String? platform,
    String? sortBy,
  }) async {
    final query = <String, String>{};
    if (category != null) query['category'] = category;
    if (platform != null) query['platform'] = platform;
    if (sortBy != null) query['sort-by'] = sortBy;

    final uri = Uri.parse('$_baseUrl/games').replace(queryParameters: query);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch games: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => GameModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<GameModel> fetchGameDetails(int id) async {
    final uri = Uri.parse('$_baseUrl/game').replace(
      queryParameters: {'id': id.toString()},
    );
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch game details: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return GameModel.fromJson({
      ...data,
      'details': data,
    });
  }
}
