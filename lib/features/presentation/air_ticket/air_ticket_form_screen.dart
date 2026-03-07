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
import 'package:travel_crm/features/presentation/air_ticket/models/flight_segment.dart';
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
            // MAIN CONTENT SECTION (Inquiry Form bar, Air Ticket Form bar, form card, checklist)
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
                      // 1. Inquiry Form section header (title + subtitle + chevron)
                      _SectionHeaderBar(
                        title: StringConstant.inquiryForm,
                        subtitle: StringConstant.fillInFormForCustomerInquiry,
                        trailing: _ChevronCircleIcon(),
                      ),
                      const SizedBox(height: 16),
                      // 2. Air Ticket Form section (no card/border — on dark background)
                      _AirTicketFormSectionHeader(),
                      const SizedBox(height: 16),
                      // 3. Air Ticket Form Card
                      _AirTicketFormCard(),
                      const SizedBox(height: 32),
                      // 4. Checklist Section
                      _ChecklistSectionWidget(),
                    ],
                  ),
                ),
              ),
            ),


          ],
        );
      },
    );
  }
}

/// Reusable section header bar: dark card with title, subtitle, and optional trailing (e.g. contact + chevron).
class _SectionHeaderBar extends StatelessWidget {
  const _SectionHeaderBar({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    final textStyles = AppTheme.textStyles(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1A2E), Color(0xFF2A2338)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.borderSecondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: textStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          trailing,
        ],
      ),
    );
  }
}

/// Circular icon with downward chevron (for collapsible section).
class _ChevronCircleIcon extends StatelessWidget {
  const _ChevronCircleIcon();

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colors.inputBackground,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.keyboard_arrow_down,
        color: colors.textPrimary,
        size: 20,
      ),
    );
  }
}

/// Air Ticket Form section header: no card/border, text directly on dark background.
/// Left: title + subtitle. Right: "You can reach us anytime via " + blue email.
class _AirTicketFormSectionHeader extends StatelessWidget {
  const _AirTicketFormSectionHeader();

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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You can reach us anytime via ',
              style: textStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            Text(
              'kthplcrm@mail.com',
              style: textStyles.bodySmall.copyWith(
                color: colors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Air Ticket Form Card — matches screenshot: flight type, multiple bordered flight-detail sections, visa, remark.
class _AirTicketFormCard extends StatelessWidget {
  /// Builds one FlightDetailsSection per segment; each has its own border. First segment has Traveller & Class; last has Add another City.
  static List<Widget> _buildFlightDetailsSections(
    BuildContext context,
    AirTicketState state,
  ) {
    final bloc = context.read<AirTicketBloc>();
    final totalSegments = 1 + state.flightSegments.length;
    final list = <Widget>[];

    // Segment 0 (main state)
    list.add(
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
        onFromChanged: (v) => bloc.add(FromLocationChanged(v)),
        onToChanged: (v) => bloc.add(ToLocationChanged(v)),
        onDepartureDateChanged: (d) => bloc.add(DepartureDateChanged(d)),
        onReturnDateChanged: (d) => bloc.add(ReturnDateChanged(d)),
        onSwapLocations: () => bloc.add(SwapLocations()),
        onTravellerCountChanged: (c) => bloc.add(TravellerCountChanged(c)),
        onClassTypeChanged: (t) => bloc.add(ClassTypeChanged(t)),
        showTravellerClass: true,
        showAddAnotherCity: totalSegments == 1,
        onAddAnotherField: totalSegments == 1 ? () => bloc.add(AddFlightSegment()) : null,
        addAnotherButtonLabel: StringConstant.addAnotherCity,
      ),
    );

    // Extra segments (from flightSegments)
    for (var i = 0; i < state.flightSegments.length; i++) {
      final seg = state.flightSegments[i];
      final isLast = i == state.flightSegments.length - 1;
      list.add(const SizedBox(height: 16));
      list.add(
        FlightDetailsSection(
          from: seg.from,
          to: seg.to,
          departureDate: seg.departureDate,
          returnDate: seg.returnDate,
          bookingType: state.bookingType,
          travellerCount: state.travellerCount,
          classType: state.classType,
          fromError: null,
          toError: null,
          departureDateError: null,
          returnDateError: null,
          travellerCountError: null,
          onFromChanged: (v) => bloc.add(SegmentFromChanged(i, v)),
          onToChanged: (v) => bloc.add(SegmentToChanged(i, v)),
          onDepartureDateChanged: (d) => bloc.add(SegmentDepartureDateChanged(i, d)),
          onReturnDateChanged: (d) => bloc.add(SegmentReturnDateChanged(i, d)),
          onSwapLocations: () => bloc.add(SegmentSwapLocations(i)),
          onTravellerCountChanged: null,
          onClassTypeChanged: null,
          showTravellerClass: false,
          showAddAnotherCity: isLast,
          onAddAnotherField: isLast ? () => bloc.add(AddFlightSegment()) : null,
          addAnotherButtonLabel: StringConstant.addAnotherCity,
          onRemove: () => bloc.add(RemoveFlightSegment(i)),
        ),
      );
    }

    return list;
  }

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

              // Flight Details Sections: one per segment, each with its own border (per screenshot)
              ..._buildFlightDetailsSections(context, state),
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
