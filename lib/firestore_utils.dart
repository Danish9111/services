import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<DocumentSnapshot> fetchDocumentWithRetry(String collection, String docId,
    {int maxRetries = 5}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  int retryCount = 0;
  while (true) {
    try {
      DocumentSnapshot doc = await fetchDocumentWithRetry('workerProfiles', uid!);

      return doc;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' && retryCount < maxRetries) {
        retryCount++;
        // Exponential backoff delay (2^retryCount seconds)
        int delaySeconds = pow(2, retryCount).toInt();
        await Future.delayed(Duration(seconds: delaySeconds));
      } else {
        rethrow;
      }
    }
  }
}
