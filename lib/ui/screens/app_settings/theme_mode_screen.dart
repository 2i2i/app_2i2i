import 'package:app_2i2i/infrastructure/commons/keys.dart';
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
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(Keys.theme.tr(context),style: Theme.of(context).textTheme.headline5,),
            SizedBox(height: 20),
            Text(
              Keys.themeMode.tr(context),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1,
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
                      appSettingModel.setThemeMode(Keys.light);
                    },
                  ),
                  ModeWidgets(
                    isDarkMode: true,
                    isSelected:
                    appSettingModel.currentThemeMode == ThemeMode.dark,
                    onTap: () {
                      appSettingModel.setThemeMode(Keys.dark);
                    },
                  ),
                ],
              ),
            ),
            Divider(color: Colors.transparent),
            ListTile(
              title: Text(Keys.automatic.tr(context)),
              trailing: Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: appSettingModel.isAutoModeEnable,
                    onChanged: (value) async {
                      String mode = await appSettingModel.getThemeMode()??"";
                      appSettingModel.setThemeMode(value ? Keys.auto : mode);
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
