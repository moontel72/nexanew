/// Replay models — used by the VAR / Instant Replay system.
///
/// These models mirror the backend's cricket_replay_events,
/// cricket_replay_clips, and cricket_replay_chunks tables.

class ReplayEventModel {
  final String id;
  final String matchId;
  final String? chunkId;
  final String eventType;
  final int frameTimestamp;
  final String? annotation;
  final String? taggedByManagerId;
  final bool isPublished;
  final DateTime createdAt;

  const ReplayEventModel({
    required this.id,
    required this.matchId,
    this.chunkId,
    required this.eventType,
    required this.frameTimestamp,
    this.annotation,
    this.taggedByManagerId,
    this.isPublished = false,
    required this.createdAt,
  });

  factory ReplayEventModel.fromJson(Map<String, dynamic> json) =>
      ReplayEventModel(
        id: json['id'] as String? ?? '',
        matchId: json['match_id'] as String? ?? '',
        chunkId: json['chunk_id'] as String?,
        eventType: json['event_type'] as String? ?? 'custom',
        frameTimestamp: (json['frame_timestamp'] as num?)?.toInt() ?? 0,
        annotation: json['annotation'] as String?,
        taggedByManagerId: json['tagged_by_cricket_manager_id'] as String?,
        isPublished: json['is_published'] as bool? ?? false,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  String get displayType => eventType.replaceAll('_', ' ').toUpperCase();

  String get formattedTimestamp {
    final totalSecs = frameTimestamp / 1000;
    final mins = (totalSecs / 60).floor();
    final secs = (totalSecs % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  IconType get iconType => switch (eventType) {
    'wicket' => IconType.wicket,
    'boundary' => IconType.boundary,
    'appeal' => IconType.appeal,
    'review' => IconType.review,
    _ => IconType.custom,
  };
}

enum IconType { wicket, boundary, appeal, review, custom }

class ReplayClipModel {
  final String id;
  final String matchId;
  final String eventId;
  final String clipFilePath;
  final int bufferBeforeMs;
  final int bufferAfterMs;
  final double playbackSpeed;
  final bool isPublished;
  final DateTime? publishedAt;

  const ReplayClipModel({
    required this.id,
    required this.matchId,
    required this.eventId,
    required this.clipFilePath,
    this.bufferBeforeMs = 5000,
    this.bufferAfterMs = 5000,
    this.playbackSpeed = 1.0,
    this.isPublished = false,
    this.publishedAt,
  });

  factory ReplayClipModel.fromJson(Map<String, dynamic> json) =>
      ReplayClipModel(
        id: json['id'] as String? ?? '',
        matchId: json['match_id'] as String? ?? '',
        eventId: json['event_id'] as String? ?? '',
        clipFilePath: json['clip_file_path'] as String? ?? '',
        bufferBeforeMs: (json['buffer_before_ms'] as num?)?.toInt() ?? 5000,
        bufferAfterMs: (json['buffer_after_ms'] as num?)?.toInt() ?? 5000,
        playbackSpeed: (json['playback_speed'] as num?)?.toDouble() ?? 1.0,
        isPublished: json['is_published'] as bool? ?? false,
        publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
      );

  String get bufferBeforeLabel => '${(bufferBeforeMs / 1000).round()}s';
  String get bufferAfterLabel => '${(bufferAfterMs / 1000).round()}s';
  String get speedLabel => '${playbackSpeed}x';
}
