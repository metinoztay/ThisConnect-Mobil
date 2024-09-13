import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  List<bool> helpItems = [false, false];

  void expandeHelp(int index) {
    setState(() {
      helpItems[index] = !helpItems[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help",
            style:
                TextStyle(fontSize: 20, color: Colors.white, letterSpacing: 1)),
        backgroundColor: Colors.blue,
        elevation: 210,
        centerTitle: true,
        titleSpacing: 1,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Help Topic 1'),
            onTap: () {
              expandeHelp(0);
            },
            trailing: Icon(
              helpItems[0]
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
          ),
          if (helpItems[0])
            Container(
              margin: const EdgeInsets.only(left: 35, right: 25),
              child: const Text(
                'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
          ListTile(
            title: const Text('Help Topic 2'),
            onTap: () {
              expandeHelp(1);
            },
            trailing: Icon(
              helpItems[1]
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
          ),
          if (helpItems[1])
            Container(
              margin: EdgeInsets.only(left: 35, right: 25),
              child: const Text(
                'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using Content here, content here, making it look like readable English. ',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
        ],
      ),
    );
  }
}
