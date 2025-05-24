import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';           // ★ add uuid: ^3.0.6 to your pubspec

Future<void> uploadImageWithRandomSubcollection({
  required String collectionName,
  required String documentId,
  required File yourLocalFile,
  required String eegPrediction,
}) async {
  try {
    // 1️⃣ Init Firebase (once in your app):

    // 2️⃣ Upload image to Storage:
    final fileName = path.basename(yourLocalFile.path);
    final storageRef = FirebaseStorage.instance.ref('images/$fileName');
    final uploadTask = storageRef.putFile(yourLocalFile);
    final snap = await uploadTask;
    if (snap.state != TaskState.success) {
      print('❌ Upload failed (state=${snap.state})');
      return;
    }
    final downloadUrl = await storageRef.getDownloadURL();

    // 3️⃣ Pick a random sub-collection name:
    final subColName = const Uuid().v4();

    // 4️⃣ Build the path: 
    //    /collectionName/documentId/<< subColName >>/<< autoDocId >>
    final parentDoc = FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentId);
    final newDoc = parentDoc
        .collection(subColName)
        .doc(); // auto-generated ID

    // 5️⃣ Write both fields:
    await newDoc.set({
      'imageUrl':       downloadUrl,
      'eeg_prediction': eegPrediction,
    });

    print('✅ Success! Stored at '
        '$collectionName/$documentId/$subColName/${newDoc.id}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
