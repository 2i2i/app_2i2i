import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme{
  static final AppTheme _singleton = AppTheme._internal();

  AppTheme._internal();

  factory AppTheme() {
    return _singleton;
  }

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
  Color tabColor = Color.fromRGBO(118, 118, 128, 0.12);
  Color tabTextColor = Color.fromRGBO(153, 153, 153, 1);
  Color fillColor = Color(0xFFC1C1D7);

  Color thumbColor = Color(0xFFD2D2DF);

  Color warningColor = Color(0xFFFEEBEB);
  Color redColor = Color(0xFFF92A2A);

  Color lightSecondaryTextColor = Color(0xff8E8E93);
  Color lightPrimaryTextColor = Colors.black;

  ThemeData mainTheme(BuildContext context) {

    return ThemeData(
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
      appBarTheme: appBarTheme(false,context),
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
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            primary: secondaryColor,
            padding: EdgeInsets.all(kIsWeb?22:14),
            textStyle: TextStyle(
              fontFamily: 'SofiaPro',
              fontSize: 17.0,
              fontWeight: FontWeight.w400,
            ),
            side:BorderSide(color: secondaryColor),
            shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            )
        ),
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
      fontFamily: 'SofiaPro',
      textTheme: TextTheme(
        headline4: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w600,
          fontSize: 34,
          // color: Color(0xff8E8E93),
        ),
        headline5: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w800,
          fontSize: 28,
          // color: Color(0xff8E8E93),
        ),
        headline6: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          // color: Colors.black,
        ),
        subtitle1: TextStyle(
          fontStyle: FontStyle.normal,
          fontSize: 16,
          // color: Color(0xff8E8E93),
        ),
        subtitle2: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          // color: Colors.black,
        ),
        bodyText1: TextStyle(
          // fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w300,
          fontSize: 16,
          color: lightSecondaryTextColor,
        ),
        bodyText2: TextStyle(
          fontStyle: FontStyle.normal,
          // fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
        /*bodyText2: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          // color: Colors.black,
        ),*/
        caption: TextStyle(
          fontStyle: FontStyle.normal,
          fontSize: 12,
          // color: Color(0xff8E8E93),
        ),
      ),
    );
  }

  ThemeData darkTheme(BuildContext context) {
    return ThemeData(
        brightness: Brightness.dark,
        appBarTheme: appBarTheme(true,context),
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
            selectedIconTheme: IconThemeData(color: primaryColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: secondaryDarkColor,
            padding: EdgeInsets.all(24),
            textStyle: TextStyle(
              fontFamily: 'SofiaPro',
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            primary: secondaryDarkColor,
            padding: EdgeInsets.all(24),
            textStyle: TextStyle(
              fontFamily: 'SofiaPro',
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryLightColor,
        ),
        tabBarTheme: TabBarTheme(
          indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            color: primaryColor,
          ),
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
        colorScheme: ColorScheme.dark(secondary: primaryColor),
        textSelectionTheme: TextSelectionThemeData(cursorColor: primaryLightColor),
      fontFamily: 'SofiaPro',
      textTheme: TextTheme(
        headline4: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w600,
          fontSize: 34,
          // color: Color(0xff8E8E93),
        ),
        headline5: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w800,
          fontSize: 28,
          // color: Color(0xff8E8E93),
        ),
        headline6: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          // color: Colors.black,
        ),
        subtitle1: TextStyle(
          fontStyle: FontStyle.normal,
          fontSize: 16,
          // color: Color(0xff8E8E93),
        ),
        subtitle2: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          // color: Colors.black,
        ),
        bodyText1: TextStyle(
          // fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w300,
          fontSize: 16,
          color: lightSecondaryTextColor,
        ),
        bodyText2: TextStyle(
          fontStyle: FontStyle.normal,
          // fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
        /*bodyText2: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          // color: Colors.black,
        ),*/
        caption: TextStyle(
          fontStyle: FontStyle.normal,
          fontSize: 12,
          // color: Color(0xff8E8E93),
        ),
      ),
    );
  }

  AppBarTheme appBarTheme(bool dark,BuildContext context) => AppBarTheme(
    elevation: 0,
    backgroundColor: !dark ? primaryColor : primaryDarkColor,
    iconTheme: IconThemeData(color: dark ? white : cardDarkColor),
    titleTextStyle: TextStyle(
      color: Color(0xff48484A),
      fontSize: 34,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.37,
    ),
  );

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
