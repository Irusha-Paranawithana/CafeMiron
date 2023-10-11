import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:miron/map_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:uni_links/uni_links.dart';

void main() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Us',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange, // Change the app bar color
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: contactData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No data available.'));
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
                  SizedBox(height: 20), // Add some spacing
                  if (logoUrl != null)
                    CachedNetworkImage(
                      imageUrl: logoUrl,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: 150, // Set the logo width
                      height: 150, // Set the logo height
                    ),
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Divider(), // Add a horizontal line
                  if (email != null)
                    ListTile(
                      title: Text(
                        'Email:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: GestureDetector(
                        onTap: () async {
                          final mailtoUrl = 'mailto:$email';
                          //await _launchURL(mailtoUrl);
                        },
                        child: Text(
                          email,
                          style: TextStyle(
                            color: Colors.blue, // Make it look like a link
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  if (telephone != null)
                    ListTile(
                      title: Text(
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
                          style: TextStyle(
                            color: Colors.blue, // Make it look like a link
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  if (website != null)
                    ListTile(
                      title: Text(
                        'Website:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: ElevatedButton(
                        onPressed: () {
                          // _launchURL(website); // Use the _launchURL function
                        },
                        child: Text('Visit Cafe Miron Website'),
                      ),
                    ),
                  if (address != null)
                    ListTile(
                      title: Text(
                        'Address:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(address), // Show the address
                    ),
                  SizedBox(height: 20), // Add spacing
                  ElevatedButton(
                    onPressed: () async {
                      MapUtils.openMap(81.0090496, 6.3504384);
                    },
                    child: Text('Find Cafe Miron on Google Maps'),
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
