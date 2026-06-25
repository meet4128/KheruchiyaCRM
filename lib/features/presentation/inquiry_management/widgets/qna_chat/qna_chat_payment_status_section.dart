import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_crm/core/constants/asset_constants.dart';
import 'package:travel_crm/core/constants/color_constants.dart';
import 'package:travel_crm/core/constants/dimension_constant.dart';
import 'package:travel_crm/core/constants/font_constant.dart';
import 'package:travel_crm/core/constants/string_constants.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_bloc.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_event.dart';
import 'package:travel_crm/features/presentation/inquiry_management/bloc/qna_chat/qna_chat_state.dart';
import 'package:travel_crm/features/presentation/inquiry_management/models/qna_chat_installment_row.dart';
import 'package:travel_crm/features/presentation/inquiry_management/widgets/qna_chat/qna_chat_quick_actions.dart';

/// Payment status selection (One-Time / Installment) shown alongside the
/// quick actions row. Selecting "Installment" reveals an inline payment
/// terms form. Driven by QnaChatBloc.
class QnaChatPaymentStatusSection extends StatelessWidget {
  const QnaChatPaymentStatusSection({
    super.key,
    this.customerName = '',
    this.inquiryId = '',
    this.bookingType,
    this.onAddNotes,
    this.onText,
    this.onCallAgent,
  });

  final String customerName;
  final String inquiryId;
  final String? bookingType;
  final VoidCallback? onAddNotes;
  final VoidCallback? onText;
  final VoidCallback? onCallAgent;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QnaChatBloc, QnaChatState>(
      buildWhen: (previous, current) => previous.paymentStatus != current.paymentStatus,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PaymentStatusDropdown(selected: state.paymentStatus),
                const Spacer(),
                QnaChatQuickActions(
                  onAddNotes: onAddNotes,
                  onText: onText,
                  onCallAgent: onCallAgent,
                ),
              ],
            ),
            if (state.paymentStatus != null) ...[
              const SizedBox(height: DimensionConstant.d20),
              _PaymentTermsForm(
                customerName: customerName,
                inquiryId: inquiryId,
                bookingType: bookingType,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PaymentStatusDropdown extends StatelessWidget {
  const _PaymentStatusDropdown({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selected != null;
    return PopupMenuButton<String>(
      tooltip: StringConstant.qnaChatPaymentStatus,
      color: ColorConstant.cardBgColor,
      onSelected: (value) =>
          context.read<QnaChatBloc>().add(QnaChatPaymentStatusChanged(value)),
      itemBuilder: (context) => StringConstant.qnaChatPaymentStatusOptions
          .map(
            (o) => PopupMenuItem<String>(
              value: o,
              child: Text(
                o,
                style: FontConstant.interNormal(
                  color: ColorConstant.whiteColor,
                  fontSize: DimensionConstant.d13,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DimensionConstant.d15,
          vertical: DimensionConstant.d12,
        ),
        decoration: BoxDecoration(
          color: hasSelection ? null : ColorConstant.blackColor,
          gradient: hasSelection
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [ColorConstant.purple, ColorConstant.indigo],
                )
              : null,
          borderRadius: BorderRadius.circular(DimensionConstant.d4),
          border: hasSelection ? null : Border.all(color: ColorConstant.borderColorWhite30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasSelection
                  ? '${StringConstant.qnaChatPaymentStatus}: $selected'
                  : StringConstant.qnaChatPaymentStatus,
              style: FontConstant.interMedium(
                color: ColorConstant.whiteColor,
                fontSize: DimensionConstant.d12,
              ),
            ),
            const SizedBox(width: DimensionConstant.d6),
            RotatedBox(
              quarterTurns: DimensionConstant.i2,
              child: SvgPicture.asset(
                AssetConstants.icArrowRight,
                height: DimensionConstant.d8,
                width: DimensionConstant.d8,
                colorFilter: const ColorFilter.mode(ColorConstant.whiteColor, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTermsForm extends StatefulWidget {
  const _PaymentTermsForm({
    required this.customerName,
    required this.inquiryId,
    this.bookingType,
  });

  final String customerName;
  final String inquiryId;
  final String? bookingType;

  @override
  State<_PaymentTermsForm> createState() => _PaymentTermsFormState();
}

class _PaymentTermsFormState extends State<_PaymentTermsForm> {
  final TextEditingController _totalAmountController = TextEditingController();
  final Map<String, TextEditingController> _rowControllers = {};
  int _lastShownErrorToken = 0;

  TextEditingController _controllerFor(QnaChatInstallmentRow row) {
    return _rowControllers.putIfAbsent(
      row.id,
      () => TextEditingController(text: row.amountText),
    );
  }

  void _pruneControllers(List<QnaChatInstallmentRow> rows) {
    final validIds = rows.map((r) => r.id).toSet();
    _rowControllers.removeWhere((id, controller) {
      if (validIds.contains(id)) return false;
      controller.dispose();
      return true;
    });
  }

  @override
  void dispose() {
    _totalAmountController.dispose();
    for (final controller in _rowControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickRowDate({
    required BuildContext context,
    required QnaChatInstallmentRow row,
    required bool isDueDate,
  }) async {
    final current = isDueDate ? row.dueDate : row.receivedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ColorConstant.purple,
              surface: ColorConstant.cardBgColor,
            ),
            dialogBackgroundColor: ColorConstant.cardBgColor,
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !context.mounted) return;
    context.read<QnaChatBloc>().add(
          QnaChatInstallmentRowDateChanged(rowId: row.id, isDueDate: isDueDate, date: picked),
        );
  }

  Future<void> _pickTravelDate(BuildContext context, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ColorConstant.purple,
              surface: ColorConstant.cardBgColor,
            ),
            dialogBackgroundColor: ColorConstant.cardBgColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      context.read<QnaChatBloc>().add(QnaChatTravelDateChanged(picked));
    }
  }

  Future<void> _pickTravelTime(BuildContext context, TimeOfDay? current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ColorConstant.purple,
              surface: ColorConstant.cardBgColor,
            ),
            dialogBackgroundColor: ColorConstant.cardBgColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && context.mounted) {
      context.read<QnaChatBloc>().add(QnaChatTravelTimeChanged(picked));
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  String _formattedTravelDate(DateTime? date) => date == null ? '--/--/----' : _formatDate(date);

  String _formattedTravelTime(BuildContext context, TimeOfDay? time) =>
      time?.format(context) ?? '--:--';

  String _statusFor(QnaChatInstallmentRow row) {
    if (row.receivedDate == null) return '-';
    return row.isLate ? StringConstant.qnaChatLate : StringConstant.qnaChatOnTime;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QnaChatBloc, QnaChatState>(
      listenWhen: (previous, current) =>
          previous.totalAmount != current.totalAmount ||
          previous.installmentRows != current.installmentRows ||
          previous.installmentAmountErrorToken != current.installmentAmountErrorToken,
      listener: (context, state) {
        if (_totalAmountController.text != state.totalAmount) {
          _totalAmountController.value = TextEditingValue(
            text: state.totalAmount,
            selection: TextSelection.collapsed(offset: state.totalAmount.length),
          );
        }
        _pruneControllers(state.installmentRows);
        for (final row in state.installmentRows) {
          if (row.isAuto) continue;
          final controller = _controllerFor(row);
          if (controller.text != row.amountText) {
            controller.value = TextEditingValue(
              text: row.amountText,
              selection: TextSelection.collapsed(offset: row.amountText.length),
            );
          }
        }
        if (state.installmentAmountErrorToken != _lastShownErrorToken) {
          _lastShownErrorToken = state.installmentAmountErrorToken;
          final remaining = state.installmentAmountErrorRemaining;
          if (remaining != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${StringConstant.qnaChatRemainingAmount}: ₹$remaining'),
                backgroundColor: ColorConstant.purpleBrown,
              ),
            );
          }
        }
      },
      buildWhen: (previous, current) =>
          previous.travelDate != current.travelDate ||
          previous.travelTime != current.travelTime ||
          previous.totalAmount != current.totalAmount ||
          previous.installmentCount != current.installmentCount ||
          previous.installmentRows != current.installmentRows ||
          previous.isInstallmentPayment != current.isInstallmentPayment ||
          previous.paymentReceivedTillNow != current.paymentReceivedTillNow,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(DimensionConstant.d15),
          decoration: BoxDecoration(
            color: ColorConstant.cardBgColor,
            borderRadius: BorderRadius.circular(DimensionConstant.d4),
            border: Border.all(color: ColorConstant.borderColorWhite30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${StringConstant.qnaChatPaymentTermsOf} ${widget.customerName}',
                style: FontConstant.interMedium(
                  color: ColorConstant.whiteColor,
                  fontSize: DimensionConstant.d16,
                ),
              ),
              const SizedBox(height: DimensionConstant.d6),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${StringConstant.qnaChatInquiryInformation}: ',
                      style: FontConstant.interNormal(
                        color: ColorConstant.whiteColor.withValues(alpha: 0.7),
                        fontSize: DimensionConstant.d13,
                      ),
                    ),
                    TextSpan(
                      text: '#${widget.inquiryId}',
                      style: FontConstant.interMedium(
                        color: ColorConstant.inquiryInfoTxtColor,
                        fontSize: DimensionConstant.d13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DimensionConstant.d20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _field(
                      label: StringConstant.qnaChatEnterTravelDateTime,
                      child: Row(
                        children: [
                          Expanded(
                            child: _tapBox(
                              _formattedTravelDate(state.travelDate),
                              icon: AssetConstants.icCalendar,
                              onTap: () => _pickTravelDate(context, state.travelDate),
                            ),
                          ),
                          const SizedBox(width: DimensionConstant.d8),
                          Expanded(
                            child: _tapBox(
                              _formattedTravelTime(context, state.travelTime),
                              icon: AssetConstants.icClock,
                              onTap: () => _pickTravelTime(context, state.travelTime),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: DimensionConstant.d15),
                  Expanded(
                    child: _field(
                      label: StringConstant.qnaChatBookingType,
                      child: _readOnlyBox(widget.bookingType ?? '-'),
                    ),
                  ),
                  const SizedBox(width: DimensionConstant.d15),
                  Expanded(
                    child: _field(
                      label: StringConstant.qnaChatTotalAmountToBeReceived,
                      child: _amountField(_totalAmountController, context),
                    ),
                  ),
                  const SizedBox(width: DimensionConstant.d15),
                  Expanded(
                    child: _field(
                      label: StringConstant.qnaChatNoOfInstallments,
                      child: state.isInstallmentPayment
                          ? _installmentDropdown(context, state.installmentCount)
                          : _readOnlyBox('1'),
                    ),
                  ),
                  const SizedBox(width: DimensionConstant.d15),
                  Expanded(
                    child: _field(
                      label: StringConstant.qnaChatPaymentReceivedTillNow,
                      child: _readOnlyBox(
                        '${state.paymentReceivedTillNow}',
                        textColor: ColorConstant.redColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DimensionConstant.d20),
              _installmentTable(context, state.installmentRows),
            ],
          ),
        );
      },
    );
  }

  Widget _field({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FontConstant.interNormal(
            color: ColorConstant.whiteColor.withValues(alpha: 0.6),
            fontSize: DimensionConstant.d12,
          ),
        ),
        const SizedBox(height: DimensionConstant.d8),
        child,
      ],
    );
  }

  Widget _tapBox(String text, {required String icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: DimensionConstant.d40,
        padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d10),
        decoration: BoxDecoration(
          color: ColorConstant.blackColor,
          borderRadius: BorderRadius.circular(DimensionConstant.d4),
          border: Border.all(color: ColorConstant.borderColorWhite30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor,
                fontSize: DimensionConstant.d12,
              ),
            ),
            SvgPicture.asset(icon, width: DimensionConstant.d16, height: DimensionConstant.d16),
          ],
        ),
      ),
    );
  }

  Widget _readOnlyBox(String text, {Color textColor = ColorConstant.whiteColor}) {
    return Container(
      height: DimensionConstant.d40,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d10),
      decoration: BoxDecoration(
        color: ColorConstant.blackColor,
        borderRadius: BorderRadius.circular(DimensionConstant.d4),
        border: Border.all(color: ColorConstant.borderColorWhite30),
      ),
      child: Text(
        text,
        style: FontConstant.interMedium(color: textColor, fontSize: DimensionConstant.d12),
      ),
    );
  }

  Widget _amountField(TextEditingController controller, BuildContext context) {
    return Container(
      height: DimensionConstant.d40,
      padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d10),
      decoration: BoxDecoration(
        color: ColorConstant.blackColor,
        borderRadius: BorderRadius.circular(DimensionConstant.d4),
        border: Border.all(color: ColorConstant.borderColorWhite30),
      ),
      child: Row(
        children: [
          Text(
            '₹',
            style: FontConstant.interMedium(
              color: ColorConstant.whiteColor,
              fontSize: DimensionConstant.d12,
            ),
          ),
          const SizedBox(width: DimensionConstant.d6),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor,
                fontSize: DimensionConstant.d12,
              ),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              onChanged: (text) =>
                  context.read<QnaChatBloc>().add(QnaChatTotalAmountChanged(text)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _installmentDropdown(BuildContext context, int installmentCount) {
    return PopupMenuButton<int>(
      color: ColorConstant.cardBgColor,
      onSelected: (value) =>
          context.read<QnaChatBloc>().add(QnaChatInstallmentCountChanged(value)),
      itemBuilder: (context) => List.generate(
        12,
        (i) => PopupMenuItem<int>(
          value: i + 1,
          child: Text(
            '${i + 1}',
            style: FontConstant.interNormal(
              color: ColorConstant.whiteColor,
              fontSize: DimensionConstant.d13,
            ),
          ),
        ),
      ),
      child: Container(
        height: DimensionConstant.d40,
        padding: const EdgeInsets.symmetric(horizontal: DimensionConstant.d10),
        decoration: BoxDecoration(
          color: ColorConstant.blackColor,
          borderRadius: BorderRadius.circular(DimensionConstant.d4),
          border: Border.all(color: ColorConstant.borderColorWhite30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$installmentCount',
              style: FontConstant.interNormal(
                color: ColorConstant.whiteColor,
                fontSize: DimensionConstant.d12,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: ColorConstant.whiteColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _installmentTable(BuildContext context, List<QnaChatInstallmentRow> rows) {
    final count = rows.length;
    final label = count == 1
        ? StringConstant.qnaChatInstallmentSingular
        : StringConstant.qnaChatInstallmentPlural;
    return Container(
      decoration: BoxDecoration(
        color: ColorConstant.blackColor,
        borderRadius: BorderRadius.circular(DimensionConstant.d4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(DimensionConstant.d15),
            child: Text(
              '${StringConstant.qnaChatPaymentTermsFinalisedOn} $count $label',
              style: FontConstant.interMedium(
                color: ColorConstant.whiteColor,
                fontSize: DimensionConstant.d14,
              ),
            ),
          ),
          _tableHeaderRow(),
          for (var i = 0; i < rows.length; i++)
            _tableDataRow(context, rows[i], isEven: i.isEven),
        ],
      ),
    );
  }

  Widget _tableHeaderRow() {
    return Container(
      color: ColorConstant.purpleBrown,
      padding: const EdgeInsets.symmetric(
        horizontal: DimensionConstant.d15,
        vertical: DimensionConstant.d12,
      ),
      child: Row(
        children: [
          _headerCell(StringConstant.qnaChatColumnAmount, flex: 1),
          _headerCell(StringConstant.qnaChatColumnDueDate, flex: 2),
          _headerCell(StringConstant.qnaChatColumnReceivedDate, flex: 2),
          _headerCell(StringConstant.qnaChatColumnMode, flex: 1),
          _headerCell(StringConstant.qnaChatColumnStatus, flex: 1),
          _headerCell(StringConstant.qnaChatColumnPaymentProof, flex: 2),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: FontConstant.interMedium(
          color: ColorConstant.whiteColor,
          fontSize: DimensionConstant.d13,
        ),
      ),
    );
  }

  Widget _tableDataRow(BuildContext context, QnaChatInstallmentRow row, {required bool isEven}) {
    final isLate = row.isLate;
    final status = _statusFor(row);
    final statusColor = status == StringConstant.qnaChatOnTime
        ? ColorConstant.subTitleGreenColor
        : status == StringConstant.qnaChatLate
            ? ColorConstant.orangeColor
            : ColorConstant.whiteColor.withValues(alpha: 0.5);

    return Container(
      color: isEven ? ColorConstant.cardBgColor : ColorConstant.blackColor,
      padding: const EdgeInsets.symmetric(
        horizontal: DimensionConstant.d15,
        vertical: DimensionConstant.d12,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: SizedBox(
                width: DimensionConstant.d60,
                child: row.isAuto
                    ? Text(
                        row.amountText.isEmpty ? '-' : row.amountText,
                        textAlign: TextAlign.center,
                        style: FontConstant.interMedium(
                          color: ColorConstant.whiteColor.withValues(alpha: 0.6),
                          fontSize: DimensionConstant.d13,
                        ),
                      )
                    : TextField(
                        controller: _controllerFor(row),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (text) => context.read<QnaChatBloc>().add(
                              QnaChatInstallmentRowAmountChanged(rowId: row.id, text: text),
                            ),
                        style: FontConstant.interNormal(
                          color: ColorConstant.whiteColor,
                          fontSize: DimensionConstant.d13,
                        ),
                        decoration:
                            const InputDecoration(border: InputBorder.none, isDense: true),
                      ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: _rowDateCell(
                row.dueDate != null ? _formatDate(row.dueDate!) : null,
                onTap: () => _pickRowDate(context: context, row: row, isDueDate: true),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: _rowDateCell(
                row.receivedDate != null ? _formatDate(row.receivedDate!) : null,
                placeholder: StringConstant.qnaChatNotReceivedYet,
                onTap: () => _pickRowDate(context: context, row: row, isDueDate: false),
                showLateIndicator: isLate,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(child: _modeDropdown(context, row)),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                status,
                style: FontConstant.interMedium(color: statusColor, fontSize: DimensionConstant.d13),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _paymentProofCell(row, isLate: isLate)),
          ),
        ],
      ),
    );
  }

  Widget _rowDateCell(
    String? text, {
    String placeholder = '--/--/----',
    required VoidCallback onTap,
    bool showLateIndicator = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text ?? placeholder,
            style: FontConstant.interNormal(
              color: ColorConstant.whiteColor,
              fontSize: DimensionConstant.d13,
            ),
          ),
          if (showLateIndicator) ...[
            const SizedBox(width: DimensionConstant.d6),
            Tooltip(
              message: StringConstant.qnaChatPaymentLateTooltip,
              child: const Icon(Icons.info_outline, color: ColorConstant.orangeColor, size: 14),
            ),
          ],
          const SizedBox(width: DimensionConstant.d6),
          const Icon(Icons.calendar_today_outlined, color: ColorConstant.whiteColor, size: 14),
        ],
      ),
    );
  }

  Widget _modeDropdown(BuildContext context, QnaChatInstallmentRow row) {
    return PopupMenuButton<String>(
      color: ColorConstant.cardBgColor,
      onSelected: (value) => context.read<QnaChatBloc>().add(
            QnaChatInstallmentRowModeChanged(rowId: row.id, mode: value),
          ),
      itemBuilder: (context) => StringConstant.qnaChatPaymentModeOptions
          .map(
            (o) => PopupMenuItem<String>(
              value: o,
              child: Text(
                o,
                style: FontConstant.interNormal(
                  color: ColorConstant.whiteColor,
                  fontSize: DimensionConstant.d13,
                ),
              ),
            ),
          )
          .toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            row.mode ?? '-',
            style: FontConstant.interNormal(
              color: ColorConstant.whiteColor,
              fontSize: DimensionConstant.d13,
            ),
          ),
          const SizedBox(width: DimensionConstant.d4),
          const Icon(Icons.keyboard_arrow_down, color: ColorConstant.whiteColor, size: 16),
        ],
      ),
    );
  }

  Widget _paymentProofCell(QnaChatInstallmentRow row, {required bool isLate}) {
    if (row.mode == 'Cash') {
      return Text(
        row.mode!,
        style: FontConstant.interNormal(color: ColorConstant.whiteColor, fontSize: DimensionConstant.d13),
      );
    }
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: StringConstant.qnaChatUploadProof,
                  style: FontConstant.interNormal(
                    color: ColorConstant.whiteColor,
                    fontSize: DimensionConstant.d13,
                  ),
                ),
                if (isLate)
                  TextSpan(
                    text: ' *',
                    style: FontConstant.interMedium(
                      color: ColorConstant.asteriskRedColor,
                      fontSize: DimensionConstant.d13,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: DimensionConstant.d6),
          const Icon(Icons.upload, color: ColorConstant.whiteColor, size: 14),
        ],
      ),
    );
  }
}
