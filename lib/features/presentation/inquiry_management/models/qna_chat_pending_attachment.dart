import 'package:equatable/equatable.dart';

/// File chosen via + but not sent yet — shown above the composer until send.
class QnaChatPendingAttachment extends Equatable {
  const QnaChatPendingAttachment({
    required this.fileName,
    this.filePath,
    this.bytes,
  });

  final String fileName;
  final String? filePath;
  final List<int>? bytes;

  @override
  List<Object?> get props => [fileName, filePath, bytes];
}
