import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/checklist_voice_record_cubit.dart';

/// Shows the themed voice-record dialog. State is driven by [ChecklistVoiceRecordCubit].
Future<void> showChecklistVoiceRecordDialog(
  BuildContext context, {
  ValueChanged<String?>? onRecordingSaved,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => BlocProvider(
      create: (_) => ChecklistVoiceRecordCubit(),
      child: _ChecklistVoiceRecordDialog(onRecordingSaved: onRecordingSaved),
    ),
  );
}

class _ChecklistVoiceRecordDialog extends StatelessWidget {
  const _ChecklistVoiceRecordDialog({this.onRecordingSaved});

  final ValueChanged<String?>? onRecordingSaved;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final borderColor = colors.secondary.withValues(alpha: 0.5);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      StringConstant.voiceNoteTitle,
                      style: textStyles.heading5.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BlocBuilder<ChecklistVoiceRecordCubit, ChecklistVoiceRecordState>(
                buildWhen: (p, c) =>
                    p.waveformBars != c.waveformBars ||
                    p.phase != c.phase ||
                    p.durationSeconds != c.durationSeconds ||
                    p.errorMessage != c.errorMessage ||
                    p.recordedDurationSeconds != c.recordedDurationSeconds,
                builder: (context, state) {
                  final hint = state.phase == ChecklistVoiceRecordPhase.recording
                      ? StringConstant.voiceNoteRecording
                      : state.phase == ChecklistVoiceRecordPhase.stopped
                          ? StringConstant.voiceNoteSaved
                          : state.phase == ChecklistVoiceRecordPhase.error
                              ? (state.errorMessage ??
                                  StringConstant.somethingWentWrong)
                              : StringConstant.voiceNoteHint;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 100,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.inputBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: colors.secondary.withValues(alpha: 0.12),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: state.phase == ChecklistVoiceRecordPhase.recording
                            ? _WaveformBars(
                                bars: state.waveformBars,
                                activeColor: colors.secondary,
                                idleColor: colors.textSecondary,
                              )
                            : Center(
                                child: Icon(
                                  Icons.graphic_eq,
                                  size: 40,
                                  color: colors.textSecondary.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.phase ==
                              ChecklistVoiceRecordPhase.recording) ...[
                            Icon(
                              Icons.fiber_manual_record,
                              size: 14,
                              color: const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDuration(state.durationSeconds),
                              style: textStyles.labelLarge.copyWith(
                                color: colors.textPrimary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: textStyles.bodySmall.copyWith(
                          color: state.phase == ChecklistVoiceRecordPhase.error
                              ? const Color(0xFFEF4444)
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
              BlocBuilder<ChecklistVoiceRecordCubit, ChecklistVoiceRecordState>(
                buildWhen: (p, c) =>
                    p.phase != c.phase ||
                    p.recordedPath != c.recordedPath ||
                    p.playbackPlaying != c.playbackPlaying ||
                    p.playbackPosition != c.playbackPosition ||
                    p.playbackTotalDuration != c.playbackTotalDuration ||
                    p.recordedDurationSeconds != c.recordedDurationSeconds,
                builder: (context, state) {
                  if (!state.canPlayback) {
                    return const SizedBox.shrink();
                  }
                  final totalSec = state.playbackTotalDuration?.inSeconds ??
                      state.recordedDurationSeconds ??
                      1;
                  final posSec = state.playbackPosition.inSeconds
                      .clamp(0, totalSec > 0 ? totalSec : 1);
                  final progress = totalSec > 0 ? posSec / totalSec : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Row(
                        children: [
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: colors.secondary,
                              foregroundColor: colors.textOnPrimary,
                            ),
                            onPressed: () => context
                                .read<ChecklistVoiceRecordCubit>()
                                .togglePlayback(),
                            icon: Icon(
                              state.playbackPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 28,
                            ),
                            tooltip: state.playbackPlaying
                                ? StringConstant.pausePlayback
                                : StringConstant.playRecording,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    minHeight: 6,
                                    backgroundColor:
                                        colors.textSecondary.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colors.secondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_formatDuration(posSec)} / ${_formatDuration(totalSec)}',
                                  textAlign: TextAlign.center,
                                  style: textStyles.labelMedium.copyWith(
                                    color: colors.textPrimary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlocBuilder<ChecklistVoiceRecordCubit, ChecklistVoiceRecordState>(
                    buildWhen: (p, c) => p.phase != c.phase,
                    builder: (context, state) {
                      final recording =
                          state.phase == ChecklistVoiceRecordPhase.recording;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context
                              .read<ChecklistVoiceRecordCubit>()
                              .toggleRecording(),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: recording
                                  ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                                  : colors.inputBackground,
                              border: Border.all(
                                color: recording
                                    ? const Color(0xFFEF4444)
                                    : borderColor,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.secondary.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              recording ? Icons.stop_rounded : Icons.mic_rounded,
                              size: 32,
                              color: recording
                                  ? const Color(0xFFEF4444)
                                  : colors.secondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<ChecklistVoiceRecordCubit, ChecklistVoiceRecordState>(
                buildWhen: (p, c) =>
                    p.phase != c.phase || p.recordedPath != c.recordedPath,
                builder: (context, state) {
                  if (state.phase != ChecklistVoiceRecordPhase.stopped) {
                    return const SizedBox.shrink();
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context
                              .read<ChecklistVoiceRecordCubit>()
                              .startRecording(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textPrimary,
                            side: BorderSide(color: borderColor),
                          ),
                          child: Text(StringConstant.recordAgain),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            onRecordingSaved?.call(state.recordedPath);
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.secondary,
                            foregroundColor: colors.textOnPrimary,
                          ),
                          child: Text(StringConstant.done),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveformBars extends StatelessWidget {
  const _WaveformBars({
    required this.bars,
    required this.activeColor,
    required this.idleColor,
  });

  final List<double> bars;
  final Color activeColor;
  final Color idleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final h in bars)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                curve: Curves.easeOut,
                height: 4 + h * 72,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    idleColor.withValues(alpha: 0.25),
                    activeColor,
                    h,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
