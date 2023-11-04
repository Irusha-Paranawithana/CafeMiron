import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:miron/map_utils.dart';
import 'package:miron/model/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter services are initialized.
  runApp(ContactUsApp());
}

class ContactUsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContactUsPage(),
    );
  }
}

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> contactData;

  @override
  void initState() {
    super.initState();
    contactData = FirebaseFirestore.instance
        .collection('Contact')
        .doc('RocyenfXA7McM2GUKih3')
        .get();
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Contact Us',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor, // Change the app bar color
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: contactData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('No data available.'));
          } else {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final logoUrl = data['LogoUrl'];
            final title = data['Title'];
            final email = data['Email'];
            final telephone = data['Telephone'];
            final website = data['Website'];
            final address = data['Address'];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), // Add some spacing
                  if (logoUrl != null)
                    CachedNetworkImage(
                      imageUrl: logoUrl,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      width: 150, // Set the logo width
                      height: 150, // Set the logo height
                    ),
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Divider(), // Add a horizontal line
                  if (email != null)
                    ListTile(
                      title: const Text(
                        'Email:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: GestureDetector(
                        onTap: () async {
                          final mailtoUrl = 'mailto:$email';
                          _launchURL(mailtoUrl);
                        },
                        child: Text(
                          email,
                          style: const TextStyle(
                            color: Colors.blue, // Make it look like a link
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  if (telephone != null)
                    ListTile(
                      title: const Text(
                        'Telephone:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: GestureDetector(
                        onTap: () async {
                          try {
                            await FlutterPhoneDirectCaller.callNumber(
                              telephone,
                            );
                          } catch (e) {
                            throw 'Could not make the call: $e';
                          }
                        },
                        child: Text(
                          telephone,
                          style: const TextStyle(
                            color: Colors.blue, // Make it look like a link
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  if (website != null)
                    ListTile(
                      title: const Text(
                        'Website:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Container(
                    width: 3 /
                        5 *
                        MediaQuery.of(context)
                            .size
                            .width, // Set the width to 2/3 of the screen width
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _launchURL(website); // Use the _launchURL function
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Adjust the border radius as needed
                          ),
                        ),
                      ),
                      child: Text(
                        'Visit Cafe Miron Website',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (address != null)
                    ListTile(
                      title: const Text(
                        'Address:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(address), // Show the address
                    ),
                  const SizedBox(height: 20), // Add spacing
                  Container(
                    width: 3 /
                        5 *
                        MediaQuery.of(context)
                            .size
                            .width, // Set the width to 3/5 of the screen width
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapPage(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15.0), // Adjust the border radius as needed
                          ),
                        ),
                      ),
                      child: Text(
                        'Find Cafe Miron on Google Maps',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
