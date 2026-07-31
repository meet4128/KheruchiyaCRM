import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/widgets/inquiry_management_items.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_detail/inquiry_detail_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_detail/inquiry_detail_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_detail/inquiry_detail_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/inquiry_status_chip.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/vendor_inquiry_row.dart';
import 'package:travel_crm/features/presentation/inquiry_management/utils/amendment_status_filter.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/amendment_info_card.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/inquiry_information.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widget/qna_notes.dart';

class InquiryManagementScreen extends StatefulWidget {
  const InquiryManagementScreen({super.key, this.vendorRow, this.inquiryId});

  final VendorInquiryRow? vendorRow;

  /// Inquiry id used to bootstrap the detail when navigated without a full
  /// [VendorInquiryRow] (e.g. tapping a follow-up reminder on the calendar).
  /// The [InquiryDetailBloc] loads the inquiry and rebuilds the row from it.
  final String? inquiryId;

  @override
  State<InquiryManagementScreen> createState() =>
      _InquiryManagementScreenState();
}

class _InquiryManagementScreenState extends State<InquiryManagementScreen> {
  late final InquiryDetailBloc _detailBloc;
  int _selectedStatusIndex = InquiryStatusChipX.indexOf(
    InquiryStatusChip.all,
  );

  @override
  void initState() {
    super.initState();
    final resolvedInquiryId = widget.inquiryId?.trim().isNotEmpty ?? false
        ? widget.inquiryId!.trim()
        : (widget.vendorRow?.bookingId ?? '');
    _detailBloc = sl<InquiryDetailBloc>(param1: widget.vendorRow)
      ..add(InquiryDetailStarted(inquiryId: resolvedInquiryId));
  }

  @override
  void dispose() {
    _detailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _detailBloc,
      child: BlocBuilder<InquiryDetailBloc, InquiryDetailState>(
        builder: (context, detailState) {
          final row = detailState.vendorRow ?? widget.vendorRow;
          final selectedTab = InquiryStatusChipX.fromIndex(
            _selectedStatusIndex,
          );
          final statusBarItems = buildAmendmentStatusBarItems(
            detailState.amendments,
          );
          final filteredAmendments = filterAmendmentsByTab(
            detailState.amendments,
            selectedTab,
          );

          return Scaffold(
            backgroundColor: ColorConstant.inquiryManagementBgColor,
            body: Padding(
              padding: const EdgeInsets.all(DimensionConstant.d25),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: ColorConstant.cardBgColor,
                      width: double.infinity,
                      height: DimensionConstant.d133,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _hierarchyHeader(
                                title: 'Inquiry Management',
                                icon: AssetConstants.icRightArrow,
                              ),
                              _hierarchyHeader(
                                title: '${selectedTab.label} ',
                                icon: AssetConstants.icRightArrow,
                              ),
                              _hierarchyHeader(
                                title: _breadcrumbDetailTitle(row),
                                color: ColorConstant.whiteColor,
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () => _detailBloc.add(
                                  const InquiryDetailRefreshRequested(),
                                ),
                                child: Text(
                                  'Refresh',
                                  style: FontConstant.interMedium(
                                    fontSize: DimensionConstant.d16,
                                    color: ColorConstant.whiteColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: DimensionConstant.d15),
                              InkWell(
                                onTap: () => context.pop(),
                                child: Container(
                                  height: DimensionConstant.d30,
                                  width: DimensionConstant.d30,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        ColorConstant.purple,
                                        ColorConstant.indigo,
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      DimensionConstant.d7,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        AssetConstants.icRepeat,
                                        height: DimensionConstant.d24,
                                        width: DimensionConstant.d24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: DimensionConstant.d25),
                          StatusBar(
                            items: statusBarItems,
                            selectedIndex: _selectedStatusIndex,
                            onSelected: (index) {
                              setState(() => _selectedStatusIndex = index);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DimensionConstant.d25),
                    if (detailState.status == InquiryDetailStatus.loading &&
                        detailState.amendments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(DimensionConstant.d40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (detailState.status ==
                            InquiryDetailStatus.failure &&
                        detailState.amendments.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(DimensionConstant.d24),
                        child: Text(
                          detailState.errorMessage ?? 'Failed to load inquiry',
                          style: FontConstant.interNormal(
                            color: ColorConstant.redColor,
                            fontSize: DimensionConstant.d14,
                          ),
                        ),
                      )
                    else ...[
                      InquiryInformation(row: row),
                      const SizedBox(height: DimensionConstant.d10),
                      if (detailState.amendments.isNotEmpty &&
                          filteredAmendments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: DimensionConstant.d24,
                          ),
                          child: Center(
                            child: Text(
                              'No ${selectedTab.label} amendments',
                              style: FontConstant.interNormal(
                                color: ColorConstant.whiteColor.withValues(
                                  alpha: DimensionConstant.d0_5,
                                ),
                                fontSize: DimensionConstant.d14,
                              ),
                            ),
                          ),
                        )
                      else
                        ...filteredAmendments.map(
                          (a) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: DimensionConstant.d10,
                            ),
                            child: AmendmentInfoCard(
                              amendment: a,
                              inquiryId: detailState.inquiryId,
                              inquiryChecklist: row?.checklist ?? const [],
                            ),
                          ),
                        ),
                      const SizedBox(height: DimensionConstant.d10),
                      QnaNotes(
                        inquiryId: detailState.inquiryId,
                        inquiryDisplayNo: row?.inquiryNo ?? '',
                        peerPhone: detailState.peerPhoneE164,
                        sessionId: detailState.activeSessionId,
                        customerName: row?.name ?? '',
                        bookingType: row?.bookingType,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _breadcrumbDetailTitle(VendorInquiryRow? r) {
    if (r == null) return '—';
    return '${r.inquiryNo} - ${r.name}';
  }

  Widget _hierarchyHeader({required String title, String? icon, Color? color}) {
    return Row(
      children: [
        Text(
          title,
          style: FontConstant.interMedium(
            fontSize: DimensionConstant.d16,
            color:
                color ??
                ColorConstant.whiteColor.withValues(
                  alpha: DimensionConstant.d0_5,
                ),
          ),
        ),
        if (icon != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DimensionConstant.d13,
            ),
            child: SvgPicture.asset(
              icon,
              height: DimensionConstant.d24,
              width: DimensionConstant.d24,
            ),
          ),
      ],
    );
  }
}
