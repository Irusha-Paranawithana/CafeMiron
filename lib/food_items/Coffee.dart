import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miron/model/colors.dart';
import 'package:miron/product.dart';

class CoffeeListView extends StatefulWidget {
  @override
  _CoffeeListViewState createState() => _CoffeeListViewState();
}

class _CoffeeListViewState extends State<CoffeeListView>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredCoffeeTypes = [];

  // Animation duration
  Duration _animationDuration = const Duration(seconds: 5);
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    loadAllCoffeeTypes();

    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void loadAllCoffeeTypes() async {
    final QuerySnapshot snapshot =
        await _firestore.collection('coffee_types').get();
    final CoffeeTypes =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    setState(() {
      filteredCoffeeTypes = CoffeeTypes;
    });
  }

  void filterCoffeeTypes(String query) {
    final lowercaseQuery = query.toLowerCase();
    final filteredList = filteredCoffeeTypes
        .where((CoffeeData) => CoffeeData['title']
            .toString()
            .toLowerCase()
            .contains(lowercaseQuery))
        .toList();

    setState(() {
      filteredCoffeeTypes = filteredList;
    });
  }

  void _navigateToProductPage(
      BuildContext context, Map<String, dynamic> CoffeeData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Product(
          CoffeeData: CoffeeData,
          PastryData: {},
          coffeeData: {},
          burgerData: {},
          ChickenData: {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Café Miron',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: mainColor,
          elevation: 0, // Remove app bar shadow
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 211, 116, 7)),
                  onChanged: (query) {
                    filterCoffeeTypes(query);
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 0.8,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        width: 1.0,
                        color: mainColor,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: "Search Food and Beverages",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      color: Colors.black,
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          loadAllCoffeeTypes();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final CoffeeData = filteredCoffeeTypes[index];
                  final title = CoffeeData['title'];

                  final price = CoffeeData['price'];

                  final imageUrl = CoffeeData['imageUrl'];

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () {
                        _navigateToProductPage(context, CoffeeData);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 300.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Rs ' + price.toString(),
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: filteredCoffeeTypes.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
