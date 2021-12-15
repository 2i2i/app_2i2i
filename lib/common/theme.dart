import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Color green = Color.fromRGBO(80, 121, 66, 1);
  Color red = Color.fromARGB(255, 239, 102, 84);
  Color pink = Color.fromARGB(255, 244, 162, 163);
  Color gray = Color.fromRGBO(112, 112, 108, 1);
  Color lightGray = Color.fromRGBO(221, 221, 217, 1);
  Color black = Colors.black;
  Color white = Colors.white;

  Color primaryColor = Color(0xFF9dc183);
  Color primaryLightColor = Color(0xFFcff4b3);
  Color primaryDarkColor = Color(0xFF6e9156);

  Color secondaryColor = Color(0xFF2e7d32);
  Color secondaryDarkColor = Color(0xFF005005);
  Color primaryTextColor = Color(0xFF000000);
  Color secondaryTextColor = Color(0xFFffffff);

  ThemeData get mainTheme {
    return ThemeData(
      fontFamily: 'ShipporiAntique',
      brightness: Brightness.light,
        primaryColor: primaryColor,
        primaryColorLight: primaryLightColor,
        primaryColorDark: primaryDarkColor,
        colorScheme: ColorScheme.light(
          secondary: secondaryColor,
        ),
        textTheme: themeMode(),
        appBarTheme: appBarTheme(false),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(primary: Colors.black),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: primaryColor,
            selectedIconTheme: IconThemeData(color: Colors.white)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(primary: primaryColor),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: primaryDarkColor
          ),
          enabledBorder: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(5.0),
            borderSide: BorderSide(color: primaryColor),
          ),
          focusedBorder: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(5.0),
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(cursorColor: primaryColor));
  }

  ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: appBarTheme(false),
      fontFamily: 'ShipporiAntique',
      primaryColor: primaryColor,
      primaryColorLight: primaryLightColor,
      primaryColorDark: primaryDarkColor,
      textTheme: themeMode(),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(primary: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: primaryColor,
          selectedIconTheme: IconThemeData(color: Colors.black)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(primary: primaryColor),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryLightColor,
      ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
              color: primaryLightColor
          ),
          enabledBorder: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(5.0),
            borderSide: BorderSide(color: primaryLightColor),
          ),
          focusedBorder: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(5.0),
            borderSide: BorderSide(color: primaryLightColor),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(cursorColor: primaryLightColor)
    );
  }

  TextTheme themeMode() => TextTheme(
        headline6: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w600,
        ),
        headline5: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w500,
        ),
        headline4: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
        ),
        headline3: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
        ),
        headline2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal),
        headline1: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        subtitle2: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        ),
        subtitle1: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        bodyText2: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        bodyText1: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
        caption: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
        ),
      );

  AppBarTheme appBarTheme(bool dark) => AppBarTheme(
      backgroundColor: primaryColor,
      titleTextStyle: TextStyle(
        fontSize: 20.0,
        color: dark ? white : lightGray,
        fontFamily: 'ShipporiAntique',
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