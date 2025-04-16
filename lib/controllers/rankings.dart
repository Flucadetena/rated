import 'dart:async';

import 'package:get/get.dart';
import 'package:labhouse/controllers/auth.dart';
import 'package:labhouse/models/item.dart';
import 'package:labhouse/models/ranking.dart';
import 'package:labhouse/services/firebase/references.dart';
import 'package:labhouse/services/firebase/retrieve.dart';

class RankingsDetails extends GetxController {
  List<Ranking>? rankings;
  List<RankingItem>? top10;

  String? _authId;
  StreamSubscription? _subAuth;
  StreamSubscription? _subRankings;
  StreamSubscription? _subTop10;

  @override
  void onInit() {
    super.onInit();

    _subAuth = Get.find<AuthDetails>().userChanges.listen((auth) {
      if (auth != null && _authId != auth.uid) {
        _listenToRankings();
        _listenToTop10();
      }
      _authId = auth?.uid;
    });
  }

  @override
  void onClose() {
    super.onClose();
    _subRankings?.cancel();
    _subAuth?.cancel();
  }

  _listenToRankings() {
    _subRankings?.cancel();
    _subRankings = FireCollection(
      refCollUserRankings(AuthDetails.currentUser!.uid),
      Ranking(),
    ).stream.listen((newRankings) {
      rankings = newRankings.sortedByUpdated;
      update();
    });
  }

  _listenToTop10() {
    _subTop10?.cancel();
    _subTop10 = FireCollection(
      refCollGroupRankingItems(AuthDetails.currentUser!.uid).where('position', isEqualTo: 1),
      RankingItem(),
    ).stream.listen((newItems) {
      top10 = newItems.sortedByName;
      update();
    });
  }
}
