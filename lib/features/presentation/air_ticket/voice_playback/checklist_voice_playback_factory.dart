import 'checklist_voice_playback_interface.dart';
import 'checklist_voice_playback_stub.dart'
    if (dart.library.html) 'checklist_voice_playback_web.dart'
    if (dart.library.io) 'checklist_voice_playback_io.dart';

/// Web uses HTML5 audio; IO uses [just_audio].
ChecklistVoicePlayback createChecklistVoicePlayback() =>
    createChecklistVoicePlaybackImpl();
