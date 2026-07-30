import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/utils/snackbar_utils.dart';
import 'package:travel_crm/data/repositories/payments_repository.dart';
import 'package:travel_crm/di/injector.dart';

import '../bloc/unverified_payments_bloc.dart';
import '../bloc/unverified_payments_event.dart';
import '../bloc/verify_payment/verify_payment_cubit.dart';
import '../bloc/verify_payment/verify_payment_state.dart';
import '../models/payment_installment_row_ui.dart';

/// Opens the "Verify payment" confirmation dialog for a single installment.
///
/// Mirrors the plan-level verify flow: the accountant reviews the instalment
/// details, ticks the confirmation checkbox and submits. On success the list is
/// refreshed (keeping the row expanded) so the now-verified installment — and
/// whether the plan left the queue — shows. [listBloc] is the caller's
/// [UnverifiedPaymentsBloc] (the dialog sits above its provider once pushed).
Future<void> showVerifyInstallmentDialog(
  BuildContext context, {
  required String inquiryId,
  required String assignedTo,
  required PaymentInstallmentRowUi installment,
}) {
  final listBloc = context.read<UnverifiedPaymentsBloc>();
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) => BlocProvider(
      create: (_) => VerifyPaymentCubit(
        repository: sl<PaymentsRepository>(),
        inquiryId: inquiryId,
        installmentId: installment.paymentId,
      ),
      child: _VerifyPaymentDialog(
        installment: installment,
        assignedTo: assignedTo,
        listBloc: listBloc,
      ),
    ),
  );
}

class _VerifyPaymentDialog extends StatelessWidget {
  const _VerifyPaymentDialog({
    required this.installment,
    required this.assignedTo,
    required this.listBloc,
  });

  final PaymentInstallmentRowUi installment;
  final String assignedTo;
  final UnverifiedPaymentsBloc listBloc;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final width = MediaQuery.of(context).size.width;

    return BlocListener<VerifyPaymentCubit, VerifyPaymentState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == VerifyPaymentStatus.success) {
          Navigator.of(context).pop();
          SnackBarUtils.showSuccess(context, 'Payment marked as verified.');
          // Refresh (keeping the row open) so the verified installment — and
          // whether the plan left the queue — shows.
          listBloc.add(
            const UnverifiedPaymentsRefreshed(preserveExpansion: true),
          );
        } else if (state.status == VerifyPaymentStatus.failure) {
          SnackBarUtils.showError(
            context,
            state.errorMessage ?? 'Could not verify the payment.',
          );
        }
      },
      child: Dialog(
        backgroundColor: colors.backgroundDark,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.borderPrimary),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogHeader(),
                  const SizedBox(height: 24),
                  _PaymentDetailsSection(
                    installment: installment,
                    assignedTo: assignedTo,
                  ),
                  const SizedBox(height: 28),
                  _ConfirmationSection(),
                  const SizedBox(height: 24),
                  _ActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Verify payment',
              style: textStyles.heading4.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close, color: colors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: colors.borderPrimary, height: 1),
      ],
    );
  }
}

class _PaymentDetailsSection extends StatelessWidget {
  const _PaymentDetailsSection({
    required this.installment,
    required this.assignedTo,
  });

  final PaymentInstallmentRowUi installment;
  final String assignedTo;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    final paidOn =
        installment.isReceived ? installment.receivedOn : installment.dueOn;

    return Column(
      children: [
        Center(
          child: Text(
            'Payment Details',
            style: textStyles.heading5.copyWith(color: colors.textPrimary),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Please review the instalment and transaction details',
            textAlign: TextAlign.center,
            style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primaryDark.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.borderPrimary),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DetailField(
                  label: 'Paid Amount (INR)',
                  value: installment.amount,
                ),
              ),
              Expanded(
                child: _DetailField(label: 'Paid On', value: paidOn),
              ),
              Expanded(
                child: _DetailField(label: 'Logged By', value: assignedTo),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 8),
        Text(
          value.isEmpty ? '—' : value,
          style: textStyles.bodyMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ConfirmationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirmation',
          style: textStyles.heading5.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Please provide your confirmation regarding this transaction',
          style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: colors.warning, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'After verification, you can not update any details regarding '
                  'this instalment and this transaction',
                  style:
                      textStyles.bodySmall.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _ConfirmCheckbox(),
      ],
    );
  }
}

class _ConfirmCheckbox extends StatelessWidget {
  const _ConfirmCheckbox();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return BlocBuilder<VerifyPaymentCubit, VerifyPaymentState>(
      buildWhen: (p, c) => p.confirmed != c.confirmed,
      builder: (context, state) {
        return InkWell(
          onTap: () =>
              context.read<VerifyPaymentCubit>().setConfirmed(!state.confirmed),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.borderPrimary),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: state.confirmed,
                  onChanged: (v) =>
                      context.read<VerifyPaymentCubit>().setConfirmed(v ?? false),
                  activeColor: colors.secondary,
                ),
                Expanded(
                  child: Text(
                    'I have verified with accounts that this is a valid transaction',
                    style: textStyles.bodyMedium
                        .copyWith(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: AppTheme.colors(context).borderPrimary, height: 1),
        const SizedBox(height: 16),
        BlocBuilder<VerifyPaymentCubit, VerifyPaymentState>(
          buildWhen: (p, c) =>
              p.confirmed != c.confirmed || p.status != c.status,
          builder: (context, state) {
            return Row(
              children: [
                Expanded(child: _VerifiedButton(state: state)),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: AppTheme.colors(context).borderPrimary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppTheme.colors(context).textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _VerifiedButton extends StatelessWidget {
  const _VerifiedButton({required this.state});

  final VerifyPaymentState state;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final enabled = state.canSubmit;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primaryMedium, colors.secondary],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: enabled
                ? () => context.read<VerifyPaymentCubit>().submit()
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isSubmitting)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'I understand, this is verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
