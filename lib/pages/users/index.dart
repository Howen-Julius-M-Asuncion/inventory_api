import 'package:flutter/cupertino.dart';
import '/pages/users/tabs/menu.dart';
import '/pages/users/tabs/cart.dart';

class Indexpage extends StatelessWidget {
  final int initialTab;
  const Indexpage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: CupertinoTabController(initialIndex: initialTab),
      tabBar: CupertinoTabBar(
        // activeColor: AppColors.mainColor,
        // inactiveColor: AppColors.accentColor,
        height: 75,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(CupertinoIcons.heart),
          //   activeIcon: Icon(CupertinoIcons.heart_fill),
          //   label: 'Favorites',
          // ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cart),
            activeIcon: Icon(CupertinoIcons.cart_fill),
            label: 'My Cart',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(CupertinoIcons.alarm),
          //   activeIcon: Icon(CupertinoIcons.alarm_fill),
          //   label: 'My Orders',
          // ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return Menupage();
          case 1:
            return Cartpage();
          // case 1:
          //   return Favoritepage();
          // case 2:
          //   return Cartpage();
          // case 3:
          //   return Orderpage();
          default:
            return Menupage();
        }
      },
    );
  }
}
