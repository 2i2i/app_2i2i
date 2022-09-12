import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/my_user_provider/my_user_page_view_model.dart';
import 'package:app_2i2i/ui/commons/custom_app_bar_web.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/commons/theme.dart';
import '../../../infrastructure/data_access_layer/services/logging.dart';
import '../../../infrastructure/models/social_links_model.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../../../infrastructure/providers/setup_user_provider/setup_user_view_model.dart';
import '../../commons/custom_alert_widget.dart';
import '../../commons/custom_profile_image_view.dart';
import '../create_bid/top_card_widget.dart';
import 'image_pick_option_widget.dart';

class UserSettingWeb extends ConsumerStatefulWidget {
  final bool? fromBottomSheet;

  UserSettingWeb({Key? key, this.fromBottomSheet}) : super(key: key);

  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends ConsumerState<UserSettingWeb> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);
    final signUpViewModel = ref.watch(setupUserViewModelProvider);
    Widget body = SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: kToolbarHeight * 2),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: kToolbarHeight - 30,
            ),
            Text(
              widget.fromBottomSheet ?? false ? Keys.setUpAccount.tr(context) : Keys.userSettings.tr(context),
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: kToolbarHeight - 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfileWidget(
                          onTap: () => CustomAlertWidget.showBottomSheet(
                                context,
                                child: ImagePickOptionWidget(
                                  imageCallBack: (ImageType imageType, String imagePath) {
                                    if (imagePath.isNotEmpty) {
                                      Navigator.of(context).pop();
                                      imageUrl = imagePath;
                                      this.imageType = imageType;
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                          stringPath: imageUrl,
                          radius: kToolbarHeight * 1.45,
                          imageType: imageType,
                          isRating: false,
                          showEdit: true,
                          hideShadow: true),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Keys.name.tr(context),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            maxLength: 30,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(30),
                              //FilteringTextInputFormatter.deny(' '),
                              FilteringTextInputFormatter.deny(
                                RegExp(r'[/\\.,?!£$%^&*()+=.]'),
                              ),
                              FilteringTextInputFormatter.allow(
                                RegExp("[a-z A-Z 0-9]"),
                              ),
                            ],
                            controller: userNameEditController,
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            style: TextStyle(color: AppTheme().cardDarkColor),
                            validator: (value) {
                              value ??= '';
                              if (value.trim().isEmpty) {
                                return Keys.required.tr(context);
                              } else if (value.trim().length < 3) {
                                return 'Required min 3 characters';
                              }
                              if (value.trim().length < 3) {
                                return "name must be 3 characters long";
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
                    ],
                  ),
                ),
                SizedBox(width: kToolbarHeight * 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Keys.bio.tr(context),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        controller: bioTextController,
                        textInputAction: TextInputAction.newline,
                        maxLines: 4,
                        style: TextStyle(color: AppTheme().cardDarkColor),
                        decoration: InputDecoration(
                          filled: true,
                          border: OutlineInputBorder(),
                          hintText: Keys.bioExample.tr(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: kToolbarHeight - 20),
            Visibility(
              visible: !(widget.fromBottomSheet ?? false),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${Keys.minSpeed.tr(context)}: ${minSpeedString()}',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              onChanged: (value) => setState(() {}),
                              controller: speedEditController,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(color: AppTheme().cardDarkColor),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}')),
                              ],
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              autofocus: false,
                              validator: (value) {
                                value ??= '';
                                if (value.trim().isEmpty || num.tryParse(value) == null) {
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
                          ],
                        ),
                      ),
                      const SizedBox(width: kToolbarHeight * 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Keys.maxDuration.tr(context),
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            const SizedBox(height: 10),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: kToolbarHeight),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Keys.importance.tr(context)}: ${importanceString()}',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(color: Theme.of(context).shadowColor.withOpacity(0.20), borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Text(
                                '${Keys.chrony.tr(context)}',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4.0,
                                    thumbColor: Colors.blueAccent,
                                    activeTrackColor: Theme.of(context).cardColor,
                                    inactiveTrackColor: Theme.of(context).disabledColor,
                                    thumbShape: CustomSliderThumbRect(
                                        mainContext: context, thumbRadius: 20, showValue: true, valueMain: (_importanceRatioValue?.round() ?? 0).toString()),
                                  ),
                                  child: _importanceSliderValue == null
                                      ? Container()
                                      : Slider(
                                          mouseCursor: MaterialStateMouseCursor.clickable,
                                          divisions: 10,
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
                                            });
                                          },
                                        ),
                                ),
                              ),
                              Text('${Keys.highRoller.tr(context)}', style: Theme.of(context).textTheme.subtitle1),
                              SizedBox(width: 10),
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
                      ],
                    ),
                  ),
                  SizedBox(height: kToolbarHeight),
                ],
              ),
            ),
            Visibility(
              //visible: !(widget.fromBottomSheet ?? false),
              visible: true,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 7,
                    decoration: BoxDecoration(),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          CustomAlertWidget.loader(true, context);
                          await onClickSave(context: context, myUserPageViewModel: myUserPageViewModel, setupUserViewModel: signUpViewModel);
                          CustomAlertWidget.loader(false, context);
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8.0,
                      ),
                      child: Text(Keys.save.tr(context)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (widget.fromBottomSheet ?? false) {
      return body;
    }
    return Scaffold(
      appBar: CustomAppbarWeb(),
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

      speedEditController.text = (user.rule.minSpeed / MILLION).toString();
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
    final m = ratio.round() - 1;
    return lounge == Lounge.chrony
        ? {
            Lounge.chrony: 1,
            Lounge.highroller: m,
          }
        : {
            Lounge.chrony: m,
            Lounge.highroller: 1,
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
    final minSpeedPerSec = getSpeedFromText();
    final minSpeedPerHour = minSpeedPerSec * 3600;
    final minSpeedPerHourinALGO = minSpeedPerHour / MILLION;
    return '$minSpeedPerHourinALGO ALGO/hour';
  }

  int getSpeedFromText() => ((num.tryParse(speedEditController.text) ?? 0) * MILLION).round();

  String getHour(int sec) {
    var duration = Duration(seconds: sec);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
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
      user?.socialLinks = [setupUserViewModel!.socialLinksModel!];
    }
    if ((validate && !invalidTime.value) || (widget.fromBottomSheet ?? false)) {
      if (!(widget.fromBottomSheet ?? false)) {
        int seconds = int.tryParse(secondEditController.text) ?? 0;
        seconds += (int.tryParse(minuteEditController.text) ?? 0) * 60;
        seconds += (int.tryParse(hourEditController.text) ?? 0) * 3600;

        user!.setNameOrBio(name: userNameEditController.text, bio: bioTextController.text);

        final lounge = _importanceSliderMaxHalf <= _importanceSliderValue! ? Lounge.chrony : Lounge.highroller;
        final importance = findImportances(_importanceRatioValue!, lounge);

        Rule rule = Rule(
          minSpeed: getSpeedFromText(),
          maxMeetingDuration: seconds,
          importance: {
            Lounge.chrony: importance[Lounge.chrony]!,
            Lounge.highroller: importance[Lounge.highroller]!,
          },
        );
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
