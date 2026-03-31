import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/vendor_inquiry_row.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/inquiry_priority_trend_icon.dart';

class InquiryInformation extends StatefulWidget {
  const InquiryInformation({super.key, this.row});

  /// Row from vendor list tap; when null, placeholders are shown.
  final VendorInquiryRow? row;

  @override
  State<InquiryInformation> createState() => _InquiryInformationState();
}

class _InquiryInformationState extends State<InquiryInformation> {
  final ExpansibleController _controller = ExpansibleController();
  Timer? _slaTimer;

  @override
  void initState() {
    super.initState();
    if (widget.row?.slaDeadline != null) {
      _slaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void didUpdateWidget(covariant InquiryInformation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.row?.slaDeadline != widget.row?.slaDeadline) {
      _slaTimer?.cancel();
      _slaTimer = null;
      if (widget.row?.slaDeadline != null) {
        _slaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _slaTimer?.cancel();
    super.dispose();
  }

  String get _inquiryNoDisplay {
    final r = widget.row;
    if (r == null) return ' —';
    return ' ${r.inquiryNo}';
  }

  String get _generatedDisplay {
    final r = widget.row;
    if (r == null) return ' —';
    return ' ${r.generatedAt}';
  }

  String get _assignedDisplay {
    final r = widget.row;
    if (r == null) return '—';
    return r.assignedToText;
  }

  String _priorityLabel(VendorInquiryRow r) {
    final d = r.slaDeadline;
    if (d != null) {
      return VendorInquiryRow.formatSlaCountdownLabel(d, DateTime.now());
    }
    return r.priorityText;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.row;

    return Container(
      color: ColorConstant.card1BgColor,
      width: double.infinity,
      child: Padding(
        padding: _controller.isExpanded
            ? EdgeInsets.symmetric(
                horizontal: DimensionConstant.d25,
                vertical: DimensionConstant.d30,
              )
            : EdgeInsets.only(
                right: DimensionConstant.d25,
                left: DimensionConstant.d25,
                top: DimensionConstant.d30,
              ),
        child: Expansible(
          controller: _controller,
          headerBuilder: (BuildContext context, Animation<double> animation) {
            return InkWell(
              onTap: () {
                (_controller.isExpanded) ? _controller.collapse() : _controller.expand();
                setState(() {});
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        StringConstant.inquiryInformation,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d16,
                        ),
                      ),
                      Text(
                        _inquiryNoDisplay,
                        style: FontConstant.interNormal(
                          color: ColorConstant.inquiryInfoTxtColor,
                          fontSize: DimensionConstant.d16,
                        ),
                      ),
                      const Spacer(),

                      /// Bottom action bar
                      Align(
                        alignment: Alignment.centerRight,
                        child: IntrinsicHeight(
                          child: IntrinsicWidth(
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorConstant.blackColor,
                                borderRadius: BorderRadius.circular(DimensionConstant.d4),
                                border: Border.all(color: ColorConstant.borderColorWhite30),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Padding(
                                      padding: const EdgeInsets.all(DimensionConstant.d15),
                                      child: Center(
                                        child: Text(
                                          StringConstant.allTicketBookings,
                                          textAlign: TextAlign.center,
                                          style: FontConstant.interMedium(
                                            color: ColorConstant.whiteColor,
                                            fontSize: DimensionConstant.d12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(color: ColorConstant.borderColorWhite30),

                                  InkWell(
                                    onTap: () {},
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(DimensionConstant.d15),
                                        child: Text(
                                          StringConstant.allInvoices,
                                          textAlign: TextAlign.center,
                                          style: FontConstant.interMedium(
                                            color: ColorConstant.whiteColor,
                                            fontSize: DimensionConstant.d12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  VerticalDivider(color: ColorConstant.borderColorWhite30),
                                  InkWell(
                                    onTap: () {},
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: DimensionConstant.d15,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              StringConstant.moreOptions,
                                              textAlign: TextAlign.center,
                                              style: FontConstant.interMedium(
                                                color: ColorConstant.whiteColor,
                                                fontSize: DimensionConstant.d12,
                                              ),
                                            ),
                                            const SizedBox(width: DimensionConstant.d6),
                                            SvgPicture.asset(
                                              AssetConstants.icArrowRight,
                                              height: DimensionConstant.d16,
                                              width: DimensionConstant.d16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d25),
                      _controller.isExpanded
                          ? SvgPicture.asset(AssetConstants.icUpRoundArrow)
                          : RotatedBox(
                              quarterTurns: DimensionConstant.i2,
                              child: SvgPicture.asset(AssetConstants.icUpRoundArrow),
                            ),
                    ],
                  ),
                  const SizedBox(height: DimensionConstant.d25),
                  Row(
                    children: [
                      Text(
                        StringConstant.inquiryNumber,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      Text(
                        _inquiryNoDisplay,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d10),
                      Text(
                        StringConstant.inquiryGenerated,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      Text(
                        _generatedDisplay,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        StringConstant.assignedTo,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      if (r != null && r.assignedToNames.isNotEmpty) ...[
                        _AssigneeInitialsAvatars(names: r.assignedToNames),
                        const SizedBox(width: DimensionConstant.d5),
                      ],
                      Text(
                        _assignedDisplay,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d15),
                      Text(
                        StringConstant.priority,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d5),
                      if (r != null) ...[
                        InquiryPriorityTrendIcon(trend: r.priorityTrend, size: DimensionConstant.d16),
                        const SizedBox(width: DimensionConstant.d5),
                        Flexible(
                          child: Text(
                            _priorityLabel(r),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FontConstant.interNormal(
                              color: ColorConstant.whiteColor.withValues(alpha: .5),
                              fontSize: DimensionConstant.d12,
                            ),
                          ),
                        ),
                      ] else
                        Text(
                          '—',
                          style: FontConstant.interNormal(
                            color: ColorConstant.whiteColor.withValues(alpha: .5),
                            fontSize: DimensionConstant.d12,
                          ),
                        ),
                      const SizedBox(width: DimensionConstant.d15),
                      Text(
                        StringConstant.statusColon,
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor.withValues(alpha: .5),
                          fontSize: DimensionConstant.d12,
                        ),
                      ),
                      const SizedBox(width: DimensionConstant.d5),
                      SvgPicture.asset(
                        AssetConstants.icTimer,
                        height: DimensionConstant.d16,
                        width: DimensionConstant.d16,
                      ),
                      const SizedBox(width: DimensionConstant.d5),
                      Flexible(
                        child: Text(
                          r?.status ?? '—',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FontConstant.interNormal(
                            color: ColorConstant.whiteColor.withValues(alpha: .5),
                            fontSize: DimensionConstant.d12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d25),
                    child: Divider(color: ColorConstant.whiteColor.withValues(alpha: .3)),
                  ),
                  _InquiryDetailMetaAndBasicDetails(row: r),
                ],
              ),
            );
          },
          bodyBuilder: (BuildContext context, Animation<double> animation) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

/// Read-only label + value text (same typography as inquiry number row); no [TextField].
class _InquiryDetailMetaAndBasicDetails extends StatelessWidget {
  const _InquiryDetailMetaAndBasicDetails({required this.row});

  final VendorInquiryRow? row;

  static TextStyle get _labelStyle => FontConstant.interNormal(
        color: ColorConstant.whiteColor.withValues(alpha: .5),
        fontSize: DimensionConstant.d12,
      );

  static TextStyle get _valueStyle => FontConstant.interNormal(
        color: ColorConstant.whiteColor,
        fontSize: DimensionConstant.d12,
      );

  @override
  Widget build(BuildContext context) {
    final r = row;

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final fourCol = w >= 900;
              final metaChildren = <Widget>[
                _metaPair('Booking ID', r?.bookingId ?? '—'),
                _metaPair('Order Type', r?.orderTypeDisplay ?? '—'),
                _metaPair('Reference Number', r?.referenceNumberDisplay ?? '—'),
                _metaPair('Reference Name', r?.referenceNameDisplay ?? '—'),
              ];
              if (fourCol) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < metaChildren.length; i++) ...[
                      Expanded(child: metaChildren[i]),
                      if (i < metaChildren.length - 1) const SizedBox(width: DimensionConstant.d16),
                    ],
                  ],
                );
              }
              return Wrap(
                spacing: DimensionConstant.d16,
                runSpacing: DimensionConstant.d12,
                children: metaChildren
                    .map((e) => SizedBox(width: (w - DimensionConstant.d16) / 2, child: e))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: DimensionConstant.d25),
          Text(
            'Basic Details',
            style: FontConstant.interMedium(
              color: ColorConstant.whiteColor,
              fontSize: DimensionConstant.d16,
            ),
          ),
          const SizedBox(height: DimensionConstant.d16),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final wide = w >= 1000;
              if (wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _readonlyBox(
                            label: 'Title',
                            value: r?.title ?? '—',
                            requiredField: true,
                          ),
                        ),
                        const SizedBox(width: DimensionConstant.d12),
                        Expanded(
                          child: _readonlyBox(
                            label: 'Full Name',
                            value: r?.name ?? '—',
                          ),
                        ),
                        const SizedBox(width: DimensionConstant.d12),
                        Expanded(
                          child: _readonlyBox(
                            label: 'Phone Number',
                            value: r?.phoneDisplay ?? '—',
                            requiredField: true,
                          ),
                        ),
                        const SizedBox(width: DimensionConstant.d12),
                        Expanded(
                          child: _readonlyBox(
                            label: 'E-mail',
                            value: r?.emailDisplay ?? '—',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DimensionConstant.d12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _readonlyBox(
                            label: 'Type of Client',
                            value: r?.typeOfClient ?? '—',
                            requiredField: true,
                          ),
                        ),
                        const SizedBox(width: DimensionConstant.d12),
                        Expanded(
                          child: _readonlyBox(
                            label: 'Address',
                            value: r?.addressDisplay ?? '—',
                          ),
                        ),
                        const SizedBox(width: DimensionConstant.d12),
                        Expanded(
                          child: _readonlyBox(
                            label: 'Type of Booking',
                            value: r?.bookingType ?? '—',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _readonlyBox(label: 'Title', value: r?.title ?? '—', requiredField: true),
                  const SizedBox(height: DimensionConstant.d12),
                  _readonlyBox(label: 'Full Name', value: r?.name ?? '—'),
                  const SizedBox(height: DimensionConstant.d12),
                  _readonlyBox(
                    label: 'Phone Number',
                    value: r?.phoneDisplay ?? '—',
                    requiredField: true,
                  ),
                  const SizedBox(height: DimensionConstant.d12),
                  _readonlyBox(label: 'E-mail', value: r?.emailDisplay ?? '—'),
                  const SizedBox(height: DimensionConstant.d12),
                  _readonlyBox(
                    label: 'Type of Client',
                    value: r?.typeOfClient ?? '—',
                    requiredField: true,
                  ),
                  const SizedBox(height: DimensionConstant.d12),
                  _readonlyBox(label: 'Address', value: r?.addressDisplay ?? '—'),
                  const SizedBox(height: DimensionConstant.d12),
                  _readonlyBox(label: 'Type of Booking', value: r?.bookingType ?? '—'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metaPair(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: _labelStyle),
        Expanded(
          child: Text(value, style: _valueStyle),
        ),
      ],
    );
  }

  Widget _readonlyBox({
    required String label,
    required String value,
    bool requiredField = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DimensionConstant.d12,
        vertical: DimensionConstant.d10,
      ),
      decoration: BoxDecoration(
        color: ColorConstant.whiteColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(DimensionConstant.d4),
        border: Border.all(
          color: ColorConstant.whiteColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: _labelStyle,
              children: [
                TextSpan(text: label),
                if (requiredField)
                  TextSpan(
                    text: '*',
                    style: _labelStyle.copyWith(
                      color: const Color(0xFFFF383C),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: DimensionConstant.d6),
          Text(value, style: _valueStyle),
        ],
      ),
    );
  }
}

/// Same visual idea as [VendorListView] assignee avatars: initials in overlapping circles.
class _AssigneeInitialsAvatars extends StatelessWidget {
  const _AssigneeInitialsAvatars({required this.names});

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
                  color: ColorConstant.whiteColor,
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
