import 'package:flutter/cupertino.dart';
import 'package:inventory_api/pages/profile.dart';
import 'package:inventory_api/pages/users/index.dart';
import 'package:inventory_api/pages/login.dart';

import 'package:inventory_api/pages/profile.dart';

bool isLoggedIn = false;
bool isLoading = false;

void main() {
  runApp(CupertinoApp(
    home: isLoggedIn ? Indexpage() : Loginpage(),
    debugShowCheckedModeBanner: false,
    theme: CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: CupertinoColors.systemOrange
    ),
    routes: {
      Profilepage.routeName: (context) => Profilepage(),
    },
  ));
}
