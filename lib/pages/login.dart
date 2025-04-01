import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_api/pages/users/index.dart';
import '../main.dart';
import '../public/variables.dart';


class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  String server = serverVariable.url;

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool hidePassword = true;
  bool _isLoading = false;
  String loginMsg = "";

  Future<void> _showErrorDialog(String message) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> logIn() async {
    setState(() {
      _isLoading = true;
      loginMsg = "";
    });

    try {
      final response = await http.post(
        Uri.parse('$server/api/accounts/login.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'username': _username.text,
          'password': _password.text
        }),
      );

      if (kDebugMode) {
        print('Response Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login successful
        setState(() {
          isLoggedIn = true;
          profileVariables.userProfile = {
            'id': responseData['id'],
            'username': responseData['user'],
          };
        });

        // Navigate to the next page after a small delay
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(builder: (context) => const Indexpage())
          );
        });
      } else {
        // Show error dialog with message from API
        final errorMessage = responseData['message'] ?? 'Login failed. Please try again.';
        await _showErrorDialog(errorMessage);
      }
    } catch (e) {
      await _showErrorDialog('Error: Unable to login. Check your internet connection.');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/defaults/background_alt.png"),
                fit: BoxFit.cover,
              )
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView(
                children: [
                  Column(
                    children: [
                      Image.asset(
                        'assets/icons/transparent_notext.png',
                        width: 200,
                      ),
                      Text(
                        'Crucian EATS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 50,
                            color: CupertinoColors.white
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Made by Crucians, for Crucians',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: CupertinoColors.white
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: CupertinoColors.systemGrey3, indent: 24, endIndent: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            'By continuing you indicate that you agree to Crucian EATS\' Terms of Service and Privacy Policy.',
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: CupertinoColors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: CupertinoTextField(
                      controller: _username,
                      placeholder: 'Username',
                      prefix: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.person_alt_circle),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      height: 45,
                      child: CupertinoTextField(
                        controller: _password,
                        placeholder: 'Password',
                        obscureText: hidePassword,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(CupertinoIcons.lock_circle),
                        ),
                        suffix: CupertinoButton(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                            child: Icon(
                                hidePassword ? CupertinoIcons.eye_solid : CupertinoIcons.eye_slash_fill,
                                color: CupertinoColors.label,
                                size: 24
                            ),
                          ),
                          onPressed: () => setState(() => hidePassword = !hidePassword),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Divider(color: CupertinoColors.systemGrey3, indent: 24, endIndent: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Crucian EATS · Dev Ops 2 · 2025',
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: CupertinoColors.white
                            ),
                          ),
                        ]
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onPressed: _isLoading ? null : logIn,
                        child: _isLoading
                            ? const CupertinoActivityIndicator()
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Login ',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            Icon(CupertinoIcons.arrow_right_square, size: 20),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
