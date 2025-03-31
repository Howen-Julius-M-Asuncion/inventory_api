import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Menupage extends StatefulWidget {
  const Menupage({super.key});

  @override
  State<Menupage> createState() => _MenupageState();
}

class _MenupageState extends State<Menupage> {
  String server = "http://192.168.1.55/inventory_api/";
  List<dynamic> products = [];
  List<dynamic> categories = [];
  String? selectedCategory;

  Future<void> getData() async {
    final categoryResponse = await http.get(
      Uri.parse("${server}api/category/get.php?limit=8&random=true"),
    );
    final productResponse = await http.get(
      Uri.parse("${server}api/products/get.php"),
    );
    setState(() {
      categories = jsonDecode(categoryResponse.body) ?? [];
      products = jsonDecode(productResponse.body) ?? [];
    });
  }

  Future<void> getCategoryProducts(String categoryId) async {
    if (categoryId == "all") {
      return getData();
    }
    final response = await http.get(
      Uri.parse("${server}api/category/item.php?c=$categoryId"),
    );
    final data = jsonDecode(response.body);
    setState(() {
      products = data['products'] ?? [];
      selectedCategory = categoryId;
    });
  }


  @override
  void initState() {
    getData();

    super.initState();
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
          onPressed: () {},
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Prevent unnecessary space issues
            children: [
              // Search
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: CupertinoSearchTextField(),
              ),

              // Best Selling Section
              Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Our Best Selling', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
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
                            color: Colors.grey[300], // Placeholder for image
                          ),
                          child: Icon(
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
                                'Adobong Manok',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              Text(
                                '₱75.00',
                                style: TextStyle(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                'Description of item goes here. This is a longer description that will be truncated if too long.',
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
              ),

              // Categories Section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Explore by Category', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),),
                    CupertinoButton(padding: EdgeInsets.zero,
                      onPressed: () {

                      },
                      child: Icon(
                        CupertinoIcons.ellipsis,
                        size: 28,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
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
                                onTap: () {
                                  setState(() {
                                    selectedCategory = null;
                                  });
                                  print(selectedCategory);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedCategory == null ? CupertinoColors.systemYellow : CupertinoColors.activeOrange,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Column(
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(CupertinoIcons.list_bullet, color: CupertinoColors.black, size: 40),
                                      SizedBox(width: 6),
                                      Text('All',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: CupertinoColors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Dynamic category chips with images
                              ...categories.map((category) {
                                bool isSelected = category['name'] == selectedCategory;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = category['name'];
                                    });
                                    print(selectedCategory);
                                    print("Selected Category ID: ${category['id']}");
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? CupertinoColors.systemYellow : CupertinoColors.activeOrange,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Column(
                                      children: [
                                        category['image'] != null && category['image'].isNotEmpty
                                            ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            category['image'],
                                            width: 46,
                                            height: 46,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : Icon(CupertinoIcons.photo, size: 46, color: CupertinoColors.black),
                                        SizedBox(width: 6),
                                        Text(
                                          category['name'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            color: isSelected ? CupertinoColors.black : CupertinoColors.label,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
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
                    Text('Popular', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),),
                    CupertinoButton(padding: EdgeInsets.zero,
                        onPressed: () {

                        },
                        child: Row(
                          children: [
                            Text('See All  ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                            Icon(
                              CupertinoIcons.arrow_right_circle_fill,
                              size: 26,
                              color: CupertinoColors.activeBlue,
                            ),
                          ],
                        )
                    ),
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
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
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
                                  product['name'],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₱${product['price']}',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CupertinoColors.activeBlue),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product['description'],
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
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
      ),
    );
  }
}