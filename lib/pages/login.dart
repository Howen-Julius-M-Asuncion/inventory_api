import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool hidePassword = true;
  String loginMsg = "";

  isLogin(String username, String password){
    if(username == "admin@navbook" && password == "123"){
      setState(() {
        _username.text = "";
        _password.text = "";
        loginMsg = "";
      });
      return true;
    }else{
      return false;
    }
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
                    Image.asset(
                      'assets/icons/transparent_notext.png',
                      width: 100, // Set the desired width
                      // height: 50, // Set the desired height
                      fit: BoxFit.contain, // Adjust how the image fits in the given space
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('Eats', style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 60,
                    )),
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
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      )
                  ),
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
                  Text('By continuing you indicate that you agree to NavBook\'s Terms of Service and Privacy Policy.',
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      )
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
              CupertinoButton(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  child:Text('Continue to Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )
                  ),
                  onPressed: (){
                    isLogin(_username.text, _password.text) ? []
                        : setState (() {
                      _password.text = "";
                      _username.text = "";
                      loginMsg = "Incorrect Username or Password";
                    });
                  }
              ),
              SizedBox(height: 30,),
              Divider(color: CupertinoColors.systemGrey3, indent: 50, endIndent: 50, /* height: 95, */),
              Padding(
                padding: EdgeInsets.fromLTRB(50, 5, 50, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Flexible(child:
                  Text('NavBook · Dev Ops 2 · Midterms · 2025',
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      )
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