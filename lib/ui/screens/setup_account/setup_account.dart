import 'dart:io';

import 'package:app_2i2i/infrastructure/commons/utils.dart';
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
  TextEditingController minEditController = TextEditingController();
  TextEditingController hourEditController = TextEditingController();
  TextEditingController minuteEditController = TextEditingController();
  TextEditingController bioEditController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ValueNotifier<bool> invalidTime = ValueNotifier(false);

  File? imageFile;
  String imageUrl = "";

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final uid = ref.watch(myUIDProvider)!;
      final hangout = ref.watch(hangoutProvider(uid));
      bool isLoaded = !(haveToWait(hangout));
      if (isLoaded) {
        userNameEditController.text = hangout.asData!.value.name;
        bioEditController.text = hangout.asData!.value.bio;
        imageUrl = hangout.asData!.value.name;
      }
    });
    super.initState();
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
              minLines: 6,
              maxLines: 6,
              decoration: InputDecoration(
                filled: true,
                // fillColor: Theme.of(context).primaryColorLight,
                border: OutlineInputBorder(),
                hintText: Strings().bioExample,
              ),
            ),
            const SizedBox(height: 30),

            Text(
              Strings().minSpeed,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            const SizedBox(height: 6),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: minEditController,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          if (value.trim().isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! > 24) {
                            invalidTime.value = true;
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          if (value.trim().isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! > 60) {
                            invalidTime.value = true;
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
                    padding: EdgeInsets.only(left: 12,top: 8),
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

            // const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  myUserPageViewModel?.changeNameAndBio(
                      userNameEditController.text, bioEditController.text,);
                  Navigator.of(context).maybePop();
                }
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
}
