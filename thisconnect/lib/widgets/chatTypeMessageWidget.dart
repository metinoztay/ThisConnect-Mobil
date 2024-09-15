import 'dart:io';
import 'package:flutter/material.dart';
import 'package:thisconnect/utils/appTheme.dart';
import 'package:file_picker/file_picker.dart';

class ChatTypeMessageWidget extends StatefulWidget {
  final TextEditingController messageTextController;
  final Function(File? attach) submitMessageFunction;
  final bool isMessageEmpty;

  const ChatTypeMessageWidget({
    required this.messageTextController,
    required this.submitMessageFunction,
    required this.isMessageEmpty,
    Key? key,
  }) : super(key: key);

  @override
  _ChatTypeMessageWidgetState createState() => _ChatTypeMessageWidgetState();
}

class _ChatTypeMessageWidgetState extends State<ChatTypeMessageWidget> {
  File? selectedFile;

  Future<void> attachFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedFile != null)
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "File: ${selectedFile!.path.split('/').last}",
                  style: TextStyle(color: AppTheme.gradientColorFrom),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      selectedFile = null; // Dosya seçimini iptal et
                    });
                  },
                ),
              ],
            ),
          ),
        ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 60,
            maxHeight: 120.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 20,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 60,
                        maxHeight: 120.0,
                      ),
                      child: TextField(
                        controller: widget.messageTextController,
                        scrollPhysics: BouncingScrollPhysics(),
                        maxLines: null,
                        style: TextStyle(color: AppTheme.gradientColorFrom),
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          filled: false,
                          focusedBorder: InputBorder.none,
                          hintText: "Type a message",
                          hintStyle: TextStyle(
                            color: AppTheme.gradientColorTo.withOpacity(.4),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(16, 16, 32, 16),
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.isMessageEmpty) ...[
                  GestureDetector(
                    onTap: () => attachFile(),
                    child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.attach_file_outlined,
                        color: AppTheme.gradientColorFrom,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => null,
                    child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.mic,
                        color: AppTheme.gradientColorFrom,
                      ),
                    ),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: () => {
                      widget.submitMessageFunction(selectedFile),
                      setState(() {
                        selectedFile = null; // Dosya seçimini iptal et
                      })
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.send,
                        color: AppTheme.gradientColorFrom,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}
