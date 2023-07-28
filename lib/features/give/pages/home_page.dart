import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:givt_app/app/injection/injection.dart';
import 'package:givt_app/app/routes/routes.dart';
import 'package:givt_app/core/enums/enums.dart';
import 'package:givt_app/core/network/country_iso_info.dart';
import 'package:givt_app/features/auth/cubit/auth_cubit.dart';
import 'package:givt_app/features/give/widgets/widgets.dart';
import 'package:givt_app/l10n/l10n.dart';
import 'package:givt_app/shared/bloc/remote_data_source_sync/remote_data_source_sync_bloc.dart';
import 'package:givt_app/shared/dialogs/dialogs.dart';
import 'package:givt_app/shared/widgets/widgets.dart';
import 'package:givt_app/utils/app_theme.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.code, required this.given, super.key});

  final String code;
  final bool given;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final locals = context.l10n;
    final auth = context.watch<AuthCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            // Image.asset(
            //   'assets/images/logo.png',
            //   width: size.width * 0.1,
            // ),
            // const SizedBox(height: 5),
            Text(locals.amount),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              showDragHandle: true,
              backgroundColor: AppTheme.givtPurple,
              builder: (_) => const FAQBottomSheet(),
            ),
            icon: const Icon(
              Icons.question_mark_outlined,
              size: 26,
            ),
          ),
        ],
      ),
      drawer: const CustomNavigationDrawer(),
      body: BlocListener<RemoteDataSourceSyncBloc, RemoteDataSourceSyncState>(
        listener: (context, state) {
          if (state is RemoteDataSourceSyncSuccess && kDebugMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Synced successfully Sim ${getIt<CountryIsoInfo>().countryIso}',
                ),
              ),
            );
          }
          if (state is RemoteDataSourceSyncInProgress) {
            if (!auth.user.needRegistration || auth.user.mandateSigned) {
              return;
            }
            _buildNeedsRegistrationDialog(context);
          }
        },
        child: SafeArea(
          child: _HomePageView(
            given: given,
            code: code,
          ),
        ),
      ),
    );
  }

  Future<void> _buildNeedsRegistrationDialog(
    BuildContext context,
  ) {
    final user = context.read<AuthCubit>().state.user;
    return showDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(context.l10n.importantReminder),
        content: Text(context.l10n.finalizeRegistrationPopupText),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.l10n.askMeLater),
          ),
          TextButton(
            onPressed: () {
              if (user.needRegistration) {
                context
                  ..goNamed(
                    Pages.registration.name,
                    queryParameters: {
                      'email': user.email,
                    },
                  )
                  ..pop();
                return;
              }
              context
                ..goNamed(Pages.sepaMandateExplanation.name)
                ..pop();
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
    );
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView({
    required this.given,
    required this.code,
  });

  final bool given;
  final String code;

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  late PageController pageController;
  @override
  void initState() {
    pageController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    final size = MediaQuery.sizeOf(context);
    final locals = context.l10n;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        HomePageViewLayout(
          child: PageView(
            controller: pageController,
            children: [
              ChooseAmount(
                country: Country.fromCode(auth.user.country),
                amountLimit: auth.user.amountLimit,
                hasGiven: widget.given,
                arePresetsEnabled: auth.user.presets.isEnabled,
                presets: auth.user.presets.presets,
                onAmountChanged:
                    (firstCollection, secondCollection, thirdCollection) =>
                        context.goNamed(
                  Pages.selectGivingWay.name,
                  extra: {
                    'firstCollection': firstCollection,
                    'secondCollection': secondCollection,
                    'thirdCollection': thirdCollection,
                    'code': widget.code,
                  },
                ),
              ),
              const ChooseCategory()
            ],
          ),
        ),
        ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 15,
              left: 15,
              bottom: 10,
            ),
            child: GestureDetector(
              onTap: () {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 40,
                width: pageController.page != pageController.initialPage
                    ? size.width * 0.4
                    : size.width * 0.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: pageController.page != pageController.initialPage
                      ? Colors.amber
                      : Colors.blue,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color:
                              pageController.page != pageController.initialPage
                                  ? Colors.white
                                  : Colors.amber,
                        ),
                        child: Center(
                          child: Text(
                            locals.discoverSegmentNow,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: pageController.page !=
                                      pageController.initialPage
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color:
                              pageController.page != pageController.initialPage
                                  ? Colors.amber
                                  : Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            locals.discoverSegmentWho,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: pageController.page !=
                                      pageController.initialPage
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
