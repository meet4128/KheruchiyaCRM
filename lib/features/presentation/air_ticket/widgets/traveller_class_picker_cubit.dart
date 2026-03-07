import 'package:flutter_bloc/flutter_bloc.dart';

/// State for the Traveller & Class bottom sheet picker (draft selection).
class TravellerClassPickerState {
  const TravellerClassPickerState({
    required this.travellerCount,
    required this.classType,
  });

  final int travellerCount;
  final String classType;

  TravellerClassPickerState copyWith({
    int? travellerCount,
    String? classType,
  }) {
    return TravellerClassPickerState(
      travellerCount: travellerCount ?? this.travellerCount,
      classType: classType ?? this.classType,
    );
  }
}

/// Cubit for the Traveller & Class bottom sheet: holds draft traveller count and class until Apply.
class TravellerClassPickerCubit extends Cubit<TravellerClassPickerState> {
  TravellerClassPickerCubit({
    required int initialTravellerCount,
    required String initialClassType,
  }) : super(TravellerClassPickerState(
          travellerCount: initialTravellerCount,
          classType: initialClassType,
        ));

  void selectTravellerCount(int count) {
    emit(state.copyWith(travellerCount: count));
  }

  void selectClassType(String classType) {
    emit(state.copyWith(classType: classType));
  }
}
