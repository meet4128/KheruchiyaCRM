import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import 'package:travel_crm/core/widgets/app_form_card.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';

import 'bloc/vendor_company_details_bloc.dart';
import 'bloc/vendor_company_details_event.dart';
import 'bloc/vendor_company_details_state.dart';
import 'models/bank_name.dart';
import 'models/service_pricing.dart';
import 'models/service_rating.dart';
import 'models/vendor_attachment.dart';
import 'widgets/attach_file_field.dart';

/// Vendor Company Details Form Screen (Step 2) — main content area only.
/// Mirrors the Step 1 flow: header, left text section, right form card, and a
/// two-step footer with a SUBMIT button. No Scaffold — used inside a parent.
class VendorCompanyDetailsFormScreen extends StatelessWidget {
  const VendorCompanyDetailsFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorCompanyDetailsBloc, VendorCompanyDetailsState>(
      builder: (context, state) {
        final colors = AppTheme.colors(context);
        return LoadingOverlay(
          isLoading: state.isSubmitting,
          color: colors.backgroundDark.withOpacity(0.6),
          progressIndicator: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.secondary),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1200;
              final isMobile = constraints.maxWidth < 768;

              return Column(
                children: [
                  _TopHeaderSection(),
                  Expanded(
                    child: isMobile
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ContentTitleSection(),
                                const SizedBox(height: 32),
                                _LeftTextSection(),
                                const SizedBox(height: 32),
                                _CompanyFormCard(state: state),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 60 : 30,
                                vertical: isWide ? 40 : 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ContentTitleSection(),
                                  SizedBox(height: isWide ? 40 : 32),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 45,
                                        child: _LeftTextSection(),
                                      ),
                                      SizedBox(width: isWide ? 60 : 40),
                                      Expanded(
                                        flex: 55,
                                        child: _CompanyFormCard(state: state),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                  _BottomFooterSection(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Picks a file and dispatches it to the BLoC. Captures the bloc before the
/// async gap so we never touch [context] after `await`.
Future<void> _pickAttachment(
  BuildContext context, {
  required bool isQr,
}) async {
  final bloc = context.read<VendorCompanyDetailsBloc>();
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return;
  final picked = result.files.first;
  final attachment = VendorAttachment(
    fileName: picked.name,
    bytes: picked.bytes,
    path: picked.path,
  );
  if (isQr) {
    bloc.add(VendorAttachQrChanged(attachment));
  } else {
    bloc.add(VendorAttachVisitingCardChanged(attachment));
  }
}

/// Top header: page title + search, light mode, icons, user.
class _TopHeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1A2E), Color(0xFF2A2338), Color(0xFF352040)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            // Back to Step 1 — Step 1 stays mounted underneath, so its
            // entered values are preserved for editing.
            IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(PathConstant.vendorInquiry);
                }
              },
              icon: Icon(Icons.arrow_back, color: colors.textPrimary),
              tooltip: StringConstant.vendorStep1,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Text(
              StringConstant.vendorListConstant,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 200,
              child: TextField(
                style: textStyles.bodySmall.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: StringConstant.search,
                  hintStyle: textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.light_mode, color: colors.textPrimary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    StringConstant.lightMode,
                    style: textStyles.bodySmall
                        .copyWith(color: colors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon:
                  Icon(Icons.notifications_outlined, color: colors.textPrimary),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.person_outline, color: colors.textPrimary),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            Text(
              StringConstant.defaultUserName,
              style: textStyles.bodySmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: colors.textPrimary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Content title: "Vendor's Inquiry Form" + subtitle + arrow.
class _ContentTitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              StringConstant.vendorInquiryForm,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              StringConstant.vendorInquiryFormSubtitle,
              style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colors.inputBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.keyboard_arrow_down,
              color: colors.textPrimary, size: 22),
        ),
      ],
    );
  }
}

/// Left section with heading and subheading (matches Step 1).
class _LeftTextSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                height: 1.2,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: StringConstant.letsTalkAboutClients),
                TextSpan(
                  text: StringConstant.project,
                  style: const TextStyle(color: Color(0xFFA6CAFF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            StringConstant.inquiryFormDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Right section — vendor company details form card (Step 2 fields).
class _CompanyFormCard extends StatelessWidget {
  const _CompanyFormCard({required this.state});

  final VendorCompanyDetailsState state;

  @override
  Widget build(BuildContext context) {
    const fieldGap = 22.0;
    final bloc = context.read<VendorCompanyDetailsBloc>();

    return AppFormCard(
      title: StringConstant.vendorCompanyDetailsFormTitle,
      subtitle: StringConstant.vendorCompanyDetailsFormCardSubtitle,
      centerTitle: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Company Name* | Company Address*
          Row(
            children: [
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.companyName,
                  isRequired: true,
                  child: AppTextField(
                    hint: StringConstant.enterCompanyName,
                    value: state.companyName,
                    errorText: state.companyNameError,
                    onChanged: (v) => bloc.add(VendorCompanyNameChanged(v)),
                  ),
                ),
              ),
              const SizedBox(width: fieldGap),
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.companyAddress,
                  isRequired: true,
                  child: AppTextField(
                    hint: StringConstant.enterCompanyAddress,
                    value: state.companyAddress,
                    errorText: state.companyAddressError,
                    onChanged: (v) => bloc.add(VendorCompanyAddressChanged(v)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: fieldGap),

          // 2. GST No.* | PAN Card* (text)
          Row(
            children: [
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.gstNo,
                  isRequired: true,
                  child: AppTextField(
                    hint: StringConstant.enterGstNo,
                    value: state.gstNo,
                    errorText: state.gstNoError,
                    onChanged: (v) => bloc.add(VendorGstNoChanged(v)),
                  ),
                ),
              ),
              const SizedBox(width: fieldGap),
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.panCard,
                  isRequired: true,
                  child: AppTextField(
                    hint: StringConstant.enterPanCard,
                    value: state.panCard,
                    errorText: state.panCardError,
                    onChanged: (v) => bloc.add(VendorPanCardChanged(v)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: fieldGap),

          // 3. Bank Name* (dropdown) | Account No.*
          Row(
            children: [
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.bankName,
                  isRequired: true,
                  child: AppDropdown<BankName>(
                    hintText: StringConstant.selectBankName,
                    items: BankName.values,
                    itemLabel: (b) => b.label,
                    value: state.bankName,
                    errorText: state.bankNameError,
                    onChanged: (v) {
                      if (v != null) bloc.add(VendorBankNameChanged(v));
                    },
                  ),
                ),
              ),
              const SizedBox(width: fieldGap),
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.accountNo,
                  isRequired: true,
                  child: AppTextField(
                    hint: StringConstant.enterAccountNo,
                    keyboardType: TextInputType.number,
                    value: state.accountNo,
                    errorText: state.accountNoError,
                    onChanged: (v) => bloc.add(VendorAccountNoChanged(v)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: fieldGap),

          // 4. IFSC Code* | Attach QR* (upload)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.ifscCode,
                  isRequired: true,
                  child: AppTextField(
                    hint: StringConstant.enterIfscCode,
                    textCapitalization: TextCapitalization.characters,
                    value: state.ifscCode,
                    errorText: state.ifscCodeError,
                    onChanged: (v) => bloc.add(VendorIfscCodeChanged(v)),
                  ),
                ),
              ),
              const SizedBox(width: fieldGap),
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.attachQr,
                  isRequired: true,
                  child: AttachFileField(
                    attachment: state.attachQr,
                    hint: StringConstant.uploadFile,
                    errorText: state.attachQrError,
                    onPick: () => _pickAttachment(context, isQr: true),
                    onRemove: () =>
                        bloc.add(const VendorAttachQrChanged(null)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: fieldGap),

          // 5. Attach Visiting Card* (upload) | Service Rating* | Service Pricing*
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _FormFieldWrapper(
                  label: StringConstant.attachVisitingCard,
                  isRequired: true,
                  child: AttachFileField(
                    attachment: state.attachVisitingCard,
                    hint: StringConstant.uploadFile,
                    errorText: state.attachVisitingCardError,
                    onPick: () => _pickAttachment(context, isQr: false),
                    onRemove: () => bloc
                        .add(const VendorAttachVisitingCardChanged(null)),
                  ),
                ),
              ),
              const SizedBox(width: fieldGap),
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.serviceRating,
                  isRequired: true,
                  child: AppDropdown<ServiceRating>(
                    hintText: StringConstant.selectServiceRating,
                    items: ServiceRating.values,
                    itemLabel: (r) => r.label,
                    value: state.serviceRating,
                    errorText: state.serviceRatingError,
                    onChanged: (v) {
                      if (v != null) bloc.add(VendorServiceRatingChanged(v));
                    },
                  ),
                ),
              ),
              const SizedBox(width: fieldGap),
              Expanded(
                child: _FormFieldWrapper(
                  label: StringConstant.servicePricing,
                  isRequired: true,
                  child: AppDropdown<ServicePricing>(
                    hintText: StringConstant.selectServicePricing,
                    items: ServicePricing.values,
                    itemLabel: (p) => p.label,
                    value: state.servicePricing,
                    errorText: state.servicePricingError,
                    onChanged: (v) {
                      if (v != null) bloc.add(VendorServicePricingChanged(v));
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: fieldGap),

          // 6. Note* (full width)
          _FormFieldWrapper(
            label: StringConstant.note,
            isRequired: true,
            child: AppTextField(
              hint: StringConstant.enterNote,
              maxLines: 2,
              minLines: 2,
              value: state.note,
              errorText: state.noteError,
              onChanged: (v) => bloc.add(VendorNoteChanged(v)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom footer: step progress (STEP 1 — STEP 2), helper text, and SUBMIT.
class _BottomFooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF6B2D6B), Color(0xFF8A3A86), Color(0xFF9B4A96)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  StringConstant.vendorStep1,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary.withOpacity(0.4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DashedLine(color: colors.textPrimary.withOpacity(0.5)),
                ),
                const SizedBox(width: 16),
                Text(
                  StringConstant.vendorStep2,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Text(
            StringConstant.vendorReadyToSubmitHelper,
            style: textStyles.bodySmall.copyWith(
              color: colors.textPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 260,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context
                  .read<VendorCompanyDetailsBloc>()
                  .add(const SubmitVendorCompanyDetails()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E0A1A),
                foregroundColor: colors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                StringConstant.vendorSubmit,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal dashed line used in the step progress indicator.
class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 8.0;
        const dashSpace = 6.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => SizedBox(
              width: dashWidth,
              height: 2,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            ),
          ),
        );
      },
    );
  }
}

/// Form field wrapper with label and required indicator.
class _FormFieldWrapper extends StatelessWidget {
  const _FormFieldWrapper({
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  final String label;
  final Widget child;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTheme.textStyles(context);
    final colors = AppTheme.colors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: textStyles.formLabel.copyWith(color: colors.textPrimary),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text('*',
                  style: textStyles.formLabel.copyWith(color: colors.error)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
