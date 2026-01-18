import 'package:travel_crm/features/presentation/client_leads/client_leads.dart';

class ClientLeadsState {
  const ClientLeadsState({
    this.selectedTab = InquiryTab.airTicket,
    this.tripType = TripType.oneWay,
    this.optForFullRefund = false,
    this.selectedService = TravelService.passportAssistance,
  });

  final InquiryTab selectedTab;
  final TripType tripType;
  final bool optForFullRefund;
  final TravelService selectedService;

  ClientLeadsState copyWith({
    InquiryTab? selectedTab,
    TripType? tripType,
    bool? optForFullRefund,
    TravelService? selectedService,
  }) {
    return ClientLeadsState(
      selectedTab: selectedTab ?? this.selectedTab,
      tripType: tripType ?? this.tripType,
      optForFullRefund: optForFullRefund ?? this.optForFullRefund,
      selectedService: selectedService ?? this.selectedService,
    );
  }
}
