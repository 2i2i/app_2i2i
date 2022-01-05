
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/auth.dart';

import '../../../infrastructure/commons/strings.dart';
import '../../../infrastructure/providers/all_providers.dart';
import 'widgets/mode_widgets.dart';

class AppSettingPage extends ConsumerStatefulWidget {
  @override
  _AppSettingPageState createState() => _AppSettingPageState();
}

class _AppSettingPageState extends ConsumerState<AppSettingPage> {
  int _value = 1;

  List<String> networkList = ["Main", "Test", "Both"];

  int selectedRadio = 0;
  int selectedRadioTile = 0;

  @override
  void initState() {
    getMode();
    super.initState();
  }

  Future<void> getMode() async {
    String? networkMode = await ref.read(algorandProvider).getNetworkMode();
    int itemIndex = networkList.indexWhere((element) => element == networkMode);
    if (itemIndex < 0) {
      itemIndex = 0;
    }
    setState(() {
      _value = itemIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    var algorand = ref.watch(algorandProvider);
    var appSettingModel = ref.watch(appSettingProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('App Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            Text(Strings().themeMode,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ModeWidgets(
                      isDarkMode: false,
                      isSelected: appSettingModel.currentThemeMode == ThemeMode.light,
                      onTap: () {
                        appSettingModel.setThemeMode("LIGHT");
                      }),
                  ModeWidgets(
                    isDarkMode: true,
                    isSelected: appSettingModel.currentThemeMode == ThemeMode.dark,
                    onTap: () {
                      appSettingModel.setThemeMode("DARK");
                    },
                  ),
                ],
              ),
            ),
            Divider(color: Colors.transparent),
            ListTile(
              title: Text('Automatic'),
              trailing: Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: appSettingModel.isAutoModeEnable,
                    onChanged: (value) async {
                      String mode = await appSettingModel.getThemeMode()??"";
                      appSettingModel.setThemeMode(value ? "AUTO" : mode);
                    },
                    activeColor: Theme.of(context).iconTheme.color,
                    thumbColor: Theme.of(context).scaffoldBackgroundColor,
                  )),
            ),
            Divider(),
            SizedBox(height: 8),
            Text(Strings().selectNetworkMode,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    focusColor: Colors.transparent,
                    underline: Container(),
                    value: _value,
                    borderRadius: BorderRadius.circular(10),
                    items: List.generate(
                        networkList.length,
                        (index) => DropdownMenuItem(
                              child: Text(networkList[index]),
                              value: index,
                            )),
                    onChanged: (int? value) async {
                      setState(() {
                        _value = value!;
                      });
                      await algorand
                          .setNetworkMode(networkList[_value].toString());
                    },
                  ),
                ),
              ),
            ),
            Divider(),
            SizedBox(height: 8),
            SignOutButton(),
          ],
        ),
      ),
    );
  }

  setSelectedRadioTile(int val) {
    setState(() {
      selectedRadioTile = val;
    });
  }
}
