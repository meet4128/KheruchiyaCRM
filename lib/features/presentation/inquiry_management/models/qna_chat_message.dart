import 'package:equatable/equatable.dart';
import 'package:travel_crm/core/constants/string_constants.dart';

enum QnaChatMessageKind { question, answer }

enum QnaChatMessageContentType { text, structured }

class QnaChatMessage extends Equatable {
  const QnaChatMessage({
    required this.id,
    required this.kind,
    required this.contentType,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final QnaChatMessageKind kind;
  final QnaChatMessageContentType contentType;
  final String body;
  final DateTime createdAt;

  bool get isQuestion => kind == QnaChatMessageKind.question;

  @override
  List<Object?> get props => [id, kind, contentType, body, createdAt];
}

/// One date label + messages for that calendar day (chronological).
class QnaChatDateGroup extends Equatable {
  const QnaChatDateGroup({
    required this.label,
    required this.messages,
  });

  final String label;
  final List<QnaChatMessage> messages;

  @override
  List<Object?> get props => [label, messages];
}

String qnaChatDateLabel(DateTime date, DateTime now) {
  final local = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(local).inDays;
  if (diff == 0) return StringConstant.qnaChatToday;
  if (diff == 1) return StringConstant.qnaChatYesterday;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

List<QnaChatDateGroup> groupQnaChatMessagesByDate(
  List<QnaChatMessage> messages, {
  DateTime? now,
}) {
  if (messages.isEmpty) return const [];

  final reference = now ?? DateTime.now();
  final sorted = List<QnaChatMessage>.from(messages)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  final groups = <QnaChatDateGroup>[];
  String? currentLabel;
  final bucket = <QnaChatMessage>[];

  void flush() {
    if (currentLabel == null || bucket.isEmpty) return;
    groups.add(QnaChatDateGroup(label: currentLabel, messages: List.unmodifiable(bucket)));
    bucket.clear();
  }

  for (final message in sorted) {
    final label = qnaChatDateLabel(message.createdAt, reference);
    if (label != currentLabel) {
      flush();
      currentLabel = label;
    }
    bucket.add(message);
  }
  flush();
  return groups;
}

String formatQnaChatTime(DateTime dateTime) {
  final h = dateTime.hour.toString().padLeft(2, '0');
  final m = dateTime.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
