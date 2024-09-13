import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thisconnect/models/qr_model.dart';
import 'package:thisconnect/services/api_handler.dart';

class QRViewingScreen extends StatefulWidget {
  final String qrId;
  final Function updateQRList;

  const QRViewingScreen(
      {super.key, required this.qrId, required this.updateQRList});

  @override
  State<QRViewingScreen> createState() => _QRViewingScreenState();
}

class _QRViewingScreenState extends State<QRViewingScreen> {
  late QR _qrInformation;
  late String title = "dd";
  late bool isActive = true;
  late bool sharePhone = true;
  late bool shareNote = true;
  late bool shareEmail = true;
  late String note = "dd";
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getQRResult();
  }

  void dispose() {
    widget.updateQRList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "QR View",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _qrInformation == null
              ? const Center(child: Text("No data found."))
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              QrImageView(
                                data: widget.qrId,
                                size: 150,
                                version: QrVersions.auto,
                              ),
                              ListTile(
                                title: Row(
                                  children: [
                                    const Text(
                                      "Title: ",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onDoubleTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Edit Title'),
                                                content: TextField(
                                                  controller:
                                                      TextEditingController(
                                                          text: title),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      title = value;
                                                    });
                                                  },
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('Save'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          title,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                              letterSpacing: 1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SwitchListTile(
                                inactiveTrackColor: Colors.red.shade100,
                                inactiveThumbColor: Colors.red,
                                value: isActive,
                                activeColor: Colors.green,
                                activeTrackColor: Colors.green.shade100,
                                onChanged: (value) {
                                  setState(() {
                                    isActive = value;
                                  });
                                },
                                title: const Text(
                                  'Active',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                              ),
                              SwitchListTile(
                                inactiveTrackColor: Colors.red.shade100,
                                inactiveThumbColor: Colors.red,
                                value: shareEmail,
                                activeColor: Colors.green,
                                activeTrackColor: Colors.green.shade100,
                                onChanged: (value) {
                                  setState(() {
                                    shareEmail = value;
                                  });
                                },
                                title: const Text(
                                  'Share Email',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                              ),
                              SwitchListTile(
                                inactiveTrackColor: Colors.red.shade100,
                                inactiveThumbColor: Colors.red,
                                value: sharePhone,
                                activeColor: Colors.green,
                                activeTrackColor: Colors.green.shade100,
                                onChanged: (value) {
                                  setState(() {
                                    sharePhone = value;
                                  });
                                },
                                title: const Text(
                                  'Share Phone',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                              ),
                              SwitchListTile(
                                inactiveTrackColor: Colors.red.shade100,
                                inactiveThumbColor: Colors.red,
                                value: shareNote,
                                activeColor: Colors.green,
                                activeTrackColor: Colors.green.shade100,
                                onChanged: (value) {
                                  setState(() {
                                    shareNote = value;
                                  });
                                },
                                title: const Text(
                                  'Share Note',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                child: TextField(
                                  controller: TextEditingController(text: note),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    labelText: 'Note:',
                                  ),
                                  onChanged: (value) {
                                    note = value;
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Icon(Icons.download,
                                        color: Colors.white),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Icon(Icons.share,
                                        color: Colors.white),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Are you sure delete the QR code?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  deleteQR();
                                                  Navigator.of(context).pop();
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 200,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () {
                                updateQRInformation();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "SAVE",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Future<void> getQRResult() async {
    try {
      _qrInformation = await ApiHandler.getQRInformation(widget.qrId);
      setState(() {
        title = _qrInformation.title;
        shareEmail = _qrInformation.shareEmail;
        sharePhone = _qrInformation.sharePhone;
        shareNote = _qrInformation.shareNote;
        note = _qrInformation.note!;
        isActive = _qrInformation.isActive;
      });
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateQRInformation() async {
    try {
      await ApiHandler.updateQRInformation(QR(
        qrId: _qrInformation.qrId,
        userId: _qrInformation.userId,
        title: title,
        shareEmail: shareEmail,
        sharePhone: sharePhone,
        shareNote: shareNote,
        note: note,
        createdAt: _qrInformation.createdAt,
        isActive: isActive,
        user: _qrInformation.user,
      ));
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteQR() async {
    try {
      await ApiHandler.deleteQR(widget.qrId);
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
