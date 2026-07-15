import 'package:travel_crm/core/utils/shared_pref_utils.dart';
import 'package:travel_crm/data/models/auth/user_role.dart';

/// Thin read-only accessors over the persisted auth session (role + id).
/// Keeps role/permission checks out of widgets and blocs.
class SessionUtils {
  const SessionUtils._();

  /// Current user's role, parsed from the persisted lowercase wire value.
  static UserRole currentRole() => UserRoleX.fromString(
        SharedPrefUtils.getValue<String>(SharedPrefUtilsKeys.userRole, ''),
      );

  /// Current logged-in member id (`AuthUser.id`), empty when unknown.
  static String currentUserId() =>
      SharedPrefUtils.getValue<String>(SharedPrefUtilsKeys.userId, '');

  /// Only `admin` and `sales` may assign inquiries — mirrors the
  /// `PATCH /inquiries/{id}/assign` authorization on the backend.
  static bool canAssignInquiries() {
    final role = currentRole();
    return role == UserRole.admin || role == UserRole.sales;
  }
}
