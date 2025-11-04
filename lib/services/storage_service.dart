import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File image) async {
    final String fileName = const Uuid().v4();
    final Reference ref = _storage.ref().child('images/$fileName');
    final Uint8List data = await image.readAsBytes();
    final UploadTask uploadTask = ref.putData(data);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    }
  }
}
