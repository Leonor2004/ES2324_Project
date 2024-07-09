import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maze/main.dart';
import '../firebase_auth_implementation/users_database.dart';

class ChangeUsername extends StatefulWidget {
  const ChangeUsername({super.key});
  
  @override
  _ChangeUsernameState createState() => _ChangeUsernameState();
}

class _ChangeUsernameState extends State<ChangeUsername> {
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Theme.of(context).focusColor), 
      ),
      body: Container(
        margin: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
        child: Column(
          children: [
            Container(height: 70),
            Text(
              "Change Username",
              style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            Container(height: 150),
            TextField(
              style: TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
              controller: _usernameController,
              decoration: InputDecoration(
                  labelStyle: TextStyle(
                      fontSize: 15, color: Theme.of(context).focusColor),
                  labelText: 'New username',
                  border: const UnderlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _changeUsername(),
              child: const Text('Update Username',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeUsername() async {
    try {
      await _databaseService.updateUsername(
          FirebaseAuth.instance.currentUser!.uid,
          _usernameController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully!')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (Route<dynamic> route) =>
            false, // Removes all the routes below the pushed route
      );
      //Navigator.pop(context); // Optionally navigate back
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update username: $e')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
