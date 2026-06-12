import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/air_ticket/air_ticket_form_screen.dart';
import 'package:travel_crm/features/presentation/air_ticket/widgets/air_ticket_submit_success_dialog.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/air_ticket_bloc.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/air_ticket_event.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/air_ticket_state.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_event.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_state.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_bloc.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_management_bloc.dart';

/// Air Ticket View - BLoC Provider Wrapper
/// Provides AirTicketBloc to the widget tree and handles side effects
class AirTicketView extends StatelessWidget {
  const AirTicketView({super.key, this.initialInquiryState});

  /// Inquiry form snapshot passed from previous screen when user selected Flight.
  final Object? initialInquiryState;

  @override
  Widget build(BuildContext context) {
    final inquirySnapshot = initialInquiryState is InquiryState
        ? initialInquiryState as InquiryState
        : null;
    return BlocProvider(
      create: (_) => AirTicketBloc(inquiryRepository: sl<InquiryRepository>()),
      child: _AirTicketScreen(inquirySnapshot: inquirySnapshot),
    );
  }
}

void _navigateBackToInquiry(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.read<NavigationBloc>().add(ChangePageEvent(NavPage.inquiry));
  context.go(PathConstant.inquiryView);
}

/// Internal screen widget with BLoC listener
class _AirTicketScreen extends StatelessWidget {
  const _AirTicketScreen({this.inquirySnapshot});

  final InquiryState? inquirySnapshot;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return BlocListener<AirTicketBloc, AirTicketState>(
      listenWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus &&
          (current.submissionStatus == AirTicketSubmissionStatus.success ||
              current.submissionStatus == AirTicketSubmissionStatus.failure),
      listener: (context, state) {
        final colors = AppTheme.colors(context);
        final messenger = ScaffoldMessenger.of(context);

        if (state.submissionStatus == AirTicketSubmissionStatus.success) {
          final message = state.successMessage ?? StringConstant.airTicketSubmittedSuccessfully;
          showAirTicketSubmitSuccessDialog(
            context,
            message: message,
            onAcknowledge: () {
              context.read<AirTicketBloc>().add(const ResetAirTicketForm());
              sl<InquiryBloc>().add(const ResetInquiryForm());
              // Shared singleton: refetch list so New Inquiry / vendor table shows the new inquiry.
              sl<InquiryManagementBloc>().add(InquiryManagementRefreshed());
              // Same as side menu: keep NavigationBloc in sync (router listener skips go() from sub-routes).
              context.read<NavigationBloc>().add(ChangePageEvent(NavPage.inquiryManagement));
              context.go(PathConstant.inquiryManagement);
            },
          );
        }

        if (state.submissionStatus == AirTicketSubmissionStatus.failure) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.submissionError ?? 'Submission failed'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colors.error,
            ),
          );
        }
      },
      child: PopScope(
        canPop: context.canPop(),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _navigateBackToInquiry(context);
        },
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.inputBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _navigateBackToInquiry(context),
                  icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                  tooltip: StringConstant.messagesBack,
                ),
                Expanded(
                  child: AirTicketFormScreen(inquirySnapshot: inquirySnapshot),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





