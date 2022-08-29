import 'package:app_2i2i/ui/screens/my_account/recover_account.dart';
import 'package:app_2i2i/ui/screens/my_account/recover_account_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';

class RecoverAccountPageHolder extends ConsumerStatefulWidget {
  const RecoverAccountPageHolder({Key? key}) : super(key: key);

  @override
  _RecoverAccountPageHolderState createState() => _RecoverAccountPageHolderState();
}

class _RecoverAccountPageHolderState extends ConsumerState<RecoverAccountPageHolder> {
  int currentIndex = 0;
  List<TextEditingController> listOfString = List.generate(25, (index) => TextEditingController());
  final formGlobalKey = GlobalKey<FormState>();
  bool isInValid = true;

  @override
  Widget build(BuildContext context) {

    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => RecoverAccountPage(),
      tablet: (BuildContext context) => RecoverAccountPage(),
      desktop: (BuildContext context) => RecoverAccountPageWeb(),
    );
  }
}
