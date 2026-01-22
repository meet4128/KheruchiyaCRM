import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/path_constants.dart';
import 'core/constants/string_constants.dart';
import 'di/injector.dart';
import 'features/presentation/dashboard/bloc/navigation_bloc.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await setup();

    runApp(const MyApp());
  }, (error, stackTrace) async {});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navBloc = NavigationBloc();
    final router = createRouter(navBloc);

    return BlocProvider.value(
      value: navBloc,
      child: MaterialApp.router(
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        routeInformationProvider: router.routeInformationProvider,
        debugShowCheckedModeBanner: false,
        title: StringConstant.webCRM,
        theme: ThemeData.light(),
      ),
    );
  }
}
