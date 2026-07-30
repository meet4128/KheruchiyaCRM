import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/theme/app_colors.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/data/repositories/payments_repository.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/account_panel/bloc/account_navigation_bloc.dart';
import 'package:travel_crm/features/presentation/account_panel/bloc/account_navigation_event.dart';

import '../bloc/unverified_payments_bloc.dart';
import '../bloc/unverified_payments_event.dart';
import '../bloc/unverified_payments_state.dart';
import '../widgets/unverified_payments_table.dart';

/// Accounting → Unverified → Payments. Lists sales-submitted payment plans
/// (`verified: false`) via `GET /payments/unverified`. Provides its own
/// [UnverifiedPaymentsBloc] and mirrors the search-first table layout used
/// across the app.
class UnverifiedPaymentsScreen extends StatelessWidget {
  const UnverifiedPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UnverifiedPaymentsBloc(sl<PaymentsRepository>())
        ..add(const UnverifiedPaymentsStarted()),
      child: const _UnverifiedPaymentsBody(),
    );
  }
}

class _UnverifiedPaymentsBody extends StatelessWidget {
  const _UnverifiedPaymentsBody();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    // Keep the sidebar "New" badge in sync with the loaded item count.
    return BlocListener<UnverifiedPaymentsBloc, UnverifiedPaymentsState>(
      listenWhen: (prev, curr) =>
          prev.totalItems != curr.totalItems ||
          prev.status != curr.status,
      listener: (context, state) {
        if (state.status == UnverifiedPaymentsStatus.success) {
          context
              .read<AccountNavigationBloc>()
              .add(AccountUnverifiedCountUpdated(state.totalItems));
        }
      },
      child: Container(
        color: colors.backgroundDark,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeaderRow(),
            SizedBox(height: 20),
            _CountRow(),
            SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: UnverifiedPaymentsTable(),
              ),
            ),
            SizedBox(height: 12),
            _PaginationBar(),
          ],
        ),
      ),
    );
  }
}

/// Breadcrumb (Accounting › Unverified › Payments) + search box.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Accounting',
                  style: textStyles.bodyMedium
                      .copyWith(color: colors.textSecondary)),
              _sep(colors),
              Text('Unverified',
                  style: textStyles.bodyMedium
                      .copyWith(color: colors.textSecondary)),
              _sep(colors),
              Text(
                'Payments',
                style: textStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const SizedBox(width: 320, child: _SearchBox()),
      ],
    );
  }

  Widget _sep(AppColors colors) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(Icons.chevron_right, size: 16, color: colors.textTertiary),
      );
}

class _SearchBox extends StatefulWidget {
  const _SearchBox();

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return TextField(
      controller: _controller,
      style: TextStyle(color: colors.textPrimary),
      onChanged: (value) => context
          .read<UnverifiedPaymentsBloc>()
          .add(UnverifiedPaymentsSearchChanged(value)),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search',
        hintStyle: TextStyle(color: colors.textTertiary),
        prefixIcon: Icon(Icons.search, size: 18, color: colors.textTertiary),
        filled: true,
        fillColor: colors.backgroundMedium,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colors.borderPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colors.borderPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: colors.secondary),
        ),
      ),
    );
  }
}

/// "Showing 1 - 15 of 40 items" + refresh.
class _CountRow extends StatelessWidget {
  const _CountRow();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    return BlocBuilder<UnverifiedPaymentsBloc, UnverifiedPaymentsState>(
      builder: (context, state) {
        final count = state.rows.length;
        final start = count == 0 ? 0 : ((state.page - 1) * 15) + 1;
        final end = count == 0 ? 0 : start + count - 1;
        // When searching, reflect the filtered subset of the loaded page.
        final label = state.isSearching
            ? 'Showing ${state.visibleRows.length} of $count on this page'
            : 'Showing $start - $end of ${state.totalItems} items';
        return Row(
          children: [
            Text(
              label,
              style: textStyles.bodyMedium.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => context
                  .read<UnverifiedPaymentsBloc>()
                  .add(const UnverifiedPaymentsRefreshed()),
              icon: Icon(Icons.refresh, size: 18, color: colors.secondary),
            ),
          ],
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);
    return BlocBuilder<UnverifiedPaymentsBloc, UnverifiedPaymentsState>(
      builder: (context, state) {
        if (state.totalPages <= 1) return const SizedBox.shrink();
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: state.hasPrevPage && !state.isLoading
                  ? () => context
                      .read<UnverifiedPaymentsBloc>()
                      .add(UnverifiedPaymentsPageRequested(state.page - 1))
                  : null,
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('Prev'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Page ${state.page} of ${state.totalPages}',
                style:
                    textStyles.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ),
            TextButton.icon(
              onPressed: state.hasNextPage && !state.isLoading
                  ? () => context
                      .read<UnverifiedPaymentsBloc>()
                      .add(UnverifiedPaymentsPageRequested(state.page + 1))
                  : null,
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text('Next'),
            ),
          ],
        );
      },
    );
  }
}
