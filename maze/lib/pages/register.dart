import 'package:flutter/material.dart';
import 'package:maze/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:maze/main.dart';
import 'package:maze/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_auth_implementation/users_database.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  bool visibility = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void toggleVisibility() {
    setState(() {
      visibility = !visibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Theme.of(context).focusColor), 
        title: const Text(''),
      ),
      body: Container(
        margin: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'SIGN UP',
            style: TextStyle(
                color: Theme.of(context).highlightColor,
                fontSize: 45,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
          const Text(
            "The city's maze awaits.",
            style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
          ),
          Flexible(
            child: Container(),
          ),
          TextField(
            style: TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
            controller: _usernameController,
            decoration: InputDecoration(
                labelStyle: TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
                labelText: 'Username',
                border: const UnderlineInputBorder()),
          ),
          TextField(
            style: TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
            controller: _emailController,
            decoration: InputDecoration(
                labelStyle: TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
                labelText: 'Email Address',
                border: const UnderlineInputBorder()),
          ),
          TextField(
            style: TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
            controller: _passwordController,
            obscureText: visibility,
            decoration: InputDecoration(
                suffixIcon: GestureDetector(
                    onTap: () {
                      toggleVisibility();
                      print('Suffix icon tapped!');
                    },
                    child: const Icon(Icons.visibility)),
                labelStyle:  TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
                labelText: 'Password',
                border: const UnderlineInputBorder()),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            child: Text(
              "Already have an account? Log In",
              style: TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
            ),
          ),
          ElevatedButton(
            onPressed: _signUp,
            child: const Text("Sign Up"),
          ),
        ]),
      ),
    );
  }

  void _signUp() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String username =
        _usernameController.text; // Assuming you collect this at registration

    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    if (user != null) {
      await _databaseService.createUserProfile(user.uid, username);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (Route<dynamic> route) => false, 
        // Removes all the routes below the pushed route
      );
    } else {
      print("Sign up failed.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password(more than 6 caracters) and Email required.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }
}
