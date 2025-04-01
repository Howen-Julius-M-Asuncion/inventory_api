import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_api/pages/users/index.dart';
import 'package:inventory_api/public/variables.dart';

class Productpage extends StatefulWidget {
  const Productpage({super.key});

  @override
  State<Productpage> createState() => _ProductpageState();
}

class _ProductpageState extends State<Productpage> {
  String server = serverVariable.url;

  int quantity = 1;
  bool isFavorite = false;
  bool isLoading = false;
  bool isLoadingCategories = false;
  String? error;
  String? categoriesError;

  // Local variables with defaults
  String productName = 'Loading...';
  String productPrice = '0.00';
  String productDescription = 'No description available';
  String productImage = '';
  List<Map<String, dynamic>> productCategories = [];

  Future<void> getProduct() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.get(
        Uri.parse("${server}api/products/get.php?id=${productVariables.currentProductId}"),
      );

      if (response.statusCode == 200) {
        final productData = jsonDecode(response.body);
        final product = productData is List ? productData.first : productData;

        setState(() {
          productName = product['product_name']?.toString() ?? 'No Name';
          productPrice = product['price']?.toString() ?? '0.00';
          productDescription = product['description']?.toString() ?? 'No description';
          productImage = product['image']?.toString() ?? '';
          productVariables.currentProduct = product;
        });

        // Fetch categories after product data is loaded
        await getCategories();
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load product details';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getCategories() async {
    try {
      setState(() {
        isLoadingCategories = true;
        categoriesError = null;
      });

      final response = await http.get(
        Uri.parse("${server}api/products/cat.php?id=${productVariables.currentProductId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final categoriesData = data is List ? data.first : data;

        if (categoriesData['categories'] != null && categoriesData['categories'] is List) {
          setState(() {
            productCategories = List<Map<String, dynamic>>.from(categoriesData['categories'])
                .where((cat) => cat['category_name'] != null)
                .toList();
          });
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      setState(() {
        categoriesError = 'Failed to load categories';
      });
    } finally {
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  Future<void> addToCart() async {
    try {
      final response = await http.post(
        Uri.parse("${server}api/cart/add.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'u': profileVariables.userProfile['id'], // Using account ID from your variables
          'p': productVariables.currentProductId,    // Current product ID
          'q': quantity,                            // Selected quantity
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        // Show success message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: Text('${data['message']}\nQuantity: ${data['quantity']}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        // Show error message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(data['message']),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to add to cart'),
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
  void initState() {
    super.initState();
    // Initialize with any existing data
    if (productVariables.currentProduct.isNotEmpty) {
      productName = productVariables.currentProduct['product_name']?.toString() ?? 'No Name';
      productPrice = productVariables.currentProduct['price']?.toString() ?? '0.00';
      productDescription = productVariables.currentProduct['description']?.toString() ?? 'No description';
      productImage = productVariables.currentProduct['image']?.toString() ?? '';
    }
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        // automaticallyImplyLeading: true,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back, size: 28),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => Indexpage(initialTab: 0),
              ),
            );
          },
        ),
        middle: Text(
          productName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 28,
                color: isFavorite ? CupertinoColors.destructiveRed : null,
              ),
              onPressed: () => setState(() => isFavorite = !isFavorite),
            ),
            CupertinoButton(
              padding: EdgeInsets.only(left: 12),
              child: const Icon(CupertinoIcons.cart, size: 28),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => Indexpage(initialTab: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: CupertinoColors.systemGrey5,
                      child: productImage.isNotEmpty
                          ? Image.network(
                        productImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          CupertinoIcons.photo,
                          size: 80,
                          color: CupertinoColors.systemGrey,
                        ),
                      )
                          : const Icon(
                        CupertinoIcons.photo,
                        size: 80,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),

                    // Categories Section
                    if (isLoadingCategories)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CupertinoActivityIndicator(),
                      )
                    else if (categoriesError != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          categoriesError!,
                          style: TextStyle(color: CupertinoColors.destructiveRed),
                        ),
                      )
                    else if (productCategories.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                ...productCategories.map((category) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.activeOrange,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        category['category_name'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color: CupertinoColors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),

                    // Product Info
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱$productPrice',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            productDescription,
                            style: const TextStyle(
                              fontSize: 20,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey5,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  minSize: 0,
                                  onPressed: () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1),
                                  child: const Icon(CupertinoIcons.minus),
                                ),
                                Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                                CupertinoButton(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  minSize: 0,
                                  onPressed: () => setState(() => quantity++),
                                  child: const Icon(CupertinoIcons.plus),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons (unchanged)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey4,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Favorite Button
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CupertinoColors.systemGrey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CupertinoButton(
                        borderRadius: BorderRadius.circular(5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: CupertinoColors.systemBackground,
                        onPressed: () => setState(() => isFavorite = !isFavorite),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              size: 24,
                              color: isFavorite ? CupertinoColors.destructiveRed : CupertinoColors.systemGrey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Favorite',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Checkout Button
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: CupertinoTheme.of(context).primaryColor,
                      ),
                      child: CupertinoButton(
                        borderRadius: BorderRadius.circular(5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: Colors.transparent,
                        onPressed: () {
                          // Show confirmation dialog
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: const Text('Add to Cart'),
                              content: Text('Add $quantity $productName to your cart?'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('Cancel', style: TextStyle(color: CupertinoColors.systemRed),),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Confirm', style: TextStyle(color: CupertinoColors.systemBlue),),
                                  onPressed: () async {
                                    Navigator.pop(context); // Close dialog
                                    try {
                                      final response = await http.post(
                                        Uri.parse("${server}api/cart/add.php"),
                                        headers: {'Content-Type': 'application/json'},
                                        body: jsonEncode({
                                          'u': profileVariables.userProfile['id'],
                                          'p': productVariables.currentProductId,
                                          'q': quantity,
                                        }),
                                      );

                                      final data = jsonDecode(response.body);
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) => CupertinoAlertDialog(
                                          title: Text(data['success'] ? 'Success' : 'Error'),
                                          content: Text(data['message'] ??
                                              (data['success'] ? 'Added to cart' : 'Failed to add')),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text('OK'),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      );
                                    } catch (e) {
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (context) => CupertinoAlertDialog(
                                          title: const Text('Error'),
                                          content: const Text('Failed to connect to server'),
                                          actions: [
                                            CupertinoDialogAction(
                                              child: const Text('OK'),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.cart, size: 24, color: CupertinoColors.white),
                            SizedBox(width: 8),
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
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