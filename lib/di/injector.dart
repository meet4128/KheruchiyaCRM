import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_crm/core/network/apis.dart';
import 'package:travel_crm/core/network/dio_client.dart';
import 'package:travel_crm/core/network/inquiry_api_client.dart';
import 'package:travel_crm/data/repositories/auth_repository.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import 'package:travel_crm/data/repositories/members_repository.dart';
import 'package:travel_crm/data/repositories/purchase_chat_repository.dart';
import 'package:travel_crm/features/presentation/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_detail/inquiry_detail_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_form/bloc/inquiry_bloc.dart';
import 'package:travel_crm/features/presentation/vendor_inquiry/bloc/vendor_inquiry_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/inquiry_management_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_bloc.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_chat/purchase_team_chat_bloc.dart';
import 'package:travel_crm/features/presentation/purchase_team/bloc/purchase_team_directory/purchase_team_directory_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/vendor_inquiry_row.dart';
import 'package:travel_crm/features/presentation/reset_password/bloc/reset_password_bloc.dart';
import 'package:travel_crm/features/presentation/set_password/bloc/set_password_bloc.dart';

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
  sl.registerLazySingleton<PurchaseChatRepository>(
    () => PurchaseChatRepository(sl<InquiryApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(AuthRepository.new);

  // register blocs
  sl.registerLazySingleton(() => InquiryManagementBloc(inquiryRepository: sl<InquiryRepository>()));
  sl.registerLazySingleton(() => InquiryBloc());
  sl.registerLazySingleton(() => VendorInquiryBloc());
  sl.registerFactoryParam<InquiryDetailBloc, VendorInquiryRow?, void>(
    (vendorRow, _) => InquiryDetailBloc(
      inquiryRepository: sl<InquiryRepository>(),
      initialVendorRow: vendorRow,
    ),
  );
  sl.registerFactory(
    () => QnaChatBloc(inquiryRepository: sl<InquiryRepository>()),
  );
  sl.registerFactory(
    () => PurchaseTeamDirectoryBloc(repository: sl<PurchaseChatRepository>()),
  );
  sl.registerFactory(
    () => PurchaseTeamChatBloc(repository: sl<PurchaseChatRepository>()),
  );

  // Public-auth flows (invite / forgot / reset). All three are factories —
  // each page mount must get a fresh bloc because they validate a single
  // one-shot token.
  sl.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(authRepository: sl<AuthRepository>()),
  );
  sl.registerFactory<SetPasswordBloc>(
    () => SetPasswordBloc(authRepository: sl<AuthRepository>()),
  );
  sl.registerFactory<ResetPasswordBloc>(
    () => ResetPasswordBloc(authRepository: sl<AuthRepository>()),
  );
}
