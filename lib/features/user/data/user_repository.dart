import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/app_user.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Stream<AppUser?> getUserProfile() {
    if (currentUserId == null) return Stream.value(null);
    return _usersCollection.doc(currentUserId).snapshots().map((doc) {
      if (doc.exists) {
        return AppUser.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> saveUserProfile(AppUser user) async {
    if (currentUserId == null) throw Exception('User not logged in');
    await _usersCollection.doc(user.uid).set(user.toFirestore());
  }

  Future<String> uploadProfilePicture(String filePath) async {
    if (currentUserId == null) throw Exception('User not logged in');
    final file = File(filePath);
    final String fileName =
        'profile_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference ref = _storage.ref().child(
      'users/${currentUserId}/profile_pictures/$fileName',
    );
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
