import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:thisconnect/screens/home_screen.dart';
import 'package:thisconnect/screens/login_screen.dart';
import 'package:thisconnect/screens/main_screen.dart';
import 'package:thisconnect/screens/signup_screen.dart';

import 'introduction_screens/intro_page_1.dart';
import 'introduction_screens/intro_page_2.dart';
import 'introduction_screens/intro_page_3.dart';
import 'introduction_screens/intro_page_4.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();

  bool onLastPage = false;

  void saveIntroducted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setBool('isIntroducted', true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              onLastPage = (index == 3);
            });
          },
          children: const [
            IntroPage1(),
            IntroPage2(),
            IntroPage3(),
            IntroPage4(),
          ],
        ),
        Container(
          alignment: const Alignment(0, 0.87),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  _controller.jumpToPage(3);
                },
                child: const Text(
                  "SKIP",
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SmoothPageIndicator(controller: _controller, count: 4),
              onLastPage
                  ? GestureDetector(
                      onTap: () {
                        saveIntroducted();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ));
                      },
                      child: const Text(
                        "DONE",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ))
                  : GestureDetector(
                      onTap: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      },
                      child: const Text(
                        "NEXT",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ))
            ],
          ),
        )
      ],
    ));
  }
}
