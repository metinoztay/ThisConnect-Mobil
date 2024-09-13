import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/screens/messages_screen.dart';
import 'package:thisconnect/screens/profile_menu_screen.dart';
import 'package:thisconnect/screens/qr_scanner_screen.dart';
import 'package:thisconnect/services/pref_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedPage = 0;
  User? user;
  late List<Widget> pageOptions;
  final appBarTitles = [
    "Messages",
    "Messages",
    "ProfileMenu",
  ];

  @override
  void initState() {
    super.initState();
    getPrefUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitles[selectedPage],
              style: const TextStyle(
                  fontSize: 20, color: Colors.white, letterSpacing: 1)),
          backgroundColor: Colors.blue,
          elevation: 210,
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    pageOptions = [
      MessagesScreen(user: user!),
      QRScannerScreen(user: user!),
      const ProfileMenuScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[selectedPage],
            style: const TextStyle(
                fontSize: 20, color: Colors.white, letterSpacing: 1)),
        backgroundColor: Colors.blue,
        elevation: 210,
        centerTitle: true,
      ),
      body: pageOptions[selectedPage],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        height: 54,
        initialActiveIndex: selectedPage,
        items: const [
          TabItem(icon: Icons.message, title: 'Messages'),
          TabItem(
            icon: Icons.qr_code_scanner,
            title: 'Messages',
          ),
          TabItem(icon: Icons.people, title: 'Profile'),
        ],
        onTap: (int index) {
          if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => QRScannerScreen(user: user!)));
          }
          setState(() {
            if (index != 1) {
              selectedPage = index;
            }
          });
        },
      ),
    );
  }

  Future<void> getPrefUserInformation() async {
    var temp = await PrefHandler.getPrefUserInformation();
    if (temp != null) {
      setState(() {
        user = User(
          userId: temp.userId,
          phone: temp.phone,
          email: temp.email,
          title: temp.title,
          name: temp.name,
          surname: temp.surname,
          lastSeenAt: temp.lastSeenAt,
        );
      });
    }
  }
}
