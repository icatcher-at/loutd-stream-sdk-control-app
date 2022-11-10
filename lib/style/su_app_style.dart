import 'package:flutter/material.dart';

class SUAppStyle {
  MaterialColor getPrimaryBlack() {
    const int blackPrimaryValue = 0x26B2A7;

    return MaterialColor(
      blackPrimaryValue,
    <int, Color>{
        50: streamUnlimitedGrey3(),
        100: streamUnlimitedGrey3(),
        200: streamUnlimitedGrey3(),
        300: streamUnlimitedGrey3(),
        400: streamUnlimitedGrey3(),
        500: streamUnlimitedGrey3(),
        600: streamUnlimitedGrey3(),
        700: streamUnlimitedGrey3(),
        800: streamUnlimitedGrey3(),
        900: streamUnlimitedGrey3(),
      },
    );
  }

  static Color streamUnlimitedGreen() {
    if (ThemeMode.system == ThemeMode.light)
      return const Color.fromARGB(255, 175, 215, 43);
    else
      return const Color.fromARGB(255, 175, 215, 43);
  }

  static Color streamUnlimitedGrey1() {
    if (ThemeMode.system == ThemeMode.light)
      return const Color.fromARGB(255, 27, 28, 36);
    else
      return const Color.fromARGB(255, 27, 28, 36);
  }

  static Color streamUnlimitedGrey2() {
    if (ThemeMode.system == ThemeMode.light)
      return const Color.fromARGB(255, 37, 40, 51);
    else
      return const Color.fromARGB(255, 37, 40, 51);
  }

  static Color streamUnlimitedGrey3() {
    if (ThemeMode.system == ThemeMode.light)
      return const Color.fromARGB(255, 48, 52, 64);
    else
      return const Color.fromARGB(255, 48, 52, 64);
  }

  static Color streamUnlimitedGrey4() {
    if (ThemeMode.system == ThemeMode.light)
      return const Color.fromARGB(255, 103, 103, 121);
    else
      return const Color.fromARGB(255, 103, 103, 121);
  }

  static Color streamUnlimitedGrey5() {
    if (ThemeMode.system == ThemeMode.light)
      return const Color.fromARGB(255, 128, 133, 152);
    else
      return const Color.fromARGB(255, 128, 133, 152);
  }

  static ButtonStyle getAddButtonStyle() {
    return ElevatedButton.styleFrom (
            primary: Colors.purple,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            )
          );
  }

  TextTheme _getTextTheme(Color color) {
    return TextTheme(
        headline1: TextStyle(
            color: color, fontSize: 26, fontFamily: 'RobotoBold'
        ),
        headline2: TextStyle(
            color: color, fontSize: 24, fontFamily: 'RobotoBold'
        ),
        headline3: TextStyle(
            color: color, fontSize: 18, fontFamily: 'RobotoBold'
        ),
        headline4: TextStyle(
            color: color, fontSize: 16, fontFamily: 'RobotoBold'
        ),
        headline5: TextStyle(
            color: color, fontSize: 14, fontFamily: 'Roboto'
        ));
  }

  CardTheme _getCardTheme() {
    return CardTheme(
        margin: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
        color: streamUnlimitedGrey3(),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        )
    );
  }

  AppBarTheme _getAppBarTheme() {
    return AppBarTheme(
      backgroundColor: streamUnlimitedGrey2(),
      elevation: 0.0,
    );
  }

  ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        appBarTheme: _getAppBarTheme(),
        primarySwatch: getPrimaryBlack(),
        primaryTextTheme:
            TextTheme(headline6: TextStyle(color: streamUnlimitedGreen())),
        shadowColor: Colors.black,
        backgroundColor: streamUnlimitedGrey2(),
        scaffoldBackgroundColor: streamUnlimitedGrey2(),
        dialogBackgroundColor: streamUnlimitedGreen(),
        textTheme: _getTextTheme(Colors.white),
        cardTheme: _getCardTheme(),
      );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    appBarTheme: _getAppBarTheme(),
    primarySwatch: getPrimaryBlack(),
    primaryTextTheme:
        TextTheme(headline6: TextStyle(color: streamUnlimitedGreen())),
    shadowColor: Colors.black,
    backgroundColor: streamUnlimitedGrey2(),
    scaffoldBackgroundColor: streamUnlimitedGrey2(),
    dialogBackgroundColor: streamUnlimitedGreen(),
    textTheme: _getTextTheme(Colors.white),
    cardTheme: _getCardTheme(),
  );
}

