import 'package:flutter_test/flutter_test.dart';
import 'package:ponderada_04/models/game_model.dart';

void main() {
  test('converte JSON da FreeToGame para GameModel', () {
    final json = {
      'id': 540,
      'title': 'Overwatch',
      'thumbnail': 'https://example.com/image.jpg',
      'short_description': 'Jogo de tiro em equipe.',
      'game_url': 'https://www.freetogame.com/open/overwatch',
      'genre': 'Shooter',
      'platform': 'PC',
      'publisher': 'Blizzard',
      'developer': 'Blizzard',
      'release_date': '2016-05-24',
      'freetogame_profile_url': 'https://www.freetogame.com/overwatch',
      'details': null,
    };
    final game = GameModel.fromJson(json);
    expect(game.id, equals(540));
    expect(game.title, equals('Overwatch'));
    expect(game.genre, equals('Shooter'));
    expect(game.gameUrl, equals('https://www.freetogame.com/open/overwatch'));
  });
}