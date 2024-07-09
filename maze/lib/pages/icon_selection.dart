import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:maze/firebase_auth_implementation/users_database.dart';
import 'package:maze/main.dart';

List<IconData> icons = [
  Icons.face,
  Icons.face_6,
  Icons.face_5,
  Icons.face_4,
  Icons.face_3,
  Icons.face_2,
  Icons.sentiment_satisfied,
  Icons.sentiment_neutral,
  Icons.sentiment_very_satisfied,
  Icons.commute,
  Icons.flutter_dash,
  Icons.directions_bus,
  
];

class IconSelectionPage extends StatefulWidget {
  const IconSelectionPage({super.key});

  @override
  _IconSelectionPageState createState() => _IconSelectionPageState();
}

class _IconSelectionPageState extends State<IconSelectionPage> {
  final FirebaseDatabaseService dbService = FirebaseDatabaseService();
  
  int selectedIconIndex = -1;

  void updatePfpAttribute(int index) async {
    // Assuming user's uid is available via an auth mechanism like FirebaseAuth
     // replace with your actual user id logic
    await dbService.updateUserPfpAttribute(FirebaseAuth.instance.currentUser!.uid, (index + 1));
    setState(() {
      selectedIconIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).hintColor,
      drawerScrimColor: Theme.of(context).highlightColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).hintColor,
        iconTheme: IconThemeData(color: Theme.of(context).focusColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of icons per row
                childAspectRatio: 1.0,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(16.0),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    updatePfpAttribute(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedIconIndex == index ? Theme.of(context).highlightColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    
                    boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5), // changes position of shadow
                        ),
                      ],
                     
                    ),
                    child: Icon(icons[index], size: 50),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: selectedIconIndex != -1 ? () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (Route<dynamic> route) => false,  // `false` means remove all other routes
                  );
              } : null, // Navigate only if an icon has been selected
              child: const Text("Change Profile Icon"),
            ),
          ),
        ],
      ),
    );
  }
}
