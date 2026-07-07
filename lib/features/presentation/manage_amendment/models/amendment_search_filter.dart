import 'package:equatable/equatable.dart';

import 'amendment_filter_options.dart';

/// The server-backed filter selection captured by the filter form and handed to
/// the BLoC on Search. Only fields the `/amendments/search` API supports are
/// modelled here (see `AmendmentSearchQuery`).
class AmendmentSearchFilter extends Equatable {
  const AmendmentSearchFilter({
    this.type,
    this.status,
    this.processedFrom,
    this.processedTo,
  });

  final AmendmentTypeOption? type;
  final AmendmentStatusOption? status;
  final DateTime? processedFrom;
  final DateTime? processedTo;

  AmendmentSearchFilter copyWith({
    AmendmentTypeOption? type,
    AmendmentStatusOption? status,
    DateTime? processedFrom,
    DateTime? processedTo,
    bool clearType = false,
    bool clearStatus = false,
    bool clearProcessedFrom = false,
    bool clearProcessedTo = false,
  }) {
    return AmendmentSearchFilter(
      type: clearType ? null : (type ?? this.type),
      status: clearStatus ? null : (status ?? this.status),
      processedFrom: clearProcessedFrom ? null : (processedFrom ?? this.processedFrom),
      processedTo: clearProcessedTo ? null : (processedTo ?? this.processedTo),
    );
  }

  @override
  List<Object?> get props => [type, status, processedFrom, processedTo];
}
