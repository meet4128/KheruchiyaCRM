import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/app_multi_pill_selector.dart';
import '../models/transfer_option.dart';

/// Multi-select pill selector for transfer options.
class TransfersSelector extends StatelessWidget {
  const TransfersSelector({
    super.key,
    required this.selectedTransfers,
    required this.onToggle,
  });

  final Set<TransferOption> selectedTransfers;
  final ValueChanged<TransferOption> onToggle;

  @override
  Widget build(BuildContext context) {
    return AppMultiPillSelector<TransferOption>(
      items: TransferOption.values,
      itemLabel: (transfer) => transfer.label,
      selectedValues: selectedTransfers,
      onToggle: onToggle,
      showCheckmark: true,
      spacing: 12,
    );
  }
}
