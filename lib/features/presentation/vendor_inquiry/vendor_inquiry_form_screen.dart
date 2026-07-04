import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_form_card.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/core/widgets/dial_code_picker/dial_code_picker.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_bloc.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_event.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_state.dart';

/// Vendor Inquiry Form Screen (Step 1) — main content area only.
/// Mirrors the InquiryFormScreen flow: header, left text section, right form
/// card, and a two-step footer with a NEXT button. No Scaffold — must be used
/// inside a parent layout.
class VendorInquiryFormScreen extends StatelessWidget {
  const VendorInquiryFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
                          _VendorFormCard(),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 45,
                                  child: _LeftTextSection(),
                                ),
                                SizedBox(width: isWide ? 60 : 40),
                                Expanded(
                                  flex: 55,
                                  child: _VendorFormCard(),
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
    );
  }
}

/// Top header: page title on the left; search, light mode, icons, user on right.
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
          colors: [
            Color(0xFF1F1A2E),
            Color(0xFF2A2338),
            Color(0xFF352040),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
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
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: colors.textPrimary),
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
            Icon(
              Icons.keyboard_arrow_down,
              color: colors.textPrimary,
              size: 20,
            ),
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
              style: textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
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
          child: Icon(
            Icons.keyboard_arrow_down,
            color: colors.textPrimary,
            size: 22,
          ),
        ),
      ],
    );
  }
}

/// Left section with heading and subheading.
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

/// Right section — vendor inquiry form card (Step 1 fields).
class _VendorFormCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorInquiryBloc, VendorInquiryState>(
      builder: (context, state) {
        const fieldGap = 22.0;

        return AppFormCard(
          title: StringConstant.vendorInquiryFormTitle,
          subtitle: StringConstant.vendorInquiryFormCardSubtitle,
          centerTitle: true,
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Full Name* | Phone Number*
                Row(
                  children: [
                    Expanded(
                      child: _FormFieldWrapper(
                        label: StringConstant.fullName,
                        isRequired: true,
                        child: AppTextField(
                          hint: StringConstant.enterFullName,
                          value: state.fullName,
                          errorText: state.fullNameError,
                          onChanged: (value) => context
                              .read<VendorInquiryBloc>()
                              .add(VendorFullNameChanged(value)),
                        ),
                      ),
                    ),
                    const SizedBox(width: fieldGap),
                    Expanded(
                      child: _FormFieldWrapper(
                        label: StringConstant.phoneNumber,
                        isRequired: true,
                        child: Row(
                          children: [
                            DialCodePicker(
                              dialCode: state.phoneDialCode,
                              onChanged: (code) => context
                                  .read<VendorInquiryBloc>()
                                  .add(VendorPhoneDialCodeChanged(code)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                hint: StringConstant.enterPhoneNumber,
                                keyboardType: TextInputType.phone,
                                value: state.phoneNumber,
                                errorText: state.phoneError,
                                onChanged: (value) => context
                                    .read<VendorInquiryBloc>()
                                    .add(VendorPhoneChanged(value)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: fieldGap),

                // 2. E-mail* | Designation*
                Row(
                  children: [
                    Expanded(
                      child: _FormFieldWrapper(
                        label: StringConstant.email,
                        isRequired: true,
                        child: AppTextField(
                          hint: StringConstant.enterEmail,
                          keyboardType: TextInputType.emailAddress,
                          value: state.email,
                          errorText: state.emailError,
                          onChanged: (value) => context
                              .read<VendorInquiryBloc>()
                              .add(VendorEmailChanged(value)),
                        ),
                      ),
                    ),
                    const SizedBox(width: fieldGap),
                    Expanded(
                      child: _FormFieldWrapper(
                        label: StringConstant.designation,
                        isRequired: true,
                        child: AppTextField(
                          hint: StringConstant.enterDesignation,
                          value: state.designation,
                          errorText: state.designationError,
                          onChanged: (value) => context
                              .read<VendorInquiryBloc>()
                              .add(VendorDesignationChanged(value)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: fieldGap),

                // 3. Specialize In* | Sub-Specialize In* (typeable)
                Row(
                  children: [
                    Expanded(
                      child: _FormFieldWrapper(
                        label: StringConstant.specializeIn,
                        isRequired: true,
                        child: AppTextField(
                          hint: StringConstant.enterSpecializeIn,
                          value: state.specializeIn,
                          errorText: state.specializeInError,
                          onChanged: (value) => context
                              .read<VendorInquiryBloc>()
                              .add(VendorSpecializeInChanged(value)),
                        ),
                      ),
                    ),
                    const SizedBox(width: fieldGap),
                    Expanded(
                      child: _FormFieldWrapper(
                        label: StringConstant.subSpecializeIn,
                        isRequired: true,
                        child: AppTextField(
                          hint: StringConstant.enterSubSpecializeIn,
                          value: state.subSpecializeIn,
                          errorText: state.subSpecializeInError,
                          onChanged: (value) => context
                              .read<VendorInquiryBloc>()
                              .add(VendorSubSpecializeInChanged(value)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: fieldGap),

                // 4. Address* (full width)
                _FormFieldWrapper(
                  label: StringConstant.address,
                  isRequired: true,
                  child: AppTextField(
                    hint: StringConstant.enterAddress,
                    maxLines: 2,
                    minLines: 2,
                    value: state.address,
                    errorText: state.addressError,
                    onChanged: (value) => context
                        .read<VendorInquiryBloc>()
                        .add(VendorAddressChanged(value)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bottom footer: step progress (STEP 1 — STEP 2), helper text, and NEXT button.
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
          colors: [
            Color(0xFF6B2D6B),
            Color(0xFF8A3A86),
            Color(0xFF9B4A96),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Step progress indicator
          Expanded(
            child: Row(
              children: [
                Text(
                  StringConstant.vendorStep1,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
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
                    color: colors.textPrimary.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Text(
            StringConstant.fillCompanyDetailsInStep2,
            style: textStyles.bodySmall.copyWith(
              color: colors.textPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(width: 24),
          // NEXT button
          SizedBox(
            width: 260,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context
                  .read<VendorInquiryBloc>()
                  .add(const VendorNextPressed()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E0A1A),
                foregroundColor: colors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                StringConstant.vendorNext,
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
              Text(
                '*',
                style: textStyles.formLabel.copyWith(color: colors.error),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
