import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/user_model.dart';
import 'package:app_2i2i/infrastructure/providers/my_user_provider/my_user_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

import '../../../infrastructure/commons/keys.dart';
import '../../../infrastructure/commons/theme.dart';
import '../../../infrastructure/providers/all_providers.dart';
import '../create_bid/top_card_widget.dart';

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
  TextEditingController bioEditController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ValueNotifier<bool> invalidTime = ValueNotifier(false);

  File? imageFile;
  String imageUrl = "";

  // importance
  static const double _importanceSliderMaxHalf = 5.0;
  double? _importanceRatioValue;
  double? _importanceSliderValue;

  RichTextController? bioTextController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setData();
    });
  }

  Map<Lounge, int> findImportances(double ratio, Lounge lounge) {
    final a = ratio - 1.0;

    int small = 1;
    double largeDouble = a * small;
    int largeInt = largeDouble.round();

    int minSmall = small;
    int minLarge = largeInt;
    double minError = (largeDouble - largeInt).abs();

    while (small < _importanceSliderMaxHalf * 2.0) {
      small++;
      largeDouble = a * small;
      largeInt = largeDouble.round();
      if (_importanceSliderMaxHalf * 2.0 - 1.0 < largeInt) continue;
      final error = (largeDouble - largeInt).abs();
      if (error < minError) {
        minSmall = small;
        minLarge = largeInt;
        minError = error;
      }
    }

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
    if (_importanceRatioValue == null || _importanceSliderValue == null)
      return '';
    final ratio = _importanceRatioValue!.round();
    final postfix = ordinalIndicator(ratio);
    final lounge = _importanceSliderMaxHalf <= _importanceSliderValue!
        ? Lounge.chrony
        : Lounge.highroller;
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

  void setData() {
    final uid = ref.watch(myUIDProvider)!;
    final userAsyncValue = ref.watch(userProvider(uid));
    bool isLoaded = !(haveToWait(userAsyncValue));
    if (isLoaded) {
      UserModel user = userAsyncValue.asData!.value;
      userNameEditController.text = user.name;
      bioEditController.text = user.bio;

      speedEditController.text = user.rule.minSpeed.toString();
      secondEditController.text = getSec(user.rule.maxMeetingDuration);
      minuteEditController.text = getMin(user.rule.maxMeetingDuration);
      hourEditController.text = getHour(user.rule.maxMeetingDuration);

      imageUrl = userAsyncValue.asData!.value.name;

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
      _importanceSliderValue =
          (x / (_importanceSliderMaxHalf * 2.0 - 2.0) + 1.0) *
              _importanceSliderMaxHalf;
    }
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    bioTextController ??= RichTextController(
      patternMatchMap: {
        RegExp(r"(?:#)[a-zA-Z0-9]+"):
            TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)
      },
      onMatch: (List<String> match) {},
    );
    final myUserPageViewModel = ref.watch(myUserPageViewModelProvider);

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
              widget.fromBottomSheet ?? false
                  ? Keys.setUpAccount.tr(context)
                  : Keys.userSettings.tr(context),
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 28),

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
              onChanged: (value) {
                imageUrl = value;
                setState(() {});
              },
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
                                if (value.isEmpty ||
                                    (int.tryParse(value) ?? 0) > 24) {
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
                    decoration: BoxDecoration(
                        color: Theme.of(context).shadowColor.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(10)),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Theme.of(context).cardColor,
                                inactiveTrackColor:
                                    Theme.of(context).disabledColor,
                                thumbShape: CustomSliderThumbRect(
                                  mainContext: context,
                                  thumbRadius: 15,
                                ),
                              ),
                              child: _importanceSliderValue == null
                                  ? Container()
                                  : Slider(
                                      min: 0,
                                      max: _importanceSliderMaxHalf * 2.0,
                                      value: _importanceSliderValue!,
                                      onChanged: (value) {
                                        setState(() {
                                          _importanceSliderValue = value;
                                          _importanceRatioValue =
                                              (_importanceSliderValue! -
                                                              _importanceSliderMaxHalf)
                                                          .abs() *
                                                      (_importanceSliderMaxHalf *
                                                              2.0 -
                                                          2.0) /
                                                      _importanceSliderMaxHalf +
                                                  2.0;
                                        });
                                      },
                                    ),
                            ),
                          ),
                        ),
                        Text('${Keys.highRoller.tr(context)}',
                            style: Theme.of(context).textTheme.subtitle1),
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
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(color: Theme.of(context).errorColor),
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
              onPressed: () {
                onClickSave(myUserPageViewModel, context);
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
      appBar: AppBar(elevation: 0),
      body: body,
    );
  }

  Future<void> onClickSave(
      MyUserPageViewModel? myUserPageViewModel, BuildContext context) async {
    bool validate = formKey.currentState?.validate() ?? false;
    UserModel? user = myUserPageViewModel?.user;
    if ((validate && !invalidTime.value) || (widget.fromBottomSheet ?? false)) {
      if (user is UserModel && !(widget.fromBottomSheet ?? false)) {
        int seconds = int.tryParse(secondEditController.text) ?? 0;
        seconds += (int.tryParse(minuteEditController.text) ?? 0) * 60;
        seconds += (int.tryParse(hourEditController.text) ?? 0) * 3600;

        user.setNameOrBio(
            name: userNameEditController.text, bio: bioEditController.text);

        final lounge = _importanceSliderMaxHalf <= _importanceSliderValue!
            ? Lounge.chrony
            : Lounge.highroller;
        final importances = findImportances(_importanceRatioValue!, lounge);

        Rule rule = Rule(
            minSpeed: int.parse(speedEditController.text),
            maxMeetingDuration: seconds,
            importance: {
              Lounge.chrony: importances[Lounge.chrony]!,
              Lounge.highroller: importances[Lounge.highroller]!,
            });
        user.rule = rule;
      } else {
        user!.setNameOrBio(
            name: userNameEditController.text, bio: bioEditController.text);
      }
      await myUserPageViewModel?.updateHangout(user);
      Navigator.of(context).maybePop();
    }
  }
}