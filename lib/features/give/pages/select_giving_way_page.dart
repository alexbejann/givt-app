import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:givt_app/features/give/bloc/give_bloc.dart';
import 'package:givt_app/features/give/pages/qr_code_scan_page.dart';
import 'package:givt_app/features/give/widgets/context_list_tile.dart';
import 'package:givt_app/l10n/l10n.dart';

class SelectGivingWayPage extends StatelessWidget {
  const SelectGivingWayPage({super.key});

  static MaterialPageRoute<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const SelectGivingWayPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final locals = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          locals.selectContext,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                locals.giveSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            _buildListTile(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<GiveBloc>(),
                    child: const QrCodeScanPage(),
                  ),
                  fullscreenDialog: true,
                ),
              ),
              title: locals.givingContextCollectionBag,
              subtitle: locals.selectContextCollect,
              image: 'assets/images/select_qr_phone_scan.png',
            ),
            // _buildListTile(
            //   onTap: () {},
            //   title: locals.givingContextCollectionBagList,
            //   subtitle: locals.selectContextList,
            //   image: 'assets/images/select_list.png',
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required VoidCallback onTap,
    required String title,
    required String subtitle,
    required String image,
  }) =>
      ContextListTile(
        onTap: onTap,
        leading: Image.asset(
          image,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),
        title: title,
        subtitle: subtitle,
      );
}