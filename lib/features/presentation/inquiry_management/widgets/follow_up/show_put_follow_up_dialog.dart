import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/data/repositories/inquiry_repository.dart';
import 'package:travel_crm/data/repositories/purchase_chat_repository.dart';
import 'package:travel_crm/data/repositories/reminder_repository.dart';
import 'package:travel_crm/di/injector.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/follow_up/put_follow_up_dialog.dart';

/// Shows the Put Follow-up dialog. Resolves to the local date of the created
/// calendar event on a successful save (so the caller can redirect the Calendar
/// to that month), or null when closed / saved without a calendar event.
Future<DateTime?> showPutFollowUpDialog(
  BuildContext context, {
  required String inquiryId,
  required String sessionId,
  required String amendmentTypeApi,
  VoidCallback? onSaved,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    builder: (_) => BlocProvider(
      create: (_) => PutFollowUpBloc(
        inquiryRepository: sl<InquiryRepository>(),
        purchaseChatRepository: sl<PurchaseChatRepository>(),
        reminderRepository: sl<ReminderRepository>(),
      )..add(
          PutFollowUpDialogOpened(
            inquiryId: inquiryId,
            sessionId: sessionId,
            amendmentTypeApi: amendmentTypeApi,
          ),
        ),
      child: PutFollowUpDialog(onSaved: onSaved),
    ),
  );
}
