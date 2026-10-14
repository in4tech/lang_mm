import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lang/library/vocabulary_library.dart';
import 'package:lang/library/vocabulary_set.dart';

class FirestoreVocabularySetStore implements VocabularySetStore {
  FirestoreVocabularySetStore({
    required this.ownerId,
    String? readOwnerId,
    FirebaseFirestore? firestore,
  }) : readOwnerId = readOwnerId ?? ownerId,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final String ownerId;
  final String readOwnerId;
  final FirebaseFirestore _firestore;

  Future<VocabularyLibrary> loadLibrary() async {
    final folderQuery = await _firestore
        .collection('folders')
        .where('ownerId', isEqualTo: readOwnerId)
        .get();
    final setQuery = await _firestore
        .collection('sets')
        .where('ownerId', isEqualTo: readOwnerId)
        .get();
    final folders = <CloudFolderRecord>[];
    for (final document in folderQuery.docs) {
      final data = document.data();
      final name = data['name'];
      final setIdsValue = data['setIds'];
      if (name is! String || setIdsValue is! List) {
        continue;
      }
      final createdAt = data['createdAt'];
      folders.add(
        CloudFolderRecord(
          id: document.id,
          name: name,
          setIds: <String>[
            for (final id in setIdsValue)
              if (id is String) id,
          ],
          editor: data['editor'] == true,
          createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
        ),
      );
    }
    final sets = <CloudSetRecord>[];
    for (final document in setQuery.docs) {
      final parsed = vocabularySetFromDocument(document.data());
      if (parsed == null) {
        continue;
      }
      sets.add(CloudSetRecord(id: document.id, set: parsed));
    }
    return libraryFromCloud(folders: folders, sets: sets);
  }

  @override
  Future<String> createFolder(String name, {bool editor = false}) async {
    final reference = await _firestore.collection('folders').add(
      <String, Object>{
        'name': name,
        'setIds': <String>[],
        'ownerId': ownerId,
        'createdAt': FieldValue.serverTimestamp(),
        if (editor) 'editor': true,
      },
    );
    return reference.id;
  }

  @override
  Future<void> save(VocabularySet set) async {
    final folderId = set.folderId;
    if (folderId == null || folderId.isEmpty) {
      throw StateError('A flashcard set needs a folder id');
    }
    final setReference = _firestore.collection('sets').doc();
    final batch = _firestore.batch();
    batch.set(setReference, <String, Object>{
      ...vocabularySetDocument(set),
      'ownerId': ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(
      _firestore.collection('folders').doc(folderId),
      <String, Object>{
        'setIds': FieldValue.arrayUnion(<String>[setReference.id]),
      },
    );
    await batch.commit();
  }
}
