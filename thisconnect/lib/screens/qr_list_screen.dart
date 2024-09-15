import 'package:flutter/material.dart';
import 'package:thisconnect/models/qr_model.dart';
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/screens/qr_viewing_screen.dart';
import 'package:thisconnect/services/pref_service.dart';
import 'package:thisconnect/services/qr_service.dart';
import 'package:thisconnect/services/user_service.dart';

class QRListScreen extends StatefulWidget {
  const QRListScreen({super.key});

  @override
  State<QRListScreen> createState() => _QRListScreenState();
}

class _QRListScreenState extends State<QRListScreen> {
  List<QR> _qrList = [];
  String newQRtitle = '';
  User? user;
  @override
  void initState() {
    super.initState();
    getPrefUserInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _qrList.length,
                      itemBuilder: (context, index) {
                        final item = _qrList[index];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => QRViewingScreen(
                                          qrId: item.qrId,
                                          updateQRList: loadQRList))),
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
                                leading: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'Create QR',
                              style: TextStyle(fontSize: 20),
                            ),
                            content: TextField(
                              onChanged: (value) {
                                newQRtitle = value;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter title',
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  addQR();
                                  Navigator.pop(context);
                                },
                                child: const Text('Create'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      shadowColor: Colors.grey.shade300,
                      elevation: 10,
                    ),
                    child: const Text(
                      "Create New QR",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Future<void> getPrefUserInformation() async {
    var temp = await PrefService.getPrefUserInformation();
    if (temp != null) {
      setState(() {
        user = User(
          avatarUrl: temp.avatarUrl,
          userId: temp.userId,
          phone: temp.phone,
          email: temp.email,
          title: temp.title,
          name: temp.name,
          surname: temp.surname,
          lastSeenAt: temp.lastSeenAt,
        );
      });
      loadQRList();
    }
  }

  Future<void> loadQRList() async {
    _qrList.clear();
    if (user != null) {
      final results = await QrService.getUsersQRList(user!.userId);
      setState(() {
        if (results != null) {
          _qrList = results;
        }
      });
    }
  }

  Future<void> addQR() async {
    if (user != null) {
      await QrService.addQR(
        QR(
            qrId: "test",
            userId: user!.userId,
            title: newQRtitle,
            shareEmail: false,
            sharePhone: false,
            shareNote: false,
            note: "Note",
            createdAt: DateTime.now().toString(),
            isActive: true,
            user: await UserService.getUserInformation(user!.userId)),
      );

      setState(() {
        loadQRList();
      });
    }
  }
}
