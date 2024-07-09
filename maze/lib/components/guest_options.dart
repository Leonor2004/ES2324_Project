import 'package:flutter/material.dart';
import 'package:maze/main.dart';
import 'package:maze/pages/about_us.dart';
import 'package:maze/pages/login.dart';

class GuestOptions extends StatelessWidget {
  const GuestOptions({super.key});


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.login,
              color: Theme.of(context).focusColor,
            ),
            title: Text(
              'Login',
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              MyApp.of(context)!.isThemeLight()
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Theme.of(context).focusColor,
            ),
            title: Text(
              MyApp.of(context)!.isThemeLight() ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onTap: () {
              MyApp.of(context)?.toggleTheme();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Theme.of(context).focusColor,
            ),
            title: Text(
              'About us',
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUs()),
              );
            },
          ),
        ],
      ),
    );
  }
}
