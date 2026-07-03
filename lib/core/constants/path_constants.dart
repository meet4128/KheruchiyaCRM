import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/dio_client.dart';
import '../utils/shared_pref_utils.dart';
import '../../features/pages/pages.dart';
import '../../features/presentation/purchase_team/models/messages_route_args.dart';
import '../../features/presentation/admin_panel/bloc/admin_navigation_bloc.dart';
import '../../features/presentation/dashboard/bloc/navigation_bloc.dart';
import '../../features/presentation/dashboard/bloc/navigation_event.dart';
import '../../features/presentation/admin_panel/view/admin_panel_shell.dart';
import '../../features/presentation/dashboard/view/dashboard_shell.dart';

/// Paths anyone (logged-out OR logged-in) is allowed to visit. Critically,
/// includes the invite / forgot-password / reset-password flows so users who
/// click an emailed link reach the page even when they have no session.
const Set<String> _kPublicAuthPaths = <String>{
  PathConstant.login,
  PathConstant.forgotPassword,
  PathConstant.setPassword,
  PathConstant.resetPassword,
};

FutureOr<String?> globalRedirect(BuildContext context, GoRouterState state) async {
  final path = state.uri.path.isEmpty ? PathConstant.dashboard : state.uri.path;
  final hasToken = _sessionHasAccessToken();
  final isAdmin = _sessionIsAdmin();

  // Public surface: never redirect away from these. (Logged-in users may still
  // click an invite link in their own browser — let them through. The page
  // itself handles "token invalid / wrong account" via the backend response.)
  if (_kPublicAuthPaths.contains(path)) {
    // One exception: a logged-in user hitting /login directly gets bounced to
    // their landing path so they don't see the login form for no reason.
    if (path == PathConstant.login && hasToken) {
      return isAdmin ? PathConstant.adminPanel : PathConstant.dashboard;
    }
    return null;
  }

  if (!hasToken) {
    return PathConstant.login;
  }

  if (hasToken && isAdmin && path != PathConstant.adminPanel) {
    return PathConstant.adminPanel;
  }

  if (hasToken && !isAdmin && path == PathConstant.adminPanel) {
    return PathConstant.dashboard;
  }

  return null;
}

/// True when a non-empty access token is stored (same source as [DioClient] Bearer).
bool _sessionHasAccessToken() {
  final token = SharedPrefUtils.getValue(SharedPrefUtilsKeys.userToken, '');
  return token.toString().trim().isNotEmpty;
}

bool _sessionIsAdmin() {
  final role = SharedPrefUtils.getValue(SharedPrefUtilsKeys.userRole, '');
  return role.toString().trim().toLowerCase() == 'admin';
}

/// Decides where a freshly-authenticated user should land based on the role
/// returned by `POST /auth/login` → `response.data.user.role`.
///
/// Contract (confirmed with backend):
///   - `admin`  → [PathConstant.adminPanel]
///   - `sales` / `purchase` / `account` / `user` → [PathConstant.dashboard]
///   - anything else → [PathConstant.dashboard] (defensive — never brick the
///     app if the backend introduces a new role).
String landingPathForRole(String? role) {
  switch ((role ?? '').trim().toLowerCase()) {
    case 'admin':
      return PathConstant.adminPanel;
    case 'sales':
    case 'purchase':
    case 'account':
    case 'user':
      return PathConstant.dashboard;
    default:
      return PathConstant.dashboard;
  }
}

/// Top-level GoRouter path for a drawer / [NavPage] item.
String pathForNavPage(NavPage page) {
  switch (page) {
    case NavPage.dashboard:
      return PathConstant.dashboard;
    case NavPage.inquiryManagement:
      return PathConstant.inquiryManagement;
    case NavPage.clientLeads:
      return PathConstant.clientLeads;
    case NavPage.inquiry:
      return PathConstant.inquiryView;
    case NavPage.messages:
      return PathConstant.messages;
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

String normalizeRoutePath(String path) {
  final p = path.split('?').first;
  if (p.isEmpty || p == '/') return PathConstant.dashboard;
  return p;
}

/// Maps current URL (including nested routes) to the active drawer page.
NavPage navPageFromPath(String path) {
  final p = normalizeRoutePath(path);
  if (p == PathConstant.dashboard) return NavPage.dashboard;
  if (p.startsWith(PathConstant.inquiryManagement)) return NavPage.inquiryManagement;
  if (p.startsWith(PathConstant.clientLeads)) return NavPage.clientLeads;
  if (p.startsWith(PathConstant.inquiryView)) return NavPage.inquiry;
  if (p.startsWith(PathConstant.messages)) return NavPage.messages;
  if (p.startsWith(PathConstant.projectJobs)) return NavPage.projectJobs;
  if (p.startsWith(PathConstant.invoices)) return NavPage.invoices;
  if (p.startsWith(PathConstant.payments)) return NavPage.payments;
  if (p.startsWith(PathConstant.inventory)) return NavPage.inventory;
  if (p.startsWith(PathConstant.team)) return NavPage.team;
  if (p.startsWith(PathConstant.reminders)) return NavPage.reminders;
  if (p.startsWith(PathConstant.analysis)) return NavPage.analysis;
  return NavPage.dashboard;
}

/// True when [path] is the root URL for [page] (not a nested child like inquiry detail).
bool isAtNavPageRootPath(String path, NavPage page) {
  final normalized = normalizeRoutePath(path);
  final root = pathForNavPage(page);
  if (page == NavPage.dashboard) {
    return normalized == '/' || normalized == PathConstant.dashboard;
  }
  return normalized == root;
}

/// Full-screen flows that should not overwrite drawer selection when URL changes.
bool shouldSyncBlocFromRoute(String path) {
  final p = normalizeRoutePath(path);
  return !p.startsWith(PathConstant.airTicket) &&
      !p.startsWith(PathConstant.hotelBooking);
}

/// Provides a GoRouter that syncs with the NavigationBloc.
/// Usage: Wrap app with BlocProvider and pass the nav bloc here.
String _currentRouterLocation(GoRouter router) {
  return router.routeInformationProvider.value.uri.toString();
}

GoRouter createRouter(NavigationBloc navBloc) {
  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    // Whenever DioClient detects a dead session it bumps this notifier; the
    // router re-evaluates `redirect`, sees `userToken` is empty, and bounces
    // the user to /login. This means we don't need to scatter
    // "logout-on-401" logic across every bloc.
    refreshListenable: sessionExpiredNotifier,
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
            path: PathConstant.inquiryManagement,
            name: 'inquiryManagement',
            routes: [
              GoRoute(
                path: 'detail',
                name: 'inquiryDetail',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: InquiryManagementDetailPage(),
                ),
              ),
            ],
            pageBuilder: (context, state) => NoTransitionPage(child: InquiryManagementPage()),
          ),

          GoRoute(
            path: PathConstant.clientLeads,
            name: 'clientLeads',
            pageBuilder: (context, state) => NoTransitionPage(child: ClientLeadsPage()),
          ),
          GoRoute(
            path: PathConstant.messages,
            name: 'messages',
            pageBuilder: (context, state) {
              final extra = state.extra;
              final args = extra is MessagesRouteArgs ? extra : null;
              return NoTransitionPage(child: MessagesPage(routeArgs: args));
            },
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
            pageBuilder: (context, state) => NoTransitionPage(
              child: AirTicketViewPage(initialInquiryState: state.extra),
            ),
          ),
          GoRoute(
            path: PathConstant.hotelBooking,
            name: 'hotelBooking',
            pageBuilder: (context, state) => NoTransitionPage(
              child: HotelBookingViewPage(initialInquiryState: state.extra),
            ),
          ),
        ],
      ),
      GoRoute(
        path: PathConstant.adminPanel,
        name: 'adminPanel',
        pageBuilder: (context, state) => NoTransitionPage(
          child: BlocProvider(
            create: (_) => AdminNavigationBloc(),
            child: const AdminPanelShell(),
          ),
        ),
      ),
      GoRoute(
        path: PathConstant.login,
        name: 'login',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: PathConstant.forgotPassword,
        name: 'forgotPassword',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: PathConstant.setPassword,
        name: 'setPassword',
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return NoTransitionPage(child: SetPasswordPage(token: token));
        },
      ),
      GoRoute(
        path: PathConstant.resetPassword,
        name: 'resetPassword',
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return NoTransitionPage(child: ResetPasswordPage(token: token));
        },
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
  bool isSyncingFromRouter = false;

  void syncBlocWithRouter() {
    final pathWithoutQuery = normalizeRoutePath(_currentRouterLocation(router));
    if (!shouldSyncBlocFromRoute(pathWithoutQuery)) return;

    final page = navPageFromPath(pathWithoutQuery);
    if (navBloc.state.currentPage != page) {
      isSyncingFromRouter = true;
      navBloc.add(SyncPageFromRouteEvent(page));
      Future.microtask(() {
        isSyncingFromRouter = false;
      });
    }
  }

  router.routeInformationProvider.addListener(syncBlocWithRouter);
  syncBlocWithRouter();

  // Bloc → router (e.g. programmatic page change). Side menu also calls context.go directly.
  navBloc.stream.listen((navState) {
    if (isSyncingFromRouter) return;

    final currentPath = normalizeRoutePath(_currentRouterLocation(router));
    if (isAtNavPageRootPath(currentPath, navState.currentPage)) return;

    router.go(pathForNavPage(navState.currentPage));
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
  static const String adminPanel = '/admin';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String setPassword = '/set-password';
  static const String resetPassword = '/reset-password';
  static const String clientLeads = '/client-leads';
  static const String messages = '/messages';
  static const String inquiryManagement = '/inquiry-management';
  static const String inquiryManagementDetail = '/inquiry-management/detail';
  static const String inquiryView = '/inquiry-view';
  static const String projectJobs = '/project-jobs';
  static const String invoices = '/invoices';
  static const String payments = '/payments';
  static const String inventory = '/inventory';
  static const String team = '/team';
  static const String reminders = '/reminders';
  static const String analysis = '/analysis';
  static const String airTicket = '/air-ticket';
  static const String hotelBooking = '/hotel-booking';

  static const String dashboardConstant = "Dashboard";
  static const String clientLeadsConstant = "Follow Up";
  static const String messagesConstant = "Messages";
  static const String inquiryManagementConstant = "New Inquiry";
  static const String invoicesConstant = "Invoices";
  static const String paymentsConstant = "Payments";
  static const String inventoryConstant = "Inventory";
  static const String teamConstant = "Team";
  static const String remindersConstant = "Reminders";
  static const String analysisConstant = "Analysis";
}
