import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme{
  static final AppTheme _singleton = AppTheme._internal();

  AppTheme._internal();

  factory AppTheme() {
    return _singleton;
  }

  static const MaterialColor primarySwatch = MaterialColor(
    0xFF7263E2,
    <int, Color>{
      50: Color.fromRGBO(116, 117, 109, .1),
      100: Color.fromRGBO(116, 117, 109, .2),
      200: Color.fromRGBO(116, 117, 109, .3),
      300: Color.fromRGBO(116, 117, 109, .4),
      400: Color.fromRGBO(116, 117, 109, .5),
      500: Color.fromRGBO(116, 117, 109, .6),
      600: Color.fromRGBO(116, 117, 109, .7),
      700: Color.fromRGBO(116, 117, 109, .8),
      800: Color.fromRGBO(116, 117, 109, .9),
      900: Color.fromRGBO(116, 117, 109, 1),
    },
  );

  static const MaterialColor darkTextColor = MaterialColor(
    0xFFFFFFFF,
    const <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );

  /*static const MaterialColor lightTextColor = MaterialColor(
    0xFF000000,
    const <int, Color>{
      50: const Color(0xFF000000),
      100: const Color(0xFF000000),
      200: const Color(0xFF000000),
      300: const Color(0xFF000000),
      400: const Color(0xFF000000),
      500: const Color(0xFF000000),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );*/

  Color buttonBackground = Color.fromRGBO(208, 226, 105, 1);
  Color green = Color(0xFF34C759);
  Color red = Color(0xFFFC8383);
  Color pink = Color.fromARGB(255, 244, 162, 163);
  Color gray = Color.fromRGBO(112, 112, 108, 1);
  Color lightGray = Color.fromRGBO(221, 221, 217, 1);
  Color black = Colors.black;
  Color white = Colors.white;

  Color primaryColor = Color(0xFFf3f3f7);
  Color primaryLightColor = Color(0xFFffffff);
  Color primaryDarkColor = Color(0x90000000);

  Color secondaryColor = Color(0xFF23d67d);
  Color shaDowColor = Color(0xFFDCF9EB);
  Color secondaryDarkColor = Color(0xFF00a350);

  Color primaryTextColor = Color(0xFF000000);
  Color secondaryTextColor = Color(0xFFffffff);

  Color cardDarkColor = Colors.grey.shade800;
  Color disableColor = Color(0xFF979592);
  Color fillColor = Color(0xFFC1C1D7);

  ThemeData get mainTheme {
    return ThemeData(
      fontFamily: 'SofiaPro',
      brightness: Brightness.light,
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      scaffoldBackgroundColor: primaryColor,
      shadowColor: fillColor,
      disabledColor: disableColor,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: ColorScheme.light(
        secondary: secondaryColor,
      ),
      appBarTheme: appBarTheme(false),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(primary: primaryTextColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          selectedLabelStyle: TextStyle(
            fontFamily: 'SofiaPro',
            fontSize: 10.0,
            fontWeight: FontWeight.normal,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'SofiaPro',
            fontSize: 10.0,
            fontWeight: FontWeight.normal,
          ),
          selectedItemColor: secondaryColor,
          unselectedItemColor: disableColor,
          backgroundColor: primaryLightColor,
          selectedIconTheme: IconThemeData(color: Colors.white)),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            primary: secondaryColor,
            padding: EdgeInsets.all(kIsWeb?22:14),
            textStyle: TextStyle(
              fontFamily: 'SofiaPro',
              fontSize: 17.0,
              fontWeight: FontWeight.w400,
            )),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLightColor,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: primaryColor,
        unselectedLabelColor: primaryTextColor,
        indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0), color: secondaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: fillColor.withOpacity(0.12),
        iconColor: fillColor,
        labelStyle: TextStyle(color: secondaryColor),
        border: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
        enabledBorder: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
        focusedBorder: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: secondaryColor),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
        brightness: Brightness.dark,
        appBarTheme: appBarTheme(true),
        fontFamily: 'SofiaPro',
        primaryColor: primaryDarkColor,
        primaryColorLight: secondaryDarkColor,
        primaryColorDark: secondaryTextColor,
        scaffoldBackgroundColor: primaryDarkColor,
        iconTheme: IconThemeData(color: primaryColor),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(primary: Colors.white),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: primaryColor,
            unselectedItemColor: disableColor,
            backgroundColor: Colors.grey[800],
            selectedIconTheme: IconThemeData(color: primaryColor)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              primary: cardDarkColor,
              padding: EdgeInsets.all(24),
              textStyle: TextStyle(
                fontFamily: 'SofiaPro',
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
              )),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryLightColor,
        ),
        tabBarTheme: TabBarTheme(
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0), color: primaryColor),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: primaryLightColor),
          enabledBorder: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(5.0),
            borderSide: BorderSide(color: primaryLightColor),
          ),
          focusedBorder: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(5.0),
            borderSide: BorderSide(color: primaryLightColor),
          ),
        ),
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: primaryLightColor),
        colorScheme: ColorScheme.dark(secondary: primaryColor));
  }

  AppBarTheme appBarTheme(bool dark) => AppBarTheme(
      elevation: 0,
      backgroundColor: !dark ? primaryColor : primaryDarkColor,
      iconTheme: IconThemeData(color: dark ? white : primaryTextColor),
      titleTextStyle: TextStyle(
        fontSize: 20.0,
        color: dark ? white : lightGray,
        fontFamily: 'SofiaPro',
        fontWeight: FontWeight.w500,
      ));

/*ThemeMode getThemeMode() {
    String _themeMode = GetStorage().read<String>('theme_mode') ?? '';
    switch (_themeMode) {
      case 'ThemeMode.light':
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.light
              .copyWith(systemNavigationBarColor: Colors.white),
        );
        return ThemeMode.light;
      case 'ThemeMode.dark':
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark
              .copyWith(systemNavigationBarColor: Colors.black87),
        );
        return ThemeMode.dark;
      case 'ThemeMode.system':
        return ThemeMode.system;
      default:
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.light
              .copyWith(systemNavigationBarColor: Colors.white),
        );
        return ThemeMode.light;
    }
  }*/
}