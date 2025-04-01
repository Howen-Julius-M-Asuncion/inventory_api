import 'package:flutter/cupertino.dart';
import 'package:inventory_api/main.dart';

import '../../profile.dart';

class Orderpage extends StatefulWidget {
  const Orderpage({super.key});

  @override
  State<Orderpage> createState() => _OrderpageState();
}

class _OrderpageState extends State<Orderpage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text(
          'CRUCIAN EATS',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.profile_circled,
            size: 28,
          ),
          onPressed: () {
            Navigator.push(context, CupertinoPageRoute(builder: (context) => Profilepage()));
          },
        ),
      ),
      child: SafeArea(
        child:
        !isLoggedIn ? Center(child: const CupertinoActivityIndicator(radius: 16,),)
            : Column(
          children: [


          ],
        )
      ),
    );
  }
}
