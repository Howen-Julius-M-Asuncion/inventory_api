import 'package:flutter/cupertino.dart';
import 'package:inventory_api/pages/users/index.dart';
import 'package:inventory_api/pages/login.dart';

bool isLoggedIn = false;

void main() {
  runApp(CupertinoApp(
    // home: isLoggedIn ? Indexpage() : Loginpage(),
    home: Indexpage(),
    debugShowCheckedModeBanner: false,
    theme: CupertinoThemeData(brightness: Brightness.light),
  ));
}
