import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labhouse/controllers/auth.dart';
import 'package:labhouse/models/firebase.dart';
import 'package:labhouse/services/extensions.dart';
import 'package:labhouse/services/firebase/references.dart';

class RankingItem extends FireModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String cover;
  final int position;
  Timestamp? saved;
  final String userId;
  String? link;
  Map<String, String> info;

  //! Only used in the app not saved to Firestore
  DocumentReference? ref;

  RankingItem() : this.fromMap({}, null);

  RankingItem.fromMap(Map<String, Object?> data, this.ref)
    : id = data['id'].as<String>(),
      name = data['name'].as<String>(),
      description = data['description'].as<String>(),
      category = data['category'].as<String>(),
      cover = data['cover'].as<String>(),
      position = data['position'].as<int>(),
      saved = data['saved'].asOrNull<Timestamp>(),
      userId = data['userId'].as<String>(),
      link = data['link'].asOrNull<String>(),
      info = RankingItem._getDynamicInfo(data['info'] as Map<String, Object?>? ?? {});

  RankingItem.fromPrompt(Map<String, Object?> data)
    : id = refCollUser.doc().id,
      name = data['name'].as<String>(),
      description = data['description'].as<String>(),
      category = data['category'].as<String>(),
      cover = Uri.decodeFull(data['cover'].as<String>()),
      position = data['position'].as<int>(),
      userId = AuthDetails.currentUser!.uid,
      link = data['link'].asOrNull<String>(),
      info = RankingItem._dynamicInfoFromList(data['info']);

  RankingItem.loader()
    : id = '',
      name = 'Loading...',
      description = 'Loading...',
      category = 'Loading...',
      cover = 'Loading...',
      position = 0,
      saved = Timestamp.now(),
      userId = '',
      info = {};

  @override
  Map<String, dynamic> get toMap => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'cover': cover,
    'position': position,
    'saved': saved,
    'userId': userId,
    'link': link,
    'info': info,
  };

  @override
  RankingItem toModel(Map<String, Object?> data, DocumentReference? ref) => RankingItem.fromMap(data, ref);

  static Map<String, String> _dynamicInfoFromList(Object? data) {
    final res =
        ((data as List?) ?? [])
            .map(
              (e) => MapEntry<String, String>((e['key'] as Object?).as<String>(), (e['value'] as Object?).as<String>()),
            )
            .toList();

    return Map.fromEntries(res);
  }

  static Map<String, String> _getDynamicInfo(Map<String, Object?> data) {
    final dynamicFields = <String, String>{};

    for (var key in data.keys) {
      dynamicFields[key] = data[key].as<String>();
    }

    return dynamicFields;
  }
}

extension RankingItemExtension on List<RankingItem> {
  List<RankingItem> get sortedByPosition => this..sort((a, b) => a.position.compareTo(b.position));
  List<RankingItem> get sortedByName => this..sort((a, b) => a.name.compareTo(b.name));
}
