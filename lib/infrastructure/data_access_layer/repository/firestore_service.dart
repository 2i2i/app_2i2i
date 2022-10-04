import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final instance = FirestoreService._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future runTransaction(Future<void> Function(Transaction) transactionCreator) {
    return firestore.runTransaction(transactionCreator);
  }

  String newDocId({required String path}) => firestore.collection(path).doc().id;

  Future<void> createData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = firestore.collection(path).doc();
    await reference.set(data);
  }

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = firestore.doc(path);
    await reference.set(data, SetOptions(merge: merge));
  }

  Future<DocumentSnapshot?> getData({required String path}) async {
    final reference = firestore.doc(path);
    return await reference.get(GetOptions(source: Source.serverAndCache)).catchError(
      (onError) {
        print(onError);
      },
    );
  }

  Future<Iterable<T>> getCollectionData<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, DocumentReference documentID) builder,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query)!;
    }
    final reference = await query.get();
    return reference.docs.map((snapshot) {
      return builder(snapshot.data(), snapshot.reference);
    });
  }

  Future<Iterable<T>> getCollectionGroupData<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, DocumentReference documentID) builder,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collectionGroup(path);
    if (queryBuilder != null) {
      query = queryBuilder(query)!;
    }
    final reference = await query.get();
    return reference.docs.map((snapshot) {
      return builder(snapshot.data(), snapshot.reference);
    });
  }

  Future<void> deleteData({
    required String path,
  }) async {
    final reference = firestore.doc(path);
    await reference.delete();
  }

  Stream<List<T>> collectionAddedStream<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>> query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query = firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query)!;
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docChanges
          .where((docChange) => docChange.type == DocumentChangeType.added)
          .map((docChange) => builder(docChange.doc.data(), docChange.doc.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>> query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query = firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query)!;
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs.map((doc) => builder(doc.data(), doc.id)).where((value) => value != null).toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<T> documentStream<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
  }) {
    final DocumentReference<Map<String, dynamic>> reference = firestore.doc(path);
    final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots = reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data(), snapshot.id));
  }

  Stream<Map<String, dynamic>> getDocumentStream<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>> query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query = firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query)!;
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs.map((doc) => builder(doc.data(), doc.id)).where((value) => value != null).toList();
      if (sort != null) {
        result.sort(sort);
      }
      return {'meetingList': result, 'docList': snapshot.docs};
    });
  }
}
