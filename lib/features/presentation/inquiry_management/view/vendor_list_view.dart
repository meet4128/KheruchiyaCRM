import 'package:flutter/material.dart';
import 'package:travel_crm/core/constants/font_constant.dart';

class VendorListView extends StatefulWidget {
  const VendorListView({super.key});

  @override
  State<VendorListView> createState() => _VendorListViewState();
}

class _VendorListViewState extends State<VendorListView> {
  static const double _kDesktopMinWidth = 1620;
  static const double _kGap = 25;

  final TextEditingController _searchController = TextEditingController();
  int _activeSummaryIndex = 1;

  final List<_LeadCardData> _leadCards = const [
    _LeadCardData(
      name: 'Kirsty Ben',
      subtitle: 'Hot Prospect',
      trend: _Trend.up,
      updateText: 'Update',
      updateDateTime: '08 Dec, 16:30 PM',
      chipText: 'New',
    ),
    _LeadCardData(
      name: 'Joane Dales',
      subtitle: 'Hot Prospect',
      trend: _Trend.up,
      updateText: 'Update',
      updateDateTime: '08 Dec, 16:30 PM',
      chipText: 'New',
    ),
    _LeadCardData(
      name: 'Mickey Wick',
      subtitle: 'Hot Prospect',
      trend: _Trend.down,
      updateText: 'Update',
      updateDateTime: '08 Dec, 16:30 PM',
      chipText: 'New',
    ),
    _LeadCardData(
      name: 'Joane Dales',
      subtitle: 'Hot Prospect',
      trend: _Trend.swap,
      updateText: 'Update',
      updateDateTime: '08 Dec, 16:30 PM',
      chipText: 'New',
    ),
    _LeadCardData(
      name: 'Mickey Wick',
      subtitle: 'Hot Prospect',
      trend: _Trend.up,
      updateText: 'Update',
      updateDateTime: '08 Dec, 16:30 PM',
      chipText: 'New',
    ),
  ];

  final List<_SummaryChipData> _summaryItems = const [
    _SummaryChipData(label: 'All', value: '68', valueBg: Colors.white),
    _SummaryChipData(
      label: 'New In',
      value: '18',
      valueBg: Color(0xFF0088FF),
      isActive: true,
    ),
    _SummaryChipData(label: 'Pending', value: '13', valueBg: Color(0xFFFF8D28)),
    _SummaryChipData(label: 'New Follow Up', icon: Icons.send_rounded),
    _SummaryChipData(label: 'Set Follow Up', icon: Icons.send_rounded),
    _SummaryChipData(label: 'Loss', value: '35', valueBg: Color(0xFFFF383C)),
    _SummaryChipData(label: 'Won', value: '2', valueBg: Color(0xFF34C759)),
  ];

  final List<_VendorRowData> _rows = const [
    _VendorRowData(
      inquiryNo: '#85913',
      generatedAt: '17/12/2025 @ 8:50PM',
      name: 'Hardik Kheruchiya',
      bookingType: 'Air Ticket',
      priorityType: _Trend.up,
      priorityText: '00:15 min Left',
      assignedToNames: ['Amit', 'Jenny', 'Helly'],
      assignedToText: 'Amit, Jenny & Helly',
      status: 'In Progress',
    ),
    _VendorRowData(
      inquiryNo: '#85914',
      generatedAt: '17/12/2025 @ 10:50AM',
      name: 'Meet Raval',
      bookingType: 'Air Ticket',
      priorityType: _Trend.up,
      priorityText: '00:59 min Left',
      assignedToNames: [],
      assignedToText: 'Yet to assign',
      status: 'In Progress',
    ),
    _VendorRowData(
      inquiryNo: '#85915',
      generatedAt: '17/12/2025 @ 8:52PM',
      name: 'Rahul Mourya',
      bookingType: 'Air Ticket',
      priorityType: _Trend.down,
      priorityText: '1 Week Left',
      assignedToNames: ['Jenny', 'Helly'],
      assignedToText: 'Jenny & Helly',
      status: 'In Progress',
    ),
    _VendorRowData(
      inquiryNo: '#85916',
      generatedAt: '17/12/2025 @ 11:52AM',
      name: 'Katha Raval',
      bookingType: 'Air Ticket',
      priorityType: _Trend.swap,
      priorityText: '1 day Left',
      assignedToNames: [],
      assignedToText: 'Yet to assign',
      status: 'In Progress',
    ),
  ];

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF210D20)),
          ColoredBox(color: Colors.black.withValues(alpha: 0.5)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double contentWidth =
                      constraints.maxWidth < _kDesktopMinWidth
                      ? _kDesktopMinWidth
                      : constraints.maxWidth;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: contentWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMainBoard(),
                            const SizedBox(height: _kGap),
                            _buildCollapsedSection(),
                          ],
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
  }

  Widget _buildMainBoard() {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHeader(),
          const SizedBox(height: _kGap),
          _buildLeadCards(),
          const SizedBox(height: _kGap),
          _buildSummaryStatusRow(),
          const SizedBox(height: _kGap),
          _buildToolbar(),
          const SizedBox(height: _kGap),
          _buildTable(),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recently Added Leads',
            style: FontConstant.interMedium(color: Colors.white, fontSize: 16),
          ),
        ),
        Text(
          'Refresh',
          style: FontConstant.interMedium(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(width: 15),
        InkWell(
          onTap: () {},
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

  Widget _buildLeadCards() {
    return Row(
      children: List.generate(_leadCards.length, (index) {
        final _LeadCardData card = _leadCards[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == _leadCards.length - 1 ? 0 : 12,
            ),
            child: _LeadCard(card: card),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryStatusRow() {
    return Row(
      children: List.generate(_summaryItems.length, (index) {
        final _SummaryChipData item = _summaryItems[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == _summaryItems.length - 1 ? 0 : 0.5,
            ),
            child: InkWell(
              onTap: () => setState(() => _activeSummaryIndex = index),
              child: _SummaryChip(
                item: item.copyWith(isActive: _activeSummaryIndex == index),
                isFirst: index == 0,
                isLast: index == _summaryItems.length - 1,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(
                'New In (18)',
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
        Container(
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
      ],
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        _buildTableHeader(),
        const SizedBox(height: 7),
        ...List.generate(_rows.length, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: index == _rows.length - 1 ? 0 : 7),
            child: _buildTableRow(_rows[index], index),
          );
        }),
      ],
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

  Widget _buildTableRow(_VendorRowData row, int rowIndex) {
    return SizedBox(
      height: 50,
      child: Row(
        children: List.generate(_columns.length, (index) {
          final _TableColumnData column = _columns[index];
          return _buildTableCell(
            width: column.width,
            child: _buildDataCellContent(column.key, row),
            backgroundColor: _dataCellColor(rowIndex),
            isFirst: index == 0,
          );
        }),
      ),
    );
  }

  Widget _buildDataCellContent(String key, _VendorRowData row) {
    switch (key) {
      case 'expand':
        return const Center(
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 24,
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _trendIcon(row.priorityType, size: 16),
              const SizedBox(width: 5),
              Flexible(child: _cellText(row.priorityText)),
            ],
          ),
        );
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
        );
      default:
        return const SizedBox.shrink();
    }
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

  Widget _trendIcon(_Trend trend, {double size = 16}) {
    switch (trend) {
      case _Trend.up:
        return Icon(
          Icons.north_rounded,
          size: size,
          color: const Color(0xFFFF383C),
        );
      case _Trend.down:
        return Icon(
          Icons.south_rounded,
          size: size,
          color: const Color(0xFF34C759),
        );
      case _Trend.swap:
        return Icon(
          Icons.swap_horiz_rounded,
          size: size,
          color: const Color(0xFFFF8D28),
        );
    }
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.card});

  final _LeadCardData card;

  @override
  Widget build(BuildContext context) {
    return Container(
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

  final _Trend trend;

  @override
  Widget build(BuildContext context) {
    switch (trend) {
      case _Trend.up:
        return const Icon(
          Icons.north_rounded,
          size: 16,
          color: Color(0xFFFF383C),
        );
      case _Trend.down:
        return const Icon(
          Icons.south_rounded,
          size: 16,
          color: Color(0xFF34C759),
        );
      case _Trend.swap:
        return const Icon(
          Icons.swap_horiz_rounded,
          size: 16,
          color: Color(0xFFFF8D28),
        );
    }
  }
}

enum _Trend { up, down, swap }

class _LeadCardData {
  const _LeadCardData({
    required this.name,
    required this.subtitle,
    required this.trend,
    required this.updateText,
    required this.updateDateTime,
    required this.chipText,
  });

  final String name;
  final String subtitle;
  final _Trend trend;
  final String updateText;
  final String updateDateTime;
  final String chipText;
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

class _VendorRowData {
  const _VendorRowData({
    required this.inquiryNo,
    required this.generatedAt,
    required this.name,
    required this.bookingType,
    required this.priorityType,
    required this.priorityText,
    required this.assignedToNames,
    required this.assignedToText,
    required this.status,
  });

  final String inquiryNo;
  final String generatedAt;
  final String name;
  final String bookingType;
  final _Trend priorityType;
  final String priorityText;
  final List<String> assignedToNames;
  final String assignedToText;
  final String status;
}
