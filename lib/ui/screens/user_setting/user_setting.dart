import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/social_links_model.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/my_user_provider/my_user_page_view_model.dart';
import 'package:app_2i2i/ui/commons/custom_dialogs.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/commons/theme.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/setup_user_provider/setup_user_view_model.dart';
import '../../commons/custom_alert_widget.dart';
import '../../commons/custom_profile_image_view.dart';
import '../create_bid/top_card_widget.dart';
import 'image_pick_option_widget.dart';

class UserSetting extends ConsumerStatefulWidget {
  final bool? fromBottomSheet;

  UserSetting({Key? key, this.fromBottomSheet}) : super(key: key);

  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends ConsumerState<UserSetting> {
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

  // importance
  static const double _importanceSliderMaxHalf = 5.0;
  double? _importanceRatioValue;
  double? _importanceSliderValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);
    final signUpViewModel = ref.watch(setupUserViewModelProvider);
    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Text(
              widget.fromBottomSheet ?? false ? Keys.setUpAccount.tr(context) : Keys.userSettings.tr(context),
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ProfileWidget(
                    onTap: () {
                      CustomAlertWidget.showBidAlert(context, ImagePickOptionWidget(
                        imageCallBack: (ImageType imageType, String imagePath) {
                          if (imagePath.isNotEmpty) {
                            Navigator.of(context).pop();
                            imageUrl = imagePath;
                            this.imageType = imageType;
                            setState(() {});
                          }
                        },
                      ));
                    },
                    stringPath: imageUrl,
                    radius: kToolbarHeight * 1.45,
                    imageType: imageType,
                    isRating: false,
                    showEdit: true,
                    hideShadow: true),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Keys.name.tr(context),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: userNameEditController,
                        textInputAction: TextInputAction.next,
                        autofocus: false,
                        style: TextStyle(color: AppTheme().cardDarkColor),
                        validator: (value) {
                          value ??= '';
                          if (value.trim().isEmpty) {
                            return Keys.required.tr(context);
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          hintText: Keys.yourNameHint.tr(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              Keys.bio.tr(context),
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: bioTextController,
              textInputAction: TextInputAction.newline,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              minLines: 4,
              maxLines: 4,
              style: TextStyle(color: AppTheme().cardDarkColor),
              decoration: InputDecoration(
                filled: true,
                // fillColor: Theme.of(context).primaryColorLight,
                border: OutlineInputBorder(),
                hintText: Keys.bioExample.tr(context),
              ),
            ),
            const SizedBox(height: 30),
            Visibility(
              visible: !(widget.fromBottomSheet ?? false),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${Keys.minSpeed.tr(context)}: ${minSpeedString()}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    onChanged: (value) => setState(() {}),
                    controller: speedEditController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    style: TextStyle(color: AppTheme().cardDarkColor),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autofocus: false,
                    validator: (value) {
                      value ??= '';
                      if (value.trim().isEmpty || int.tryParse(value) == null) {
                        return Keys.enterValidData.tr(context);
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      hintText: Keys.numberHint.tr(context),
                      suffix: Text(Keys.algoPerSec.tr(context)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    Keys.maxDuration.tr(context),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 210,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              controller: hourEditController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: AppTheme().cardDarkColor),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              autofocus: false,
                              validator: (value) {
                                value ??= '';
                                if (value.isEmpty || (int.tryParse(value) ?? 0) > 24) {
                                  invalidTime.value = true;
                                } else {
                                  invalidTime.value = false;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                hintText: Keys.hh.tr(context).toUpperCase(),
                                // suffix: Text(Keys..algoPerSec),
                              ),
                            ),
                          ),
                          Text(
                            ':',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              controller: minuteEditController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: AppTheme().cardDarkColor),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              autofocus: false,
                              validator: (value) {
                                value ??= '';
                                if ((int.tryParse(value) ?? 0) > 60) {
                                  invalidTime.value = true;
                                } else {
                                  invalidTime.value = false;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                hintText: Keys.mm.tr(context).toUpperCase(),
                                // suffix: Text(Keys..algoPerSec),
                              ),
                            ),
                          ),
                          Text(
                            ':',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              controller: secondEditController,
                              style: TextStyle(color: AppTheme().cardDarkColor),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              autofocus: false,
                              validator: (value) {
                                value ??= '';
                                if ((int.tryParse(value) ?? 0) > 60) {
                                  invalidTime.value = true;
                                } else {
                                  invalidTime.value = false;
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                filled: true,
                                hintText: Keys.ss.tr(context).toUpperCase(),
                                // suffix: Text(Keys..algoPerSec),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    '${Keys.importance.tr(context)}: ${importanceString()}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).shadowColor.withOpacity(0.20), borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 6),
                        Text(
                          '${Keys.chrony.tr(context)}',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Theme.of(context).cardColor,
                                inactiveTrackColor: Theme.of(context).disabledColor,
                                thumbShape: CustomSliderThumbRect(
                                    mainContext: context, thumbRadius: 15, showValue: true, valueMain: (_importanceRatioValue?.round() ?? 0).toString()),
                              ),
                              child: _importanceSliderValue == null
                                  ? Container()
                                  : Slider(
                                      min: 0,
                                      max: (_importanceSliderMaxHalf * 2.0),
                                      value: _importanceSliderValue!,
                                      onChanged: (value) {
                                        setState(() {
                                          _importanceSliderValue = value;
                                          _importanceRatioValue = (_importanceSliderValue! - _importanceSliderMaxHalf).abs() *
                                                  (_importanceSliderMaxHalf * 2.0 - 2.0) /
                                                  _importanceSliderMaxHalf +
                                              2.0;
                                          // log(X +
                                          //     '_importanceSliderValue=$_importanceSliderValue');
                                          // log(X +
                                          //     '_importanceRatioValue=$_importanceRatioValue');
                                        });
                                      },
                                    ),
                            ),
                          ),
                        ),
                        Text('${Keys.highRoller.tr(context)}', style: Theme.of(context).textTheme.subtitle1),
                        SizedBox(width: 6),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: invalidTime,
                    builder: (BuildContext context, bool value, Widget? child) {
                      return Visibility(
                        visible: value,
                        child: Padding(
                          padding: EdgeInsets.only(left: 12, top: 8),
                          child: Text(
                            Keys.enterValidData.tr(context),
                            style: Theme.of(context).textTheme.caption?.copyWith(color: Theme.of(context).errorColor),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            // const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!(widget.fromBottomSheet ?? false)) {
                  CustomDialogs.loader(true, context);
                }
                await onClickSave(context: context, myUserPageViewModel: myUserPageViewModel, setupUserViewModel: signUpViewModel);
                if (!(widget.fromBottomSheet ?? false)) {
                  CustomDialogs.loader(false, context);
                }
                // await Navigator.of(context).maybePop();
              },
              child: Text(Keys.save.tr(context)),
            )
          ],
        ),
      ),
    );
    if (widget.fromBottomSheet ?? false) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: body,
    );
  }

  void setData() {
    final uid = ref.watch(myUIDProvider)!;
    final userAsyncValue = ref.watch(userProvider(uid));
    bool isLoaded = !(haveToWait(userAsyncValue));
    if (isLoaded) {
      UserModel user = userAsyncValue.value!;
      userNameEditController.text = user.name;
      bioTextController.text = user.bio;

      speedEditController.text = user.rule.minSpeed.toString();
      secondEditController.text = getSec(user.rule.maxMeetingDuration);
      minuteEditController.text = getMin(user.rule.maxMeetingDuration);
      hourEditController.text = getHour(user.rule.maxMeetingDuration);

      if (user.imageUrl is String && user.imageUrl!.isNotEmpty) {
        imageUrl = user.imageUrl!;
        imageType = ImageType.NETWORK_IMAGE;
      } else {
        imageUrl = user.name;
      }

      // importance
      final c = user.rule.importance[Lounge.chrony]!;
      final h = user.rule.importance[Lounge.highroller]!;
      final N = c + h;
      _importanceRatioValue = N / c;
      double x = _importanceRatioValue! - 2.0;
      if (h < c) {
        _importanceRatioValue = N / h;
        x = 2.0 - _importanceRatioValue!;
      }
      _importanceSliderValue = (x / (_importanceSliderMaxHalf * 2.0 - 2.0) + 1.0) * _importanceSliderMaxHalf;
    }
    setState(() {});
  }

  Map<Lounge, int> findImportances(double ratio, Lounge lounge) {
    // log(X + 'findImportances: ratio=$ratio lounge=$lounge');
    final a = ratio - 1.0;
    // log(X + 'findImportances: a=$a');

    int small = 1;
    double largeDouble = a * small;
    int largeInt = largeDouble.round();

    // log(X +
    //     'findImportances: small=$small largeDouble=$largeDouble largeInt=$largeInt');

    int minSmall = small;
    int minLarge = largeInt;
    double minError = (largeDouble - largeInt).abs();

    // log(X +
    //     'findImportances: minSmall=$minSmall minLarge=$minLarge minError=$minError');

    while (small < _importanceSliderMaxHalf * 2.0) {
      small++;
      largeDouble = a * small;
      largeInt = largeDouble.round();
      // log(X +
      //     'findImportances: small=$small largeDouble=$largeDouble largeInt=$largeInt');

      if (_importanceSliderMaxHalf * 2.0 - 1.0 < largeInt) continue;
      final error = (largeDouble - largeInt).abs();
      // log(X + 'findImportances: error=$error');
      if (error < minError) {
        minSmall = small;
        minLarge = largeInt;
        minError = error;
        // log(X +
        //     'findImportances: minSmall=$minSmall minLarge=$minLarge minError=$minError');
      }
    }
    // log(X +
    //     'findImportances: DONE: minSmall=$minSmall minLarge=$minLarge minError=$minError');

    return lounge == Lounge.chrony
        ? {
            Lounge.chrony: minSmall,
            Lounge.highroller: minLarge,
          }
        : {
            Lounge.chrony: minLarge,
            Lounge.highroller: minSmall,
          };
  }

  String importanceString() {
    if (_importanceRatioValue == null || _importanceSliderValue == null) return '';
    final ratio = _importanceRatioValue!.round();
    final postfix = ordinalIndicator(ratio);
    final lounge = _importanceSliderMaxHalf <= _importanceSliderValue! ? Lounge.chrony : Lounge.highroller;
    return 'every $ratio$postfix is a ${lounge.name()}';
  }

  String minSpeedString() {
    if (speedEditController.text.isEmpty) return '';
    final minSpeedPerSec = int.parse(speedEditController.text);
    final minSpeedPerHour = minSpeedPerSec * 3600;
    final minSpeedPerHourinALGO = minSpeedPerHour / 1000000;
    // final s = microALGOToLargerUnit(minSpeedPerHour);
    return '$minSpeedPerHourinALGO ALGO/hour';
  }

  String getHour(int sec) {
    var duration = Duration(seconds: sec);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    // String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    if (duration.inHours <= 0) {
      return '';
    }
    return "${twoDigits(duration.inHours)}";
  }

  String getMin(int sec) {
    var duration = Duration(seconds: sec);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    if (duration.inMinutes.remainder(60) <= 0) {
      return '';
    }
    return twoDigitMinutes;
  }

  String getSec(int sec) {
    var duration = Duration(seconds: sec);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inMinutes.remainder(60) <= 0) {
      return '';
    }
    return twoDigitSeconds;
  }

  Future<void> onClickSave(
      {required MyUserPageViewModel? myUserPageViewModel, required SetupUserViewModel? setupUserViewModel, required BuildContext context}) async {
    FocusScope.of(context).requestFocus(FocusNode());

    bool validate = formKey.currentState?.validate() ?? false;
    UserModel? user = myUserPageViewModel?.user;
    if (setupUserViewModel?.socialLinksModel is SocialLinksModel) {
      SocialLinksModel? socialLinksModel = setupUserViewModel?.socialLinksModel;
      user!.socialLinks = [socialLinksModel!];
    }
    if ((validate && !invalidTime.value) || (widget.fromBottomSheet ?? false)) {
      if (!(widget.fromBottomSheet ?? false)) {
        int seconds = int.tryParse(secondEditController.text) ?? 0;
        seconds += (int.tryParse(minuteEditController.text) ?? 0) * 60;
        seconds += (int.tryParse(hourEditController.text) ?? 0) * 3600;

        user!.setNameOrBio(name: userNameEditController.text, bio: bioTextController.text);

        final lounge = _importanceSliderMaxHalf <= _importanceSliderValue! ? Lounge.chrony : Lounge.highroller;
        final importances = findImportances(_importanceRatioValue!, lounge);

        Rule rule = Rule(minSpeed: int.parse(speedEditController.text), maxMeetingDuration: seconds, importance: {
          Lounge.chrony: importances[Lounge.chrony]!,
          Lounge.highroller: importances[Lounge.highroller]!,
        });
        user.rule = rule;
      } else {
        user!.setNameOrBio(name: userNameEditController.text, bio: bioTextController.text);
      }
      if (imageType == ImageType.ASSENT_IMAGE) {
        String? firebaseImageUrl = await uploadImage();
        if ((firebaseImageUrl ?? "").isNotEmpty) {
          user.imageUrl = firebaseImageUrl;
        }
      }
      await myUserPageViewModel?.updateHangout(user);
    }
  }

  Future<String?> uploadImage() async {
    try {
      var datestamp = new DateFormat("yyyyMMdd'T'HHmmss");
      String currentDate = datestamp.format(DateTime.now());
      Reference reference = FirebaseStorage.instance.ref().child("/FCMImages/$currentDate");
      UploadTask uploadTask = reference.putFile(File(imageUrl));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      log("$e");
    }
    return "";
  }
}
