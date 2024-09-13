import 'package:thisconnect/models/user_model.dart';

class QR {
  final String qrId;

  final String userId;

  final String title;

  final bool shareEmail;

  final bool sharePhone;

  final bool shareNote;

  final String? note;

  final String createdAt;

  final String? updatedAt;

  final bool isActive;

  final User user;

  const QR({
    required this.qrId,
    required this.userId,
    required this.title,
    required this.shareEmail,
    required this.sharePhone,
    required this.shareNote,
    this.note,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
    required this.user,
  });
}
