import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:givt_app/features/auth/cubit/auth_cubit.dart';
import 'package:givt_app/features/give/widgets/choose_amount.dart';
import 'package:givt_app/l10n/l10n.dart';

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
      drawer: Drawer(
        child: ListView(
          children: [
            //todo add the necessary items here, and configure the animation
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {},
            ),
            ListTile(
              title: Text(locals.logOut),
              onTap: () async => context.read<AuthCubit>().logout(),
            ),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          ChooseAmount(
            amountLimit: auth.user.amountLimit,
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
}
