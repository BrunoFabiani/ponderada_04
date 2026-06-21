class RecommendationSessionModel {
  const RecommendationSessionModel({
    this.id,
    required this.userId,
    required this.mode,
    this.userInput,
    this.candidateGames,
    this.aiResponse,
  });

  final String? id;
  final String userId;
  final String mode;
  final Map<String, dynamic>? userInput;
  final List<dynamic>? candidateGames;
  final Map<String, dynamic>? aiResponse;

  factory RecommendationSessionModel.fromJson(Map<String, dynamic> json) {
    return RecommendationSessionModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      mode: json['mode'] as String,
      userInput: json['user_input'] as Map<String, dynamic>?,
      candidateGames: json['candidate_games'] as List<dynamic>?,
      aiResponse: json['ai_response'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'mode': mode,
      'user_input': userInput,
      'candidate_games': candidateGames,
      'ai_response': aiResponse,
    };
  }
}
