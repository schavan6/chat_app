
import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fanpage/models/user.dart' as u;

import '../models/convo.dart';


class Database {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<Convo>> streamConversations(String uid) {
    return _db
        .collection('messages')
        .orderBy('lastMessage.timestamp', descending: true)
        .where('users', arrayContains: uid)
        .snapshots()
        .map((QuerySnapshot list) => list.docs
        .map((DocumentSnapshot doc) => Convo.fromFireStore(doc))
        .toList());
  }
  static Stream<List<u.User>> streamUsers() {

    return _db
        .collection('users')
        .snapshots()
        .map((QuerySnapshot list) => list.docs
        .map((DocumentSnapshot snap) => u.User.fromMap(snap.data()))
        .toList());
  }

  static void sendMessage(
      String convoID,
      String id,
      String pid,
      String content,
      String timestamp,
      ) {
    final DocumentReference convoDoc =
    _db.collection('messages').doc(convoID);

    convoDoc.set(<String, dynamic>{
      'lastMessage': <String, dynamic>{
        'idFrom': id,
        'idTo': pid,
        'timestamp': timestamp,
        'content': content,
        'read': false
      },
      'users': <String>[id, pid]
    }).then((dynamic success) {
      final DocumentReference messageDoc = _db
          .collection('messages')
          .doc(convoID)
          .collection(convoID)
          .doc(timestamp);

      _db.runTransaction((Transaction transaction) async {
        await transaction.set(
          messageDoc,
          <String, dynamic>{
            'idFrom': id,
            'idTo': pid,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'read': false
          },
        );
      });
    });
  }

  static void updateMessageRead(DocumentSnapshot doc, String convoID) {
    print(convoID);
    print(doc.id);
   /* final DocumentReference documentReference = _db
        .collection('messages')
        .doc(convoID)
        .collection(convoID)
        .doc(doc.id);*/
     DocumentReference documentReference = _db
        .collection('messages')
        .doc(convoID);

    documentReference.set(<String, dynamic>{
      'lastMessage': <String, dynamic>{
        'read': true
      },

    },SetOptions(merge: true));
    documentReference =  documentReference.collection(convoID)
        .doc(doc.id);
    documentReference.set(<String, dynamic>{'read': true}, SetOptions(merge: true));
  }



  static Stream<List<u.User>> getUsersByList(List<String> userIds) {
    //print(userIds);
    final List<Stream<u.User>> streams = List();
    for (String id in userIds) {
      //print(id);
      streams.add(_db
          .collection('users')
          .doc(id)
          .snapshots()
          .map((DocumentSnapshot snap) => u.User.fromMap(snap.data())));
    }
    return StreamZip<u.User>(streams).asBroadcastStream();
  }
}