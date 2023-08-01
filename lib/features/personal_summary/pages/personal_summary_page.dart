import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:givt_app/core/enums/country.dart';
import 'package:givt_app/features/auth/cubit/auth_cubit.dart';
import 'package:givt_app/features/personal_summary/bloc/personal_summary_bloc.dart';
import 'package:givt_app/l10n/l10n.dart';
import 'package:givt_app/shared/dialogs/warning_dialog.dart';
import 'package:givt_app/utils/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PersonalSummary extends StatelessWidget {
  const PersonalSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final locals = context.l10n;
    final user = context.watch<AuthCubit>().state.user;
    final countryCharacter = NumberFormat.simpleCurrency(
      name: Country.fromCode(user.country).currency,
    ).currencySymbol;
    return Scaffold(
      appBar: AppBar(
        title: Text(locals.budgetMenuView),
      ),
      backgroundColor: AppTheme.givtLightGray,
      body: BlocListener<PersonalSummaryBloc, PersonalSummaryState>(
        listener: (context, state) {
          if (state.status == PersonalSummaryStatus.noInternet) {
            showDialog<void>(
              context: context,
              builder: (_) => WarningDialog(
                title: locals.noInternetConnectionTitle,
                content: locals.noInternet,
                onConfirm: () => context.pop(),
              ),
            );
          }
          if (state.status == PersonalSummaryStatus.error) {
            showDialog<void>(
              context: context,
              builder: (_) => WarningDialog(
                title: locals.saveFailed,
                content: locals.updatePersonalInfoError,
                onConfirm: () => context.pop(),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<PersonalSummaryBloc, PersonalSummaryState>(
            builder: (context, state) {
              if (state.status == PersonalSummaryStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  _buildMonthHeader(state: state, context: context),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNarrowWidget(
                          left: true,
                          size: size,
                          locals: locals,
                          countryCharacter: countryCharacter,
                          state: state,
                        ),
                        _buildNarrowWidget(
                          left: false,
                          size: size,
                          locals: locals,
                          countryCharacter: countryCharacter,
                          state: state,
                        ),
                      ],
                    ),
                  ),
                  _buildGiveNowButton(
                    locals: locals,
                    onTap: () {},
                  ),
                  _buildMonthlyHistory(
                    context: context,
                    size: size,
                    locals: locals,
                    state: state,
                    countryCharacter: countryCharacter,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(
          {required BuildContext context,
          required PersonalSummaryState state}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildArrowButton(left: true, context: context),
            Text(
              getMonthNameFromISOString(state.dateTime),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (DateTime.parse(state.dateTime).month == DateTime.now().month)
              const SizedBox(width: 25)
            else
              _buildArrowButton(left: false, context: context),
          ],
        ),
      );

  Widget _buildArrowButton(
          {required BuildContext context, required bool left}) =>
      Container(
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.transparent),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: IconButton(
          onPressed: () => context
              .read<PersonalSummaryBloc>()
              .add(PersonalSummaryMonthChange(increase: !left)),
          padding: EdgeInsets.zero,
          alignment: left ? Alignment.centerRight : Alignment.center,
          icon: Icon(
            left ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
            color: AppTheme.givtBlue,
            size: 17,
          ),
        ),
      );

  Widget _buildNarrowWidget({
    required Size size,
    required AppLocalizations locals,
    required bool left,
    required String countryCharacter,
    required PersonalSummaryState state,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: left ? AppTheme.givtLightGreen : Colors.white,
          border: Border.all(color: Colors.transparent),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: SizedBox(
          height: 150,
          width: left ? size.width * 0.32 : size.width * 0.4,
          child: left
              ? Column(
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$countryCharacter ${state.monthlyGivts.fold<double>(0, (sum, item) => sum + item.amount)}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        locals.budgetSummaryBalance,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/images/givy_money.png',
                      height: 60,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: locals.budgetSummarySetGoalBold,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.givtBlue,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTheme.fontFamily,
                            ),
                          ),
                          const TextSpan(
                            //locals.budgetSummarySetGoal
                            text: '\nGiving goal feature coming soon!',
                            style: TextStyle(
                              color: AppTheme.givtBlue,
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      );

  Widget _buildGiveNowButton(
          {required AppLocalizations locals, required VoidCallback onTap}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: AppTheme.givtBlue,
          ),
          child: Text(
            locals.budgetSummaryGiveNow,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
  Widget _buildMonthlyHistory({
    required BuildContext context,
    required Size size,
    required AppLocalizations locals,
    required PersonalSummaryState state,
    required String countryCharacter,
  }) =>
      Container(
        width: size.width * 0.9,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.transparent),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.givtGraycece,
              offset: Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.givtLightGreen,
                border: Border.all(color: Colors.transparent),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              width: double.maxFinite,
              child: Text(
                getMonthNameFromISOString(state.dateTime),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  locals.budgetSummaryGivt,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: state.monthlyGivts.isNotEmpty
                    ? [
                        ...state.monthlyGivts.take(2).map(
                              (e) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.organisationName),
                                  Text(
                                    '$countryCharacter ${e.amount}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        if (state.monthlyGivts.length > 2)
                          const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('...')),
                      ]
                    : [
                        Text(
                          locals.budgetSummaryNoGifts,
                          textAlign: TextAlign.center,
                        ),
                      ],
              ),
            ),
            if (state.monthlyGivts.length > 2)
              TextButton(
                onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) =>
                        _buildMonthlyHistoryDialog(
                          context: context,
                          size: size,
                          locals: locals,
                          state: state,
                          countryCharacter: countryCharacter,
                        )),
                child: Text(
                  locals.budgetSummaryShowAll,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
          ],
        ),
      );
  Widget _buildMonthlyHistoryDialog({
    required BuildContext context,
    required Size size,
    required AppLocalizations locals,
    required PersonalSummaryState state,
    required String countryCharacter,
  }) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: size.height * 0.1,
          maxHeight: size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.givtGraycece,
                border: Border.all(color: Colors.transparent),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              width: double.maxFinite,
              child: Text(
                getMonthNameFromISOString(state.dateTime),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: Text(
                  locals.budgetSummaryGivt,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...state.monthlyGivts.map(
                      (e) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.organisationName),
                          Text(
                            '$countryCharacter ${e.amount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  String getMonthNameFromISOString(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final monthName = DateFormat('MMMM').format(dateTime);
    return monthName;
  }
}