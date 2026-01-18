// presentation/pages/pages.dart
import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_form/inquiry_view.dart';
import 'package:travel_crm/features/presentation/air_ticket/air_ticket_view.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _page(StringConstant.dashboard);
}

class ClientLeadsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const InquiryView();
}

class InquiryViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const InquiryView();
}

class ProjectJobsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _page(StringConstant.projectJobs);
}

class InvoicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _page(StringConstant.invoices);
}

class PaymentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _page(StringConstant.payments);
}

class InventoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _page(StringConstant.inventory);
}

class TeamPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _page(StringConstant.team);
}

class RemindersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _page(StringConstant.reminders);
}

class AnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _page(StringConstant.analysis);
}

class AirTicketViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const AirTicketView();
}

Widget _page(String title) {
  return Center(
    child: Text(
      title,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    ),
  );
}
