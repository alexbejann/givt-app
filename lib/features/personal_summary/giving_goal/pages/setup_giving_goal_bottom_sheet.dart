import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:givt_app/core/enums/enums.dart';
import 'package:givt_app/features/auth/cubit/auth_cubit.dart';
import 'package:givt_app/features/personal_summary/add_external_donation/widgets/widgets.dart';
import 'package:givt_app/features/personal_summary/overview/bloc/personal_summary_bloc.dart';
import 'package:givt_app/l10n/l10n.dart';
import 'package:givt_app/shared/widgets/widgets.dart';
import 'package:givt_app/utils/utils.dart';
import 'package:go_router/go_router.dart';

class SetupGivingGoalBottomSheet extends StatefulWidget {
  const SetupGivingGoalBottomSheet({super.key});

  @override
  State<SetupGivingGoalBottomSheet> createState() =>
      _SetupGivingGoalBottomSheetState();
}

class _SetupGivingGoalBottomSheetState
    extends State<SetupGivingGoalBottomSheet> {
  late TextEditingController amountController;
  late int frequency;

  @override
  void initState() {
    final personalSummaryState = context.read<PersonalSummaryBloc>().state;
    final givingGoal = personalSummaryState.givingGoal;
    amountController = TextEditingController(
      text: givingGoal.amount.toString(),
    );
    frequency = givingGoal.periodicity;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locals = context.l10n;
    final userCountry = context.read<AuthCubit>().state.user.country;
    final country = Country.fromCode(userCountry);
    final personalSummaryState = context.watch<PersonalSummaryBloc>().state;

    return BottomSheetLayout(
      title: Text(locals.budgetGivingGoalTitle),
      bottomSheet: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => context
                .read<PersonalSummaryBloc>()
                .add(const PersonalSummaryGoalRemove()),
            child: Text(
              locals.budgetSummaryGivingGoalEdit,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    decoration: TextDecoration.underline,
                    color: AppTheme.givtPurple,
                  ),
            ),
          ),
          Visibility(
            visible:
                personalSummaryState.status == PersonalSummaryStatus.loading,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Visibility(
            visible:
                personalSummaryState.status != PersonalSummaryStatus.loading,
            child: ElevatedButton(
              onPressed: isEnabled ? () => onSave(context) : null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey,
              ),
              child: Text(
                locals.save,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          CardBanner(
            title: locals.budgetGivingGoalInfoBold,
            subtitle: locals.budgetGivingGoalInfo,
          ),
          _buildFieldTitle(locals.budgetGivingGoalMine),
          _buildTextField(context, country),
          _buildFieldTitle(locals.budgetGivingGoalTime),
          _buildPeriodDropdown(context: context),
        ],
      ),
    );
  }

  /// Build the text field for the amount
  Widget _buildTextField(
    BuildContext context,
    Country country,
  ) {
    final locals = context.l10n;
    return TextFormField(
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      style: Theme.of(context).textTheme.bodyLarge,
      controller: amountController,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          /// Allow only numbers and one comma or dot
          /// Like 123, 123.45, 12,05, 12,5
          RegExp(r'^\d+([,.]\d{0,2})?'),
        ),
      ],
      onChanged: (value) => setState(() {}),
      validator: (newValue) {
        if (newValue == null) {
          return '';
        }
        final amount = double.parse(newValue.replaceAll(',', '.'));
        if (amount <= 0 || amount > 99999) {
          return '';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: locals.budgetExternalGiftsAmount,
        hintText: locals.budgetExternalGiftsAmount,
        prefixIcon: Icon(
          Util.getCurrencyIconData(country: country),
        ),
      ),
    );
  }

  /// Build the dropdown for the period
  Widget _buildPeriodDropdown({
    required BuildContext context,
  }) {
    final locals = context.l10n;
    final frequencies = [
      locals.budgetSummaryMonth,
      locals.budgetSummaryYear,
    ];
    return DropdownButtonFormField<int>(
      hint: Text(locals.budgetExternalGiftsTime),
      value: frequency,
      onChanged: (int? newValue) {
        if (newValue == null) {
          return;
        }
        setState(() {
          frequency = newValue;
        });
      },
      items: [0, 1]
          .map<DropdownMenuItem<int>>(
            (int value) => DropdownMenuItem<int>(
              value: value,
              alignment: Alignment.centerLeft,
              child: Text(
                frequencies[value],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
          .toList(),
    );
  }

  bool get isEnabled {
    return amountController.text.isNotEmpty;
  }

  void onSave(BuildContext context) {
    // final state = context.read<PersonalSummaryBloc>().state;
    // context.read<PersonalSummaryBloc>().add(
    //       PersonalSummaryEvent.setGivingGoal(
    //         state.givingGoal!,
    //       ),
    //     );
    context.pop();
  }

  Widget _buildFieldTitle(
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
