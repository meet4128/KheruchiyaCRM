
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import 'package:travel_crm/core/widgets/app_form_card.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/core/widgets/dial_code_picker.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_event.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_state.dart';

/// Inquiry Form Screen - Main content area only
/// Renders header, left text section, right form card, and footer
/// Must be used inside a parent layout (no Scaffold)
class InquiryFormScreen extends StatelessWidget {
  const InquiryFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1200;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;
        final isMobile = constraints.maxWidth < 768;

        return Column(
          children: [
            // TOP HEADER SECTION
            _TopHeaderSection(),
            
            // MAIN CONTENT SECTION
            Expanded(
              child: isMobile
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LeftTextSection(),
                          const SizedBox(height: 32),
                          _InquiryFormCard(),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 80 : 40,
                          vertical: isWide ? 60 : 40,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // LEFT SECTION
                            Expanded(
                              flex: 1,
                              child: _LeftTextSection(),
                            ),
                            SizedBox(width: isWide ? 60 : 40),
                            // RIGHT SECTION
                            Expanded(
                              flex: 1,
                              child: _InquiryFormCard(),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            
            // BOTTOM FOOTER SECTION
            _BottomFooterSection(),
          ],
        );
      },
    );
  }
}

/// Top header section with title and arrow icon
class _TopHeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F1A2E), // Match form card gradient start
            Color(0xFF2A2338), // Match form card gradient end
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Title and subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  StringConstant.inquiryForm,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  StringConstant.fillInFormForCustomerInquiry,
                  style: textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            // Right: Arrow icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: colors.textPrimary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Left section with heading and subheading
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
          // Main heading - 56px font size
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
                  style: TextStyle(
                    color: Color(0xFFA6CAFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Subtitle paragraph - 16px font size
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

/// Right section with inquiry form card
class _InquiryFormCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InquiryBloc, InquiryState>(
      builder: (context, state) {
        return AppFormCard(
          title: StringConstant.inquiryFormTitle,
          subtitle: StringConstant.fillFormForQuote,
          child: Form(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fieldGap = 22.0; // 20-24px spacing

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Title (full width)
                        _FormFieldWrapper(
                          label: StringConstant.title,
                          isRequired: true,
                          child: AppTextField(
                            hint: StringConstant.enterTitle,
                            value: state.title,
                            errorText: state.titleError,
                            onChanged: (value) =>
                                context.read<InquiryBloc>().add(TitleChanged(value)),
                          ),
                        ),
                        SizedBox(height: fieldGap),

                        // 2. First Name + Last Name (always in one row)
                        Row(
                          children: [
                            Expanded(
                              child: _FormFieldWrapper(
                                label: StringConstant.firstName,
                                isRequired: true,
                                child: AppTextField(
                                  hint: StringConstant.enterFirstName,
                                  value: state.firstName,
                                  errorText: state.firstNameError,
                                  onChanged: (value) =>
                                      context.read<InquiryBloc>().add(FirstNameChanged(value)),
                                ),
                              ),
                            ),
                            SizedBox(width: fieldGap),
                            Expanded(
                              child: _FormFieldWrapper(
                                label: StringConstant.lastName,
                                isRequired: true,
                                child: AppTextField(
                                  hint: StringConstant.enterLastName,
                                  value: state.lastName,
                                  errorText: state.lastNameError,
                                  onChanged: (value) =>
                                      context.read<InquiryBloc>().add(LastNameChanged(value)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: fieldGap),

                        // 3. Phone Number + Email (always in one row)
                        Row(
                          children: [
                            Expanded(
                              child: _FormFieldWrapper(
                                label: StringConstant.phoneNumber,
                                isRequired: true,
                                child: Row(
                                  children: [
                                    BlocBuilder<InquiryBloc, InquiryState>(
                                      builder: (context, state) {
                                        return DialCodePicker(
                                          dialCode: state.phoneDialCode,
                                          onChanged: (code) {
                                            context.read<InquiryBloc>().add(PhoneDialCodeChanged(code));
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppTextField(
                                        hint: StringConstant.enterPhoneNumber,
                                        keyboardType: TextInputType.phone,
                                        value: state.phoneNumber,
                                        errorText: state.phoneError,
                                        onChanged: (value) =>
                                            context.read<InquiryBloc>().add(PhoneChanged(value)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: fieldGap),
                            Expanded(
                              child: _FormFieldWrapper(
                                label: StringConstant.email,
                                isRequired: true,
                                child: AppTextField(
                                  hint: StringConstant.enterEmail,
                                  keyboardType: TextInputType.emailAddress,
                                  value: state.email,
                                  errorText: state.emailError,
                                  onChanged: (value) =>
                                      context.read<InquiryBloc>().add(EmailChanged(value)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: fieldGap),

                        // 4. Address (full width)
                        _FormFieldWrapper(
                          label: StringConstant.address,
                          isRequired: true,
                          child: AppTextField(
                            hint: StringConstant.enterAddress,
                            maxLines: 2,
                            minLines: 2,
                            value: state.address,
                            errorText: state.addressError,
                            onChanged: (value) =>
                                context.read<InquiryBloc>().add(AddressChanged(value)),
                          ),
                        ),
                        SizedBox(height: fieldGap),

                        // 5. Reference Name + Reference Number (always in one row)
                        Row(
                          children: [
                            Expanded(
                              child: _FormFieldWrapper(
                                label: StringConstant.referenceName,
                                isRequired: true,
                                child: AppTextField(
                                  hint: StringConstant.enterReferenceName,
                                  value: state.referenceName,
                                  errorText: state.referenceNameError,
                                  onChanged: (value) =>
                                      context.read<InquiryBloc>().add(ReferenceNameChanged(value)),
                                ),
                              ),
                            ),
                            SizedBox(width: fieldGap),
                            Expanded(
                              child: _FormFieldWrapper(
                                label: StringConstant.referenceNumber,
                                isRequired: true,
                                child: Row(
                                  children: [
                                    BlocBuilder<InquiryBloc, InquiryState>(
                                      builder: (context, state) {
                                        return DialCodePicker(
                                          dialCode: state.referenceDialCode,
                                          onChanged: (code) {
                                            context.read<InquiryBloc>().add(ReferenceDialCodeChanged(code));
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppTextField(
                                        hint: StringConstant.enterReferenceNumber,
                                        keyboardType: TextInputType.phone,
                                        value: state.referenceNumber,
                                        errorText: state.referenceNumberError,
                                        onChanged: (value) =>
                                            context.read<InquiryBloc>().add(ReferenceNumberChanged(value)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
          );
      },
    );
  }
}

/// Bottom footer section with company name, booking type selector, and version
class _BottomFooterSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1200;
        final horizontalPadding = isWide ? 80.0 : 40.0;
        final gap = isWide ? 60.0 : 40.0;
        
        // Calculate form card width: (total width - horizontal padding * 2 - gap) / 2
        final totalWidth = constraints.maxWidth;
        final formCardWidth = (totalWidth - horizontalPadding * 2 - gap) / 2;

        return Container(
          width: double.infinity,
          height: 173,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1F1A2E), // Match form card gradient start
                Color(0xFF2A2338), // Match form card gradient end
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Select type heading and Type of Booking dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    StringConstant.selectType,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(
                    width: formCardWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: BlocBuilder<InquiryBloc, InquiryState>(
                        builder: (context, state) {
                          return _FormFieldWrapper(
                            label: StringConstant.typeOfBooking,
                            isRequired: true,
                            child: AppDropdown<BookingType>(
                              hintText: StringConstant.selectRole,
                              items: BookingType.values,
                              itemLabel: (type) => type.label,
                              value: state.bookingType,
                              errorText: state.bookingTypeError,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<InquiryBloc>().add(BookingTypeChanged(value));
                                  // Navigate to air ticket view when flight booking is selected
                                  if (value == BookingType.flight) {
                                    context.go(PathConstant.airTicket);
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              // Bottom row: Company name and Version
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    StringConstant.zeemoDigital,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  Text(
                    StringConstant.version,
                    style: textStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Form field wrapper with label and required indicator
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
        // Label with required indicator
        Row(
          children: [
            Text(
              label,
              style: textStyles.formLabel.copyWith(
                color: colors.textPrimary,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: textStyles.formLabel.copyWith(
                  color: colors.error,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Field
        child,
      ],
    );
  }
}

