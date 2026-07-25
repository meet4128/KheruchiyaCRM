import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/theme/app_theme.dart';
import 'package:travel_crm/core/widgets/app_form_card.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/core/widgets/form_field_wrapper.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_state.dart';
import 'package:travel_crm/features/presentation/air_ticket/widgets/checklist_section.dart';
import 'package:travel_crm/features/presentation/air_ticket/models/checklist_priority.dart';
import 'bloc/hotel_booking_bloc.dart';
import 'bloc/hotel_booking_event.dart';
import 'bloc/hotel_booking_state.dart';
import 'widgets/amenities_selector.dart';
import 'widgets/budget_range_field.dart';
import 'widgets/hotel_category_selector.dart';
import 'widgets/hotel_search_bar.dart';
import 'widgets/meal_plan_selector.dart';
import 'widgets/property_type_selector.dart';
import 'widgets/room_view_selector.dart';
import 'widgets/transfers_selector.dart';

/// Hotel Booking Form Screen - Main content area.
/// Renders header, form card, and checklist section.
class HotelBookingFormScreen extends StatelessWidget {
  const HotelBookingFormScreen({super.key, this.inquirySnapshot});

  /// Inquiry form data from previous screen (when user came via Hotel selection).
  final InquiryState? inquirySnapshot;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelBookingBloc, HotelBookingState>(
      builder: (context, state) {
        final colors = AppTheme.colors(context);
        return LoadingOverlay(
          isLoading:
              state.submissionStatus == HotelBookingSubmissionStatus.submitting,
          color: colors.backgroundDark.withOpacity(0.6),
          progressIndicator: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colors.secondary),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1200;
              final isTablet =
                  constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

              return SingleChildScrollView(
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
                      // 1. Inquiry Form section header
                      _SectionHeaderBar(
                        title: StringConstant.inquiryForm,
                        subtitle: StringConstant.fillInFormForCustomerInquiry,
                        trailing: const _ChevronCircleIcon(),
                      ),
                      const SizedBox(height: 16),
                      // 2. Hotel Booking Form section header
                      const _HotelBookingFormSectionHeader(),
                      const SizedBox(height: 16),
                      // 3. Hotel Booking Form Card
                      const _HotelBookingFormCard(),
                      const SizedBox(height: 32),
                      // 4. Checklist Section
                      _ChecklistSectionWidget(inquirySnapshot: inquirySnapshot),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Reusable section header bar: dark card with title, subtitle, and trailing.
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

/// Hotel Booking Form section header: text directly on dark background.
class _HotelBookingFormSectionHeader extends StatelessWidget {
  const _HotelBookingFormSectionHeader();

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
              StringConstant.hotelBookingForm,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              StringConstant.provideHotelBookingInformation,
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

/// Hotel Booking Form Card — search bar, selectors, budget, remark.
class _HotelBookingFormCard extends StatelessWidget {
  const _HotelBookingFormCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelBookingBloc, HotelBookingState>(
      builder: (context, state) {
        final bloc = context.read<HotelBookingBloc>();
        return AppFormCard(
          borderGlow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top search summary bar
              HotelSearchBar(
                city: state.city,
                checkInDate: state.checkInDate,
                checkOutDate: state.checkOutDate,
                rooms: state.rooms,
                adults: state.adults,
                cityError: state.cityError,
                checkInError: state.checkInError,
                checkOutError: state.checkOutError,
                roomGuestsError: state.roomGuestsError,
                onCityChanged: (v) => bloc.add(CityChanged(v)),
                onCheckInChanged: (d) => bloc.add(CheckInDateChanged(d)),
                onCheckOutChanged: (d) => bloc.add(CheckOutDateChanged(d)),
                onRoomsChanged: (v) => bloc.add(RoomsChanged(v)),
                onAdultsChanged: (v) => bloc.add(AdultsChanged(v)),
              ),
              const SizedBox(height: 24),

              FormFieldWrapper(
                label: StringConstant.propertyType,
                isRequired: true,
                child: PropertyTypeSelector(
                  selectedTypes: state.propertyType,
                  onToggle: (t) => bloc.add(PropertyTypeToggled(t)),
                  errorText: state.propertyTypeError,
                ),
              ),
              const SizedBox(height: 22),

              FormFieldWrapper(
                label: StringConstant.hotelCategory,
                isRequired: true,
                child: HotelCategorySelector(
                  selectedCategories: state.hotelCategory,
                  onToggle: (c) => bloc.add(HotelCategoryToggled(c)),
                  errorText: state.hotelCategoryError,
                ),
              ),
              const SizedBox(height: 22),

              FormFieldWrapper(
                label: StringConstant.roomView,
                child: RoomViewSelector(
                  selectedViews: state.roomViews,
                  onToggle: (v) => bloc.add(RoomViewToggled(v)),
                ),
              ),
              const SizedBox(height: 22),

              FormFieldWrapper(
                label: StringConstant.amenities,
                child: AmenitiesSelector(
                  selectedAmenities: state.amenities,
                  onToggle: (a) => bloc.add(AmenityToggled(a)),
                ),
              ),
              const SizedBox(height: 22),

              FormFieldWrapper(
                label: StringConstant.mealPlan,
                child: MealPlanSelector(
                  selectedMealPlans: state.mealPlan,
                  onToggle: (m) => bloc.add(MealPlanToggled(m)),
                ),
              ),
              const SizedBox(height: 22),

              FormFieldWrapper(
                label: StringConstant.transfers,
                child: TransfersSelector(
                  selectedTransfers: state.transfers,
                  onToggle: (t) => bloc.add(TransferToggled(t)),
                ),
              ),
              const SizedBox(height: 22),

              FormFieldWrapper(
                label: StringConstant.yourBudget,
                child: BudgetRangeField(
                  min: state.budgetMin,
                  max: state.budgetMax,
                  errorText: state.budgetError,
                  onMinChanged: (v) => bloc.add(BudgetMinChanged(v)),
                  onMaxChanged: (v) => bloc.add(BudgetMaxChanged(v)),
                ),
              ),
              const SizedBox(height: 22),

              FormFieldWrapper(
                label: StringConstant.remark,
                isRequired: true,
                child: AppTextField(
                  hint: StringConstant.enterRemark,
                  value: state.remark,
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

/// Checklist Section Widget.
class _ChecklistSectionWidget extends StatelessWidget {
  const _ChecklistSectionWidget({this.inquirySnapshot});

  final InquiryState? inquirySnapshot;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HotelBookingBloc, HotelBookingState>(
      builder: (context, state) {
        final bloc = context.read<HotelBookingBloc>();
        return ChecklistSection(
          items: state.checklistItems,
          users: state.checklistUsers,
          dueDate: state.checklistDueDate,
          priority: state.checklistPriority,
          category: state.checklistCategory,
          inLoop: state.checklistInLoop,
          repeat: state.checklistRepeat,
          onUsersChanged: (users) => bloc.add(ChecklistUserChanged(users)),
          onDueDateChanged: (date) => bloc.add(ChecklistDueDateChanged(date)),
          onDueTimeChanged: (time) => bloc.add(ChecklistDueTimeChanged(time)),
          onPriorityChanged: (ChecklistPriority priority) =>
              bloc.add(ChecklistPriorityChanged(priority)),
          onCategoryChanged: (category) =>
              bloc.add(ChecklistCategoryChanged(category)),
          onInLoopChanged: (inLoop) => bloc.add(ChecklistInLoopChanged(inLoop)),
          onRepeatChanged: (repeat) => bloc.add(ChecklistRepeatChanged(repeat)),
          onAddItem: () => bloc.add(const AddChecklistItem()),
          onRemoveItem: (index) => bloc.add(RemoveChecklistItem(index)),
          onSubmit: () {
            debugPrint(
                '[HotelBooking Form] Submit pressed — building request and sending.');
            bloc.add(SubmitHotelBooking(inquiryState: inquirySnapshot));
          },
          isSubmitting: state.isSubmitting,
          isValid: state.isValid,
        );
      },
    );
  }
}
