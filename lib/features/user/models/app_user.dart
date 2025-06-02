import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? email;
  final String name;
  final String? username;
  final String? description;
  final String? profilePictureUrl;

  AppUser({
    required this.uid,
    this.email,
    required this.name,
    this.username,
    this.description,
    this.profilePictureUrl,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'],
      name: data['name'] ?? '',
      username: data['username'],
      description: data['description'],
      profilePictureUrl: data['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'description': description,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? username,
    String? description,
    String? profilePictureUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      username: username ?? this.username,
      description: description ?? this.description,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
