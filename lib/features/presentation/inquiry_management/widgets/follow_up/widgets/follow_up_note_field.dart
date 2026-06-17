import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/core/widgets/app_text_field.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/put_follow_up/put_follow_up_state.dart';

class FollowUpNoteField extends StatelessWidget {
  const FollowUpNoteField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PutFollowUpBloc, PutFollowUpState>(
      buildWhen: (p, c) => p.note != c.note || p.noteError != c.noteError,
      builder: (context, state) {
        return AppTextField(
          label: '${StringConstant.addFollowUpNote} *',
          hint: StringConstant.addFollowUpNoteHint,
          value: state.note,
          onChanged: (value) {
            context.read<PutFollowUpBloc>().add(PutFollowUpNoteChanged(value));
          },
          maxLines: 4,
          minLines: 4,
          errorText: state.noteError,
        );
      },
    );
  }
}
