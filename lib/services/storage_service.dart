import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadImage(XFile image) async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final filePath = 'users/${user.uid}/images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child(filePath);

    try {
      final uploadTask = await ref.putFile(File(image.path));
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
