import 'game_model.dart';

class GameRecommendationModel {
  const GameRecommendationModel({required this.game, required this.reason});

  final GameModel game;
  final String reason;

  factory GameRecommendationModel.fromJson(Map<String, dynamic> json) {
    return GameRecommendationModel(
      game: GameModel.fromJson(json['game'] as Map<String, dynamic>),
      reason: json['reason'] as String,
    );
  }
}
