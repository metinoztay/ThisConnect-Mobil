class Attachment {
  final String attachmentId;
  final String fileType;
  final String fileUrl;
  final String fileName;

  Attachment({
    required this.attachmentId,
    required this.fileType,
    required this.fileUrl,
    required this.fileName,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      attachmentId: json['attachmentId'],
      fileType: json['fileType'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachmentId': attachmentId,
      'fileType': fileType,
      'fileUrl': fileUrl,
      'fileName': fileName,
    };
  }
}
