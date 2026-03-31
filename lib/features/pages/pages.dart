// presentation/pages/pages.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
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
