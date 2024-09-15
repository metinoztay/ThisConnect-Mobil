import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/services/pref_service.dart';
import 'package:thisconnect/services/upload_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
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
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      setState(() {
        _user = User(
          userId: json['userId'],
          phone: json['phone'],
          email: json['email'],
          title: json['title'],
          name: json['name'],
          surname: json['surname'],
          lastSeenAt: json['lastSeenAt'],
          avatarUrl: json['avatarUrl'],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: _user == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _updateProfilePhoto,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            _user!.avatarUrl,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ListView(
                  padding: EdgeInsets.all(16.0),
                  shrinkWrap: true,
                  children: [
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            _user!.name[0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text('${_user!.name} ${_user!.surname}'),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.phone),
                        title: Text(_user!.phone),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.email),
                        title: Text(_user!.email),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.title),
                        title: Text(_user!.title),
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text(_user!.lastSeenAt),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('user');
                        setState(() {
                          _user = null;
                        });
                      },
                      child: Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Future<void> _updateProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);

      try {
        String? userId = _user?.userId;

        if (userId != null) {
          // Burada resmi sunucuya yüklemeniz ve URL'yi almanız gerekiyor.
          // Örneğin, sunucuya resmi yüklemek için userService.uploadProfilePhoto(file) gibi bir metodunuz olabilir.

          await UploadService.uploadProfilePhoto(_user!.userId, file);

          // Kullanıcı bilgilerini güncelleyin
          await PrefService.updatePrefUserInformation(userId);
          _loadUserInformation(); // Kullanıcı bilgilerini tekrar yükleyin

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Your profile picture has been successfully updated.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ID not found')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'An error occurred while updating your profile picture: $e'),
          ),
        );
      }
    }
  }
}
