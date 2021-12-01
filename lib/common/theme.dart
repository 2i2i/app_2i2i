import 'package:flutter/material.dart';

class AppTheme{
  static final AppTheme _singleton = AppTheme._internal();


  AppTheme._internal();

  factory AppTheme() {
    return _singleton;
  }

  Color primaryColor = Color.fromRGBO(116, 117, 109, 1);
  Color primaryVariant = Color.fromRGBO(157, 193, 131, 1);
  Color secondary = Color.fromRGBO(199, 234, 70, 1);
  Color secondaryVariant = Color.fromRGBO(199, 234, 70, 1);
  Color buttonBackground = Color.fromRGBO(208, 226, 105, 1);
  Color green = Color.fromRGBO(80, 121, 66, 1);
  Color red = Color.fromARGB(255, 239, 102, 84);
  Color gray = Color.fromRGBO(112, 112, 108, 1);
  Color lightGray = Color.fromRGBO(221, 221, 217, 1);
  Color lightGreen = Color.fromRGBO(214, 219, 134, 1);
  Color brightBlue = Color.fromRGBO(69, 104, 177, 1);
  Color lightBeige = Color.fromRGBO(224, 224, 213, 1);
  Color black = Colors.black;

  TextStyle? body1Text(BuildContext context){
    return Theme.of(context).textTheme.bodyText1;
  }
  TextStyle? body2Text(BuildContext context){
    return Theme.of(context).textTheme.bodyText2;
  }
  TextStyle? title(BuildContext context){
    return Theme.of(context).textTheme.headline4;
  }
  TextStyle? subTitle(BuildContext context){
    return Theme.of(context).textTheme.headline5;
  }

  ThemeData get mainTheme {
    return ThemeData(
      fontFamily: 'ShipporiAntique',
      colorScheme: ColorScheme(
          primary: primaryColor,
          primaryVariant: primaryVariant,
          secondary: secondary,
          secondaryVariant: secondaryVariant,
          surface: Colors.red,
          background: Colors.red,
          error: Colors.red,
          onPrimary: Color.fromRGBO(189, 239, 204, 1),
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.black,
          brightness: Brightness.light,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: buttonBackground),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          primary: buttonBackground,
          onPrimary: Colors.black,
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.red,
      ),
      textTheme: const TextTheme(),
      scaffoldBackgroundColor: Colors.white,
    );
  }
}