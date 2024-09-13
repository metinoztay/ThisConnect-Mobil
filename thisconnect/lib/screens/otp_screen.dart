import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisconnect/models/otp_model.dart';
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/screens/main_screen.dart';
import 'package:thisconnect/screens/signup_screen.dart';
import 'package:thisconnect/services/api_handler.dart';
import 'package:thisconnect/services/pref_handler.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final OtpTimerButtonController resendButtonController =
      OtpTimerButtonController();
  String enteredOTP = "";
  String resendButtonText = "Resend OTP";
  User? user; // Nullable User type

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: Image(
                  image: AssetImage("lib/assets/images/enter_otp.png"),
                ),
              ),
            ),
            const Text("OTP Verification",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20)),
            const SizedBox(
              height: 10,
            ),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  const TextSpan(
                      text: "Enter the OTP sent to ",
                      style: TextStyle(color: Colors.grey)),
                  TextSpan(
                    text:
                        "******${widget.phoneNumber.substring(widget.phoneNumber.length - 4)}",
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            OtpTextField(
              fieldWidth: 45,
              textStyle: const TextStyle(
                fontSize: 24,
              ),
              numberOfFields: 6,
              borderColor: const Color(0xFF512DA8),
              showFieldAsBox: false,
              onCodeChanged: (String code) {
                enteredOTP = code;
              },
              onSubmit: (String verificationCode) async {
                await otpVerification(
                    Otp(phone: widget.phoneNumber, otpValue: verificationCode));
                if (user != null) {
                  PrefHandler.savePrefUserInformation(user!);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) => const MainScreen(),
                  ));
                } else {
                  // otp mi yanlış kullanıcı mı yok kontrolü yapılacak
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (_) =>
                        SignUpScreen(phoneNumber: widget.phoneNumber),
                  ));
                }
                /*showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Verification Code"),
                        content: Text('Code entered is $verificationCode'),
                      );
                    });*/
              },
            ),
            const SizedBox(
              height: 60,
            ),
            const Text("Didn't receive the code?"),
            OtpTimerButton(
              controller: resendButtonController,
              onPressed: () {
                resendButtonController.loading();
                setState(() {
                  resendButtonText = "Sending OTP ";
                });
                Future.delayed(const Duration(seconds: 2), () {
                  resendButtonController.startTimer();
                  setState(() {
                    resendButtonText = "Resend OTP";
                  });
                });
              },
              text: Text(resendButtonText),
              duration: 5,
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> otpVerification(Otp otp) async {
    var response = await ApiHandler.otpVerification(otp);
    setState(() {
      user = response;
    });
  }
}
