import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../public/variables.dart';
import '/main.dart';
import '/pages/login.dart';

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  static const routeName = '/pages/profile';

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  String server = serverVariable.url;

  List<dynamic> users = [];
  String editedEmail = "";
  String editedUsername = "";
  String editedPassword = "";

  Map<String, dynamic> currentUser = {};
  bool isEmailEdited = false;
  bool isUsernameEdited = false;
  bool isPasswordEdited = false;

  String result = "";
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  Future<void> getUser() async {
    try {
      final response = await http.get(
        Uri.parse("${server}api/accounts/get.php?id=${profileVariables.userProfile['id']}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body) ?? [];
          currentUser = users.isNotEmpty ? users[0] : {};
          editedEmail = currentUser['email'] ?? '';
          editedUsername = currentUser['username'] ?? '';
          editedPassword = currentUser['password'] ?? '';
          emailController.text = editedEmail;
          usernameController.text = editedUsername;
          passwordController.text = editedPassword;
        });
        if (kDebugMode) {
          print("User fetched: ${response.body}");
        }
      } else {
        if (kDebugMode) {
          print("Failed to load users: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user: $e");
      }
    }
  }

  Future<void> updateUser() async {
    try {
      setState(() => isLoading = true);

      Map<String, dynamic> requestBody = {'id': currentUser['id']};

      if (isEmailEdited) requestBody['email'] = editedEmail;
      if (isUsernameEdited) requestBody['username'] = editedUsername;
      if (isPasswordEdited) requestBody['password'] = editedPassword;

      final response = await http.post(
        Uri.parse('$server/api/accounts/update.php'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success case
        setState(() {
          result = 'ID: ${responseData['id']}\nEmail: ${responseData['email']}\nUsername: ${responseData['user']}';
          isEmailEdited = false;
          isUsernameEdited = false;
          isPasswordEdited = false;
        });
        await getUser();

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Profile updated successfully!'),
            actions: [
              CupertinoButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        // Handle API error responses
        throw Exception(responseData['error'] ?? 'Update failed');
      }
    } catch (e) {
      // Show clean error message
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            CupertinoButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    getUser();
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: true,
        middle: Text('MY PROFILE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        trailing: !isLoggedIn ? null : CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.info_circle, size: 28),
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (context) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('About Us'),
                          content: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        ClipOval(
                                          child: Image.asset('assets/images/devs/howen.jpg',
                                            height: 75,
                                            width: 75,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Text('Howen Julius Asuncion'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        ClipOval(
                                          child: Image.asset('assets/images/devs/goco.jpg',
                                            height: 75,
                                            width: 75,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Text('John Michael Goco'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        ClipOval(
                                          child: Image.asset('assets/images/devs/renz.jpg',
                                            height: 75,
                                            width: 75,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Text('Renz Gabriel Salas'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            CupertinoButton(
                              child: Text('Close', style: TextStyle(color: CupertinoColors.destructiveRed)),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('About Us')
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('Logout'),
                          content: Text('Are you sure?'),
                          actions: [
                            CupertinoButton(
                              child: Text("No"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            CupertinoButton(
                              child: Text("Yes", style: TextStyle(color: CupertinoColors.destructiveRed)),
                              onPressed: () {
                                setState(() {
                                  isLoggedIn = false;
                                });
                                Navigator.of(context).pushAndRemoveUntil(
                                  CupertinoPageRoute(builder: (context) => const Loginpage()),
                                      (Route<dynamic> route) => false,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Logout', style: TextStyle(color: CupertinoColors.destructiveRed))
                  ),
                ],
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: !isLoggedIn
            ? Center(child: const CupertinoActivityIndicator(radius: 16))
            : SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/defaults/default_profile.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(currentUser['username'] ?? '', style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 28,
                    )),
                    SizedBox(height: 4),
                    Text(currentUser['email'] ?? '', style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      color: CupertinoColors.secondaryLabel,
                    )),
                  ],
                ),
              ),
              Form(
                child: CupertinoFormSection.insetGrouped(
                  header: Text('Edit Profile', style: TextStyle(fontSize: 18)),
                  children: [
                    CupertinoListTile(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      leading: Icon(CupertinoIcons.at_circle, size: 34),
                      title: Text('Edit Email', style: TextStyle(fontSize: 20)),
                      subtitle: Text(editedEmail, style: TextStyle(fontSize: 14)),
                      additionalInfo: isEmailEdited
                          ? Icon(CupertinoIcons.circle_filled, color: CupertinoColors.systemGreen, size: 14)
                          : null,
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(CupertinoIcons.pencil, size: 28, color: CupertinoColors.systemBlue),
                        onPressed: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Text('Update Email'),
                              content: Column(
                                children: [
                                  SizedBox(height: 15),
                                  CupertinoTextField(
                                    controller: emailController,
                                  )
                                ],
                              ),
                              actions: [
                                CupertinoButton(
                                  child: Text('Close', style: TextStyle(color: CupertinoColors.destructiveRed)),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoButton(
                                  child: Text('Confirm', style: TextStyle(color: CupertinoColors.systemBlue)),
                                  onPressed: () {
                                    setState(() {
                                      editedEmail = emailController.text;
                                      isEmailEdited = editedEmail != currentUser['email'];
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    CupertinoListTile(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      leading: Icon(CupertinoIcons.person_alt_circle, size: 34),
                      title: Text('Edit username', style: TextStyle(fontSize: 20)),
                      subtitle: Text(editedUsername, style: TextStyle(fontSize: 14)),
                      additionalInfo: isUsernameEdited
                          ? Icon(CupertinoIcons.circle_filled, color: CupertinoColors.systemGreen, size: 14)
                          : null,
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(CupertinoIcons.pencil, size: 28, color: CupertinoColors.systemBlue),
                        onPressed: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Text('Update Username'),
                              content: Column(
                                children: [
                                  SizedBox(height: 15),
                                  CupertinoTextField(
                                    controller: usernameController,
                                  )
                                ],
                              ),
                              actions: [
                                CupertinoButton(
                                  child: Text('Close', style: TextStyle(color: CupertinoColors.destructiveRed)),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoButton(
                                  child: Text('Confirm', style: TextStyle(color: CupertinoColors.systemBlue)),
                                  onPressed: () {
                                    setState(() {
                                      editedUsername = usernameController.text;
                                      isUsernameEdited = editedUsername != currentUser['username'];
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    CupertinoListTile(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                      leading: Icon(CupertinoIcons.lock_circle, size: 34),
                      title: Text('Edit password', style: TextStyle(fontSize: 20)),
                      additionalInfo: isPasswordEdited
                          ? Icon(CupertinoIcons.circle_filled, color: CupertinoColors.systemGreen, size: 14)
                          : null,
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Icon(CupertinoIcons.pencil, size: 28, color: CupertinoColors.systemBlue),
                        onPressed: () {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Text('Update Password'),
                              content: Column(
                                children: [
                                  SizedBox(height: 15),
                                  CupertinoTextField(
                                    obscureText: true,
                                    controller: passwordController,
                                  )
                                ],
                              ),
                              actions: [
                                CupertinoButton(
                                  child: Text('Close', style: TextStyle(color: CupertinoColors.destructiveRed)),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoButton(
                                  child: Text('Confirm', style: TextStyle(color: CupertinoColors.systemBlue)),
                                  onPressed: () {
                                    setState(() {
                                      editedPassword = passwordController.text;
                                      isPasswordEdited = editedPassword != currentUser['password'];
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 150,
                child: CupertinoButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  disabledColor: CupertinoTheme.of(context).primaryColor.withAlpha(150),
                  // Disable button when no changes are made
                  onPressed: (isEmailEdited || isUsernameEdited || isPasswordEdited)
                      ? () {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text('Message'),
                        content: Text(
                          'Are you sure you want to update your profile?',
                        ),
                        actions: [
                          CupertinoButton(
                            child: Text('Close',
                                style: TextStyle(color: CupertinoColors.destructiveRed)),
                            onPressed: () => Navigator.pop(context),
                          ),
                          CupertinoButton(
                            child: Text('Confirm',
                                style: TextStyle(color: CupertinoColors.systemBlue)),
                            onPressed: () {
                              Navigator.pop(context);
                              updateUser();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                      : null, // null disables the button
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.white,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.arrow_down_to_line,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}