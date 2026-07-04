import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_bloc.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_event.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_company_details_bloc.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_company_details_event.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_company_details_state.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_bloc.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_event.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_state.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/vendor_company_details_form_screen.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/widgets/vendor_submit_success_dialog.dart';

/// Vendor Company Details View (Step 2) — BLoC provider wrapper + side effects.
/// Receives the Step 1 [VendorInquiryState] snapshot via `extra`.
class VendorCompanyDetailsView extends StatelessWidget {
  const VendorCompanyDetailsView({super.key, this.initialVendorState});

  final Object? initialVendorState;

  @override
  Widget build(BuildContext context) {
    final snapshot = initialVendorState is VendorInquiryState
        ? initialVendorState as VendorInquiryState
        : null;
    return BlocProvider(
      create: (_) => VendorCompanyDetailsBloc(),
      child: _VendorCompanyDetailsScreen(inquirySnapshot: snapshot),
    );
  }
}

void _navigateBackToVendorList(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.read<NavigationBloc>().add(ChangePageEvent(NavPage.vendorList));
  context.go(PathConstant.vendorInquiry);
}

class _VendorCompanyDetailsScreen extends StatelessWidget {
  const _VendorCompanyDetailsScreen({this.inquirySnapshot});

  final VendorInquiryState? inquirySnapshot;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return BlocListener<VendorCompanyDetailsBloc, VendorCompanyDetailsState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == VendorCompanySubmissionStatus.success ||
              current.status == VendorCompanySubmissionStatus.failure),
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);

        if (state.status == VendorCompanySubmissionStatus.success) {
          showVendorSubmitSuccessDialog(
            context,
            message: state.successMessage ??
                StringConstant.vendorSubmittedSuccessfully,
            onAcknowledge: () {
              context
                  .read<VendorCompanyDetailsBloc>()
                  .add(const ResetVendorCompanyDetailsForm());
              // Clear Step 1 too so the next vendor starts fresh.
              sl<VendorInquiryBloc>().add(const ResetVendorInquiryForm());
              context
                  .read<NavigationBloc>()
                  .add(ChangePageEvent(NavPage.vendorList));
              context.go(PathConstant.vendorInquiry);
            },
          );
        }

        if (state.status == VendorCompanySubmissionStatus.failure) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? StringConstant.vendorSubmissionFailed,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colors.error,
            ),
          );
        }
      },
      child: PopScope(
        canPop: context.canPop(),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _navigateBackToVendorList(context);
        },
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: AppTheme.gradientBackground),
            child: const VendorCompanyDetailsFormScreen(),
          ),
        ),
      ),
    );
  }
}
