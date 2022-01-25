import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
import 'package:app_2i2i/infrastructure/models/hangout_model.dart';
import 'package:app_2i2i/infrastructure/providers/my_hangout_provider/my_hangout_page_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/providers/all_providers.dart';

class HangoutSetting extends ConsumerStatefulWidget {
  final bool? fromBottomSheet;

  HangoutSetting({Key? key, this.fromBottomSheet}) : super(key: key);

  @override
  _HangoutSettingState createState() => _HangoutSettingState();
}

class _HangoutSettingState extends ConsumerState<HangoutSetting> {
  TextEditingController userNameEditController = TextEditingController();
  TextEditingController speedEditController = TextEditingController();
  TextEditingController hourEditController = TextEditingController();
  TextEditingController minuteEditController = TextEditingController();
  TextEditingController bioEditController = TextEditingController();

  TextEditingController highRollerController = TextEditingController();
  TextEditingController chronyController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ValueNotifier<bool> invalidTime = ValueNotifier(false);

  File? imageFile;
  String imageUrl = "";



  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setData();
    });
    super.initState();
  }

  void setData() {
      final uid = ref.watch(myUIDProvider)!;
    final hangout = ref.watch(hangoutProvider(uid));
    bool isLoaded = !(haveToWait(hangout));
    if (isLoaded) {
      Hangout hangoutModel = hangout.asData!.value;
      userNameEditController.text = hangoutModel.name;
      bioEditController.text = hangoutModel.bio;

      speedEditController.text = hangoutModel.rule.minSpeed.toString();
      minuteEditController.text = getMin(hangoutModel.rule.maxMeetingDuration);
      hourEditController.text = getHour(hangoutModel.rule.maxMeetingDuration);
      chronyController.text = hangoutModel.rule.importance[Lounge.chrony]?.toString()??'';
      highRollerController.text = hangoutModel.rule.importance[Lounge.highroller]?.toString()??'';

      imageUrl = hangout.asData!.value.name;
    }
  }

  String getHour(int sec) {
    var duration = Duration(seconds: sec);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    // String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    if(duration.inHours <= 0){
      return '';
    }
    return "${twoDigits(duration.inHours)}";
  }
  String getMin(int sec) {
    var duration = Duration(seconds: sec);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    if(duration.inMinutes.remainder(60) <= 0 ){
      return '';
    }
    return "$twoDigitMinutes";
  }

  @override
  Widget build(BuildContext context) {
    final myUserPageViewModel = ref.watch(myHangoutPageViewModelProvider);

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              Strings().setUpAccount,
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 28),

            Text(
              Strings().userName,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 6),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: userNameEditController,
              textInputAction: TextInputAction.next,
              autofocus: false,
              onChanged: (value) {
                imageUrl = value;
                setState(() {});
              },
              validator: (value) {
                value ??= '';
                if (value.trim().isEmpty) {
                  return Strings().required;
                }
              },
              decoration: InputDecoration(
                filled: true,
                hintText: Strings().yourNameHint,
              ),
            ),
            const SizedBox(height: 30),

            Text(
              Strings().bio,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: bioEditController,
              textInputAction: TextInputAction.newline,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              minLines: 4,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                // fillColor: Theme.of(context).primaryColorLight,
                border: OutlineInputBorder(),
                hintText: Strings().bioExample,
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
                    Strings().minSpeed,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: speedEditController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autofocus: false,
                    validator: (value) {
                      value ??= '';
                      if (value.trim().isEmpty || int.tryParse(value) == null) {
                        return Strings().enterValidData;
                      }
                    },
                    decoration: InputDecoration(
                      filled: true,
                      hintText: Strings().numberHint,
                      suffix: Text(Strings().algoPerSec),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    Strings().maxDuration,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 150,
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
                                hintText: Strings().hh.toUpperCase(),
                                // suffix: Text(Strings().algoPerSec),
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
                                hintText: Strings().mm.toUpperCase(),
                                // suffix: Text(Strings().algoPerSec),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                            Strings().enterValidData,
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
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            Lounge.highroller.name(),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 60,
                              child: TextFormField(
                                controller: highRollerController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                autofocus: false,
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText: Strings().numberZeroHint,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 30),
                      Column(
                        children: [
                          Text(
                            Lounge.chrony.name(),
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 60,
                              child: TextFormField(
                                controller: chronyController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                ],
                                autofocus: false,
                                decoration: InputDecoration(
                                  filled: true,
                                  hintText: Strings().numberZeroHint,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
              child: Text(Strings().save),
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

  void onClickSave(MyHangoutPageViewModel? myUserPageViewModel, BuildContext context) {
    bool validate = formKey.currentState?.validate() ?? false;
    Hangout? hangout = myUserPageViewModel?.hangout;
    if ((validate && !invalidTime.value) || (widget.fromBottomSheet ?? false)) {
      if (hangout is Hangout && !(widget.fromBottomSheet ?? false)) {
        int minutes = ((int.tryParse(hourEditController.text) ?? 0) * 60) + (int.tryParse(minuteEditController.text) ?? 0);
        hangout.name = userNameEditController.text;
        hangout.bio = bioEditController.text;
        HangOutRule rule = HangOutRule(
            minSpeed: int.parse(speedEditController.text),
            maxMeetingDuration: minutes * 60,
            importance: {
              Lounge.chrony: int.tryParse(chronyController.text) ?? 1,
              Lounge.highroller: int.tryParse(highRollerController.text) ?? 5,
            });
        hangout.rule = rule;
      } else {
        hangout!.name = userNameEditController.text;
        hangout.bio = bioEditController.text;
      }
      myUserPageViewModel?.updateHangout(hangout);
      Navigator.of(context).maybePop();
    }
  }
}
