import 'package:equatable/equatable.dart';

class AmendmentChecklistUiItem extends Equatable {
  const AmendmentChecklistUiItem({
    required this.label,
    required this.isChecked,
  });

  final String label;
  final bool isChecked;

  @override
  List<Object?> get props => [label, isChecked];
}

class AmendmentCardBodyUi extends Equatable {
  const AmendmentCardBodyUi({
    required this.raisedBy,
    required this.bookedBy,
    required this.assignedStaff,
    required this.amendmentInvoice,
    required this.remarks,
    required this.nextTravelDate,
    required this.processedTime,
    required this.generationTime,
    required this.attachmentsDisplay,
    this.invoiceDownloadUrl,
    this.checklistItems = const [],
  });

  final String raisedBy;
  final String bookedBy;
  final String assignedStaff;
  final String amendmentInvoice;
  final String remarks;
  final String nextTravelDate;
  final String processedTime;
  final String generationTime;
  final String attachmentsDisplay;
  final String? invoiceDownloadUrl;
  final List<AmendmentChecklistUiItem> checklistItems;

  @override
  List<Object?> get props => [
        raisedBy,
        bookedBy,
        assignedStaff,
        amendmentInvoice,
        remarks,
        nextTravelDate,
        processedTime,
        generationTime,
        attachmentsDisplay,
        invoiceDownloadUrl,
        checklistItems,
      ];
}
