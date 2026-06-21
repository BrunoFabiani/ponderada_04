class GameToPlayModel {
  const GameToPlayModel({
    this.id,
    required this.userId,
    required this.gameId,
    this.status = 'interested',
    this.priority,
    this.userNotes,
    this.source = 'freetogame',
  });

  final String? id;
  final String userId;
  final int gameId;
  final String status;
  final int? priority;
  final String? userNotes;
  final String source;

  factory GameToPlayModel.fromJson(Map<String, dynamic> json) {
    return GameToPlayModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      gameId: json['game_id'] as int,
      status: json['status'] as String,
      priority: json['priority'] as int?,
      userNotes: json['user_notes'] as String?,
      source: json['source'] as String? ?? 'freetogame',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'game_id': gameId,
      'status': status,
      'priority': priority,
      'user_notes': userNotes,
      'source': source,
    };
  }
}
