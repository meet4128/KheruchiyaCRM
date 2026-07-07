import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/theme/app_theme.dart';

import '../bloc/manage_amendment_bloc.dart';
import '../bloc/manage_amendment_event.dart';
import '../bloc/manage_amendment_state.dart';
import '../models/amendment_row_ui.dart';

/// Results area for the Manage Amendment screen. Renders one of five states:
/// blank (no search yet), loading, error, empty results, or the data table.
class AmendmentResultsTable extends StatelessWidget {
  const AmendmentResultsTable({super.key});

  static const _columns = <String>[
    'Generated Time',
    'Departure Date',
    'Next Travel Date',
    'Amendment ID',
    'Booking ID',
    'Status',
    'Booked By',
    'Type',
    'Role',
    'Booking Channel',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageAmendmentBloc, ManageAmendmentState>(
      builder: (context, state) {
        switch (state.status) {
          case ManageAmendmentStatus.initial:
            return _Placeholder(
              icon: Icons.search,
              title: 'Search to see amendments',
              message: 'Use the filters above and press Search to list amendments.',
            );
          case ManageAmendmentStatus.loading:
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            );
          case ManageAmendmentStatus.failure:
            return _ErrorState(message: state.errorMessage ?? 'Something went wrong.');
          case ManageAmendmentStatus.success:
            final rows = state.visibleRows;
            if (rows.isEmpty) {
              return _Placeholder(
                icon: Icons.inbox_outlined,
                title: 'No amendments found',
                message: 'No results match the selected filters.',
              );
            }
            return _DataTableView(rows: rows);
        }
      },
    );
  }
}

class _DataTableView extends StatelessWidget {
  const _DataTableView({required this.rows});

  final List<AmendmentRowUi> rows;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundMedium,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.borderPrimary),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(colors.backgroundLight),
          headingTextStyle: textStyles.labelMedium.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          dataTextStyle: textStyles.bodySmall.copyWith(color: colors.textPrimary),
          dividerThickness: 0.5,
          columns: [
            for (final c in AmendmentResultsTable._columns) DataColumn(label: Text(c)),
          ],
          rows: [
            for (final row in rows)
              DataRow(
                cells: [
                  DataCell(Text(row.generatedTime)),
                  DataCell(Text(row.departureDate)),
                  DataCell(Text(row.nextTravelDate)),
                  DataCell(Text(row.amendmentId)),
                  DataCell(Text(row.bookingId)),
                  DataCell(_StatusPill(label: row.statusLabel, status: row.status)),
                  DataCell(Text(row.bookedBy)),
                  DataCell(Text(row.typeLabel)),
                  DataCell(Text(row.role)),
                  DataCell(Text(row.bookingChannel)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.status});

  final String label;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final color = _colorFor(status, colors);
    return Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
    );
  }

  Color _colorFor(String? status, AppColors colors) {
    switch (status) {
      case 'success':
        return colors.success;
      case 'in_progress':
        return colors.info;
      case 'pending':
      case 'pending_with_supplier':
        return colors.warning;
      default:
        return colors.textSecondary;
    }
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
          Text(title, style: textStyles.heading5.copyWith(color: colors.textPrimary)),
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
                .read<ManageAmendmentBloc>()
                .add(const AmendmentSearchRefreshed()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
