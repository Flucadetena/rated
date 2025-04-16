import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labhouse/models/firebase.dart';
import 'package:labhouse/services/extensions.dart';
import 'package:labhouse/services/firebase/references.dart';

class Ranking extends FireModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String cover;
  final Timestamp updated;

  Ranking() : this.fromMap({});

  Ranking.fromMap(Map<String, Object?> data)
    : id = data['id'].as<String>(),
      name = data['name'].as<String>(),
      description = data['description'].as<String>(),
      category = data['category'].as<String>(),
      cover = data['cover'].as<String>(),
      updated = data['updated'].as<Timestamp>();

  Ranking.fromPrompt(Map<String, Object?> data)
    : id = refCollUser.doc().id,
      name = data['name'].as<String>(),
      description = data['description'].as<String>(),
      category = data['category'].as<String>(),
      cover = data['cover'].as<String>(),
      updated = Timestamp.now();

  Ranking.loader()
    : id = '',
      name = 'Loading...',
      description = 'Loading...',
      category = 'Loading...',
      cover = '⏱',
      updated = Timestamp.now();

  @override
  Map<String, dynamic> get toMap => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'cover': cover,
    'updated': updated,
  };

  @override
  Ranking toModel(Map<String, Object?> data, DocumentReference? ref) => Ranking.fromMap(data);
}

extension RankingItemExtension on List<Ranking> {
  List<Ranking> get sortedByUpdated => this..sort((a, b) => b.updated.compareTo(a.updated));
}
