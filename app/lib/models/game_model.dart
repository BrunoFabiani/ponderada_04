class GameModel {
  const GameModel({
    required this.id,
    required this.title,
    this.thumbnail,
    this.shortDescription,
    this.gameUrl,
    this.genre,
    this.platform,
    this.publisher,
    this.developer,
    this.releaseDate,
    this.freetogameProfileUrl,
    this.details,
  });

  final int id;
  final String title;
  final String? thumbnail;
  final String? shortDescription;
  final String? gameUrl;
  final String? genre;
  final String? platform;
  final String? publisher;
  final String? developer;
  final DateTime? releaseDate;
  final String? freetogameProfileUrl;
  final Map<String, dynamic>? details;

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as int,
      title: json['title'] as String,
      thumbnail: json['thumbnail'] as String?,
      shortDescription: json['short_description'] as String?,
      gameUrl: json['game_url'] as String?,
      genre: json['genre'] as String?,
      platform: json['platform'] as String?,
      publisher: json['publisher'] as String?,
      developer: json['developer'] as String?,
      releaseDate: json['release_date'] == null
          ? null
          : DateTime.tryParse(json['release_date'] as String),
      freetogameProfileUrl: json['freetogame_profile_url'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnail': thumbnail,
      'short_description': shortDescription,
      'game_url': gameUrl,
      'genre': genre,
      'platform': platform,
      'publisher': publisher,
      'developer': developer,
      'release_date': releaseDate?.toIso8601String().split('T').first,
      'freetogame_profile_url': freetogameProfileUrl,
      'details': details,
    };
  }
}
