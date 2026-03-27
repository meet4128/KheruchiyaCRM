import 'package:flutter/material.dart';

import '../models/inquiry_priority_trend.dart';

/// Renders the priority arrow for **HIGH** / **MEDIUM** / **LOW** (see [InquiryPriorityTrend]).
///
/// Used by the vendor list Priority column (with SLA timer) and lead cards — single source for colors/icons.
class InquiryPriorityTrendIcon extends StatelessWidget {
  const InquiryPriorityTrendIcon({
    super.key,
    required this.trend,
    this.size = 16,
  });

  final InquiryPriorityTrend trend;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      _iconData(trend),
      size: size,
      color: _iconColor(trend),
    );
  }
}

IconData _iconData(InquiryPriorityTrend t) {
  switch (t) {
    case InquiryPriorityTrend.up:
      return Icons.north_rounded;
    case InquiryPriorityTrend.down:
      return Icons.south_rounded;
    case InquiryPriorityTrend.swap:
      return Icons.swap_horiz_rounded;
  }
}

/// HIGH = red up, MEDIUM = orange swap, LOW = green down.
Color _iconColor(InquiryPriorityTrend t) {
  switch (t) {
    case InquiryPriorityTrend.up:
      return const Color(0xFFFF383C);
    case InquiryPriorityTrend.swap:
      return const Color(0xFFFF8D28);
    case InquiryPriorityTrend.down:
      return const Color(0xFF34C759);
  }
}
