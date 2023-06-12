import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:givt_app/features/auth/cubit/auth_cubit.dart';
import 'package:givt_app/features/give/bloc/bloc.dart';
import 'package:givt_app/features/give/pages/select_giving_way_page.dart';
import 'package:givt_app/features/give/widgets/choose_amount.dart';
import 'package:givt_app/injection.dart';
import 'package:givt_app/l10n/l10n.dart';
import 'package:givt_app/shared/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static MaterialPageRoute<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const HomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final locals = AppLocalizations.of(context);
    final auth = context.read<AuthCubit>().state as AuthSuccess;

    return Scaffold(
      appBar: AppBar(
        title: Text(locals.amount),
        actions: [
          IconButton(
            onPressed: () {
              //todo add faq here
            },
            icon: const Icon(
              Icons.question_mark_outlined,
              size: 26,
            ),
          ),
        ],
      ),
      drawer: const CustomNavigationDrawer(),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Builder(
            builder: (context) {
              if (auth.user.needRegistration && !auth.user.mandateSigned) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _buildNeedsRegistrationDialog(context),
                );
              }

              return ChooseAmount(
                country: auth.user.country,
                amountLimit: auth.user.amountLimit,
                onAmountChanged:
                    (firstCollection, secondCollection, thirdCollection) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider(
                        create: (context) => GiveBloc(
                          getIt(),
                          getIt(),
                          getIt(),
                        )..add(
                            GiveAmountChanged(
                              firstCollectionAmount: firstCollection,
                              secondCollectionAmount: secondCollection,
                              thirdCollectionAmount: thirdCollection,
                            ),
                          ),
                        child: const SelectGivingWayPage(),
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                  return true;
                },
              );
            },
          ),
          ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 15,
                left: 15,
                bottom: 10,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: size.width * 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _buildNeedsRegistrationDialog(
    BuildContext context,
  ) {
    return showDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(context.l10n.importantReminder),
        content: Text(context.l10n.finalizeRegistrationPopupText),
        actions: [
          Column(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.askMeLater),
              ),
              const Divider(
                height: 2,
              ),
              TextButton(
                onPressed: () {
                  //todo redirect to registration page
                },
                child: Text(
                  context.l10n.finalizeRegistration,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
