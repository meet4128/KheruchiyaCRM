import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/features/presentation/client_leads/bloc/client_lead_event.dart';
import 'package:travel_crm/features/presentation/client_leads/bloc/client_lead_state.dart';

class ClientLeadsBloc extends Bloc<ClientLeadsEvent, ClientLeadsState> {
  ClientLeadsBloc() : super(const ClientLeadsState()) {
    on<TabChangedEvent>((event, emit) {
      emit(state.copyWith(selectedTab: event.tab));
    });
    on<TripTypeChangedEvent>((event, emit) {
      emit(state.copyWith(tripType: event.tripType));
    });
    on<RefundPreferenceChangedEvent>((event, emit) {
      emit(state.copyWith(optForFullRefund: event.optForFullRefund));
    });
    on<ServiceSelectedEvent>((event, emit) {
      emit(state.copyWith(selectedService: event.service));
    });
  }
}
