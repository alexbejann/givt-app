import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:givt_app/app/injection/injection.dart';
import 'package:givt_app/app/routes/route_utils.dart';
import 'package:givt_app/features/auth/cubit/auth_cubit.dart';
import 'package:givt_app/features/first_use/pages/welcome_page.dart';
import 'package:givt_app/features/give/bloc/bloc.dart';
import 'package:givt_app/features/give/pages/giving_page.dart';
import 'package:givt_app/features/give/pages/home_page.dart';
import 'package:givt_app/features/give/pages/select_giving_way_page.dart';
import 'package:givt_app/features/registration/bloc/registration_bloc.dart';
import 'package:givt_app/features/registration/pages/bacs_explanation_page.dart';
import 'package:givt_app/features/registration/pages/gift_aid_request_page.dart';
import 'package:givt_app/features/registration/pages/mandate_explanation_page.dart';
import 'package:givt_app/features/registration/pages/personal_info_page.dart';
import 'package:givt_app/features/registration/pages/sign_bacs_mandate_page.dart';
import 'package:givt_app/features/registration/pages/sign_sepa_mandate_page.dart';
import 'package:givt_app/features/registration/pages/signup_page.dart';
import 'package:givt_app/l10n/l10n.dart';
import 'package:givt_app/shared/bloc/remote_data_source_sync/remote_data_source_sync_bloc.dart';
import 'package:givt_app/shared/dialogs/dialogs.dart';
import 'package:givt_app/shared/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/download',
        name: 'download',
        redirect: (context, state) {
          final auth = context.read<AuthCubit>().state;
          final code = state.queryParameters['code'];
          if (auth is AuthSuccess) {
            return '/${Pages.home.path}?code=$code';
          }
          return '/${Pages.welcome.path}?code=$code';
        },
      ),
      GoRoute(
        path: Pages.splash.path,
        name: Pages.splash.name,
        routes: [
          GoRoute(
            path: Pages.home.path,
            name: Pages.home.name,
            routes: [
              GoRoute(
                path: Pages.registration.path,
                name: Pages.registration.name,
                builder: (context, state) {
                  final email = state.queryParameters['email'] ?? '';
                  return BlocProvider(
                    create: (context) => RegistrationBloc(
                      authCubit: context.read<AuthCubit>(),
                      authRepositoy: getIt(),
                    ),
                    child: SignUpPage(
                      email: email,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: Pages.personalInfo.path,
                    name: Pages.personalInfo.name,
                    builder: (context, state) => BlocProvider.value(
                      value: state.extra! as RegistrationBloc,
                      child: const PersonalInfoPage(),
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: Pages.sepaMandateExplanation.path,
                name: Pages.sepaMandateExplanation.name,
                routes: [
                  GoRoute(
                    path: Pages.signSepaMandate.path,
                    name: Pages.signSepaMandate.name,
                    builder: (context, state) => BlocProvider.value(
                      value: state.extra! as RegistrationBloc,
                      child: const SignSepaMandatePage(),
                    ),
                  ),
                  GoRoute(
                    path: Pages.bacsMandateExplanation.path,
                    name: Pages.bacsMandateExplanation.name,
                    routes: [
                      GoRoute(
                        path: Pages.signBacsMandate.path,
                        name: Pages.signBacsMandate.name,
                        builder: (context, state) => BlocProvider.value(
                          value: state.extra! as RegistrationBloc,
                          child: const SignBacsMandatePage(),
                        ),
                      ),
                      GoRoute(
                        path: Pages.giftAid.path,
                        name: Pages.giftAid.name,
                        builder: (context, state) => BlocProvider(
                          create: (context) => RegistrationBloc(
                            authCubit: context.read<AuthCubit>(),
                            authRepositoy: getIt(),
                          )..add(const RegistrationInit()),
                          child: const GiftAidRequestPage(),
                        ),
                      ),
                    ],
                    builder: (context, state) => BlocProvider.value(
                      value: state.extra! as RegistrationBloc,
                      child: const BacsExplanationPage(),
                    ),
                  ),
                ],
                builder: (context, state) => BlocProvider(
                  create: (context) => RegistrationBloc(
                    authCubit: context.read<AuthCubit>(),
                    authRepositoy: getIt(),
                  )..add(const RegistrationInit()),
                  child: const MandateExplanationPage(),
                ),
              ),
              GoRoute(
                path: Pages.selectGivingWay.path,
                name: Pages.selectGivingWay.name,
                builder: (context, state) => BlocProvider(
                  create: (_) {
                    final extra = state.extra! as Map<String, dynamic>;
                    final auth = context.read<AuthCubit>().state as AuthSuccess;
                    final bloc = GiveBloc(
                      getIt(),
                      getIt(),
                      getIt(),
                    )..add(
                        GiveAmountChanged(
                          firstCollectionAmount:
                              extra['firstCollection'] as double,
                          secondCollectionAmount:
                              extra['secondCollection'] as double,
                          thirdCollectionAmount:
                              extra['thirdCollection'] as double,
                        ),
                      );
                    if ((extra['code'] as String).isNotEmpty) {
                      bloc.add(
                        GiveQRCodeScannedOutOfApp(
                          extra['code'] as String,
                          auth.user.guid,
                        ),
                      );
                    }
                    return bloc;
                  },
                  child: const SelectGivingWayPage(),
                ),
                routes: [
                  GoRoute(
                    path: Pages.give.path,
                    name: Pages.give.name,
                    builder: (context, state) => BlocProvider(
                      create: (_) => state.extra! as GiveBloc,
                      child: const GivingPage(),
                    ),
                  ),
                  GoRoute(
                    path: Pages.giveOffline.path,
                    name: Pages.giveOffline.name,
                    builder: (context, state) => BlocProvider(
                      create: (_) => state.extra! as GiveBloc,
                      child: const GivingPage(),
                    ),
                  ),
                ],
              ),
            ],
            builder: (context, state) => BlocProvider(
              create: (_) => RemoteDataSourceSyncBloc(
                getIt(),
                getIt(),
              )..add(const RemoteDataSourceSyncRequested()),
              child: HomePage(
                code: state.queryParameters['code'] ?? '',
              ),
            ),
          ),
          GoRoute(
            path: Pages.welcome.path,
            name: Pages.welcome.name,
            builder: (context, state) => const WelcomePage(),
          ),
        ],
        builder: (context, routerState) => BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              context.goNamed(
                Pages.home.name,
                queryParameters: routerState.queryParameters,
              );
            }
            if (state is AuthLogout || state is AuthUnkown) {
              context.goNamed(Pages.welcome.name);
            }
          },
          child: const SplashPage(),
        ),
      ),
    ],
  );
}