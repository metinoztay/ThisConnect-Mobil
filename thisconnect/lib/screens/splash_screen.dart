import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/screens/main_screen.dart';
import 'package:thisconnect/screens/onboarding_screen.dart';
import 'package:thisconnect/services/pref_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool isIntroducted = false;
  User? user;

  void checkIsIntroductedandLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.clear();
    isIntroducted = prefs.getBool('isIntroducted') ?? false;
    await getPrefUserInformation();
    if (user != null) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnBoardingScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Future.delayed(const Duration(seconds: 1), () async {
      checkIsIntroductedandLogin();
    });
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.connect_without_contact_rounded,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "This Connect!",
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    fontSize: 32),
              )
            ],
          )),
    );
  }

  Future<void> getPrefUserInformation() async {
    var temp = await PrefService.getPrefUserInformation();
    if (temp != null) {
      setState(() {
        user = temp;
      });
    }
  }
}
