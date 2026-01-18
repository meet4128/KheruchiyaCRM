import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/pages/pages.dart';
import '../../features/presentation/dashboard/bloc/navigation_bloc.dart';
import '../../features/presentation/dashboard/bloc/navigation_event.dart';
import '../../features/presentation/dashboard/view/dashboard_shell.dart';

FutureOr<String?> globalRedirect(BuildContext context, GoRouterState state) async {
  // bool isLoggedIn = SharedPrefUtils.getValue(SharedPrefUtilsKeys.isLoggedIn, false);
  // bool isRememberMe = SharedPrefUtils.getValue(SharedPrefUtilsKeys.isRememberMe, false);
  //
  // if (state.uri.toString() == PathConstant.forgotPassword) {
  //   return PathConstant.forgotPassword;
  // }
  // if ((isLoggedIn || isRememberMe) && state.uri.toString() == PathConstant.login) {
  //   return PathConstant.dashBoard;
  // }
  // if (!isLoggedIn && !isRememberMe) {
  //   return PathConstant.login;
  // }
  return null;
}

String _pathFor(NavPage page) {
  switch (page) {
    case NavPage.dashboard:
      return PathConstant.dashboard;
    case NavPage.clientLeads:
      return PathConstant.clientLeads;
    case NavPage.inquiry:
      return PathConstant.inquiryView;
    case NavPage.projectJobs:
      return PathConstant.projectJobs;
    case NavPage.invoices:
      return PathConstant.invoices;
    case NavPage.payments:
      return PathConstant.payments;
    case NavPage.inventory:
      return PathConstant.inventory;
    case NavPage.team:
      return PathConstant.team;
    case NavPage.reminders:
      return PathConstant.reminders;
    case NavPage.analysis:
      return PathConstant.analysis;
  }
}

NavPage _pageFromPath(String path) {
  final p = path.split('?').first;
  switch (p) {
    case PathConstant.dashboard:
      return NavPage.dashboard;
    case PathConstant.clientLeads:
      return NavPage.clientLeads;
    case PathConstant.inquiryView:
      return NavPage.inquiry;
    case PathConstant.projectJobs:
      return NavPage.projectJobs;
    case PathConstant.invoices:
      return NavPage.invoices;
    case PathConstant.payments:
      return NavPage.payments;
    case PathConstant.inventory:
      return NavPage.inventory;
    case PathConstant.team:
      return NavPage.team;
    case PathConstant.reminders:
      return NavPage.reminders;
    case PathConstant.analysis:
      return NavPage.analysis;
    default:
      return NavPage.dashboard;
  }
}

/// Provides a GoRouter that syncs with the NavigationBloc.
/// Usage: Wrap app with BlocProvider<NavigationBloc> and pass the bloc here.
String _currentRouterLocation(GoRouter router) {
  return router.routeInformationProvider.value.uri.toString();
}

GoRouter createRouter(NavigationBloc navBloc) {
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return DashboardShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: PathConstant.dashboard,
            pageBuilder: (context, state) => NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: PathConstant.clientLeads,
            name: 'clientLeads',
            pageBuilder: (context, state) => NoTransitionPage(child: ClientLeadsPage()),
          ),

          GoRoute(
            path: PathConstant.inquiryView,
            name: 'inquiryView',
            pageBuilder: (context, state) => NoTransitionPage(child: InquiryViewPage()),
          ),
          GoRoute(
            path: PathConstant.projectJobs,
            name: 'projectJobs',
            pageBuilder: (context, state) => NoTransitionPage(child: ProjectJobsPage()),
          ),
          GoRoute(
            path: PathConstant.invoices,
            name: 'invoices',
            pageBuilder: (context, state) => NoTransitionPage(child: InvoicesPage()),
          ),
          GoRoute(
            path: PathConstant.payments,
            name: 'payments',
            pageBuilder: (context, state) => NoTransitionPage(child: PaymentsPage()),
          ),
          GoRoute(
            path: PathConstant.inventory,
            name: 'inventory',
            pageBuilder: (context, state) => NoTransitionPage(child: InventoryPage()),
          ),
          GoRoute(
            path: PathConstant.team,
            name: 'team',
            pageBuilder: (context, state) => NoTransitionPage(child: TeamPage()),
          ),
          GoRoute(
            path: PathConstant.reminders,
            name: 'reminders',
            pageBuilder: (context, state) => NoTransitionPage(child: RemindersPage()),
          ),
          GoRoute(
            path: PathConstant.analysis,
            name: 'analysis',
            pageBuilder: (context, state) => NoTransitionPage(child: AnalysisPage()),
          ),
          GoRoute(
            path: PathConstant.airTicket,
            name: 'airTicket',
            pageBuilder: (context, state) => NoTransitionPage(child: AirTicketViewPage()),
          ),
        ],
      ),
    ],

    /// When the router location changes (back/forward in browser or direct URL),
    /// sync it into the NavigationBloc.
    // refreshListenable: GoRouterRefreshStream(navBloc.stream.map((s) => s.currentPage)),
    // redirect: (context, state) {
    //   // We don't want to block navigation; sync happens in a listener below.
    //   return null;
    // },
    redirect: (context, state) async {
      // Handle global redirects
      String? redirect = await globalRedirect(context, state);
      if (redirect != null) return redirect;

      // // Handle loyalty path redirects
      // if (state.uri.path == PathConstant.loyalty) {
      //   return PathConstant.loyaltyRewards;
      // }

      return null;
    },
  );

  /*void syncBlocWithRouter() {
    final currentPath = _currentRouterLocation(router);
    final page = _pageFromPath(currentPath);
    // Only sync if the path maps to a known NavPage (not a sub-route like air-ticket)
    // Check if current path is one of the known NavPage paths
    final knownPaths = [
      PathConstant.dashboard,
      PathConstant.clientLeads,
      PathConstant.inquiryView,
      PathConstant.projectJobs,
      PathConstant.invoices,
      PathConstant.payments,
      PathConstant.inventory,
      PathConstant.team,
      PathConstant.reminders,
      PathConstant.analysis,
    ];
    final pathWithoutQuery = currentPath.split('?').first;
    if (knownPaths.contains(pathWithoutQuery)) {
      navBloc.add(SyncPageFromRouteEvent(page));
    }
  }*/

  // Track if we're currently syncing from router to prevent navigation loops
  bool _isSyncingFromRouter = false;

  void syncBlocWithRouter() {
    final currentPath = _currentRouterLocation(router);
    final pathWithoutQuery = currentPath.split('?').first;
    final page = _pageFromPath(currentPath);
    
    // Only sync if the path maps to a known NavPage (not a sub-route like air-ticket)
    final knownPaths = [
      PathConstant.dashboard,
      PathConstant.clientLeads,
      PathConstant.inquiryView,
      PathConstant.projectJobs,
      PathConstant.invoices,
      PathConstant.payments,
      PathConstant.inventory,
      PathConstant.team,
      PathConstant.reminders,
      PathConstant.analysis,
    ];
    
    if (knownPaths.contains(pathWithoutQuery)) {
      // Only sync if the page actually changed to prevent unnecessary updates
      if (navBloc.state.currentPage != page) {
        _isSyncingFromRouter = true;
        navBloc.add(SyncPageFromRouteEvent(page));
        // Reset flag after bloc processes the event
        Future.microtask(() {
          _isSyncingFromRouter = false;
        });
      }
    }
  }

  router.routeInformationProvider.addListener(syncBlocWithRouter);
  syncBlocWithRouter();

  // Also listen to bloc changes and push router navigation (menu click).
  navBloc.stream.listen((navState) {
    // Don't navigate if we're currently syncing from router (browser back/forward)
    if (_isSyncingFromRouter) return;
    
    final desiredPath = _pathFor(navState.currentPage);
    final currentPath = _currentRouterLocation(router).split('?').first;
    
    // Don't navigate if:
    // 1. Already on the desired path
    // 2. Current path is a sub-route (like air-ticket) - let browser handle it
    final isSubRoute = ![
      PathConstant.dashboard,
      PathConstant.clientLeads,
      PathConstant.inquiryView,
      PathConstant.projectJobs,
      PathConstant.invoices,
      PathConstant.payments,
      PathConstant.inventory,
      PathConstant.team,
      PathConstant.reminders,
      PathConstant.analysis,
    ].contains(currentPath);
    
    if (currentPath != desiredPath && !isSubRoute) {
      // Use go() to change URL (works on web)
      router.go(desiredPath);
    }
  });

  return router;
}

/// small helper so GoRouter can refresh on bloc emission
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class PathConstant {
  static const String dashboard = '/';
  static const String clientLeads = '/client-leads';
  static const String inquiryView = '/inquiry-view';
  static const String projectJobs = '/project-jobs';
  static const String invoices = '/invoices';
  static const String payments = '/payments';
  static const String inventory = '/inventory';
  static const String team = '/team';
  static const String reminders = '/reminders';
  static const String analysis = '/analysis';
  static const String airTicket = '/air-ticket';

  static const String dashboardConstant = "Dashboard";
  static const String clientLeadsConstant = "Client Leads";
  static const String projectJobsConstant = "Project Jobs";
  static const String invoicesConstant = "Invoices";
  static const String paymentsConstant = "Payments";
  static const String inventoryConstant = "Inventory";
  static const String teamConstant = "Team";
  static const String remindersConstant = "Reminders";
  static const String analysisConstant = "Analysis";
}
