import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/data/repositories/amendment_repository.dart';
import 'package:travel_crm/di/injector.dart';

import '../bloc/manage_amendment_bloc.dart';
import '../widgets/amendment_filter_form.dart';
import '../widgets/amendment_result_tabs.dart';
import '../widgets/amendment_results_table.dart';

/// Manage Amendment — search-first screen. The filter form runs
/// `/amendments/search`; results appear below and stay blank until a search
/// is submitted. Follows the feature/BLoC layout used across the app.
class ManageAmendmentScreen extends StatelessWidget {
  const ManageAmendmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManageAmendmentBloc(sl<AmendmentRepository>()),
      child: Builder(
        builder: (context) {
          final colors = AppTheme.colors(context);
          return Container(
            color: colors.backgroundDark,
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: const [
                AmendmentFilterForm(),
                SizedBox(height: 20),
                AmendmentResultTabs(),
                SizedBox(height: 12),
                AmendmentResultsTable(),
              ],
            ),
          );
        },
      ),
    );
  }
}
