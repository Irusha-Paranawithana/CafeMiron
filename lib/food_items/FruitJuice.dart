import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miron/model/colors.dart';
import 'package:miron/product.dart';

class JuiceListView extends StatefulWidget {
  @override
  _JuiceListViewState createState() => _JuiceListViewState();
}

class _JuiceListViewState extends State<JuiceListView>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredJuiceTypes = [];

  @override
  void initState() {
    super.initState();
    loadAllJuiceTypes();
  }

  void loadAllJuiceTypes() async {
    final QuerySnapshot snapshot =
        await _firestore.collection('Fruit_Juice_Types').get();
    final JuiceTypes =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    setState(() {
      filteredJuiceTypes = JuiceTypes;
    });
  }

  void filterJuiceTypes(String query) {
    final lowercaseQuery = query.toLowerCase();
    final filteredList = filteredJuiceTypes
        .where((JuiceData) => JuiceData['title']
            .toString()
            .toLowerCase()
            .contains(lowercaseQuery))
        .toList();

    setState(() {
      filteredJuiceTypes = filteredList;
    });
  }

  void _navigateToProductPage(
      BuildContext context, Map<String, dynamic> JuiceData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Product(
          JuiceData: JuiceData,
          PastryData: {},
          coffeeData: {},
          CoffeeData: {},
          ChickenData: {},
          burgerData: {},
          IceCreamData: {},
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
                    filterJuiceTypes(query);
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
                          loadAllJuiceTypes();
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
                  final JuiceData = filteredJuiceTypes[index];
                  final title = JuiceData['title'];

                  final price = JuiceData['price'];

                  final imageUrl = JuiceData['imageUrl'];

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () {
                        _navigateToProductPage(context, JuiceData);
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
                childCount: filteredJuiceTypes.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
