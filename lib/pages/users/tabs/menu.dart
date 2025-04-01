import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:inventory_api/pages/profile.dart';
import 'package:inventory_api/pages/product.dart';
import 'package:inventory_api/public/variables.dart';


class Menupage extends StatefulWidget {
  const Menupage({super.key});

  @override
  State<Menupage> createState() => _MenupageState();
}

class _MenupageState extends State<Menupage> {
  String server = serverVariable.url;

  List<dynamic> products = [];
  List<dynamic> categories = [];
  String? selectedCategory;
  dynamic bestSellingProduct;

  String selectedCatName = "";
  bool isAllSelected = true;
  
  int cardLimit = 0;

  Future<void> getCategory(int limit, bool random) async {
    try {
      final response = await http.get(
        Uri.parse("${server}api/category/get.php?&random=$random&limit=$limit"),
      );
      if (response.statusCode == 200) {
        setState(() {
          categories = jsonDecode(response.body) ?? [];
        });
      } else {
        if (kDebugMode) {
          print("Failed to load categories: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching categories: $e");
      }
    }
  }

  Future<void> getData(String id, int limit, bool random) async {
    try {
      final response = await http.get(
        Uri.parse(id.isEmpty
            ? "${server}api/products/get.php?limit=$limit&random=$random"
            : "${server}api/category/item.php?id=$id&limit=$limit&random=$random"),
      );

      if (kDebugMode) {
        print("Response Body: ${response.body}");
      } // Debugging line

      final decodedResponse = jsonDecode(response.body);

      if (decodedResponse is List) {
        setState(() {
          products = decodedResponse;
        });
      } else if (decodedResponse is Map) {
        setState(() {
          products = decodedResponse['data'] ?? []; // Adjust this based on your API structure
        });
      } else {
        if (kDebugMode) {
          print("Unexpected response format.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching products: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchBestSelling();
  }

  Future<void> fetchData() async {
    await Future.wait([
      getData('', cardLimit, true),
      getCategory(0, true),
    ]);
  }

  Future<void> fetchBestSelling() async {
    try {
      final response = await http.get(
        Uri.parse("${server}api/products/get.php?limit=1&random=true"),
      );

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        if (decodedResponse is List && decodedResponse.isNotEmpty) {
          setState(() {
            bestSellingProduct = decodedResponse.first;
          });
        } else if (decodedResponse is Map && decodedResponse['data'] is List && decodedResponse['data'].isNotEmpty) {
          setState(() {
            bestSellingProduct = decodedResponse['data'].first;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching best selling product: $e");
      }
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
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              // Search
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              //   child: CupertinoSearchTextField(),
              // ),

              // Best Selling Section
              Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recommendation', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w500)),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(CupertinoIcons.refresh_circled_solid, size: 30,),
                      onPressed: (){
                        fetchBestSelling();
                      })
                  ]
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (kDebugMode) {
                    print('Tapped recommended product ID: ${bestSellingProduct['product_id']}');
                  }
                  productVariables.currentProductId = bestSellingProduct['product_id'];
                  productVariables.currentProduct = bestSellingProduct;

                  Navigator.push(context, CupertinoPageRoute(builder: (context) => Productpage()));

                },
                child: (
                  Card(
                    margin: EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 225,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                              ),
                              child: bestSellingProduct != null && bestSellingProduct['image'] != null && bestSellingProduct['image'].isNotEmpty
                                  ? Image.network(
                                bestSellingProduct['image'],
                                fit: BoxFit.cover,
                              )
                                  : Icon(
                                CupertinoIcons.photo,
                                size: 80,
                                color: Colors.grey,

                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bestSellingProduct != null
                                        ? bestSellingProduct['product_name'] ?? 'No Name'
                                        : 'Loading...',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    bestSellingProduct != null
                                        ? '₱${bestSellingProduct['price'] ?? ''}'
                                        : '₱00.00',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CupertinoTheme.of(context).primaryColor),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    bestSellingProduct != null
                                        ? bestSellingProduct['description'] ?? 'No description available'
                                        : 'Loading product details...',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                    overflow: TextOverflow.fade,
                                    maxLines: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                )
              ),
              // Categories Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Explore by Category', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),),
                    // CupertinoButton(padding: EdgeInsets.zero,
                    //   onPressed: () {
                    //
                    //   },
                    //   child: Icon(
                    //     CupertinoIcons.ellipsis,
                    //     size: 28,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  width: double.infinity,
                  height: 100,
                  // color: CupertinoColors.systemBlue,
                  margin: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          SizedBox(width: 8.0),
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8.0,
                            runSpacing: 10.0,
                            children: [
                              // "All" Chip
                              GestureDetector(
                                onTap: () async {
                                  await getData('', cardLimit, true);
                                  setState(() {
                                    selectedCategory = '';
                                    selectedCatName = '';
                                    isAllSelected = true;
                                  });
                                  if (kDebugMode) {
                                    print('No Specific Category Show all ${products.length} Items');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: selectedCategory == '' ? CupertinoColors.activeOrange.darkHighContrastColor : CupertinoColors.activeOrange,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text('All', style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal, color: CupertinoColors.black),),
                                ),
                              ),
                              // Dynamic category chips with images
                              ...categories.map((category) {
                                bool isSelected = category['name'] == selectedCategory;
                                String imagePath = "assets/images/categories/${category['id']}.png";
                                return GestureDetector(
                                  onTap: () async {  // Make this an async function
                                    String categoryId = category['id'];
                                    String categoryName = category['name'];

                                    // Fetch data before updating state
                                    await getData(categoryId, cardLimit, true);


                                    setState(() {
                                      selectedCategory = categoryName;
                                      selectedCatName = categoryName;
                                      isAllSelected = false;
                                    });

                                    if (kDebugMode) {
                                      print("Selected Category: ID = $categoryId, Name = $selectedCategory");
                                    }
                                    if (kDebugMode) {
                                      print("Showing only ${products.length} Items");
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? CupertinoColors.activeOrange.darkHighContrastColor : CupertinoColors.activeOrange,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipOval(
                                          child: Image.asset(
                                            imagePath,
                                            width: 33,
                                            height: 33,

                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(CupertinoIcons.photo, size: 46, color: CupertinoColors.black),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          category['name'],
                                          style: TextStyle(
                                            fontSize: 24,

                                            fontWeight: FontWeight.normal,
                                            color: isSelected ? CupertinoColors.black : CupertinoColors.label,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Products Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAllSelected
                      ? 'Best Food Selection'
                      // : selectedCatName.contains('food') || selectedCatName.contains('Food')
                      //     ? 'Best $selectedCategory'
                      //     : 'Best $selectedCategory Selection'
                      : 'Best $selectedCategory Selection'
                      ,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),),
                    // CupertinoButton(padding: EdgeInsets.zero,
                    //   onPressed: () {
                    //
                    //   },
                    //   child: Row(
                    //     children: [
                    //       Text('See All  ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                    //       Icon(
                    //         CupertinoIcons.arrow_right_circle_fill,
                    //         size: 26,
                    //       ),
                    //     ],
                    //   )
                    // ),

                  ],
                ),
              ),

              // Product Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,https://play.google.com/console/u/4/developers/6587184058240122287/app/4975469634759179850/app-dashboard
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        if (kDebugMode) {
                          print('Tapped product ID: ${product['product_id']}');
                        }
                        productVariables.currentProductId = product['product_id'];
                        productVariables.currentProduct = product;
                        Navigator.push(context, CupertinoPageRoute(builder: (context) => Productpage()));
                      },
                      child: (
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                  image: product['image'] != null && product['image'].isNotEmpty
                                      ? DecorationImage(
                                    image: NetworkImage(product['image']),
                                    fit: BoxFit.cover,
                                  )
                                      : null,

                                ),
                                child: product['image'] == null || product['image'].isEmpty
                                    ? Center(
                                  child: Icon(CupertinoIcons.photo, size: 50, color: Colors.grey),
                                )
                                    : null,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['product_name'] ?? '',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '₱${product['price']}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CupertinoTheme.of(context).primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      )
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
