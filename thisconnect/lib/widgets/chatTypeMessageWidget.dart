import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:thisconnect/utils/appTheme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

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
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  Timer? _timer;
  int _recordDuration = 0;
  Duration _currentPosition = Duration();
  Duration _audioDuration = Duration();
  StreamSubscription? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _openRecorder();
  }

  Future<void> _openPlayer() async {
    await _player!.openPlayer();
    _player!.setSubscriptionDuration(Duration(milliseconds: 10));
  }

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.status;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      await _recorder!.openRecorder();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mikrofon izni verilmedi."),
        ),
      );
    }
  }

  Future<void> startRecording() async {
    if (await Permission.microphone.isGranted) {
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });
      DateTime now = DateTime.now();
      String formattedDate =
          "${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}_${now.second}";
      _recordedFilePath = '/storage/emulated/0/Download/$formattedDate.aac';
      await _recorder!.startRecorder(
        toFile: _recordedFilePath,
        codec: Codec.aacADTS,
      );

      _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
        setState(() {
          _recordDuration++;
        });
      });
    } else {
      await Permission.microphone.request();
    }
  }

  Future<void> stopRecording() async {
    if (_isRecording) {
      await _recorder!.stopRecorder();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
        selectedFile = File(_recordedFilePath!);
      });
    }
  }

  Future<void> playAudio() async {
    if (_player!.isStopped) {
      await _openPlayer();

      _progressSubscription = _player!.onProgress!.listen((event) {
        setState(() {
          _currentPosition = event.position;
          _audioDuration = event.duration;
        });
      });

      await _player!.startPlayer(
        fromURI: selectedFile!.path,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _currentPosition = Duration(); // Sıfırlama
          });
          _progressSubscription?.cancel();
        },
      );

      setState(() {
        _isPlaying = true;
      });
    } else {
      stopPlaying();
    }
  }

  Future<void> stopPlaying() async {
    if (_isPlaying) {
      await _player!.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
      _progressSubscription?.cancel();
      _currentPosition = Duration();
      _audioDuration = Duration();
    }
  }

  Future<void> attachFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    _timer?.cancel();
    _progressSubscription?.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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
                if (selectedFile!.path.endsWith('.aac'))
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: playAudio,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Voice Record",
                        style: TextStyle(
                            fontSize: 16, color: AppTheme.gradientColorFrom),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "${formatDuration(_currentPosition)} / ${formatDuration(_audioDuration)}",
                        style: TextStyle(
                            fontSize: 16, color: AppTheme.gradientColorFrom),
                      ),
                    ],
                  )
                else
                  Text(
                    "File: ${selectedFile!.path.split('/').last}",
                    style: TextStyle(color: AppTheme.gradientColorFrom),
                  ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      selectedFile = null;
                      stopPlaying();
                    });
                  },
                ),
              ],
            ),
          ),
        if (_isRecording)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mic, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text(
                "${_recordDuration ~/ 60}:${(_recordDuration % 60).toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ],
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
                    onLongPress: () => startRecording(),
                    onLongPressUp: () => stopRecording(),
                    child: Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        _isRecording ? Icons.mic_off : Icons.mic,
                        color: AppTheme.gradientColorFrom,
                      ),
                    ),
                  ),
                ] else ...[
                  GestureDetector(
                    onTap: () => {
                      widget.submitMessageFunction(selectedFile),
                      setState(() {
                        selectedFile = null;
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
