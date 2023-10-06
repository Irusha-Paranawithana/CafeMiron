import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('FAQ'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('FAQ').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.orange, // Custom loading indicator color
              ),
            );
          }

          final faqDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: faqDocs.length,
            itemBuilder: (context, index) {
              final docData = faqDocs[index].data() as Map<String, dynamic>;
              final question = docData['question'] as String?;
              final answer = docData['answer'] as String?;

              if (question == null || answer == null) {
                // Handle the case where the fields are missing or null
                return Card(
                  elevation: 2.0,
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Question or Answer Missing'),
                    subtitle: Text('Please check this FAQ entry.'),
                    leading:
                        Icon(Icons.warning, color: Colors.red), // Warning icon
                  ),
                );
              }

              return Card(
                elevation: 2.0,
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    question,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  subtitle: Text(
                    answer,
                    style: TextStyle(fontSize: 18),
                  ),
                  leading: Icon(
                    Icons.help_outline,
                    color: Colors.blue,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
