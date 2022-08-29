import 'package:app_2i2i/infrastructure/data_access_layer/accounts/local_account.dart';
import 'package:app_2i2i/ui/screens/my_account/verify_perhaps_page.dart';
import 'package:app_2i2i/ui/screens/my_account/verify_perhaps_page_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

class VerifyPerhapsPageHolder extends ConsumerStatefulWidget {
  final List perhaps;
  final LocalAccount account;

  const VerifyPerhapsPageHolder({
    Key? key,
    required this.perhaps,
    required this.account,
  }) : super(key: key);

  @override
  _VerifyPerhapsPageHolderState createState() => _VerifyPerhapsPageHolderState();
}

class _VerifyPerhapsPageHolderState extends ConsumerState<VerifyPerhapsPageHolder> {

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => VerifyPerhapsPage(account: widget.account, perhaps: widget.perhaps),
      tablet: (BuildContext context) => VerifyPerhapsPage(account: widget.account, perhaps: widget.perhaps),
      desktop: (BuildContext context) => VerifyPerhapsPageWeb(account: widget.account, perhaps: widget.perhaps),
    );
  }
}
