import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_form/inquiry_view.dart';
import 'package:travel_crm/features/presentation/inquiry_management/view/vendor_list_view.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_state.dart';
import '../bloc/navigation_event.dart';

class WebContent extends StatelessWidget {
  const WebContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (_, state) {
        switch (state.currentPage) {
          case NavPage.dashboard:
            return _dashboard();
          case NavPage.clientLeads:
            return _clientLeads();
          case NavPage.inquiry:
            return _inquiry();
          case NavPage.projectJobs:
            return _projectJobs();
          case NavPage.invoices:
            return _invoices();
          case NavPage.payments:
            return _payments();
          case NavPage.inventory:
            return _inventory();
          case NavPage.team:
            return _team();
          case NavPage.reminders:
            return _reminders();
          case NavPage.analysis:
            return _analysis();
          case NavPage.inquiryManagement:
            return _inquiryManagement();
        }
      },
    );
  }

  Widget _dashboard() => _page(StringConstant.dashboard);
  Widget _inquiryManagement() => const VendorListView();
  Widget _clientLeads() => const InquiryView();
  Widget _inquiry() => const InquiryView();
  Widget _projectJobs() => _page(StringConstant.projectJobs);
  Widget _invoices() => _page(StringConstant.invoices);
  Widget _payments() => _page(StringConstant.payments);
  Widget _inventory() => _page(StringConstant.inventory);
  Widget _team() => _page(StringConstant.team);
  Widget _reminders() => _page(StringConstant.reminders);
  Widget _analysis() => _page(StringConstant.analysis);

  Widget _page(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
    );
  }
}
