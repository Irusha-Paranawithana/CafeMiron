import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miron/model/colors.dart';
import 'package:miron/product.dart';

class IceCreamListView extends StatefulWidget {
  @override
  _IceCreamListViewState createState() => _IceCreamListViewState();
}

class _IceCreamListViewState extends State<IceCreamListView>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredIceCreamTypes = [];

  // Animation duration
  Duration _animationDuration = const Duration(seconds: 5);
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    loadAllIceCreamTypes();

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

  void loadAllIceCreamTypes() async {
    final QuerySnapshot snapshot =
        await _firestore.collection('Ice Cream_types').get();
    final IceCreamTypes =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    setState(() {
      filteredIceCreamTypes = IceCreamTypes;
    });
  }

  void filterIceCreamTypes(String query) {
    final lowercaseQuery = query.toLowerCase();
    final filteredList = filteredIceCreamTypes
        .where((IceCreamData) => IceCreamData['title']
            .toString()
            .toLowerCase()
            .contains(lowercaseQuery))
        .toList();

    setState(() {
      filteredIceCreamTypes = filteredList;
    });
  }

  void _navigateToProductPage(
      BuildContext context, Map<String, dynamic> IceCreamData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Product(
          IceCreamData: IceCreamData,
          PastryData: {},
          coffeeData: {},
          burgerData: {},
          ChickenData: {},
          JuiceData: {},
          CoffeeData: {},
          SaladData: {},
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
                    filterIceCreamTypes(query);
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
                          loadAllIceCreamTypes();
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
                  final IceCreamData = filteredIceCreamTypes[index];
                  final title = IceCreamData['title'];

                  final price = IceCreamData['price'];

                  final imageUrl = IceCreamData['imageUrl'];

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () {
                        _navigateToProductPage(context, IceCreamData);
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
                childCount: filteredIceCreamTypes.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
