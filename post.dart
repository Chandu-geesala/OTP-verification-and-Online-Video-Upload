import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadVideo(String videoUrl) async {
    Reference ref = _storage.ref().child('posts/${DateTime.now()}.mp4');
    await ref.putFile(File(videoUrl));
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }


  static Future<void> saveVideoData(
      String videoDownloadUrl,
      String title,
      String description,
      String category,
      ) async {
    await _firestore.collection('posts').add({
      'url': videoDownloadUrl,
      'timeStamp': FieldValue.serverTimestamp(),
      'name': 'User Video',
      'title': title,
      'description': description,
      'category': category,
    });
  }


}
