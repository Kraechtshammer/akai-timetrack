/// Keeps the progress bar of the running-shift notification moving.
/// See RunningProgressPlugin.kt.
library;

import 'package:flutter/services.dart';

abstract final class RunningProgress {
  static const _channel = MethodChannel('de.garten.running_progress');

  /// Call right after (re-)posting the notification [notificationId]: it is
  /// updated now and every few minutes until [end].
  static Future<void> start({
    required int notificationId,
    required DateTime start,
    required DateTime end,
    required int color,
  }) => _channel.invokeMethod<void>('start', {
    'notificationId': notificationId,
    'startMs': start.millisecondsSinceEpoch,
    'endMs': end.millisecondsSinceEpoch,
    'color': color,
  });

  /// Stops the updates (recording ended).
  static Future<void> stop() => _channel.invokeMethod<void>('stop');
}
