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
          pinned: data['pinned'] != false,
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
  Future<String> createFolder(
    String name, {
    bool editor = false,
    bool pinned = true,
  }) async {
    final reference = await _firestore.collection('folders').add(
      <String, Object>{
        'name': name,
        'setIds': <String>[],
        'ownerId': ownerId,
        'pinned': pinned,
        'createdAt': FieldValue.serverTimestamp(),
        if (editor) 'editor': true,
      },
    );
    return reference.id;
  }

  @override
  Future<void> renameFolder(String id, String name) async {
    await _firestore.collection('folders').doc(id).update(<String, Object>{
      'name': name,
    });
  }

  @override
  Future<void> deleteFolder(String id) async {
    await _firestore.collection('folders').doc(id).delete();
  }

  @override
  Future<void> setFolderPinned(String id, bool pinned) async {
    await _firestore.collection('folders').doc(id).update(<String, Object>{
      'pinned': pinned,
    });
  }

  @override
  Future<String> save(VocabularySet set) async {
    final folderId = set.folderId;
    final setReference = _firestore.collection('sets').doc();
    final batch = _firestore.batch();
    batch.set(setReference, <String, Object>{
      ...vocabularySetDocument(set),
      'ownerId': ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (folderId != null && folderId.isNotEmpty) {
      batch.update(
        _firestore.collection('folders').doc(folderId),
        <String, Object>{
          'setIds': FieldValue.arrayUnion(<String>[setReference.id]),
        },
      );
    }
    await batch.commit();
    return setReference.id;
  }

  @override
  Future<void> addSetToFolder(String folderId, String setId) async {
    await _firestore.collection('folders').doc(folderId).update(<String, Object>{
      'setIds': FieldValue.arrayUnion(<String>[setId]),
    });
  }

  @override
  Future<void> updateWords(VocabularySet set) async {
    final id = set.id;
    if (id == null || id.isEmpty) {
      return;
    }
    await _firestore.collection('sets').doc(id).update(<String, Object>{
      'words': vocabularySetDocument(set)['words'] as Object,
    });
  }
}
