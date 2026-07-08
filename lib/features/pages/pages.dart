// presentation/pages/pages.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:travel_crm/features/presentation/forgot_password/view/forgot_password_screen.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_bloc.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_state.dart';
import 'package:travel_crm/features/presentation/login/view/login_screen.dart';
import 'package:travel_crm/features/presentation/reset_password/bloc/reset_password_bloc.dart';
import 'package:travel_crm/features/presentation/reset_password/view/reset_password_screen.dart';
import 'package:travel_crm/features/presentation/set_password/bloc/set_password_bloc.dart';
import 'package:travel_crm/features/presentation/set_password/bloc/set_password_event.dart';
import 'package:travel_crm/features/presentation/set_password/view/set_password_screen.dart';
import 'package:travel_crm/features/presentation/inquiry_form/inquiry_view.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/vendor_inquiry_view.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/vendor_company_details_view.dart';
import 'package:travel_crm/features/presentation/air_ticket/air_ticket_view.dart';
import 'package:travel_crm/features/presentation/hotel_booking/hotel_booking_view.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/vendor_inquiry_row.dart';
import 'package:travel_crm/features/presentation/inquiry_management/view/inquiry_management_screen.dart';
import 'package:travel_crm/features/presentation/inquiry_management/view/vendor_list_view.dart';
import 'package:travel_crm/features/presentation/calendar/view/calendar_screen.dart';
import 'package:travel_crm/features/presentation/manage_amendment/view/manage_amendment_screen.dart';
import 'package:travel_crm/features/presentation/purchase_team/models/messages_route_args.dart';
import 'package:travel_crm/features/presentation/purchase_team/view/messages_screen.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) => _page(StringConstant.dashboard);
}

/// Operations Portal login — route-level [BlocProvider]; shell routes use [DashboardShell] only.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(authRepository: sl()),
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == LoginStatus.success,
        listener: (context, state) {
          if (!context.mounted) return;
          context.go(landingPathForRole(state.userRole));
        },
        child: const LoginScreen(),
      ),
    );
  }
}

/// Public route — `/forgot-password`. Provides the [ForgotPasswordBloc] for
/// its subtree so the screen widget stays stateless.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordBloc>(
      create: (_) => sl<ForgotPasswordBloc>(),
      child: const ForgotPasswordScreen(),
    );
  }
}

/// Public route — `/set-password?token=…`. The [token] is parsed from the
/// query string in the [GoRoute] `pageBuilder` and forwarded to the bloc via
/// [SetPasswordTokenReceived], which kicks off `validateToken(purpose: invite)`.
class SetPasswordPage extends StatelessWidget {
  const SetPasswordPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SetPasswordBloc>(
      create: (_) =>
          sl<SetPasswordBloc>()..add(SetPasswordTokenReceived(token)),
      child: const SetPasswordScreen(),
    );
  }
}

/// Public route — `/reset-password?token=…`. Same wiring as
/// [SetPasswordPage], but provides a [ResetPasswordBloc] (subclass of
/// `SetPasswordBloc`) so the shared screen widget keeps reading
/// `SetPasswordBloc` from context.
class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SetPasswordBloc>(
      create: (_) =>
          sl<ResetPasswordBloc>()..add(SetPasswordTokenReceived(token)),
      child: const ResetPasswordScreen(),
    );
  }
}

/// The whole Inquiry Management Module

class InquiryManagementPage extends StatelessWidget {
  const InquiryManagementPage({super.key});

  @override
  Widget build(BuildContext context) => const VendorListView();
}

class InquiryManagementDetailPage extends StatelessWidget {
  const InquiryManagementDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    // The vendor list passes the full row; the calendar follow-up flow passes
    // just the inquiry id (String) so the detail bloc bootstraps from the id.
    final row = extra is VendorInquiryRow ? extra : null;
    final inquiryId = extra is String ? extra : null;
    return InquiryManagementScreen(vendorRow: row, inquiryId: inquiryId);
  }
}

class ClientLeadsPage extends StatelessWidget {
  const ClientLeadsPage({super.key});

  @override
  Widget build(BuildContext context) => const InquiryView();
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key, this.routeArgs});

  final MessagesRouteArgs? routeArgs;

  @override
  Widget build(BuildContext context) => MessagesScreen(routeArgs: routeArgs);
}

class InquiryViewPage extends StatelessWidget {
  const InquiryViewPage({super.key});

  @override
  Widget build(BuildContext context) => const InquiryView();
}

/// Vendor Leads — Step 1. Mirrors [InquiryViewPage]; the NEXT button in the
/// form routes to [VendorCompanyDetailsPage] (Step 2).
class VendorInquiryPage extends StatelessWidget {
  const VendorInquiryPage({super.key});

  @override
  Widget build(BuildContext context) => const VendorInquiryView();
}

/// Vendor Leads — Step 2 (Company Details). Placeholder until the design is
/// provided; receives the Step 1 snapshot via `state.extra`.
class VendorCompanyDetailsPage extends StatelessWidget {
  const VendorCompanyDetailsPage({super.key, this.initialVendorState});

  /// Step 1 vendor form data passed when navigating from the vendor form.
  final Object? initialVendorState;

  @override
  Widget build(BuildContext context) =>
      VendorCompanyDetailsView(initialVendorState: initialVendorState);
}

class ProjectJobsPage extends StatelessWidget {
  const ProjectJobsPage({super.key});

  @override
  Widget build(BuildContext context) => _page(StringConstant.projectJobs);
}

class InvoicesPage extends StatelessWidget {
  const InvoicesPage({super.key});

  @override
  Widget build(BuildContext context) => _page(StringConstant.invoices);
}

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) => _page(StringConstant.payments);
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) => _page(StringConstant.inventory);
}

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) => _page(StringConstant.team);
}

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) => _page(StringConstant.reminders);
}

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) => _page(StringConstant.analysis);
}

class ManageAmendmentPage extends StatelessWidget {
  const ManageAmendmentPage({super.key});

  @override
  Widget build(BuildContext context) => const ManageAmendmentScreen();
}

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final focusDate = extra is DateTime ? extra : null;
    return CalendarScreen(focusDate: focusDate);
  }
}

class AddFollowUpPage extends StatelessWidget {
  const AddFollowUpPage({super.key});

  @override
  Widget build(BuildContext context) => _page(PathConstant.addFollowUpConstant);
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => _page(PathConstant.settingsConstant);
}

class AirTicketViewPage extends StatelessWidget {
  const AirTicketViewPage({super.key, this.initialInquiryState});

  /// Inquiry form data passed when navigating from inquiry form (e.g. after selecting Flight).
  final Object? initialInquiryState;

  @override
  Widget build(BuildContext context) =>
      AirTicketView(initialInquiryState: initialInquiryState);
}

class HotelBookingViewPage extends StatelessWidget {
  const HotelBookingViewPage({super.key, this.initialInquiryState});

  /// Inquiry form data passed when navigating from inquiry form (e.g. after selecting Hotel).
  final Object? initialInquiryState;

  @override
  Widget build(BuildContext context) =>
      HotelBookingView(initialInquiryState: initialInquiryState);
}

Widget _page(String title) {
  return Center(
    child: Text(
      title,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    ),
  );
}
