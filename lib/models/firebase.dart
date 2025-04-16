import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labhouse/services/extensions.dart';

/// Basic model class for all models in the app.
/// It ensures all models have a [fromMap] and [toMap] implementation.
///
/// The [fromMap] constructor is used to create an instance with the data
/// coming from Firestore.
///
/// The [toMap] getter is used to convert the instance into a [Map] to set or
/// update the data in Firestore.
abstract class FireModel {
  FireModel();

  /// Constructor to create an instance of the model with the data
  /// coming from Firestore.
  ///
  /// Use the methods from [FirestoreMapping] extension to convert the data into the correct type.
  factory FireModel.fromMap(Map<String, Object?> data, DocumentReference? ref) => throw UnimplementedError();

  /// Converts the instance into a [Map] to set or update the data in Firestore.
  Map<String, dynamic> get toMap;

  /// This method allows as to call the [fromMap] constructor from an existing instance
  /// to create a new instance with data.
  /// This is useful when we need to reuse the same method for different types.
  /// For example when retrieving documents from Firestore. As implemented in [FireDocument] class.
  FireModel toModel(Map<String, Object?> data, DocumentReference? ref) ;
}
