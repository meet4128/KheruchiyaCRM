import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_crm/core/network/apis.dart';
import 'package:travel_crm/core/network/dio_client.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/repositories/auth_repository.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import 'package:travel_crm/data/repositories/members_repository.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_management_bloc.dart';

GetIt sl = GetIt.instance;

Future setup() async {
  // shared preference
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // inquiry API (Create Inquiry) — use DioClient so Authorization header is sent
  sl.registerLazySingleton<InquiryApiClient>(
    () => InquiryApiClient(
      DioClient.getInstance(),
      baseUrl: Apis.inquiryBaseUrl,
    ),
  );
  sl.registerLazySingleton<InquiryRepository>(
    () => InquiryRepository(sl<InquiryApiClient>()),
  );
  sl.registerLazySingleton<MembersRepository>(
    () => MembersRepository(sl<InquiryApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(AuthRepository.new);

  // register blocs
  sl.registerLazySingleton(() => InquiryManagementBloc(inquiryRepository: sl<InquiryRepository>()));
}
