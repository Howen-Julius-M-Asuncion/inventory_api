import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:inventory_api/main.dart';
import 'package:inventory_api/pages/product.dart';
import 'package:inventory_api/public/variables.dart';

import '../../profile.dart';


class Cartpage extends StatefulWidget {
  const Cartpage({super.key});

  @override
  State<Cartpage> createState() => _CartpageState();
}

class _CartpageState extends State<Cartpage> {
  String server = serverVariable.url;

  bool isLoading = true;
  String? error;
  List<dynamic> cartProducts = [];
  double deliveryFee = 50.00;

  @override
  void initState() {
    super.initState();
    getCartData();
  }

  double get totalAmount {
    return cartProducts.fold(0, (sum, item) {
      final price = double.tryParse(item['product']['price'].toString()) ?? 0;
      return sum + (price * (item['quantity'] as int));
    });
  }


  Future<void> getCartData() async {
    try {
      final response = await http.get(
        Uri.parse("${server}api/cart/get.php?id=${profileVariables.userProfile['id']}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            cartProducts = data['cart_products'] ?? [];
            isLoading = false;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to load cart');
        }
      } else {
        throw Exception('Failed to load cart');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> updateCartData(String productId, int newQuantity) async {
    try {
      final response = await http.post(
        Uri.parse("${server}api/cart/update.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'u': profileVariables.userProfile['id'],
          'p': productId,
          'q': newQuantity,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to update quantity');
      }
      await getCartData(); // Refresh cart data
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> removeProduct(String productId) async {
    try {
      final response = await http.post(
        Uri.parse("${server}api/cart/delete.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'u': profileVariables.userProfile['id'],
          'p': productId,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to remove item');
      }
      await getCartData(); // Refresh cart data
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

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
        child: !isLoggedIn
            ? const Center(child: CupertinoActivityIndicator(radius: 16))
            : Column(
          children: [
            if (isLoading)
              const Expanded(
                  child: Center(child: CupertinoActivityIndicator()))
            else if (error != null)
              Expanded(child: Center(child: Text(error!)))
            else if (cartProducts.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(
                          fontSize: 18, color: CupertinoColors.systemGrey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    itemCount: cartProducts.length,
                    itemBuilder: (context, index) {
                      final item = cartProducts[index];
                      final product = item['product'];
                      final quantity = item['quantity'] as int;
                      final price = double.tryParse(product['price'].toString()) ?? 0;

                      return GestureDetector(
                        onTap: () {
                          // Set the current product data
                          productVariables.currentProductId = product['id'];
                          productVariables.currentProduct = product;

                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => Productpage(),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Item image
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color: CupertinoColors.systemGrey5,
                                  child: product['image'] != null
                                      ? Image.network(
                                    product['image'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      CupertinoIcons.photo,
                                      size: 40,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  )
                                      : const Icon(
                                    CupertinoIcons.photo,
                                    size: 40,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Added: ${item['added_at']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '₱${price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: CupertinoTheme.of(context).primaryColor,
                                            ),
                                          ),
                                          // Quantity Editor
                                          Container(
                                            decoration: BoxDecoration(
                                              color: CupertinoColors.systemGrey5,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                CupertinoButton(
                                                  padding: const EdgeInsets.all(8),
                                                  minSize: 0,
                                                  onPressed: () async {
                                                    final newQuantity = quantity - 1;
                                                    if (newQuantity > 0) {
                                                      await updateCartData(product['id'], newQuantity);
                                                    } else {
                                                      showCupertinoDialog(
                                                        context: context,
                                                        builder: (context) => CupertinoAlertDialog(
                                                          title: const Text('Remove Item'),
                                                          content: const Text('Remove this item from your cart?'),
                                                          actions: [
                                                            CupertinoDialogAction(
                                                              child: const Text('Cancel'),
                                                              onPressed: () => Navigator.pop(context),
                                                            ),
                                                            CupertinoDialogAction(
                                                              isDestructiveAction: true,
                                                              onPressed: () async {
                                                                Navigator.pop(context);
                                                                await removeProduct(product['id']);
                                                              },
                                                              child: const Text('Remove'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: const Icon(
                                                    CupertinoIcons.minus,
                                                    size: 16,
                                                  ),
                                                ),
                                                Text(
                                                  quantity.toString(),
                                                  style: const TextStyle(fontSize: 16),
                                                ),
                                                CupertinoButton(
                                                  padding: const EdgeInsets.all(8),
                                                  minSize: 0,
                                                  onPressed: () async {
                                                    await updateCartData(product['id'], quantity + 1);
                                                    if (kDebugMode) {
                                                      print(quantity + 1);
                                                    }
                                                  },
                                                  child: const Icon(
                                                    CupertinoIcons.plus,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CupertinoButton(
                                padding: const EdgeInsets.only(right: 8),
                                onPressed: () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: const Text('Remove Item'),
                                      content: const Text('Are you sure you want to remove this item?'),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text('Cancel'),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                        CupertinoDialogAction(
                                          isDestructiveAction: true,
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await removeProduct(product['id']);
                                          },
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  color: CupertinoColors.destructiveRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

            if (!isLoading && error == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  border: Border(
                    top: BorderSide(
                      color: CupertinoColors.systemGrey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₱${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Fee',
                            style: TextStyle(fontSize: 16)),
                        Text(
                          '₱${cartProducts.isEmpty ? '0.00' : deliveryFee.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₱${(totalAmount + (cartProducts.isEmpty ? 0 : deliveryFee)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: CupertinoTheme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        onPressed: (){

                        },
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}