import 'package:firebase_auth/firebase_auth.dart';
import 'package:maze/main.dart';
import 'package:flutter/material.dart';
import 'package:maze/pages/register.dart';
import 'package:maze/firebase_auth_implementation/firebase_auth_services.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool hidden = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void toggleVisibility() {
    setState(() {
      hidden = !hidden;
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
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text(
            'LOG IN',
            style: TextStyle(
                color: Theme.of(context).highlightColor,
                fontSize: 45,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic),
          ),
          Text(
            "Welcome back, navigator",
            style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).focusColor,
                fontStyle: FontStyle.italic),
          ),
          Flexible(
            child: Container(),
          ),
          TextField(
            style: TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
            controller: _emailController,
            decoration: InputDecoration(
                labelStyle: TextStyle(
                    fontSize: 15, color: Theme.of(context).focusColor),
                labelText: 'Email Address',
                border: const UnderlineInputBorder()),
          ),
          TextField(
            style: TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
            
            controller: _passwordController,
            decoration: InputDecoration(
                suffixIcon: GestureDetector(
                    onTap: () => toggleVisibility(),
                    child: const Icon(Icons.visibility)),
                labelStyle: TextStyle(
                    fontSize: 15, color: Theme.of(context).focusColor),
                labelText: 'Password',
                border: const UnderlineInputBorder()),
                obscureText: hidden,
          ) ,
          
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Register()),
              );
            },
            child: Text(
              "Don't have an account? Sign Up",
              style:
                  TextStyle(fontSize: 15, color: Theme.of(context).focusColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: _signIn,
            child: Text(
              "Login",
              style: TextStyle(color: Theme.of(context).focusColor),
            ),
          ),
        ]),
      ),
    );
  }

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null) {
      print("User is successfully logged in");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MyHomePage()),
        (Route<dynamic> route) => false, 
        // Removes all the routes below the pushed route
      );
    } else {
      print("Some error happened.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to log in.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }
}
