import 'package:shared_preferences/shared_preferences.dart';

import '../../presentation/broadcaster_cubit.dart';

/// Persists the broadcaster connection config so a camera operator only
/// fills the form once. The saved config survives app restarts until the
/// operator explicitly deletes it (Delete button on the config form).
///
/// Backing store: SharedPreferences on Android/iOS, localStorage on web
/// (the PWA). Note the TURN password is stored in plain text — the store
/// is for operator convenience, not for secrets.
class BroadcasterConfigStore {
  static const _kBaseUrl = 'broadcaster.base_url';
  static const _kRoomId = 'broadcaster.room_id';
  static const _kCameraId = 'broadcaster.camera_id';
  static const _kToken = 'broadcaster.token';
  static const _kStunUrl = 'broadcaster.stun_url';
  static const _kTurnUrl = 'broadcaster.turn_url';
  static const _kTurnUsername = 'broadcaster.turn_username';
  static const _kTurnPassword = 'broadcaster.turn_password';

  /// Saves the config. The last-saved config is what the form restores on
  /// the next app start.
  static Future<void> save(BroadcasterConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseUrl, config.baseUrl);
    await prefs.setString(_kRoomId, config.roomId);
    await prefs.setString(_kCameraId, config.cameraId);
    await prefs.setString(_kToken, config.token);
    await prefs.setString(_kStunUrl, config.stunUrl);
    await prefs.setString(_kTurnUrl, config.turnUrl);
    await prefs.setString(_kTurnUsername, config.turnUsername);
    await prefs.setString(_kTurnPassword, config.turnPassword);
  }

  /// Loads the last-saved config, or null when nothing was ever saved.
  static Future<BroadcasterConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(_kBaseUrl) ?? '';
    final roomId = prefs.getString(_kRoomId) ?? '';
    final cameraId = prefs.getString(_kCameraId) ?? '';
    final token = prefs.getString(_kToken) ?? '';
    if (baseUrl.isEmpty && roomId.isEmpty && token.isEmpty) {
      return null;
    }
    return BroadcasterConfig(
      baseUrl: baseUrl,
      roomId: roomId,
      cameraId: cameraId,
      token: token,
      stunUrl: prefs.getString(_kStunUrl) ?? '',
      turnUrl: prefs.getString(_kTurnUrl) ?? '',
      turnUsername: prefs.getString(_kTurnUsername) ?? '',
      turnPassword: prefs.getString(_kTurnPassword) ?? '',
    );
  }

  /// Deletes the saved config (operator-triggered via the Delete button).
  static Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBaseUrl);
    await prefs.remove(_kRoomId);
    await prefs.remove(_kCameraId);
    await prefs.remove(_kToken);
    await prefs.remove(_kStunUrl);
    await prefs.remove(_kTurnUrl);
    await prefs.remove(_kTurnUsername);
    await prefs.remove(_kTurnPassword);
  }
}
