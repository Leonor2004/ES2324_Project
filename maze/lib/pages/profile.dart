import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maze/components/guest_options.dart';
import 'package:maze/components/logged_options.dart';
import 'package:maze/pages/icon_selection.dart';

import 'package:maze/firebase_auth_implementation/users_database.dart';
import 'package:maze/main.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, void toggleTheme});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseDatabaseService databaseService = FirebaseDatabaseService();

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (Route<dynamic> route) =>
            false, // Removes all the routes below the pushed route
      );
      setState(() {});
    } catch (e) {
      // Error handling, e.g., show a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 70),
          child: StreamBuilder<Map<String, dynamic>?>(
            stream: user != null
                ? databaseService.getUserData(user.uid).asStream()
                : const Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              var userData = snapshot.data;
              IconData iconData = Icons.question_mark;
              if (userData != null &&
                  userData['pfp'] != null &&
                  userData['pfp'] <= icons.length) {
                iconData = icons[userData['pfp'] - 1];
              }
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 20),
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Theme.of(context).highlightColor,
                    foregroundColor: Theme.of(context).hintColor,
                    child: Icon(iconData, size: 100),
                  ),
                  const SizedBox(width: 20), // Space between the icon and the text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userData == null
                              ? "Guest"
                              : userData['username'].toString(),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).focusColor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text(""),
                        if (userData != null) ...[
                          Text(
                            "Contributions: ${userData['contributions']}",
                            style: TextStyle(
                              fontSize: 19,
                              color: Theme.of(context).focusColor,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 50),
        Divider(thickness: 1, color: Theme.of(context).focusColor),
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return LoggedOptions(
                logout: _logout,
              );
              // User is signed in, return an empty container or show user-specific options
            } else {
              // User is not signed in, show login button
              return const GuestOptions();
            }
          },
        ),
      ],
    );
  }
}
