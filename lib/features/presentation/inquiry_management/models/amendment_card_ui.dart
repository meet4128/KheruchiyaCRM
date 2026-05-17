import 'package:equatable/equatable.dart';

class AmendmentCardUi extends Equatable {
  const AmendmentCardUi({
    required this.mongoId,
    required this.amendmentId,
    required this.amendmentType,
    required this.amendmentTypeLabel,
    required this.status,
    required this.statusLabel,
    this.amountCharged,
    required this.amountChargedDisplay,
    this.sessionId,
    this.chatLockedAt,
    this.processedAt,
    this.createdAt,
    this.isReadOnly = true,
  });

  final String mongoId;
  final String amendmentId;
  final String amendmentType;
  final String amendmentTypeLabel;
  final String status;
  final String statusLabel;
  final double? amountCharged;
  final String amountChargedDisplay;
  final String? sessionId;
  final DateTime? chatLockedAt;
  final DateTime? processedAt;
  final DateTime? createdAt;
  final bool isReadOnly;

  bool get hasAmendmentId => amendmentId.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        mongoId,
        amendmentId,
        amendmentType,
        amendmentTypeLabel,
        status,
        statusLabel,
        amountCharged,
        amountChargedDisplay,
        sessionId,
        chatLockedAt,
        processedAt,
        createdAt,
        isReadOnly,
      ];
}
