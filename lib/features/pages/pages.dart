// presentation/pages/pages.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_bloc.dart';
import 'package:travel_crm/features/presentation/login/bloc/login_state.dart';
import 'package:travel_crm/features/presentation/login/view/login_screen.dart';
import 'package:travel_crm/features/presentation/inquiry_form/inquiry_view.dart';
import 'package:travel_crm/features/presentation/air_ticket/air_ticket_view.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/vendor_inquiry_row.dart';
import 'package:travel_crm/features/presentation/inquiry_management/view/inquiry_management_screen.dart';
import 'package:travel_crm/features/presentation/inquiry_management/view/vendor_list_view.dart';

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
          if (state.userRole == 'admin') {
            context.go('/admin');
            return;
          }
          context.go('/');
        },
        child: const LoginScreen(),
      ),
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
    final row = extra is VendorInquiryRow ? extra : null;
    return InquiryManagementScreen(vendorRow: row);
  }
}

class ClientLeadsPage extends StatelessWidget {
  const ClientLeadsPage({super.key});

  @override
  Widget build(BuildContext context) => const InquiryView();
}

class InquiryViewPage extends StatelessWidget {
  const InquiryViewPage({super.key});

  @override
  Widget build(BuildContext context) => const InquiryView();
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

class AirTicketViewPage extends StatelessWidget {
  const AirTicketViewPage({super.key, this.initialInquiryState});

  /// Inquiry form data passed when navigating from inquiry form (e.g. after selecting Flight).
  final Object? initialInquiryState;

  @override
  Widget build(BuildContext context) =>
      AirTicketView(initialInquiryState: initialInquiryState);
}

Widget _page(String title) {
  return Center(
    child: Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
  );
}
