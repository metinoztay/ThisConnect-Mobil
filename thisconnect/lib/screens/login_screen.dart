import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:thisconnect/screens/otp_screen.dart';
import 'package:thisconnect/services/api_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: Image(
                      image: AssetImage("lib/assets/images/send_otp.png")),
                ),
                const Text("OTP Verification",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20)),
                const SizedBox(
                  height: 10,
                ),
                const Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    children: [
                      TextSpan(
                          text: "We will send you an ",
                          style: TextStyle(color: Colors.grey)),
                      TextSpan(
                        text: "One Time Password",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      TextSpan(
                          text: " on your mobile number",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(children: [
                    IntlPhoneField(
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(),
                        ),
                      ),
                      initialCountryCode: 'TR',
                      onChanged: (phone) {
                        phoneController.text = phone.number.toString();
                      },
                    )
                  ]),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ApiHandler.createOtpRequest(phoneController.text);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OTPScreen(phoneNumber: phoneController.text),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.indigoAccent,
                    shadowColor: Colors.grey.shade300,
                    elevation: 10,
                  ),
                  child: const Text(
                    "Get OTP",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
