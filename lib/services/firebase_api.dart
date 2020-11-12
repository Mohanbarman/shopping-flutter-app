import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

// ignore: non_constant_identifier_names
int MAX_SIZE = 1024 * 1024 * 5;

class FirebaseStorageApi {
  Uint8List imageBytes;

  // ignore: non_constant_identifier_names
  Future trendingOffersFuture(int index) async {
    try {
      var x = await FirebaseFirestore.instance
          .collection('offers')
          .where('type', isEqualTo: 'trending')
          .get();
      List docs = x.docs.toList();
      return FirebaseStorage.instance
          .ref()
          .child(docs[index]['image'])
          .getData(MAX_SIZE);
      // return null;
    } catch (e) {
      print(e);
    }
  }

  static Future futureFromImagePath(String path) {
    try {
      return FirebaseStorage.instance.ref().child(path).getData(MAX_SIZE);
    } catch (e) {
      print(e);
    }
  }

  // Get the list of regular offers future
  static Future<List> regularOffersFuture(int index) async {
    try {
      var value = await FirebaseFirestore.instance.collection('offers').get();
      List docs = value.docs.toList();
      return FirebaseStorage.instance
          .ref()
          .child(docs[index]['image'])
          .getData(MAX_SIZE);
    } catch (e) {
      print(e);
    }
  }

  static Stream allOffersStream({int limit}) {
    try {
      return limit == null
          ? FirebaseFirestore.instance.collection('offers').snapshots()
          : FirebaseFirestore.instance
              .collection('offers')
              .limit(limit)
              .snapshots();
    } catch (e) {
      print(e);
    }
  }

  static Stream trendingOffersStream() {
    try {
      return FirebaseFirestore.instance
          .collection('offers')
          .where('type', isEqualTo: 'trending')
          .snapshots();
    } catch (e) {
      print(e);
    }
  }

  static Stream streamOfCollection({
    String collection,
    int limit,
    String where,
    String isEqualsTo,
  }) {
    try {
      return limit == null
          ? FirebaseFirestore.instance.collection(collection).snapshots()
          : FirebaseFirestore.instance
              .collection(collection)
              .limit(limit + 1)
              .snapshots();
    } catch (e) {
      print(e);
    }
  }

  static Stream streamOfCollectionFiltered({
    String collection,
    int limit,
    String where,
    String isEqualsTo,
  }) {
    try {
      return limit == null
          ? FirebaseFirestore.instance.collection(collection).snapshots()
          : FirebaseFirestore.instance
              .collection(collection)
              .where('type', isEqualTo: 'whatsapp')
              .limit(limit + 1)
              .snapshots();
    } catch (e) {
      print(e);
    }
  }

  static updateDocument({model, String collection}) {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection(collection);
      ref.doc(model.id).update(model.toJson());
    } catch (e) {
      print(e);
    }
  }

  static Future<void> uploadFile({File file, String filename}) async {
    try {
      StorageReference ref = FirebaseStorage.instance.ref().child(filename);
      final StorageUploadTask uploadTask = ref.putFile(file);
      uploadTask.onComplete
          .then((value) => print('successfully uploaded to $filename'));
    } catch (e) {
      print(e);
    }
  }

  static Future<void> addData({Map data, String collection}) async {
    try {
      print(data);
      CollectionReference ref =
          FirebaseFirestore.instance.collection(collection);
      ref.add(data);
    } catch (e) {
      print(e);
    }
  }

  static Future deleteDoc({String id, String collection}) async {
    try {
      CollectionReference ref =
          FirebaseFirestore.instance.collection(collection);
      await ref.doc(id).delete();
    } catch (e) {
      print(e);
    }
  }
}
