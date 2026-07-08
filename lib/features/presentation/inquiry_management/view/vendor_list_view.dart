import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/data/models/inquiry/list_inquiry_item.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_bloc.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_management_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/inquiry_priority_trend.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/vendor_inquiry_row.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/follow_up/show_put_follow_up_dialog.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/inquiry_priority_trend_icon.dart';

class VendorListView extends StatefulWidget {
  const VendorListView({super.key});

  @override
  State<VendorListView> createState() => _VendorListViewState();
}

class _VendorListViewState extends State<VendorListView> {
  static const double _kDesktopMinWidth = 1620;
  static const double _kGap = 25;

  final TextEditingController _searchController = TextEditingController();

  /// Drives the persistent horizontal scrollbar under the board so the wide
  /// table can be scrolled by dragging the thumb (desktop mouse wheels only
  /// scroll vertically).
  final ScrollController _horizontalScrollController = ScrollController();
  final InquiryManagementBloc _bloc = sl<InquiryManagementBloc>();

  final List<_TableColumnData> _columns = const [
    _TableColumnData(key: 'expand', title: 'Expand', width: 100),
    _TableColumnData(key: 'inquiry', title: 'Inquiry Number', width: 152.5),
    _TableColumnData(
      key: 'generated',
      title: 'Inquiry Generated',
      width: 152.5,
    ),
    _TableColumnData(key: 'name', title: 'Name', width: 152.5),
    _TableColumnData(key: 'booking', title: 'Type of booking', width: 152.5),
    _TableColumnData(key: 'priority', title: 'Priority', width: 152.5),
    _TableColumnData(key: 'assigned', title: 'Assigned to', width: 195),
    _TableColumnData(key: 'status', title: 'Status', width: 152.5),
    _TableColumnData(key: 'set_follow', title: 'Set Follow Up', width: 120),
    _TableColumnData(key: 'new_follow', title: 'New Follow Up', width: 120),
    _TableColumnData(key: 'assign', title: 'Assign', width: 120),
  ];

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final current = _bloc.state;
    if (current is InquiryManagementLoaded &&
        current.items.isEmpty &&
        current.requestStatus == InquiryManagementStatus.idle) {
      _bloc.add(InquiryManagementInitialized(page: 1, limit: 20));
    }
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _bloc.add(InquiryManagementSearchChanged(search: _searchController.text));
  }

  /// Opens the Put Follow-up dialog seeded with the latest created inquiry.
  /// Mirrors the QnA-notes flow (same dialog + BLoC); on a saved reminder it
  /// jumps to the Calendar focused on that month and refreshes the list.
  Future<void> _onNewFollowUp(InquiryManagementLoaded state) async {
    final inquiryId = state.latestCreatedInquiry?.id?.trim() ?? '';
    if (inquiryId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No inquiry available to set a follow-up.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final focusDate = await showPutFollowUpDialog(
      context,
      inquiryId: inquiryId,
      sessionId: '',
      amendmentTypeApi: _newFollowUpAmendmentType,
      onSaved: () {
        if (!mounted) return;
        _bloc.add(InquiryManagementRefreshed());
      },
    );

    if (focusDate != null && mounted) {
      context.read<NavigationBloc>().add(ChangePageEvent(NavPage.calendar));
      context.go(PathConstant.calendar, extra: focusDate);
    }
  }

  static const String _sessionExpiredMessage =
      'Session expired or invalid. Please log in again.';

  /// Summary-chip labels that open the follow-up dialog for the latest inquiry.
  static const String _newFollowUpChipLabel = 'New Follow Up';
  static const String _setFollowUpChipLabel = 'Set Follow Up';

  /// Amendment type used when creating a follow-up straight from the list (no
  /// chat session/amendment context) — the base `booking` amendment.
  static const String _newFollowUpAmendmentType = 'booking';

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<InquiryManagementBloc, InquiryManagementState>(
        listener: (context, state) {
          if (state is! InquiryManagementLoaded) return;
          final s = state;
          if (s.requestStatus != InquiryManagementStatus.failure) return;
          final msg = s.errorMessage ?? '';
          final isAuthError =
              msg.contains('401') ||
              msg.toLowerCase().contains('session expired') ||
              msg.toLowerCase().contains('invalid');
          if (isAuthError && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_sessionExpiredMessage),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final s = state as InquiryManagementLoaded;
          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: Color(0xFF210D20)),
                ColoredBox(color: Colors.black.withValues(alpha: 0.5)),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 25,
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double contentWidth =
                            constraints.maxWidth < _kDesktopMinWidth
                            ? _kDesktopMinWidth
                            : constraints.maxWidth;

                        return Scrollbar(
                          controller: _horizontalScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            // Stop hard at both edges instead of the macOS
                            // rubber-band bounce ("back press") seen when the
                            // narrow-window table is scrolled to its ends.
                            physics: const ClampingScrollPhysics(),
                            child: SizedBox(
                              width: contentWidth,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMainBoard(s),
                                    const SizedBox(height: _kGap),
                                    _buildCollapsedSection(),
                                    // Clears the pinned horizontal scrollbar so it
                                    // never overlaps the bottom section.
                                    const SizedBox(height: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainBoard(InquiryManagementLoaded state) {
    final leadCards = _highPriorityLeadCards(state);
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // High-priority leads section — hidden entirely when none exist.
          if (leadCards.isNotEmpty) ...[
            _buildTopHeader(),
            const SizedBox(height: _kGap),
            _buildLeadCards(leadCards),
            const SizedBox(height: _kGap),
          ],
          _buildSummaryStatusRow(state),
          const SizedBox(height: _kGap),
          _buildToolbar(state),
          const SizedBox(height: _kGap),
          _buildTable(state),
          const SizedBox(height: 14),
          _buildPaginationBar(state),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'High Priority Leads',
            style: FontConstant.interMedium(color: Colors.white, fontSize: 16),
          ),
        ),
        Text(
          'Refresh',
          style: FontConstant.interMedium(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(width: 15),
        InkWell(
          onTap: () => _bloc.add(InquiryManagementRefreshed()),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF903A8C), Color(0xFF393285)],
              ),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadCards(List<_LeadCardData> leadCards) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(leadCards.length, (index) {
          final _LeadCardData card = leadCards[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == leadCards.length - 1 ? 0 : 12,
            ),
            child: SizedBox(width: 280, child: _LeadCard(card: card)),
          );
        }),
      ),
    );
  }

  /// Maps the high-priority leads selected by the BLoC state
  /// ([InquiryManagementLoaded.highPriorityLeads]) to presentation cards.
  List<_LeadCardData> _highPriorityLeadCards(InquiryManagementLoaded state) {
    return state.highPriorityLeads.map((e) {
      final row = VendorInquiryRow.fromListInquiryItem(e);
      return _LeadCardData(
        name: row.name,
        subtitle: row.bookingType,
        trend: row.priorityTrend,
        updateText: 'Created',
        updateDateTime: row.generatedAt,
        chipText: row.status,
        row: row,
      );
    }).toList();
  }

  List<_SummaryChipData> _buildSummaryItems(InquiryManagementLoaded state) {
    return [
      _SummaryChipData(
        label: 'All',
        value: '${state.totalInquiryCount}',
        valueBg: Colors.white,
      ),
      _SummaryChipData(
        label: 'New In',
        value: '${state.inquiryCountByStatus('IN_PROGRESS')}',
        valueBg: const Color(0xFF0088FF),
      ),
      _SummaryChipData(
        label: 'Pending',
        value: '${state.inquiryCountByStatus('PENDING')}',
        valueBg: const Color(0xFFFF8D28),
      ),
      const _SummaryChipData(label: 'New Follow Up', icon: Icons.send_rounded),
      const _SummaryChipData(label: 'Set Follow Up', icon: Icons.send_rounded),
      _SummaryChipData(
        label: 'Loss',
        value: '${state.inquiryCountByStatus('CANCELLED')}',
        valueBg: const Color(0xFFFF383C),
      ),
      _SummaryChipData(
        label: 'Won',
        value: '${state.inquiryCountByStatus('COMPLETED')}',
        valueBg: const Color(0xFF34C759),
      ),
    ];
  }

  String? _statusFromChip(String label) {
    switch (label.toLowerCase()) {
      case 'all':
        return null;
      case 'new in':
        return 'IN_PROGRESS';
      case 'pending':
        return 'PENDING';
      case 'loss':
        return 'CANCELLED';
      case 'won':
        return 'COMPLETED';
      default:
        return null;
    }
  }

  Widget _buildSummaryStatusRow(InquiryManagementLoaded state) {
    final summaryItems = _buildSummaryItems(state);

    return Row(
      children: List.generate(summaryItems.length, (index) {
        final _SummaryChipData item = summaryItems[index];
        final chipStatus = _statusFromChip(item.label);
        final isAll = chipStatus == null && state.status == null;
        final isActive = item.icon != null
            ? false
            : (isAll ? true : chipStatus == state.status);
        final VoidCallback? onTap;
        if (item.label == _newFollowUpChipLabel ||
            item.label == _setFollowUpChipLabel) {
          onTap = () => _onNewFollowUp(state);
        } else if (item.icon != null) {
          onTap = null;
        } else {
          onTap = () =>
              _bloc.add(InquiryManagementStatusChipChanged(chipStatus));
        }
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == summaryItems.length - 1 ? 0 : 0.5,
            ),
            child: InkWell(
              onTap: onTap,
              child: _SummaryChip(
                item: item.copyWith(isActive: isAll ? true : isActive),
                isFirst: index == 0,
                isLast: index == summaryItems.length - 1,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToolbar(InquiryManagementLoaded state) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                'New in (${state.requestStatus == InquiryManagementStatus.loading && state.items.isEmpty ? 0 : state.items.length})',
                style: FontConstant.interMedium(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 15),
              Container(
                width: 300,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 0.15,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: FontConstant.interNormal(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search',
                          hintStyle: FontConstant.interNormal(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                          isCollapsed: true,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 29,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Text(
                'This Month',
                style: FontConstant.interNormal(
                  color: const Color(0xFF1B1535),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: Color(0xFF1B1535),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Text(
          'Refresh',
          style: FontConstant.interMedium(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(width: 15),
        InkWell(
          onTap: () => _bloc.add(InquiryManagementRefreshed()),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF903A8C), Color(0xFF393285)],
              ),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(InquiryManagementLoaded state) {
    if (state.requestStatus == InquiryManagementStatus.loading &&
        state.items.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      );
    }

    if (state.requestStatus == InquiryManagementStatus.failure &&
        state.items.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage ?? 'Something went wrong',
                style: FontConstant.interNormal(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _bloc.add(InquiryManagementRefreshed()),
                child: Text(
                  'Retry',
                  style: FontConstant.interMedium(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final rawItems = state.items;
    final items = (rawItems).whereType<ListInquiryItem>().toList();
    if (state.requestStatus == InquiryManagementStatus.success &&
        items.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No inquiries found',
            style: FontConstant.interNormal(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    final rows = items.map(VendorInquiryRow.fromListInquiryItem).toList();
    // Only tick while at least one row's SLA is actually running (New In).
    final needsSlaTicker = rows.any((r) => r.isSlaRunning);

    final Widget tableRows = needsSlaTicker
        ? _VendorTableRowsWithSlaTicker(
            rows: rows,
            buildRow: (row, index) =>
                _buildTableRow(row, index, slaClock: DateTime.now()),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(rows.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == rows.length - 1 ? 0 : 7,
                  ),
                  child: _buildTableRow(rows[index], index),
                );
              }),
            ],
          );

    return Column(
      children: [
        _buildTableHeader(),
        const SizedBox(height: 7),
        tableRows,
        if (state.isLoadingMore) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 24,
            child: Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaginationBar(InquiryManagementLoaded state) {
    if (state.total <= 0) return const SizedBox.shrink();
    final totalPages = (state.total / state.limit).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    final currentPage = state.page;
    final start = (currentPage - 3).clamp(1, totalPages);
    final end = (currentPage + 3).clamp(1, totalPages);

    final pages = <int>[for (int p = start; p <= end; p++) p];

    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pages.map((p) {
          final isActive = p == currentPage;
          return InkWell(
            onTap: () => _bloc.add(InquiryManagementPageChanged(page: p)),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$p',
                style: FontConstant.interMedium(
                  color: isActive ? const Color(0xFF1B1535) : Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableHeader() {
    return SizedBox(
      height: 50,
      child: Row(
        children: List.generate(_columns.length, (index) {
          final _TableColumnData column = _columns[index];
          return _buildTableCell(
            width: column.width,
            child: Center(
              child: Text(
                column.title,
                style: FontConstant.interNormal(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            backgroundColor: _headerCellColor(),
            isFirst: index == 0,
          );
        }),
      ),
    );
  }

  Widget _buildTableRow(
    VendorInquiryRow row,
    int rowIndex, {
    DateTime? slaClock,
  }) {
    return SizedBox(
      height: 50,
      child: Row(
        children: List.generate(_columns.length, (index) {
          final _TableColumnData column = _columns[index];
          return _buildTableCell(
            width: column.width,
            child: _buildDataCellContent(column.key, row, slaClock: slaClock),
            backgroundColor: _dataCellColor(rowIndex),
            isFirst: index == 0,
          );
        }),
      ),
    );
  }

  Widget _buildDataCellContent(
    String key,
    VendorInquiryRow row, {
    DateTime? slaClock,
  }) {
    switch (key) {
      case 'expand':
        return Center(
          child: InkWell(
            onTap: () {
              context.push(PathConstant.inquiryManagementDetail, extra: row);
            },
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        );
      case 'inquiry':
        return _cellText(row.inquiryNo);
      case 'generated':
        return _cellText(row.generatedAt);
      case 'name':
        return _cellText(row.name);
      case 'booking':
        return _cellText(row.bookingType);
      case 'priority':
        return _PrioritySlaCell(row: row, now: slaClock ?? DateTime.now());
      case 'assigned':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: row.assignedToNames.isEmpty
              ? Center(child: _cellText(row.assignedToText))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AssigneeAvatars(names: row.assignedToNames),
                    const SizedBox(width: 7),
                    Flexible(child: _cellText(row.assignedToText)),
                  ],
                ),
        );
      case 'status':
        return _cellText(row.status);
      case 'set_follow':
        return _cellText('-');
      case 'new_follow':
        return const Center(
          child: Icon(Icons.add, color: Colors.white, size: 16),
        );
      case 'assign':
        return Center(
          child: PopupMenuButton<String>(
            tooltip: 'Assign',
            offset: const Offset(0, 36),
            color: const Color(0xFF2A1F3D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Container(
              width: 77,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF903A8C), Color(0xFF393285)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                'Assign to',
                style: FontConstant.interNormal(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            itemBuilder: (context) => _assignToMenuItems(row),
            onSelected: (_) {},
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Names from the same row as **Assigned to** (comma/`&`-parsed [VendorInquiryRow.assignedToNames]).
  List<PopupMenuEntry<String>> _assignToMenuItems(VendorInquiryRow row) {
    if (row.assignedToNames.isEmpty) {
      return [
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            'Yet to assign',
            style: FontConstant.interNormal(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      ];
    }
    return row.assignedToNames
        .map(
          (name) => PopupMenuItem<String>(
            value: name,
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontConstant.interNormal(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildTableCell({
    required double width,
    required Widget child,
    required Color backgroundColor,
    required bool isFirst,
  }) {
    return Container(
      width: width,
      height: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          left: BorderSide(
            color: isFirst
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: child,
    );
  }

  Widget _buildCollapsedSection() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: const Color(0xFF26193E).withValues(alpha: 0.6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'New',
              style: FontConstant.interMedium(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
        ],
      ),
    );
  }

  Widget _cellText(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: FontConstant.interNormal(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Color _headerCellColor() {
    return Color.alphaBlend(
      Colors.white.withValues(alpha: 0.07),
      const Color(0xFF210D20),
    );
  }

  Color _dataCellColor(int rowIndex) {
    final double overlay = rowIndex.isEven ? 0.1 : 0.4;
    return Color.alphaBlend(
      Colors.black.withValues(alpha: overlay),
      const Color(0xFF26193E),
    );
  }
}

/// One [Timer] for all SLA rows — avoids N timers when the table has many entries.
class _VendorTableRowsWithSlaTicker extends StatefulWidget {
  const _VendorTableRowsWithSlaTicker({
    required this.rows,
    required this.buildRow,
  });

  final List<VendorInquiryRow> rows;
  final Widget Function(VendorInquiryRow row, int index) buildRow;

  @override
  State<_VendorTableRowsWithSlaTicker> createState() =>
      _VendorTableRowsWithSlaTickerState();
}

class _VendorTableRowsWithSlaTickerState
    extends State<_VendorTableRowsWithSlaTicker> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(widget.rows.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == widget.rows.length - 1 ? 0 : 7,
            ),
            child: widget.buildRow(widget.rows[index], index),
          );
        }),
      ],
    );
  }
}

/// Priority column: trend icon + SLA countdown (15m / 1h / 8h from inquiry
/// `createdAt`). The countdown runs only while the inquiry is **New In**; past
/// its deadline it keeps counting into red "Overdue". Once the status leaves
/// New In the timer stops and only the priority label is shown.
class _PrioritySlaCell extends StatelessWidget {
  const _PrioritySlaCell({required this.row, required this.now});

  /// Red used for overdue countdowns (matches the palette's "Loss" red).
  static const Color _overdueColor = Color(0xFFFF383C);

  final VendorInquiryRow row;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final deadline = row.slaDeadline;
    String label;
    bool isOverdue = false;
    if (row.isSlaRunning && deadline != null) {
      label = VendorInquiryRow.formatSlaCountdownLabel(deadline, now);
      isOverdue = !now.isBefore(deadline);
    } else {
      // Timer stopped (status no longer New In) or no SLA — show priority label.
      label = row.priorityText;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InquiryPriorityTrendIcon(trend: row.priorityTrend, size: 16),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FontConstant.interNormal(
                color: isOverdue ? _overdueColor : Colors.white,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.card});

  final _LeadCardData card;

  void _openDetail(BuildContext context) {
    final row = card.row;
    if (row == null) return;
    context.push(PathConstant.inquiryManagementDetail, extra: row);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: card.row != null ? () => _openDetail(context) : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 113,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1535),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        child: const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  card.name,
                                  style: FontConstant.interNormal(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                _LeadTrendIcon(trend: card.trend),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              card.subtitle,
                              style: FontConstant.interNormal(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.open_in_full_rounded,
                    size: 16,
                    color: Color(0xFF1B1535),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.updateText,
                        style: FontConstant.interNormal(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card.updateDateTime,
                        style: FontConstant.interNormal(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 23,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0088FF),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    card.chipText,
                    style: FontConstant.interNormal(
                      color: const Color(0xFF1B1535),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  final _SummaryChipData item;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bool isActive = item.isActive;
    final Color backgroundColor = isActive
        ? Colors.transparent
        : Color.alphaBlend(Colors.white.withValues(alpha: 0.07), Colors.black);

    final BoxDecoration decoration = BoxDecoration(
      color: isActive ? null : backgroundColor,
      gradient: isActive
          ? const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF903A8C), Color(0xFF393285)],
            )
          : null,
      border: Border.all(
        color: Colors.white.withValues(alpha: isActive ? 0 : 0.3),
        width: isActive ? 0 : 0.5,
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(isFirst ? 4 : 0),
        bottomLeft: Radius.circular(isFirst ? 4 : 0),
        topRight: Radius.circular(isLast ? 4 : 0),
        bottomRight: Radius.circular(isLast ? 4 : 0),
      ),
    );

    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: decoration,
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.label,
              style: FontConstant.interNormal(
                color: Colors.white,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _buildValueWidget(),
        ],
      ),
    );
  }

  Widget _buildValueWidget() {
    if (item.icon != null) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Transform.flip(
          flipX: true,
          child: Icon(item.icon, size: 12, color: const Color(0xFF1B1535)),
        ),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(color: item.valueBg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        item.value ?? '',
        style: FontConstant.interNormal(
          color: const Color(0xFF1B1535),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AssigneeAvatars extends StatelessWidget {
  const _AssigneeAvatars({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    const double size = 18;
    const double overlap = 8;
    final double width = size + ((names.length - 1) * (size - overlap));

    return SizedBox(
      width: width,
      height: size,
      child: Stack(
        children: List.generate(names.length, (index) {
          final String initial = names[index].substring(0, 1).toUpperCase();
          return Positioned(
            left: index * (size - overlap),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.25),
                border: Border.all(color: Colors.white, width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: FontConstant.interNormal(
                  color: Colors.white,
                  fontSize: 9,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LeadTrendIcon extends StatelessWidget {
  const _LeadTrendIcon({required this.trend});

  final InquiryPriorityTrend trend;

  @override
  Widget build(BuildContext context) =>
      InquiryPriorityTrendIcon(trend: trend, size: 16);
}

class _LeadCardData {
  const _LeadCardData({
    required this.name,
    required this.subtitle,
    required this.trend,
    required this.updateText,
    required this.updateDateTime,
    required this.chipText,
    this.row,
  });

  final String name;
  final String subtitle;
  final InquiryPriorityTrend trend;
  final String updateText;
  final String updateDateTime;
  final String chipText;

  /// Source row for navigation to inquiry detail on tap.
  final VendorInquiryRow? row;
}

class _SummaryChipData {
  const _SummaryChipData({
    required this.label,
    this.value,
    this.valueBg = Colors.white,
    this.icon,
    this.isActive = false,
  });

  final String label;
  final String? value;
  final Color valueBg;
  final IconData? icon;
  final bool isActive;

  _SummaryChipData copyWith({bool? isActive}) {
    return _SummaryChipData(
      label: label,
      value: value,
      valueBg: valueBg,
      icon: icon,
      isActive: isActive ?? this.isActive,
    );
  }
}

class _TableColumnData {
  const _TableColumnData({
    required this.key,
    required this.title,
    required this.width,
  });

  final String key;
  final String title;
  final double width;
}
