import 'dart:math' show sin;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_dropdown.dart';
import 'package:travel_crm/core/widgets/app_form_card.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/core/widgets/dial_code_picker/dial_code_picker.dart';
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
            // TOP HEADER (New Inquiry, search, light mode, user)
            _TopHeaderSection(),
            // MAIN CONTENT SECTION (includes Inquiry Form title + left/right content)
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
                          _InquiryFormCard(),
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
                                  child: _InquiryFormCard(),
                                ),
                              ],
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

/// Top header: menu + "New Inquiry" on left; search, light mode, icons, user on right
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
            Color(0xFF1F1A2E),
            Color(0xFF2A2338),
            Color(0xFF352040), // Slight reddish-purple
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Text(
              StringConstant.newInquiry,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            // Search bar
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
            // Light Mode toggle
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

/// Blue wavy line separator below header
class _WavySeparatorLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 12),
      painter: _WavyLinePainter(),
    );
  }
}

class _WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A90D9)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const amplitude = 3.0;
    const frequency = 0.05;
    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 + amplitude * sin(x * frequency * 6.28);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Content title: "Inquiry Form" + subtitle + arrow (used inside main content section)
class _ContentTitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                StringConstant.inquiryForm,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                StringConstant.fillInFormForCustomerInquiry,
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
          centerTitle: true,
          child: Form(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fieldGap = 22.0; // 20-24px spacing

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Title* (full width)
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

                        // 2. Phone Number* | Full Name* (one row)
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
                                label: StringConstant.fullName,
                                isRequired: true,
                                child: AppTextField(
                                  hint: StringConstant.enterFullName,
                                  value: [state.firstName, state.lastName].where((s) => s.isNotEmpty).join(' ').trim(),
                                  errorText: state.firstNameError ?? state.lastNameError,
                                  onChanged: (value) {
                                    final parts = value.trim().split(RegExp(r'\s+'));
                                    final first = parts.isNotEmpty ? parts.first : '';
                                    final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
                                    context.read<InquiryBloc>().add(FirstNameChanged(first));
                                    context.read<InquiryBloc>().add(LastNameChanged(last));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: fieldGap),

                        // 3. E-mail | Type of Client* (one row)
                        Row(
                          children: [
                            Expanded(
                              child: _FormFieldWrapper(
                                label: StringConstant.email,
                                isRequired: false,
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
                            SizedBox(width: fieldGap),
                            Expanded(
                              child: _FormFieldWrapper(
                                label: StringConstant.typeOfClient,
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
                                      if (value == BookingType.flight) {
                                        context.go(PathConstant.airTicket);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: fieldGap),

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
                            onChanged: (value) =>
                                context.read<InquiryBloc>().add(AddressChanged(value)),
                          ),
                        ),
                        SizedBox(height: fieldGap),

                        // 5. Reference Number* | Refrence Name* (one row)
                        Row(
                          children: [
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
                            SizedBox(width: fieldGap),
                            Expanded(
                              child: _FormFieldWrapper(
                                label: StringConstant.referenceNameLabel,
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
                          ],
                        ),
                        SizedBox(height: fieldGap),

                        // 6. Client Behaviour* (full width)
                        _FormFieldWrapper(
                          label: StringConstant.clientBehaviour,
                          isRequired: true,
                          child: AppTextField(
                            hint: StringConstant.enterClientBehaviour,
                            maxLines: 2,
                            minLines: 2,
                            value: state.clientBehaviour,
                            errorText: state.clientBehaviourError,
                            onChanged: (value) =>
                                context.read<InquiryBloc>().add(ClientBehaviourChanged(value)),
                          ),
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

