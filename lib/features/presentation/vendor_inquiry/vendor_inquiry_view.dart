import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_bloc.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_event.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_state.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/vendor_inquiry_form_screen.dart';

/// Vendor Inquiry View — BLoC provider wrapper + side-effect listener.
/// Renders the Step 1 form; when Step 1 is valid and NEXT is pressed, routes to
/// Step 2 (Company Details), passing the Step 1 snapshot as `extra`.
class VendorInquiryView extends StatelessWidget {
  const VendorInquiryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<VendorInquiryBloc>(),
      child: const _VendorInquiryScreen(),
    );
  }
}

class _VendorInquiryScreen extends StatelessWidget {
  const _VendorInquiryScreen();

  @override
  Widget build(BuildContext context) {
    return BlocListener<VendorInquiryBloc, VendorInquiryState>(
      listenWhen: (previous, current) =>
          current.pendingNavigateToStep2 && !previous.pendingNavigateToStep2,
      listener: (context, state) {
        context.read<VendorInquiryBloc>().add(const ClearPendingNavigateToStep2());
        context.push(PathConstant.vendorCompanyDetails, extra: state);
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.gradientBackground,
          ),
          child: const VendorInquiryFormScreen(),
        ),
      ),
    );
  }
}
