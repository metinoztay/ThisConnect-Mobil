import 'package:thisconnect/models/profileitem.dart';
import 'package:flutter/material.dart';
import 'package:thisconnect/services/pref_handler.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  List<Profileitem> profileItems = [];
  List<String> itemMaps = ['/profile', '/qrList', '/chat', '/help', '/login'];
  @override
  void initState() {
    super.initState();
    loadProfileItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: ListView.builder(
          itemCount: profileItems.length,
          itemBuilder: (context, index) {
            final item = profileItems[index];
            return Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (item.title == 'Logout') {
                      var result = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                  'Are you sure you want to logout?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('No'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          });
                      if (result ?? false) {
                        await PrefHandler.removePrefUserInformation();
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    } else {
                      Navigator.of(context).pushNamed(itemMaps[index]);
                    }
                  },
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    leading: Icon(item.icon),
                  ),
                ),
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }

  loadProfileItems() {
    profileItems = [
      Profileitem(title: 'Profile', icon: Icons.person),
      Profileitem(title: 'QR List', icon: Icons.qr_code),
      Profileitem(title: 'Settings', icon: Icons.settings),
      Profileitem(title: 'Help', icon: Icons.help),
      Profileitem(title: 'Logout', icon: Icons.logout),
    ];
  }
}
