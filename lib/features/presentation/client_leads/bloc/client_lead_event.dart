import '../client_leads.dart';

abstract class ClientLeadsEvent {
  const ClientLeadsEvent();
}

class TabChangedEvent extends ClientLeadsEvent {
  const TabChangedEvent(this.tab);
  final InquiryTab tab;
}

class TripTypeChangedEvent extends ClientLeadsEvent {
  const TripTypeChangedEvent(this.tripType);

  final TripType tripType;
}

class RefundPreferenceChangedEvent extends ClientLeadsEvent {
  const RefundPreferenceChangedEvent(this.optForFullRefund);

  final bool optForFullRefund;
}

class ServiceSelectedEvent extends ClientLeadsEvent {
  const ServiceSelectedEvent(this.service);

  final TravelService service;
}
