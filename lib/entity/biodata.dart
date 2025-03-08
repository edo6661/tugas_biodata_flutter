import 'package:cloud_firestore/cloud_firestore.dart';

class Biodata {
  final String? docId;
  final String userId;
  final String username;
  final String age;
  final String address;
  final String avatarUrl;
  final Timestamp? createdAt;

  Biodata({
    this.docId,
    required this.userId,
    required this.username,
    required this.age,
    required this.address,
    required this.avatarUrl,
    this.createdAt,
  });

  factory Biodata.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Biodata(
      docId: docId,
      userId: map['userId'] as String? ?? '',
      username: map['username'] as String? ?? '',
      age: map['age'] as String? ?? '',
      address: map['address'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
