import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:givt_app/app/routes/route_utils.dart';
import 'package:givt_app/features/children/vpc/cubit/vpc_cubit.dart';
import 'package:givt_app/l10n/l10n.dart';
import 'package:givt_app/utils/app_theme.dart';
import 'package:go_router/go_router.dart';

class VPCSuccessPage extends StatelessWidget {
  const VPCSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final locals = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 35),
        width: double.infinity,
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: size.height * 0.035,
            ),
            Container(
              padding: const EdgeInsets.all(20),
              height: size.height * 0.82,
              child: SizedBox.expand(
                child: Column(
                  children: [
                    Text(
                      locals.vpcSuccessText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: AppTheme.sliderIndicatorFilled),
                    ),
                    Expanded(
                      child: SvgPicture.asset('assets/images/vpc_givy.svg'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35, right: 35, bottom: 30),
              child: ElevatedButton(
                onPressed: () {
                  context.read<VPCCubit>().resetVPC();
                  context.goNamed(Pages.createChild.name);
                },
                child: Text(
                  locals.setupChildProfileButtonText,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}