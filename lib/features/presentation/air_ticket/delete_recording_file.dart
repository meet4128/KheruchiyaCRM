import 'delete_recording_file_stub.dart'
    if (dart.library.io) 'delete_recording_file_io.dart';

/// Removes temp file from disk when possible (no-op on web).
void deleteRecordingFileIfExists(String? path) => deleteRecordingFileImpl(path);
