import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDrawerHeader extends StatelessWidget {
  final User? user;
  final String? userName;
  final String? mobileNumber;

  UserDrawerHeader({required this.user, this.userName, this.mobileNumber});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight =
        screenHeight / 8; // Set header height to 1/5 of the screen height

    return SafeArea(
      child: Container(
        height: headerHeight,
        color: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // User's profile photo (letter avatar)
            ClipOval(
              child: Container(
                color: Colors.white, // Change the background color as desired
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 30,
                  child: Text(
                    (userName?.isNotEmpty == true)
                        ? userName![0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.orange,
                    ), // Adjust the font size and color
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // User name and phone number on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userName ?? 'User Name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    mobileNumber ?? 'Mobile Number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
