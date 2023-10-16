import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miron/auth_helper.dart';
import 'package:miron/contact.dart';
import 'package:miron/faq.dart';
import 'package:miron/model/confirmationDialog.dart';
import 'package:miron/myOrders.dart';
import 'package:miron/pages/Review.dart';
import 'package:miron/screens/user_profile.dart';
import 'package:miron/screens/userDrawerHeader.dart';

class AppDrawer extends StatelessWidget {
  final User? user;
  final String? userName;
  final String? mobileNumber;

  AppDrawer({
    required this.user,
    required this.userName,
    required this.mobileNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserDrawerHeader(
            user: user,
            userName: userName,
            mobileNumber: mobileNumber,
          ),
          ListTile(
            leading: Icon(Icons.person_3_rounded),
            title: Text('Edit Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    userId: user!.uid,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('My Orders'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyOrders(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_document),
            title: const Text('Inquiries'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Review()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('FAQ'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => FAQPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ContactUsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: const Text('Logout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmationDialog(
                    title: 'Logout Confirmation',
                    content: 'Are you sure you want to logout?',
                    confirmText: 'Yes, Logout',
                    cancelText: 'Cancel',
                    onConfirm: () {
                      // Perform the logout action here
                      AuthHelper.instance.logout(context);
                    },
                    onCancel: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
