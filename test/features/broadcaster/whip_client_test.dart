import 'package:flutter_test/flutter_test.dart';
import 'package:trace_odd/features/broadcaster/data/services/whip_client.dart';

void main() {
  group('WhipClient.parseWhipUrl', () {
    test('parses the canonical Studio ingest URL', () {
      final parts = WhipClient.parseWhipUrl(
        'https://studio.traceodd.com/api/v1/whip/ingest/room-1/cam-1'
        '?token=eyJhbGciOiJIUzI1NiJ9.abc.def',
      );

      expect(parts, isNotNull);
      expect(parts!.baseUrl, 'https://studio.traceodd.com');
      expect(parts.roomId, 'room-1');
      expect(parts.cameraId, 'cam-1');
      expect(parts.token, 'eyJhbGciOiJIUzI1NiJ9.abc.def');
    });

    test('parses a URL without a token', () {
      final parts = WhipClient.parseWhipUrl(
        'https://studio.traceodd.com/api/v1/whip/ingest/room-1/cam-1',
      );

      expect(parts, isNotNull);
      expect(parts!.roomId, 'room-1');
      expect(parts.cameraId, 'cam-1');
      expect(parts.token, isEmpty);
    });

    test('parses a room-only URL', () {
      final parts = WhipClient.parseWhipUrl(
        'https://studio.traceodd.com/api/v1/whip/ingest/room-1',
      );

      expect(parts, isNotNull);
      expect(parts!.roomId, 'room-1');
      expect(parts.cameraId, isEmpty);
    });

    test('tolerates a trailing slash after the camera id', () {
      final parts = WhipClient.parseWhipUrl(
        'https://studio.traceodd.com/api/v1/whip/ingest/room-1/cam-1/',
      );

      expect(parts, isNotNull);
      expect(parts!.cameraId, 'cam-1');
    });

    test('tolerates a trailing slash on the origin', () {
      final parts = WhipClient.parseWhipUrl(
        'https://studio.traceodd.com//api/v1/whip/ingest/room-1/cam-1',
      );

      expect(parts, isNotNull);
      expect(parts!.baseUrl, 'https://studio.traceodd.com');
      expect(parts.roomId, 'room-1');
    });

    test('unwraps angle brackets, parentheses and quotes', () {
      for (final wrapped in <String>[
        '<https://studio.traceodd.com/api/v1/whip/ingest/r/c?token=t>',
        '(https://studio.traceodd.com/api/v1/whip/ingest/r/c?token=t)',
        '"https://studio.traceodd.com/api/v1/whip/ingest/r/c?token=t"',
        "'https://studio.traceodd.com/api/v1/whip/ingest/r/c?token=t'",
      ]) {
        final parts = WhipClient.parseWhipUrl(wrapped);
        expect(parts, isNotNull, reason: wrapped);
        expect(parts!.roomId, 'r', reason: wrapped);
        expect(parts.cameraId, 'c', reason: wrapped);
        expect(parts.token, 't', reason: wrapped);
      }
    });

    test('strips trailing sentence punctuation from a pasted URL', () {
      final parts = WhipClient.parseWhipUrl(
        'https://studio.traceodd.com/api/v1/whip/ingest/r/c?token=t.',
      );

      expect(parts, isNotNull);
      expect(parts!.token, 't');
    });

    test('restores a missing scheme', () {
      final parts = WhipClient.parseWhipUrl(
        'studio.traceodd.com/api/v1/whip/ingest/r/c?token=t',
      );

      expect(parts, isNotNull);
      expect(parts!.baseUrl, 'https://studio.traceodd.com');
      expect(parts.token, 't');
    });

    test('unwraps share links that embed the ingest URL', () {
      final parts = WhipClient.parseWhipUrl(
        'https://broadcaster.traceodd.com/?url='
        'https%3A%2F%2Fstudio.traceodd.com%2Fapi%2Fv1%2Fwhip%2Fingest%2Fr%2Fc'
        '%3Ftoken%3Dt',
      );

      expect(parts, isNotNull);
      expect(parts!.baseUrl, 'https://studio.traceodd.com');
      expect(parts.roomId, 'r');
      expect(parts.cameraId, 'c');
      expect(parts.token, 't');
    });

    test('rejects non-WHIP URLs', () {
      expect(
        WhipClient.parseWhipUrl('https://studio.traceodd.com/login'),
        isNull,
      );
      expect(
        WhipClient.parseWhipUrl(
          'https://studio.traceodd.com/api/v1/whep/watch/r/c',
        ),
        isNull,
      );
      expect(WhipClient.parseWhipUrl('not a url'), isNull);
      expect(WhipClient.parseWhipUrl(''), isNull);
    });
  });
}
