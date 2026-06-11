import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/traveller_breakdown.dart';

/// State for the Traveller & Class bottom sheet picker (draft selection).
class TravellerClassPickerState extends Equatable {
  const TravellerClassPickerState({
    required this.adultCount,
    required this.childCount,
    required this.infantCount,
    required this.classType,
  });

  final int adultCount;
  final int childCount;
  final int infantCount;
  final String classType;

  int get totalCount => adultCount + childCount + infantCount;

  TravellerBreakdown get breakdown => TravellerBreakdown(
        adultCount: adultCount,
        childCount: childCount,
        infantCount: infantCount,
      );

  bool get canApply => breakdown.isValid;

  TravellerClassPickerState copyWith({
    int? adultCount,
    int? childCount,
    int? infantCount,
    String? classType,
  }) {
    return TravellerClassPickerState(
      adultCount: adultCount ?? this.adultCount,
      childCount: childCount ?? this.childCount,
      infantCount: infantCount ?? this.infantCount,
      classType: classType ?? this.classType,
    );
  }

  @override
  List<Object?> get props => [adultCount, childCount, infantCount, classType];
}

/// Cubit for the Traveller & Class bottom sheet: holds draft counts and class until Apply.
class TravellerClassPickerCubit extends Cubit<TravellerClassPickerState> {
  TravellerClassPickerCubit({
    required TravellerBreakdown initialBreakdown,
    required String initialClassType,
  }) : super(TravellerClassPickerState(
          adultCount: initialBreakdown.adultCount,
          childCount: initialBreakdown.childCount,
          infantCount: initialBreakdown.infantCount,
          classType: initialClassType,
        ));

  void incrementAdult() {
    if (state.totalCount >= TravellerBreakdown.maxTravellers) return;
    emit(state.copyWith(adultCount: state.adultCount + 1));
  }

  void decrementAdult() {
    if (state.adultCount <= 1) return;
    final newAdultCount = state.adultCount - 1;
    final newInfantCount = state.infantCount > newAdultCount
        ? newAdultCount
        : state.infantCount;
    emit(state.copyWith(
      adultCount: newAdultCount,
      infantCount: newInfantCount,
    ));
  }

  void incrementChild() {
    if (state.totalCount >= TravellerBreakdown.maxTravellers) return;
    emit(state.copyWith(childCount: state.childCount + 1));
  }

  void decrementChild() {
    if (state.childCount <= 0) return;
    emit(state.copyWith(childCount: state.childCount - 1));
  }

  void incrementInfant() {
    if (state.totalCount >= TravellerBreakdown.maxTravellers) return;
    if (state.infantCount >= state.adultCount) return;
    emit(state.copyWith(infantCount: state.infantCount + 1));
  }

  void decrementInfant() {
    if (state.infantCount <= 0) return;
    emit(state.copyWith(infantCount: state.infantCount - 1));
  }

  void selectClassType(String classType) {
    emit(state.copyWith(classType: classType));
  }
}
