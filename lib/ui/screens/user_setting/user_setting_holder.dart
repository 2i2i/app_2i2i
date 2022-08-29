import 'package:app_2i2i/ui/screens/user_setting/user_setting.dart';
import 'package:app_2i2i/ui/screens/user_setting/user_setting_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

import '../../commons/custom_profile_image_view.dart';

class UserSettingHolder extends ConsumerStatefulWidget {
  final bool? fromBottomSheet;

  UserSettingHolder({Key? key, this.fromBottomSheet}) : super(key: key);

  @override
  _UserSettingHolderState createState() => _UserSettingHolderState();
}

class _UserSettingHolderState extends ConsumerState<UserSettingHolder> {
  TextEditingController userNameEditController = TextEditingController();
  TextEditingController speedEditController = TextEditingController();
  TextEditingController hourEditController = TextEditingController();
  TextEditingController minuteEditController = TextEditingController();
  TextEditingController secondEditController = TextEditingController();
  RichTextController bioTextController = RichTextController(
    patternMatchMap: {RegExp(r"(?:#)[a-zA-Z0-9]+"): TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)},
    onMatch: (List<String> match) {},
  );

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ValueNotifier<bool> invalidTime = ValueNotifier(false);

  String imageUrl = "";
  ImageType imageType = ImageType.NAME_IMAGE;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => UserSetting(),
      tablet: (BuildContext context) => UserSetting(),
      desktop: (BuildContext context) => UserSettingWeb(),
    );
  }
}
