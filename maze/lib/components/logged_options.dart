import 'package:flutter/material.dart';
import 'package:maze/main.dart';
import 'package:maze/pages/about_us.dart';
import 'package:maze/pages/change_username.dart';
import 'package:maze/pages/icon_selection.dart';
import 'package:maze/pages/report.dart';

class LoggedOptions extends StatelessWidget {
  const LoggedOptions({super.key, required this.logout});

  final void Function(BuildContext) logout;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          
          ListTile(
            leading: Icon(
              Icons.edit,
              color: Theme.of(context).focusColor,
            ),
            title: Text(
              'Change username',
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangeUsername()),
              );
            },
          ),
         ListTile(
            leading: Icon(
              Icons.mood,
              color: Theme.of(context).focusColor,
            ),
            title: Text(
              'Change icon',
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>  const IconSelectionPage()),
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
              Icons.report,
              color: Theme.of(context).focusColor,
            ),
            title: Text(
              'Submit a report',
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Report()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).focusColor,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
            ),
            onTap: () {
              logout(context);
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
