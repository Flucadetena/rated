import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labhouse/models/firebase.dart';
import 'package:labhouse/services/extensions.dart';

/// Class that represents a Firestore document.
/// Use this class to retrieve or listen to changes in a Firestore document.
/// Update or create the document data using the [upSet] method.
/// The document data is automatically converted to an instance of [T].
///
/// Example:
/// ```dart
/// final user = await FireDocument(FirebaseFirestore.instance.collection('users').doc('userId'), User()).data;
/// print('User: ${user.name}');
/// ```
class FireDocument<T extends FireModel> {
  final DocumentReference ref;
  final T type;

  ListenSource streamSource;
  GetOptions? dataOptions;

  /// Creates a new instance of [FireDocument].
  ///
  /// [ref] is the reference to the Firestore document.
  /// [type] is model to which you want the document to be casted to.
  ///
  /// There is no need to specify the [T] type when creating an instance of [FireDocument].
  /// The [Type] is inferred from the [type] parameter.
  ///
  /// For the [data] and [dataOrNull] methods:
  /// You can set the [dataOptions] to specify the [Source] and the behavior of server [Timestamps].
  /// The default value for [source] in the [dataOptions] is [Source.serverAndCache]. You can set it
  /// to [Source.server] to avoid the cache or [Source.cache] to only return the cached data.
  ///
  /// For the [stream] and [streamOrNull] methods:
  /// You can set the [streamSource] to specify the source to listen for document changes.
  /// The default value for [streamSource] is [ListenSource.defaultSource].
  /// You can set it to [ListenSource.cache] to only listen for local changes.
  FireDocument(this.ref, this.type, {this.streamSource = ListenSource.defaultSource, this.dataOptions});

  /// Converts a [DocumentSnapshot] to an instance of [T].
  T _snapAsT(DocumentSnapshot snap) => type.toModel(snap.dataAsMap, snap.reference) as T;

  /// Retrieves the document data from Firestore and returns it as an instance of [T].
  /// If the document doesn't exist it will return the default instance of [T].
  Future<T> get data => ref.get(dataOptions).then((snap) => _snapAsT(snap));

  /// Retrieves the document data from Firestore and returns it as an instance of [T].
  /// If the document doesn't exist it will return `null`.
  Future<T?> get dataOrNull => ref.get(dataOptions).then((snap) => snap.exists ? _snapAsT(snap) : null);

  /// Listens to changes in the document data and emits an instance of [T] whenever the data changes.
  /// If the document doesn't exist it will emit the default instance of [T].
  Stream<T> get stream => ref.snapshots(source: streamSource).map(_snapAsT);

  /// Listens to changes in the document data and emits an instance of [T].
  /// If the document doesn't exist it will emit `null`.
  Stream<T?> get streamOrNull => ref.snapshots(source: streamSource).map((snap) => snap.exists ? _snapAsT(snap) : null);

  /// Created or updates the document data on Firestore using the method [toMap] from the instance of [T].
  /// It uses the method [set] from Firestore with the option [SetOptions(merge: true)].
  /// Take this into consideration as it will not delete any field that is no longer present in the instance of [T]
  /// but it is still present in Firestore.
  Future<void> get upSet => ref.set(type.toMap, SetOptions(merge: true));
}

/// A class that represents a collection of documents in Firestore.
///
/// Use this class to retrieve or listen to changes in a Firestore collection.
/// The collection is automatically converted to an instance of [List<T>].
///
/// Example:
/// ```dart
/// final users = await FireCollection(FirebaseFirestore.instance.collection('users'), User()).data;
/// print('Users: ${users.map((user) => user.name).join(', ')}');
/// ```
class FireCollection<T extends FireModel> {
  Query query;
  final T instance;

  ListenSource streamSource;
  GetOptions? dataOptions;

  /// Creates a new instance of [FireCollection].
  ///
  /// The [query] parameter is the Firestore query used to retrieve the data.
  /// [instance] it is either the instance to use in the [upset] method to save or create a new document in Firestore
  /// or you can pass and empty instance of [T] to map the document coming from Firestore to an instance of [T].
  ///
  /// There is no need to specify the [T] type when creating an instance of [FireDocument].
  /// The type is inferred from the [instance] parameter.
  ///
  /// For the [data] and [dataOrNull] methods:
  /// You can set the [dataOptions] to specify the [Source] and the behavior of server [Timestamps].
  /// The default value for [source] in the [dataOptions] is [Source.serverAndCache]. You can set it
  /// to [Source.server] to avoid the cache or [Source.cache] to only return the cached data.
  ///
  /// For the [stream] and [streamOrNull] methods:
  /// You can set the [streamSource] to specify the source to listen for document changes.
  /// The default value for [streamSource] is [ListenSource.defaultSource].
  /// You can set it to [ListenSource.cache] to only listen for local changes.
  FireCollection(this.query, this.instance, {this.streamSource = ListenSource.defaultSource, this.dataOptions});

  /// Converts a [QuerySnapshot] to an instance of [List<T>].
  List<T> _snapsAsListT(QuerySnapshot<Object?> snaps) =>
      snaps.docs.map((snap) => instance.toModel(snap.dataAsMap, snap.reference) as T).toList();

  /// Retrieves the data from Firestore as a list of objects of type [T].
  /// If the collection is empty it will return an empty list.
  Future<List<T>> get data async {
    var snapshots = await query.get(dataOptions);
    return _snapsAsListT(snapshots);
  }

  /// Retrieves the data from Firestore as a list of objects of type [T],
  /// If the collection is empty it will return `null`.
  Future<List<T>?> get dataOrNull async {
    var snapshots = await query.get(dataOptions);
    return snapshots.docs.isEmpty ? null : _snapsAsListT(snapshots);
  }

  /// Retrieves the data from Firestore as a stream of lists of objects of type [T].
  /// If the collection is empty it will return an empty list.
  Stream<List<T>> get stream => query.snapshots(source: streamSource).map(_snapsAsListT);

  /// Retrieves the data from Firestore as a stream of lists of objects of type [T].
  /// If the collection is empty it will return `null`.
  Stream<List<T>?> get streamOrNull => query
      .snapshots(source: streamSource)
      .map((snapshots) => snapshots.docs.isEmpty ? null : _snapsAsListT(snapshots));
}
