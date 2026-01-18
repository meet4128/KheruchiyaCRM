import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/client_leads/bloc/client_lead_bloc.dart';
import 'package:travel_crm/features/presentation/client_leads/bloc/client_lead_event.dart';
import 'package:travel_crm/features/presentation/client_leads/bloc/client_lead_state.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_bloc.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_event.dart';

class ClientLeads extends StatelessWidget {
  const ClientLeads({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientLeadsBloc(),
      child: const _ClientLeadsView(),
    );
  }
}

class _ClientLeadsView extends StatelessWidget {
  const _ClientLeadsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: DimensionConstant.infinity,
      color: ColorConstant.primaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: DimensionConstant.d40,
        vertical: DimensionConstant.d32,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringConstant.inquiryForm,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DimensionConstant.d24),
              const _InquiryTabs(),
              const SizedBox(height: DimensionConstant.d32),
              const _InquirySearchPanel(),
              const SizedBox(height: DimensionConstant.d32),
              const _AdditionalServicesSection(),
              const SizedBox(height: DimensionConstant.d24),
              BlocBuilder<ClientLeadsBloc, ClientLeadsState>(
                builder: (context, state) {
                  return Text(
                    '${StringConstant.selected}${state.selectedTab.label}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InquiryTabs extends StatelessWidget {
  const _InquiryTabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientLeadsBloc, ClientLeadsState>(
      buildWhen: (previous, current) =>
          previous.selectedTab != current.selectedTab,
      builder: (context, state) {
        final tabs = InquiryTab.values;
        return Container(
          padding: const EdgeInsets.all(DimensionConstant.d6),
          decoration: BoxDecoration(
            color: const Color(0xFF161424),
            borderRadius: BorderRadius.circular(DimensionConstant.d20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: tabs
                .map(
                  (tab) => Expanded(
                    child: _InquiryTabButton(
                      tab: tab,
                      isSelected: tab == state.selectedTab,
                      onTap: () => context.read<ClientLeadsBloc>().add(
                        TabChangedEvent(tab),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _InquiryTabButton extends StatelessWidget {
  const _InquiryTabButton({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final InquiryTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration = isSelected
        ? BoxDecoration(
            color: ColorConstant.selectedTabColor,
            borderRadius: BorderRadius.circular(DimensionConstant.d18),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          )
        : BoxDecoration(
            color: Colors.white.withOpacity(DimensionConstant.d0_1),
            borderRadius: BorderRadius.circular(DimensionConstant.d18),
            border: Border.all(color: Colors.white10),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d6),
      child: InkWell(
        borderRadius: BorderRadius.circular(DimensionConstant.d18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(
            horizontal: DimensionConstant.d18,
            vertical: DimensionConstant.d20,
          ),
          decoration: decoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.flight_takeoff,
                color: isSelected ? Colors.white : Colors.white70,
              ),
              const SizedBox(height: DimensionConstant.d12),
              Text(
                tab.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InquirySearchPanel extends StatelessWidget {
  const _InquirySearchPanel();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientLeadsBloc, ClientLeadsState>(
      builder: (context, state) {
        return Container(
          width: DimensionConstant.infinity,
          padding: const EdgeInsets.all(DimensionConstant.d24),
          decoration: BoxDecoration(
            color: ColorConstant.selectedTabColor,
            borderRadius: BorderRadius.circular(DimensionConstant.d25),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: DimensionConstant.d20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TripTypeSelector(selected: state.tripType),
              const SizedBox(height: DimensionConstant.d20),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: DimensionConstant.d20),
              _JourneyDetailsRow(tripType: state.tripType),
              const SizedBox(height: DimensionConstant.d24),
              _RefundToggle(isChecked: state.optForFullRefund),
            ],
          ),
        );
      },
    );
  }
}

class _TripTypeSelector extends StatelessWidget {
  const _TripTypeSelector({required this.selected});

  final TripType selected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DimensionConstant.d12,
      runSpacing: DimensionConstant.d12,
      children: TripType.values
          .map(
            (trip) => _TripTypeChip(
              tripType: trip,
              isSelected: trip == selected,
              onTap: () => context.read<ClientLeadsBloc>().add(
                TripTypeChangedEvent(trip),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TripTypeChip extends StatelessWidget {
  const _TripTypeChip({
    required this.tripType,
    required this.isSelected,
    required this.onTap,
  });

  final TripType tripType;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gradientColors = isSelected
        ? const [Color(0xFF8046FF), Color(0xFFB24BFF)]
        : [Colors.transparent, Colors.transparent];

    return InkWell(
      borderRadius: BorderRadius.circular(DimensionConstant.d30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: DimensionConstant.d24,
          vertical: DimensionConstant.d12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: gradientColors) : null,
          borderRadius: BorderRadius.circular(DimensionConstant.d30),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.12),
          ),
          color: isSelected ? null : const Color(0xFF1E1C2D),
        ),
        child: Text(
          tripType.label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _JourneyDetailsRow extends StatelessWidget {
  const _JourneyDetailsRow({required this.tripType});

  final TripType tripType;

  @override
  Widget build(BuildContext context) {
    const tileSpacing = SizedBox(width: DimensionConstant.d12);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _InfoTile(
            label: StringConstant.fromLabel,
            value: StringConstant.defaultFromLocation,
            sublabel: StringConstant.defaultAirportFrom,
          ),
        ),
        tileSpacing,
        const _SwapIcon(),
        tileSpacing,
        Expanded(
          flex: 2,
          child: _InfoTile(
            label: StringConstant.toLabel,
            value: StringConstant.defaultToLocation,
            sublabel: StringConstant.defaultAirportTo,
          ),
        ),
        tileSpacing,
        Expanded(
          flex: 2,
          child: _InfoTile(
            label: StringConstant.departure,
            value: StringConstant.defaultDepartureDate,
            sublabel: StringConstant.defaultAirportTo,
          ),
        ),
        tileSpacing,
        Expanded(
          flex: 2,
          child: _InfoTile(
            label: StringConstant.returnLabel,
            value: tripType == TripType.oneWay
                ? '—'
                : StringConstant.defaultDepartureDate,
            sublabel: tripType == TripType.oneWay
                ? StringConstant.selectIfNeeded
                : StringConstant.flexibleDate,
          ),
        ),
        tileSpacing,
        Expanded(
          flex: 2,
          child: _InfoTile(
            label: StringConstant.travellerAndClass,
            value: StringConstant.defaultTraveller,
            sublabel: StringConstant.modifyWhenSearching,
          ),
        ),
        tileSpacing,
        const _SearchButton(),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.sublabel,
  });

  final String label;
  final String value;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DimensionConstant.d18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1829),
        borderRadius: BorderRadius.circular(DimensionConstant.d20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: DimensionConstant.d10),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DimensionConstant.d4),
          Text(
            sublabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }
}

class _SwapIcon extends StatelessWidget {
  const _SwapIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DimensionConstant.d45,
      height: DimensionConstant.d45,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C2D),
        borderRadius: BorderRadius.circular(DimensionConstant.d16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Icon(Icons.sync_alt, color: Colors.white70),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: DimensionConstant.d24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DimensionConstant.d20),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {},
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B4BFF), Color(0xFFB74CFF)],
            ),
            borderRadius: BorderRadius.circular(DimensionConstant.d20),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              StringConstant.search,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RefundToggle extends StatelessWidget {
  const _RefundToggle({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<ClientLeadsBloc>().add(
        RefundPreferenceChangedEvent(!isChecked),
      ),
      child: Row(
        children: [
          Container(
            width: DimensionConstant.d24,
            height: DimensionConstant.d24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DimensionConstant.d6),
              border: Border.all(
                color: isChecked ? Colors.purpleAccent : Colors.white54,
              ),
              color: isChecked ? const Color(0xFF7B4BFF) : Colors.transparent,
            ),
            child: isChecked
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: DimensionConstant.d12),
          Text(
            StringConstant.optForFullRefund,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdditionalServicesSection extends StatelessWidget {
  const _AdditionalServicesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ClientLeadsBloc, ClientLeadsState>(
      buildWhen: (previous, current) =>
          previous.selectedService != current.selectedService,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              StringConstant.everythingNeedTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DimensionConstant.d20),
            Wrap(
              spacing: DimensionConstant.d16,
              runSpacing: DimensionConstant.d16,
              children: TravelService.values
                  .map(
                    (service) => _ServiceTextField(
                      service: service,
                      isSelected: service == state.selectedService,
                      onTap: () {
                        context
                            .read<ClientLeadsBloc>()
                            .add(ServiceSelectedEvent(service));
                        // Jump to the dedicated inquiry form when a lead taps a service.
                        context
                            .read<NavigationBloc>()
                            .add(ChangePageEvent(NavPage.inquiry));
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _ServiceTextField extends StatelessWidget {
  const _ServiceTextField({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  final TravelService service;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? Colors.purpleAccent
        : Colors.white.withOpacity(0.2);
    final fillColor = isSelected
        ? const Color(0xFF2A1F3F)
        : const Color(0xFF131022);

    return SizedBox(
      width: 210,
      child: TextFormField(
        readOnly: true,
        initialValue: service.label,
        onTap: onTap,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(service.icon, color: Colors.white),
          filled: true,
          fillColor: fillColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: DimensionConstant.d18,
            horizontal: DimensionConstant.d12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DimensionConstant.d20),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DimensionConstant.d20),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DimensionConstant.d20),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }
}

enum InquiryTab {
  airTicket,
  domesticPackage,
  internationalPackage,
  hotelBooking,
}

extension InquiryTabName on InquiryTab {
  String get label {
    switch (this) {
      case InquiryTab.airTicket:
        return StringConstant.airTicket;
      case InquiryTab.domesticPackage:
        return StringConstant.domesticPackage;
      case InquiryTab.internationalPackage:
        return StringConstant.internationalPackage;
      case InquiryTab.hotelBooking:
        return StringConstant.hotelBooking;
    }
  }
}

enum TravelService {
  passportAssistance,
  visitorVisa,
  travelInsurance,
  forex,
  taxi,
}

extension TravelServiceMeta on TravelService {
  String get label {
    switch (this) {
      case TravelService.passportAssistance:
        return StringConstant.passportAssistance;
      case TravelService.visitorVisa:
        return StringConstant.visitorVisa;
      case TravelService.travelInsurance:
        return StringConstant.travelInsurance;
      case TravelService.forex:
        return StringConstant.forex;
      case TravelService.taxi:
        return StringConstant.taxi;
    }
  }

  IconData get icon {
    switch (this) {
      case TravelService.passportAssistance:
        return Icons.badge_outlined;
      case TravelService.visitorVisa:
        return Icons.airplane_ticket_outlined;
      case TravelService.travelInsurance:
        return Icons.health_and_safety_outlined;
      case TravelService.forex:
        return Icons.currency_exchange;
      case TravelService.taxi:
        return Icons.directions_car;
    }
  }
}

enum TripType {
  oneWay,
  roundTrip,
  multiCity,
}

extension TripTypeLabel on TripType {
  String get label {
    switch (this) {
      case TripType.oneWay:
        return StringConstant.oneWay;
      case TripType.roundTrip:
        return StringConstant.roundTrip;
      case TripType.multiCity:
        return StringConstant.multiCity;
    }
  }
}

