import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

/// All references to Firestore collections
CollectionReference get refCollUser => _db.collection('users');
CollectionReference refCollUserRankings(String userId) =>
    refUser(userId).collection('rankings');
CollectionReference refCollRankingItems(String userId, String rankingId) =>
    refUserRanking(userId, rankingId).collection('ranking_items');

/// All references to Firestore documents
DocumentReference refUser(String userId) => refCollUser.doc(userId);
DocumentReference refUserRanking(String userId, String rankingId) =>
    refCollUserRankings(userId).doc(rankingId);
DocumentReference refRankingItem(String userId, String rankingId, String itemId) =>
    refCollRankingItems(userId, rankingId).doc(itemId);

Query refCollGroupRankingItems(String userId) => _db.collectionGroup('ranking_items').where('userId', isEqualTo: userId);
