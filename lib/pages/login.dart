import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_api/pages/users/index.dart';

import '../main.dart';

Map<String, dynamic> userProfile = {};

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  String server = "http://192.168.1.55/inventory_api/";
  List<dynamic> accounts = [];

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool hidePassword = true;
  String result = '';
  String loginMsg = "";

  Future<void> logIn() async {
    try {
      final response = await http.post(
        Uri.parse('${server}/api/accounts/login.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': _username.text,
          'password': _password.text
        }),
      );

      print('Response Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Login successful
        final responseData = jsonDecode(response.body);

        setState(() {
          result = 'ID: ${responseData['id']}\nName: ${responseData['user']}';
          isLoggedIn = true;
          loginMsg = ""; // Clear any previous error messages
        });

        userProfile = {
          'id': responseData['id'],
          'username': responseData['user'],
        };

        print(result);

        // Navigate to the next page after a small delay
        Future.delayed(Duration(milliseconds: 100), () {
          Navigator.pushReplacement(
              context, CupertinoPageRoute(builder: (context) => Indexpage())
          );
        });

      } else if (response.statusCode == 400) {
        // Invalid credentials
        setState(() {
          loginMsg = "Invalid Credentials. Please try again.";
        });

      } else {
        // Other errors (server issues, network problems, etc.)
        setState(() {
          loginMsg = "Unexpected error occurred. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        loginMsg = 'Error: Unable to login. Check your internet connection.';
      });
    }
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: CupertinoColors.systemFill.darkColor,
      child:
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/defaults/background_alt.png"),
            fit: BoxFit.cover,
          )
        ),
        child: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(height: 75,),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Column(
                children: [
                  Image.asset('assets/icons/transparent_notext.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  Text('Crucian EATS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50,)),
                ],
              ),
            ]),
            SizedBox(height: 24,),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Flexible(child:
                Text('Made by Crucians, for Crucians',
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,)                ),
                ),
              ]),
            ),
            SizedBox(height: 25,),
            Divider(color: CupertinoColors.systemGrey3, indent: 50, endIndent: 50, /* height: 95, */),
            // SizedBox(height: 5,),
            Padding(
              padding: EdgeInsets.fromLTRB(50, 5, 50, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Flexible(child:
                  Text('By continuing you indicate that you agree to Crucian EATS\' Terms of Service and Privacy Policy.',
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16,)
                  ),
                ),
              ]),
            ),
            SizedBox(height: 40,),
            Padding(
              padding: EdgeInsets.fromLTRB(50, 0, 50, 10),
              child: SizedBox(
                height: 45,
                child: CupertinoTextField(
                  controller: _username,
                  placeholder: 'Username',
                  padding: EdgeInsets.all(10),
                  prefix: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                    child: Icon(CupertinoIcons.profile_circled, color: CupertinoColors.label,),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(50, 0, 50, 10),
              child: SizedBox(
                height: 45,
                child: CupertinoTextField(
                  controller: _password,
                  placeholder: 'Password',
                  padding: EdgeInsets.all(10),
                  obscureText: hidePassword,
                  prefix: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                    child: Icon(CupertinoIcons.lock_circle, color: CupertinoColors.label,),
                  ),
                  suffix: CupertinoButton(child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    child: Icon(
                        hidePassword? CupertinoIcons.eye_solid : CupertinoIcons.eye_slash_fill, color: CupertinoColors.label, size:24),
                  ),
                    onPressed: (){
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Text(loginMsg, style: TextStyle(color: CupertinoColors.destructiveRed, fontWeight: FontWeight.bold)),
            SizedBox(height: 20,),
            CupertinoButton.filled(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              child:Text('Continue to Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                )
              ),
              onPressed: () async {
                logIn();
              }
            ),
            SizedBox(height: 30,),
            Divider(color: CupertinoColors.systemGrey3, indent: 50, endIndent: 50, /* height: 95, */),
            Padding(
              padding: EdgeInsets.fromLTRB(50, 5, 50, 0),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Flexible(child:
                  Text('Crucian EATS · Dev Ops 2 · 2025',
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16,)
                  ),
                ),
              ]),
            ),
          ]),
        ),
      )
    );
  }
}
