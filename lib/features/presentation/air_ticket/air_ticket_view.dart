import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/air_ticket_bloc.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/air_ticket_state.dart';
import 'package:travel_crm/features/presentation/air_ticket/air_ticket_form_screen.dart';

/// Air Ticket View - BLoC Provider Wrapper
/// Provides AirTicketBloc to the widget tree and handles side effects
class AirTicketView extends StatelessWidget {
  const AirTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AirTicketBloc(),
      child: const _AirTicketScreen(),
    );
  }
}

/// Internal screen widget with BLoC listener
class _AirTicketScreen extends StatelessWidget {
  const _AirTicketScreen();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AirTicketBloc, AirTicketState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == AirTicketSubmissionStatus.success ||
              current.status == AirTicketSubmissionStatus.failure),
      listener: (context, state) {
        final colors = AppTheme.colors(context);
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: colors.success,
            ),
          );
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
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.colors(context).inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.colors(context).secondary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
            ],
          ),
          child: const AirTicketFormScreen(),
        ),
      ),
    );
  }
}





