import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'checklist_voice_playback_interface.dart';

ChecklistVoicePlayback createChecklistVoicePlaybackImpl() =>
    ChecklistVoicePlaybackHtml();

/// HTML5 [AudioElement] — avoids [just_audio] platform channels on Flutter Web.
class ChecklistVoicePlaybackHtml implements ChecklistVoicePlayback {
  html.AudioElement? _audio;
  String? _loadedPath;

  final StreamController<PlaybackUpdate> _updates =
      StreamController<PlaybackUpdate>.broadcast();

  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  Stream<PlaybackUpdate> get updates => _updates.stream;

  @override
  bool get isPlaying =>
      _audio != null && !_audio!.paused && !_audio!.ended;

  void _emitPlayback() {
    final el = _audio;
    if (el == null) {
      _updates.add(
        const PlaybackUpdate(
          playing: false,
          position: Duration.zero,
        ),
      );
      return;
    }
    final durSec = el.duration;
    final dur = durSec.isFinite && durSec > 0
        ? Duration(milliseconds: (durSec * 1000).round())
        : null;
    final pos = Duration(milliseconds: (el.currentTime * 1000).round());
    _updates.add(
      PlaybackUpdate(
        playing: !el.paused && !el.ended,
        position: pos,
        duration: dur,
      ),
    );
  }

  void _attachListeners(html.AudioElement a) {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();

    _subs.add(a.onPlay.listen((_) => _emitPlayback()));
    _subs.add(a.onPause.listen((_) => _emitPlayback()));
    _subs.add(a.onTimeUpdate.listen((_) => _emitPlayback()));
    _subs.add(a.onDurationChange.listen((_) => _emitPlayback()));
    _subs.add(
      a.onEnded.listen((_) {
        final el = _audio;
        if (el == null) return;
        final durSec = el.duration;
        final dur = durSec.isFinite && durSec > 0
            ? Duration(milliseconds: (durSec * 1000).round())
            : null;
        _updates.add(
          PlaybackUpdate(
            playing: false,
            position: Duration.zero,
            duration: dur,
            completed: true,
          ),
        );
      }),
    );
  }

  @override
  Future<void> play(String path, {required bool isUrl}) async {
    final el = _audio;
    if (el != null && path == _loadedPath) {
      if (!el.paused) {
        el.pause();
        _emitPlayback();
        return;
      }
      if (el.ended) {
        el.currentTime = 0;
      }
      await el.play();
      _emitPlayback();
      return;
    }

    _audio?.remove();
    _audio = html.AudioElement()
      ..src = path
      ..preload = 'auto';
    _loadedPath = path;
    _attachListeners(_audio!);
    await _audio!.play();
    _emitPlayback();
  }

  @override
  Future<void> pause() async {
    _audio?.pause();
    _emitPlayback();
  }

  @override
  Future<void> stopAndReset() async {
    final el = _audio;
    if (el != null) {
      el.pause();
      el.currentTime = 0;
    }
    _loadedPath = null;
    _audio?.remove();
    _audio = null;
    _updates.add(
      const PlaybackUpdate(
        playing: false,
        position: Duration.zero,
        completed: false,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    _audio?.remove();
    _audio = null;
    _loadedPath = null;
    await _updates.close();
  }
}
