import 'package:flutter/cupertino.dart';
import 'package:inventory_api/pages/login.dart';

bool isLoggedIn = false;
bool isLoading = false;

void main() {
  // debugDisableShadows = true;
  runApp(CupertinoApp(
    home: const Loginpage(),
    // debugShowCheckedModeBanner: false,
    theme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: CupertinoColors.systemOrange
    ),
  ));
}