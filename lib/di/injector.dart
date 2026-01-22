import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_management_bloc.dart';

GetIt sl = GetIt.instance;

Future setup() async {
  // shared preference
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // register blocs
  sl.registerFactory(() => InquiryManagementBloc());
}
