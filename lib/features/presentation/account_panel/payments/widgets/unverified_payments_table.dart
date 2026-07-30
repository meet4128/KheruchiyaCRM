import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../bloc/unverified_payments_bloc.dart';
import '../bloc/unverified_payments_event.dart';
import '../bloc/unverified_payments_state.dart';
import '../models/payment_installment_row_ui.dart';
import '../models/unverified_payment_row_ui.dart';
import 'payment_proof_viewer.dart';
import 'verify_payment_dialog.dart';

/// Results area for the Unverified Payments screen. Renders one of four states:
/// loading, error, empty, or the data table.
///
/// Each row is expandable (chevron / tap): the expanded panel lists every
/// installment with its own amount, mode, date, status and proof so the
/// accountant can verify a split payment part by part.
class UnverifiedPaymentsTable extends StatelessWidget {
  const UnverifiedPaymentsTable({super.key});

  // Column labels (the leading chevron column has no label). Kept aligned with
  // [_columnWidths] below (index 0 = chevron).
  static const _columns = <String>[
    'Inquiry Number',
    'Amount',
    'Paid on',
    'Credit Account',
    'Contact',
    'Assigned to',
  ];

  /// Fixed widths so the header and every (expandable) row stay aligned inside
  /// the horizontal scroll. Index 0 is the expand chevron. Verification is done
  /// per-installment inside the expanded breakdown, so there is no row-level
  /// Actions column.
  static const _columnWidths = <double>[44, 140, 110, 140, 150, 220, 160];

  static double get _tableWidth =>
      _columnWidths.fold<double>(0, (sum, w) => sum + w);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnverifiedPaymentsBloc, UnverifiedPaymentsState>(
      builder: (context, state) {
        switch (state.status) {
          case UnverifiedPaymentsStatus.loading:
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: Center(child: CircularProgressIndicator()),
            );
          case UnverifiedPaymentsStatus.failure:
            return _ErrorState(
              message: state.errorMessage ?? 'Something went wrong.',
            );
          case UnverifiedPaymentsStatus.success:
            final rows = state.visibleRows;
            if (rows.isEmpty) {
              return state.isSearching
                  ? const _Placeholder(
                      icon: Icons.search_off,
                      title: 'No matches',
                      message: 'No payments on this page match your search.',
                    )
                  : const _Placeholder(
                      icon: Icons.inbox_outlined,
                      title: 'No unverified payments',
                      message:
                          'Sales-submitted payment plans awaiting verification '
                          'will appear here.',
                    );
            }
            return _DataTableView(rows: rows, expandedIds: state.expandedIds);
        }
      },
    );
  }
}

class _DataTableView extends StatelessWidget {
  const _DataTableView({required this.rows, required this.expandedIds});

  final List<UnverifiedPaymentRowUi> rows;
  final Set<String> expandedIds;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderPrimary),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: UnverifiedPaymentsTable._tableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderRow(),
              for (final row in rows)
                _ExpandableRow(
                  row: row,
                  expanded: expandedIds.contains(row.paymentPlanId),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A cell sized to its column so header and rows line up.
class _Cell extends StatelessWidget {
  const _Cell({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: UnverifiedPaymentsTable._columnWidths[index],
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: child,
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final style = textStyles.labelMedium.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Container(
      color: colors.backgroundLight,
      constraints: const BoxConstraints(minHeight: 48),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          const _Cell(index: 0, child: SizedBox.shrink()),
          for (var i = 0; i < UnverifiedPaymentsTable._columns.length; i++)
            _Cell(
              index: i + 1,
              child: Text(UnverifiedPaymentsTable._columns[i], style: style),
            ),
        ],
      ),
    );
  }
}

class _ExpandableRow extends StatelessWidget {
  const _ExpandableRow({required this.row, required this.expanded});

  final UnverifiedPaymentRowUi row;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => context
              .read<UnverifiedPaymentsBloc>()
              .add(UnverifiedPaymentExpansionToggled(row.paymentPlanId)),
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.borderPrimary, width: 0.5),
              ),
              color: expanded
                  ? colors.backgroundLight.withValues(alpha: 0.4)
                  : null,
            ),
            child: Row(
              children: [
                _Cell(
                  index: 0,
                  child: AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                _Cell(index: 1, child: _InquiryCell(row: row)),
                _Cell(
                  index: 2,
                  child: Text(
                    row.amount,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ),
                _Cell(index: 3, child: _PaidOnCell(row: row)),
                _Cell(index: 4, child: _CreditAccountCell(row: row)),
                _Cell(index: 5, child: _ContactCell(row: row)),
                _Cell(index: 6, child: _AssignedToCell(name: row.assignedTo)),
              ],
            ),
          ),
        ),
        if (expanded) _InstallmentPanel(row: row),
      ],
    );
  }
}

class _InquiryCell extends StatelessWidget {
  const _InquiryCell({required this.row});

  final UnverifiedPaymentRowUi row;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final count = row.installmentCount;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(row.inquiryNumber, style: TextStyle(color: colors.textPrimary)),
        if (count > 0)
          Text(
            count == 1 ? '1 installment' : '$count installments',
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
      ],
    );
  }
}

/// Full-width breakdown shown under an expanded row — one tile per installment.
class _InstallmentPanel extends StatelessWidget {
  const _InstallmentPanel({required this.row});

  final UnverifiedPaymentRowUi row;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(44, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.backgroundDark,
        border: Border(
          bottom: BorderSide(color: colors.borderPrimary, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment breakdown',
            style: textStyles.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          if (row.installments.isEmpty)
            Text(
              'No installment details available.',
              style: textStyles.bodySmall.copyWith(color: colors.textTertiary),
            )
          else
            for (final installment in row.installments)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _InstallmentTile(
                  installment: installment,
                  inquiryId: row.inquiryId,
                  assignedTo: row.assignedTo,
                ),
              ),
        ],
      ),
    );
  }
}

class _InstallmentTile extends StatelessWidget {
  const _InstallmentTile({
    required this.installment,
    required this.inquiryId,
    required this.assignedTo,
  });

  final PaymentInstallmentRowUi installment;
  final String inquiryId;
  final String assignedTo;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.backgroundMedium,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              installment.label,
              style: textStyles.bodySmall
                  .copyWith(color: colors.textSecondary),
            ),
          ),
          Text(
            installment.amount,
            style: textStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          _Chip(label: installment.mode, icon: Icons.account_balance_wallet_outlined),
          _MetaText(label: 'Due', value: installment.dueOn),
          _MetaText(label: 'Received', value: installment.receivedOn),
          _StatusChip(status: installment.status),
          if (installment.hasProof)
            _ProofLink(url: installment.paymentProofUrl),
          _InstallmentVerifyAction(
            installment: installment,
            inquiryId: inquiryId,
            assignedTo: assignedTo,
          ),
        ],
      ),
    );
  }
}

/// Per-installment verify control shown at the end of each installment tile:
///  - already VERIFIED → a green "Verified" pill.
///  - received & not verified → a "Verify" button that opens the confirmation
///    dialog (same flow as the plan-level verify).
///  - not yet received → nothing (no payment to verify).
class _InstallmentVerifyAction extends StatelessWidget {
  const _InstallmentVerifyAction({
    required this.installment,
    required this.inquiryId,
    required this.assignedTo,
  });

  final PaymentInstallmentRowUi installment;
  final String inquiryId;
  final String assignedTo;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    if (installment.isVerified) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: colors.success, size: 16),
          const SizedBox(width: 6),
          Text(
            'Verified',
            style: textStyles.bodySmall.copyWith(
              color: colors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (!installment.canVerify) return const SizedBox.shrink();

    return OutlinedButton.icon(
      onPressed: () => showVerifyInstallmentDialog(
        context,
        inquiryId: inquiryId,
        assignedTo: assignedTo,
        installment: installment,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.secondary,
        side: BorderSide(color: colors.secondary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.check_circle_outline, size: 16),
      label: const Text('Verify'),
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return RichText(
      text: TextSpan(
        style: TextStyle(color: colors.textSecondary, fontSize: 12),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: TextStyle(color: colors.textPrimary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: colors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: colors.textPrimary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final lower = status.toLowerCase();
    final Color color;
    if (lower == 'pending') {
      color = colors.warning;
    } else if (lower == 'late') {
      color = colors.error;
    } else {
      color = colors.success;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProofLink extends StatelessWidget {
  const _ProofLink({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return InkWell(
      onTap: () => showPaymentProofViewer(context, url: url),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 14, color: colors.secondary),
          const SizedBox(width: 2),
          Text(
            'View proof',
            style: TextStyle(
              color: colors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaidOnCell extends StatelessWidget {
  const _PaidOnCell({required this.row});

  final UnverifiedPaymentRowUi row;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(row.paidOn, style: TextStyle(color: colors.textPrimary)),
        if (row.paidOnSub.isNotEmpty)
          Text(
            row.paidOnSub,
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
      ],
    );
  }
}

class _CreditAccountCell extends StatelessWidget {
  const _CreditAccountCell({required this.row});

  final UnverifiedPaymentRowUi row;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            row.creditAccount,
            style: TextStyle(color: colors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (row.hasProof) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: () =>
                showPaymentProofViewer(context, url: row.paymentProofUrl),
            child: Icon(Icons.receipt_long_outlined,
                size: 14, color: colors.secondary),
          ),
        ],
      ],
    );
  }
}

class _ContactCell extends StatelessWidget {
  const _ContactCell({required this.row});

  final UnverifiedPaymentRowUi row;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                row.contactName,
                style: TextStyle(color: colors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (row.contactRoute.isNotEmpty) ...[
              Text('  •  ', style: TextStyle(color: colors.textTertiary)),
              Flexible(
                child: Text(
                  row.contactRoute,
                  style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        if (row.contactPhone.isNotEmpty)
          Text(
            row.contactPhone,
            style: TextStyle(color: colors.textTertiary, fontSize: 11),
          ),
      ],
    );
  }
}

class _AssignedToCell extends StatelessWidget {
  const _AssignedToCell({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final initials = _initials(name);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: colors.secondary.withValues(alpha: 0.25),
          child: Text(
            initials,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            name,
            style: TextStyle(color: colors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty || parts.first == '—') return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: colors.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.textTertiary),
          const SizedBox(height: 12),
          Text(title,
              style: textStyles.heading5.copyWith(color: colors.textPrimary)),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: colors.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40, color: colors.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textStyles.bodyMedium.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context
                .read<UnverifiedPaymentsBloc>()
                .add(const UnverifiedPaymentsRefreshed()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
