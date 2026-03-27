import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/air_ticket/voice_playback/checklist_voice_playback_factory.dart';
import 'package:travel_crm/features/presentation/air_ticket/voice_playback/checklist_voice_playback_interface.dart';

enum ChecklistVoiceRecordPhase { idle, recording, stopped, error }

class ChecklistVoiceRecordState extends Equatable {
  const ChecklistVoiceRecordState({
    required this.phase,
    required this.waveformBars,
    this.durationSeconds = 0,
    this.recordedPath,
    this.errorMessage,
    this.recordedDurationSeconds,
    this.playbackPlaying = false,
    this.playbackPosition = Duration.zero,
    this.playbackTotalDuration,
  });

  final ChecklistVoiceRecordPhase phase;
  final List<double> waveformBars;
  final int durationSeconds;
  final String? recordedPath;
  final String? errorMessage;

  /// Length of the last recording session (for UI when file duration is not yet loaded).
  final int? recordedDurationSeconds;
  final bool playbackPlaying;
  final Duration playbackPosition;
  final Duration? playbackTotalDuration;

  bool get isRecording => phase == ChecklistVoiceRecordPhase.recording;

  bool get canPlayback =>
      phase == ChecklistVoiceRecordPhase.stopped &&
      recordedPath != null &&
      recordedPath!.isNotEmpty;

  ChecklistVoiceRecordState copyWith({
    ChecklistVoiceRecordPhase? phase,
    List<double>? waveformBars,
    int? durationSeconds,
    String? recordedPath,
    String? errorMessage,
    int? recordedDurationSeconds,
    bool? playbackPlaying,
    Duration? playbackPosition,
    Duration? playbackTotalDuration,
    bool clearError = false,
    bool clearRecordedPath = false,
    bool clearRecordedDuration = false,
    bool clearPlaybackTotalDuration = false,
  }) {
    return ChecklistVoiceRecordState(
      phase: phase ?? this.phase,
      waveformBars: waveformBars ?? this.waveformBars,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      recordedPath:
          clearRecordedPath ? null : (recordedPath ?? this.recordedPath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recordedDurationSeconds: clearRecordedDuration
          ? null
          : (recordedDurationSeconds ?? this.recordedDurationSeconds),
      playbackPlaying: playbackPlaying ?? this.playbackPlaying,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      playbackTotalDuration: clearPlaybackTotalDuration
          ? null
          : (playbackTotalDuration ?? this.playbackTotalDuration),
    );
  }

  @override
  List<Object?> get props => [
        phase,
        waveformBars,
        durationSeconds,
        recordedPath,
        errorMessage,
        recordedDurationSeconds,
        playbackPlaying,
        playbackPosition,
        playbackTotalDuration,
      ];
}

/// Drives mic permission, recording session, waveform levels, and playback preview.
class ChecklistVoiceRecordCubit extends Cubit<ChecklistVoiceRecordState> {
  ChecklistVoiceRecordCubit()
      : super(
          ChecklistVoiceRecordState(
            phase: ChecklistVoiceRecordPhase.idle,
            waveformBars: List<double>.filled(waveBarCount, _idleBar),
          ),
        ) {
    _bindPlaybackStreams();
  }

  static const int waveBarCount = 32;
  static const double _idleBar = 0.06;

  final AudioRecorder _recorder = AudioRecorder();
  final ChecklistVoicePlayback _playback = createChecklistVoicePlayback();

  StreamSubscription<Amplitude>? _amplitudeSub;
  StreamSubscription<PlaybackUpdate>? _playbackUpdateSub;

  DateTime? _recordStartedAt;

  void _bindPlaybackStreams() {
    _playbackUpdateSub = _playback.updates.listen((u) {
      if (isClosed) return;
      final s = state;
      if (s.phase != ChecklistVoiceRecordPhase.stopped) return;
      if (u.completed) {
        emit(
          s.copyWith(
            playbackPlaying: false,
            playbackPosition: Duration.zero,
          ),
        );
      } else {
        emit(
          s.copyWith(
            playbackPlaying: u.playing,
            playbackPosition: u.position,
            playbackTotalDuration: u.duration,
          ),
        );
      }
    });
  }

  static double _dbToBar(double db) {
    const minDb = -55.0;
    const maxDb = -8.0;
    if (db.isNaN || db <= minDb) return _idleBar;
    if (db >= maxDb) return 1.0;
    return _idleBar + (db - minDb) / (maxDb - minDb) * (1.0 - _idleBar);
  }

  Future<String> _outputPath() async {
    if (kIsWeb) {
      return '';
    }
    final dir = await getTemporaryDirectory();
    return p.join(
      dir.path,
      'checklist_voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
  }

  Future<void> _resetPlaybackForNewRecording() async {
    await _playback.stopAndReset();
    emit(
      state.copyWith(
        playbackPlaying: false,
        playbackPosition: Duration.zero,
        clearPlaybackTotalDuration: true,
      ),
    );
  }

  /// Opens the dialog in playback mode (e.g. user re-taps mic after saving).
  void setExistingRecording(String path) {
    if (path.isEmpty) return;
    emit(
      state.copyWith(
        phase: ChecklistVoiceRecordPhase.stopped,
        recordedPath: path,
        waveformBars: List<double>.filled(waveBarCount, _idleBar),
        durationSeconds: 0,
        clearRecordedDuration: true,
        playbackPlaying: false,
        playbackPosition: Duration.zero,
        clearPlaybackTotalDuration: true,
        clearError: true,
      ),
    );
  }

  Future<void> toggleRecording() async {
    if (state.phase == ChecklistVoiceRecordPhase.recording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> togglePlayback() async {
    if (!state.canPlayback) return;
    final path = state.recordedPath!;

    try {
      if (_playback.isPlaying) {
        await _playback.pause();
        return;
      }
      await _playback.play(path, isUrl: kIsWeb);
    } catch (e) {
      emit(
        state.copyWith(
          phase: ChecklistVoiceRecordPhase.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> startRecording() async {
    if (state.phase == ChecklistVoiceRecordPhase.recording) return;

    await _resetPlaybackForNewRecording();

    emit(
      state.copyWith(
        clearError: true,
        phase: ChecklistVoiceRecordPhase.idle,
        waveformBars: List<double>.filled(waveBarCount, _idleBar),
        durationSeconds: 0,
        clearRecordedPath: true,
        clearRecordedDuration: true,
      ),
    );

    final ok = await _recorder.hasPermission();
    if (!ok) {
      emit(
        state.copyWith(
          phase: ChecklistVoiceRecordPhase.error,
          errorMessage: StringConstant.microphonePermissionRequired,
        ),
      );
      return;
    }

    try {
      final path = await _outputPath();
      const config = RecordConfig(encoder: AudioEncoder.aacLc);
      await _recorder.start(config, path: path);

      _recordStartedAt = DateTime.now();

      emit(
        state.copyWith(
          phase: ChecklistVoiceRecordPhase.recording,
          durationSeconds: 0,
          waveformBars: List<double>.filled(waveBarCount, _idleBar),
        ),
      );

      await _amplitudeSub?.cancel();
      _amplitudeSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 80))
          .listen(
        (amp) {
          final secs = _recordStartedAt == null
              ? 0
              : DateTime.now().difference(_recordStartedAt!).inSeconds;
          final bars = List<double>.from(state.waveformBars);
          if (bars.isEmpty) return;
          bars.removeAt(0);
          bars.add(_dbToBar(amp.current));
          emit(
            state.copyWith(
              waveformBars: bars,
              durationSeconds: secs,
            ),
          );
        },
        onError: (_) {},
      );
    } catch (e) {
      emit(
        state.copyWith(
          phase: ChecklistVoiceRecordPhase.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> stopRecording() async {
    if (state.phase != ChecklistVoiceRecordPhase.recording) return;
    final recordingDuration = state.durationSeconds;
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    _recordStartedAt = null;

    try {
      final path = await _recorder.stop();
      emit(
        state.copyWith(
          phase: ChecklistVoiceRecordPhase.stopped,
          recordedPath: path,
          waveformBars: List<double>.filled(waveBarCount, _idleBar),
          durationSeconds: 0,
          recordedDurationSeconds: recordingDuration,
          playbackPosition: Duration.zero,
          playbackPlaying: false,
          clearPlaybackTotalDuration: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          phase: ChecklistVoiceRecordPhase.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _amplitudeSub?.cancel();
    await _playbackUpdateSub?.cancel();
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    await _recorder.dispose();
    await _playback.dispose();
    return super.close();
  }
}
