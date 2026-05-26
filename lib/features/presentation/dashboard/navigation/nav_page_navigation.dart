import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_crm/core/constants/path_constants.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_bloc.dart';
import 'package:travel_crm/features/presentation/dashboard/bloc/navigation_event.dart';

/// Side menu and other UI: update [NavigationBloc] and navigate via GoRouter.
void navigateToNavPage(BuildContext context, NavPage page) {
  context.read<NavigationBloc>().add(ChangePageEvent(page));
  context.go(pathForNavPage(page));
}
