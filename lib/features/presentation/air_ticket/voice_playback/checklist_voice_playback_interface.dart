/// Platform-agnostic playback updates for [ChecklistVoiceRecordCubit].
class PlaybackUpdate {
  const PlaybackUpdate({
    required this.playing,
    required this.position,
    this.duration,
    this.completed = false,
  });

  final bool playing;
  final Duration position;
  final Duration? duration;
  final bool completed;
}

/// Voice preview playback (just_audio on IO, HTML5 audio on web).
abstract class ChecklistVoicePlayback {
  Stream<PlaybackUpdate> get updates;

  bool get isPlaying;

  Future<void> play(String path, {required bool isUrl});

  Future<void> pause();

  /// Stops playback and clears loaded source (before a new recording).
  Future<void> stopAndReset();

  Future<void> dispose();
}
