import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_event.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_state.dart';
import 'package:travel_crm/features/presentation/inquiry_form/inquiry_form_screen.dart';

class InquiryView extends StatelessWidget {
  const InquiryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<InquiryBloc>(),
      child: const _InquiryScreen(),
    );
  }
}

class _InquiryScreen extends StatelessWidget {
  const _InquiryScreen();

  @override
  Widget build(BuildContext context) {
    return BlocListener<InquiryBloc, InquiryState>(
      listenWhen: (previous, current) {
        if (current.pendingNavigateToAirTicket && !previous.pendingNavigateToAirTicket) {
          return true;
        }
        if (current.pendingNavigateToHotelBooking &&
            !previous.pendingNavigateToHotelBooking) {
          return true;
        }
        return previous.status != current.status &&
            (current.status == InquirySubmissionStatus.success ||
                current.status == InquirySubmissionStatus.failure);
      },
      listener: (context, state) {
        final colors = AppTheme.colors(context);
        if (state.pendingNavigateToAirTicket) {
          context.read<InquiryBloc>().add(ClearPendingNavigateToAirTicket());
          context.push(PathConstant.airTicket, extra: state);
          return;
        }
        if (state.pendingNavigateToHotelBooking) {
          context.read<InquiryBloc>().add(ClearPendingNavigateToHotelBooking());
          context.push(PathConstant.hotelBooking, extra: state);
          return;
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colors.success,
            ),
          );
          context.read<InquiryBloc>().add(const ResetInquiryForm());
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.gradientBackground,
          ),
          child: const InquiryFormScreen(),
        ),
      ),
    );
  }
}
