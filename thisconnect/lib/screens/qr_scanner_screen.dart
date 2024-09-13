import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/screens/qr_result_screen.dart';
import 'package:thisconnect/widgets/qr_overlay.dart';

class QRScannerScreen extends StatefulWidget {
  final User user;
  const QRScannerScreen({required this.user, super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanCompleted = false;
  @override
  void initState() {
    isScanCompleted = false;
    super.initState();
  }

  void loadScan() {
    isScanCompleted = false;
    print("Hello");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "QR Scanner",
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
                child: Container(
              color: Colors.white,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Place the QR Code in the area.",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Scanning will be started automatically.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  )
                ],
              ),
            )),
            Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    MobileScanner(
                      onDetect: (barcode) {
                        if (!isScanCompleted) {
                          String qrCode =
                              barcode.barcodes[0].rawValue.toString();
                          isScanCompleted = true;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QRResultScreen(
                                        qrCodeId: qrCode,
                                        user: widget.user,
                                        loadScan: loadScan,
                                      )));
                        }
                      },
                    ),
                    const QRScannerOverlay(overlayColour: Colors.white)
                  ],
                )),
            Expanded(
                child: Container(
              alignment: Alignment.bottomCenter,
              color: Colors.white,
              child: const Text(
                "© 2024. ThisConnect. All rights reserved.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
