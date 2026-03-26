import 'dart:async';

import 'package:just_audio/just_audio.dart';

import 'checklist_voice_playback_interface.dart';

ChecklistVoicePlayback createChecklistVoicePlaybackImpl() =>
    ChecklistVoicePlaybackJustAudio();

/// Uses [just_audio] (mobile, desktop, and other dart:io targets).
class ChecklistVoicePlaybackJustAudio implements ChecklistVoicePlayback {
  ChecklistVoicePlaybackJustAudio() : _player = AudioPlayer() {
    _wire();
  }

  final AudioPlayer _player;
  final StreamController<PlaybackUpdate> _updates =
      StreamController<PlaybackUpdate>.broadcast();

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  String? _loadedPath;

  @override
  Stream<PlaybackUpdate> get updates => _updates.stream;

  @override
  bool get isPlaying => _player.playing;

  void _emitPlayback() {
    final completed = _player.processingState == ProcessingState.completed;
    _updates.add(
      PlaybackUpdate(
        playing: _player.playing && !completed,
        position: completed ? Duration.zero : _player.position,
        duration: _player.duration,
        completed: completed,
      ),
    );
  }

  void _wire() {
    _stateSub = _player.playerStateStream.listen((_) => _emitPlayback());
    _positionSub = _player.positionStream.listen((_) {
      if (_player.playing) _emitPlayback();
    });
    _durationSub = _player.durationStream.listen((_) => _emitPlayback());
  }

  @override
  Future<void> play(String path, {required bool isUrl}) async {
    if (_player.playing) {
      await _player.pause();
      _emitPlayback();
      return;
    }

    if (path != _loadedPath) {
      if (isUrl) {
        await _player.setUrl(path);
      } else {
        await _player.setFilePath(path);
      }
      _loadedPath = path;
    }

    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }

    await _player.play();
    _emitPlayback();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _emitPlayback();
  }

  @override
  Future<void> stopAndReset() async {
    try {
      await _player.pause();
      await _player.stop();
    } catch (_) {}
    _loadedPath = null;
    _emitPlayback();
  }

  @override
  Future<void> dispose() async {
    await _stateSub?.cancel();
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _player.dispose();
    await _updates.close();
  }
}
