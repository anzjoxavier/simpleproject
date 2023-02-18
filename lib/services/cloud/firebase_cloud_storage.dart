import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpleproject/services/cloud/cloud_note.dart';
import 'package:simpleproject/services/cloud/cloud_storage_constants.dart';
import 'package:simpleproject/services/crud/crud_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
      notes.snapshots().map((event) => event.docs
          .map((doc) => CloudNote.fromSnapshot(doc))
          .where((note) => note.ownerUserId == ownerUserId));

  Future<void> deleteNote({required String documentId}) async{
    try {

      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNote();
    }
  }

  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNote();
    }
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    return await notes
        .where(ownerUserFieldName, isEqualTo: ownerUserId)
        .get()
        .then((value) => value.docs.map(
              (doc) {
                return CloudNote(
                    documentId: doc.id,
                    ownerUserId: doc.data()[ownerUserFieldName] as String,
                    text: doc.data()[textFieldName] as String);
              },
            ));
  }

  void createNote({required String ownerUserId}) async {
    await notes.add({ownerUserFieldName: ownerUserId, textFieldName: ''});
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
