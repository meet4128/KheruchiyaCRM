import 'package:flutter/material.dart';
import 'package:travel_crm/core/widgets/auth/auth_page_scaffold.dart';
import 'package:travel_crm/features/presentation/set_password/view/password_setter_card.dart';

/// Public route landed on by a forgot-password email link:
/// `/reset-password?token=…`.
///
/// Identical chrome / form to [SetPasswordScreen]; the underlying bloc
/// (`ResetPasswordBloc`) differs in which API endpoint it hits and what it
/// does on success.
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthPageScaffold(
      card: PasswordSetterCard(mode: PasswordSetterMode.resetPassword),
    );
  }
}
