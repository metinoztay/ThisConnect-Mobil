class User {
  String userId;
  String phone;
  String email;
  String title;
  String name;
  String surname;
  String avatarUrl;
  String lastSeenAt;

  User({
    required this.userId,
    required this.phone,
    required this.email,
    required this.title,
    required this.name,
    required this.surname,
    required this.avatarUrl,
    required this.lastSeenAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      phone: json['phone'],
      email: json['email'],
      title: json['title'],
      name: json['name'],
      surname: json['surname'],
      avatarUrl: json['avatarUrl'],
      lastSeenAt: json['lastSeenAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['title'] = this.title;
    data['name'] = this.name;
    data['surname'] = this.surname;
    data['avatarUrl'] = this.avatarUrl;
    data['lastSeenAt'] = this.lastSeenAt;
    return data;
  }
}
