import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'create_local_account.dart';
import 'create_local_account_web.dart';

class CreateLocalAccountHolder extends ConsumerStatefulWidget {
  const CreateLocalAccountHolder({Key? key}) : super(key: key);

  @override
  _CreateLocalAccountHolderState createState() => _CreateLocalAccountHolderState();
}

class _CreateLocalAccountHolderState extends ConsumerState<CreateLocalAccountHolder> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(myAccountPageViewModelProvider).addLocalAccount();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => CreateLocalAccount(),
      tablet: (BuildContext context) => CreateLocalAccount(),
      desktop: (BuildContext context) => CreateLocalAccountWeb(),
    );
  }
}
