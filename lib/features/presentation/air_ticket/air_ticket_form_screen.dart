import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_button.dart';
import 'package:travel_crm/core/widgets/app_form_card.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/core/widgets/form_field_wrapper.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/air_ticket_bloc.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/air_ticket_event.dart';
import 'package:travel_crm/features/presentation/air_ticket/bloc/air_ticket_state.dart';
import 'package:travel_crm/features/presentation/air_ticket/models/booking_type.dart';
import 'package:travel_crm/features/presentation/air_ticket/models/priority.dart';
import 'package:travel_crm/features/presentation/air_ticket/models/visa_type.dart';
import 'package:travel_crm/features/presentation/air_ticket/widgets/booking_type_selector.dart';
import 'package:travel_crm/features/presentation/air_ticket/widgets/checklist_section.dart';
import 'package:travel_crm/features/presentation/air_ticket/widgets/flight_details_section.dart';
import 'package:travel_crm/features/presentation/air_ticket/widgets/priority_selector.dart';
import 'package:travel_crm/features/presentation/air_ticket/widgets/visa_type_selector.dart';

import '../../../core/widgets/app_dropdown.dart';

/// Air Ticket Form Screen - Main content area
/// Renders header, form card, and checklist section
class AirTicketFormScreen extends StatelessWidget {
  const AirTicketFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1200;
        final isTablet =
            constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

        return Column(
          children: [
            // TOP HEADER SECTION
            _TopHeaderSection(),

            // MAIN CONTENT SECTION
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide
                        ? 80
                        : isTablet
                        ? 40
                        : 24,
                    vertical: isWide ? 60 : 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Card
                      _AirTicketFormCard(),
                      const SizedBox(height: 32),
                      // Checklist Section
                      _ChecklistSectionWidget(),
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
          colors: [Color(0xFF1F1A2E), Color(0xFF2A2338)],
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
                  StringConstant.airTicketForm,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  StringConstant.provideFlightBookingInformation,
                  style: textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            // Right: Contact info and arrow icon
            Row(
              children: [
                Text(
                  StringConstant.youCanReachUsAnytime,
                  style: textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
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
          ],
        ),
      ),
    );
  }
}

/// Air Ticket Form Card — matches screenshot: no inner title, flight type, details row, visa, remark.
class _AirTicketFormCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AirTicketBloc, AirTicketState>(
      builder: (context, state) {
        return AppFormCard(
          title: null,
          subtitle: null,
          borderGlow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flight Type Selection (One Way, Round Trip, Multi City)
              BookingTypeSelector(
                selectedType: state.bookingType,
                onChanged: (AirTicketBookingType type) =>
                    context.read<AirTicketBloc>().add(BookingTypeChanged(type)),
              ),
              const SizedBox(height: 22),

              // Flight Details Section (From, To, Departure, Return, Traveller & Class, Add another field)
              FlightDetailsSection(
                from: state.from,
                to: state.to,
                departureDate: state.departureDate,
                returnDate: state.returnDate,
                bookingType: state.bookingType,
                travellerCount: state.travellerCount,
                classType: state.classType,
                fromError: state.fromError,
                toError: state.toError,
                departureDateError: state.departureDateError,
                returnDateError: state.returnDateError,
                travellerCountError: state.travellerCountError,
                onFromChanged: (value) => context.read<AirTicketBloc>().add(
                  FromLocationChanged(value),
                ),
                onToChanged: (value) =>
                    context.read<AirTicketBloc>().add(ToLocationChanged(value)),
                onDepartureDateChanged: (date) => context
                    .read<AirTicketBloc>()
                    .add(DepartureDateChanged(date)),
                onReturnDateChanged: (date) =>
                    context.read<AirTicketBloc>().add(ReturnDateChanged(date)),
                onSwapLocations: () =>
                    context.read<AirTicketBloc>().add(SwapLocations()),
                onTravellerCountChanged: (count) => context
                    .read<AirTicketBloc>()
                    .add(TravellerCountChanged(count)),
                onClassTypeChanged: (type) =>
                    context.read<AirTicketBloc>().add(ClassTypeChanged(type)),
                onAddAnotherField: () {
                  // TODO: Implement add another field functionality
                },
              ),
              const SizedBox(height: 22),
              // Type of Visa Selection (Visitor Visa, Student Visa, PR, Work Permit)
              FormFieldWrapper(
                label: StringConstant.typeOfVisa,
                isRequired: false,
                child: VisaTypeSelector(
                  selectedType: state.visaType,
                  onChanged: (VisaType type) =>
                      context.read<AirTicketBloc>().add(VisaTypeChanged(type)),
                  errorText: state.visaTypeError,
                ),
              ),
              const SizedBox(height: 22),
              // Remark Field
              FormFieldWrapper(
                label: StringConstant.remark,
                isRequired: true,
                child: AppTextField(
                  hint: StringConstant.enterRemark,
                  value: state.remark,
                  errorText: state.remarkError,
                  onChanged: (value) =>
                      context.read<AirTicketBloc>().add(RemarkChanged(value)),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Priority and Follow-ups Section
class _PriorityFollowUpsSection extends StatelessWidget {
  const _PriorityFollowUpsSection({
    required this.priority,
    required this.followUpType,
    required this.onPriorityChanged,
    required this.onFollowUpTypeChanged,
  });

  final Priority? priority;
  final String followUpType;
  final ValueChanged<Priority> onPriorityChanged;
  final ValueChanged<String> onFollowUpTypeChanged;

  static const List<String> followUpTypes = [
    StringConstant.email,
    StringConstant.phoneCall,
    StringConstant.sms,
    StringConstant.whatsapp,
    StringConstant.inPerson,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Priority Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    StringConstant.setPriority,
                    style: textStyles.formLabel.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PrioritySelector(
                selectedPriority: priority,
                onChanged: onPriorityChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Follow-ups Section
        Expanded(
          child: FormFieldWrapper(
            label: StringConstant.typeOfFollowUps,
            child: AppDropdown<String>(
              hintText: StringConstant.selectFollowUpType,
              items: followUpTypes,
              itemLabel: (type) => type,
              value: followUpType.isEmpty ? null : followUpType,
              onChanged: (value) {
                if (value != null) {
                  onFollowUpTypeChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom footer section with company name, version, and submit button
class _BottomFooterSection extends StatelessWidget {
  const _BottomFooterSection();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1A2E), Color(0xFF2A2338)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Company name
          Text(
            StringConstant.emoDigital,
            style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
          ),
          // Submit button and version
          Row(
            children: [
              BlocBuilder<AirTicketBloc, AirTicketState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      AppButton(
                        text: StringConstant.submit,
                        onPressed: state.isValid && !state.isSubmitting
                            ? () => context.read<AirTicketBloc>().add(
                                SubmitAirTicket(),
                              )
                            : null,
                        isLoading: state.isSubmitting,
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: colors.textSecondary,
                        ),
                        onPressed: () {
                          // TODO: Implement menu
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 24),
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
  }
}

/// Checklist Section Widget
class _ChecklistSectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AirTicketBloc, AirTicketState>(
      builder: (context, state) {
        return ChecklistSection(
          items: state.checklistItems,
          user: state.checklistUser,
          dueDate: state.checklistDueDate,
          priority: state.checklistPriority,
          category: state.checklistCategory,
          inLoop: state.checklistInLoop,
          repeat: state.checklistRepeat,
          onUserChanged: (value) =>
              context.read<AirTicketBloc>().add(ChecklistUserChanged(value)),
          onDueDateChanged: (date) =>
              context.read<AirTicketBloc>().add(ChecklistDueDateChanged(date)),
          onPriorityChanged: (Priority priority) => context
              .read<AirTicketBloc>()
              .add(ChecklistPriorityChanged(priority)),
          onCategoryChanged: (category) => context.read<AirTicketBloc>().add(
            ChecklistCategoryChanged(category),
          ),
          onInLoopChanged: (inLoop) =>
              context.read<AirTicketBloc>().add(ChecklistInLoopChanged(inLoop)),
          onRepeatChanged: (repeat) =>
              context.read<AirTicketBloc>().add(ChecklistRepeatChanged(repeat)),
          onAddItem: () =>
              context.read<AirTicketBloc>().add(AddChecklistItem()),
          onRemoveItem: (index) =>
              context.read<AirTicketBloc>().add(RemoveChecklistItem(index)),
          onSubmit: () => context.read<AirTicketBloc>().add(SubmitAirTicket()),
          isSubmitting: state.isSubmitting,
          isValid: state.isValid,
        );
      },
    );
  }
}
