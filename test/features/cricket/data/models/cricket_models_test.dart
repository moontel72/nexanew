import 'package:flutter_test/flutter_test.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';

void main() {
  group('TeamModel.fromJson', () {
    test('parses valid JSON with all fields as strings', () {
      final json = {
        'id': 'abc-123',
        'name': 'Mumbai Indians',
        'short_code': 'MI',
        'logo_url': 'https://example.com/logo.png',
        'primary_color': '#0044AA',
        'team_code': '007',
        'home_city': 'Mumbai',
        'player_count': 15,
      };

      final team = TeamModel.fromJson(json);

      expect(team.id, 'abc-123');
      expect(team.name, 'Mumbai Indians');
      expect(team.shortCode, 'MI');
      expect(team.logoUrl, 'https://example.com/logo.png');
      expect(team.primaryColor, '#0044AA');
      expect(team.teamCode, '007');
      expect(team.homeCity, 'Mumbai');
      expect(team.playerCount, 15);
    });

    test('handles integer id (PostgreSQL serial)', () {
      final json = {'id': 42, 'name': 'Test Team', 'short_code': 'TT'};

      final team = TeamModel.fromJson(json);

      expect(team.id, '42'); // converted to string
      expect(team.name, 'Test Team');
    });

    test('handles null id gracefully', () {
      final json = {'name': 'No ID Team'};

      final team = TeamModel.fromJson(json);

      expect(team.id, '');
      expect(team.name, 'No ID Team');
      expect(team.shortCode, '');
    });

    test('handles completely empty JSON', () {
      final team = TeamModel.fromJson({});

      expect(team.id, '');
      expect(team.name, '');
      expect(team.shortCode, '');
      expect(team.logoUrl, isNull);
      expect(team.playerCount, isNull);
    });

    test('handles null fields that should be strings', () {
      final json = {
        'id': 'team-1',
        'name': null,
        'short_code': null,
        'logo_url': null,
        'primary_color': null,
        'team_code': null,
        'home_city': null,
      };

      final team = TeamModel.fromJson(json);

      expect(team.id, 'team-1');
      expect(team.name, '');
      expect(team.shortCode, '');
      expect(team.logoUrl, isNull);
      expect(team.teamCode, isNull);
    });

    test('handles player_count as string', () {
      final json = {'id': '1', 'name': 'X', 'player_count': '42'};

      final team = TeamModel.fromJson(json);

      expect(team.playerCount, 42); // parsed from string
    });

    test('handles invalid player_count gracefully', () {
      final json = {'id': '1', 'name': 'X', 'player_count': 'not-a-number'};

      final team = TeamModel.fromJson(json);

      expect(team.playerCount, isNull);
    });

    test('handles player_count as double', () {
      final json = {'id': '1', 'name': 'X', 'player_count': 3.0};

      final team = TeamModel.fromJson(json);

      // double is not int, so it will try to parse toString which fails
      expect(team.playerCount, isNull);
    });
  });

  group('CricketManagerModel.fromJson', () {
    test('parses with integer id', () {
      final json = {'id': 7, 'name': 'John', 'email': 'john@example.com'};

      final manager = CricketManagerModel.fromJson(json);

      expect(manager.id, '7');
      expect(manager.name, 'John');
    });

    test('handles null permissions', () {
      final json = {
        'id': '1',
        'name': 'Admin',
        'email': 'admin@test.com',
        'permissions': null,
      };

      final manager = CricketManagerModel.fromJson(json);

      expect(manager.permissions, isNull);
      expect(manager.canManageScores(), false);
    });
  });

  group('PlayerModel.fromJson', () {
    test('parses with all fields', () {
      final json = {
        'id': 'p1',
        'name': 'Virat Kohli',
        'player_code': '018',
        'team': {'name': 'India', 'short_code': 'IND'},
        'role': 'batsman',
        'is_captain': true,
        'is_wicket_keeper': false,
      };

      final player = PlayerModel.fromJson(json);

      expect(player.id, 'p1');
      expect(player.teamName, 'India');
      expect(player.teamShortCode, 'IND');
      expect(player.isCaptain, true);
      expect(player.isWicketKeeper, false);
    });

    test('handles integer boolean fields', () {
      final json = {
        'id': '1',
        'name': 'Player',
        'role': 'bowler',
        'is_captain': 1,
        'is_wicket_keeper': 0,
      };

      final player = PlayerModel.fromJson(json);

      expect(player.isCaptain, true);
      expect(player.isWicketKeeper, false);
    });

    test('handles missing team object', () {
      final json = {'id': '1', 'name': 'Player', 'role': 'all_rounder'};

      final player = PlayerModel.fromJson(json);

      expect(player.teamName, isNull);
      expect(player.teamShortCode, isNull);
    });
  });

  group('TournamentModel.fromJson', () {
    test('parses valid JSON', () {
      final json = {
        'id': 't1',
        'name': 'IPL 2024',
        'start_date': '2024-03-22T00:00:00Z',
        'end_date': '2024-05-29T00:00:00Z',
        'status': 'active',
      };

      final tournament = TournamentModel.fromJson(json);

      expect(tournament.id, 't1');
      expect(tournament.name, 'IPL 2024');
      expect(tournament.status, 'active');
    });

    test('handles missing dates gracefully', () {
      final json = {'id': 't1', 'name': 'Test', 'status': 'active'};

      final tournament = TournamentModel.fromJson(json);

      // Should not throw, uses DateTime.now() as fallback
      expect(tournament.id, 't1');
      expect(tournament.name, 'Test');
    });

    test('handles integer id', () {
      final json = {
        'id': 99,
        'name': 'Tournament',
        'start_date': '2024-01-01T00:00:00Z',
        'end_date': '2024-12-31T00:00:00Z',
        'status': 'completed',
      };

      final tournament = TournamentModel.fromJson(json);

      expect(tournament.id, '99');
    });
  });
}
