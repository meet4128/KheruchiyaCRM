import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/auth/auth_page_scaffold.dart';
import 'package:travel_crm/features/presentation/set_password/view/password_setter_card.dart';

/// Public route landed on by an invite email link: `/set-password?token=…`.
///
/// All UI lives inside the shared [PasswordSetterCard] — this widget just
/// drops the card into the standard auth scaffold so the chrome matches login.
class SetPasswordScreen extends StatelessWidget {
  const SetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageScaffold(
      card: PasswordSetterCard(mode: PasswordSetterMode.setPassword),
    );
  }
}
