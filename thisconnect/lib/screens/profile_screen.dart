import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisconnect/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserInformation();
  }

  Future<void> _loadUserInformation() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user');
    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      setState(() {
        _user = User(
          userId: json['userId'],
          phone: json['phone'],
          email: json['email'],
          title: json['title'],
          name: json['name'],
          surname: json['surname'],
          lastSeenAt: json['lastSeenAt'],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                ListTile(
                  title: Text('Name'),
                  subtitle: Text(_user!.name),
                ),
                ListTile(
                  title: Text('Surname'),
                  subtitle: Text(_user!.surname),
                ),
                ListTile(
                  title: Text('Email'),
                  subtitle: Text(_user!.email),
                ),
                ListTile(
                  title: Text('Phone'),
                  subtitle: Text(_user!.phone),
                ),
                ListTile(
                  title: Text('Title'),
                  subtitle: Text(_user!.title),
                ),

                ListTile(
                  title: Text('Last Seen At'),
                  subtitle: Text(_user!.lastSeenAt),
                ),
                SizedBox(
                    height:
                        20), // Butonun yukarısında biraz boşluk bırakmak için
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user');
                    setState(() {
                      _user = null;
                    });
                  },
                  child: Text('Clear'),
                ),
              ],
            ),
    );
  }
}
