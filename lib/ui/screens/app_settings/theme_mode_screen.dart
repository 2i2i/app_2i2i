import 'package:app_2i2i/infrastructure/commons/strings.dart';
import 'package:app_2i2i/infrastructure/providers/all_providers.dart';
import 'package:app_2i2i/ui/screens/app_settings/widgets/mode_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeScreen extends ConsumerStatefulWidget {
  const ThemeModeScreen({Key? key}) : super(key: key);

  @override
  _ThemeModeScreenState createState() => _ThemeModeScreenState();
}

class _ThemeModeScreenState extends ConsumerState<ThemeModeScreen> {

  int selectedRadio = 0;
  int selectedRadioTile = 0;

  @override
  Widget build(BuildContext context) {
    var appSettingModel = ref.watch(appSettingProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Theme',style: Theme.of(context).textTheme.headline6,),
            SizedBox(height: 20),
            Text(
              Strings().themeMode,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ModeWidgets(
                    isDarkMode: false,
                    isSelected:
                    appSettingModel.currentThemeMode == ThemeMode.light,
                    onTap: () {
                      appSettingModel.setThemeMode("LIGHT");
                    },
                  ),
                  ModeWidgets(
                    isDarkMode: true,
                    isSelected:
                    appSettingModel.currentThemeMode == ThemeMode.dark,
                    onTap: () {
                      appSettingModel.setThemeMode("DARK");
                    },
                  ),
                ],
              ),
            ),
            Divider(color: Colors.transparent),
            ListTile(
              title: Text(Strings().automatic),
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
          ],
        ),
      ),
    );
  }

}
