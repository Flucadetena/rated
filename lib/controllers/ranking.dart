import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:labhouse/controllers/auth.dart';
import 'package:labhouse/models/item.dart';
import 'package:labhouse/models/ranking.dart';
import 'package:labhouse/services/firebase/references.dart';
import 'package:labhouse/services/firebase/retrieve.dart';

class RankingDetails extends GetxController {
  final Ranking ranking;
  List<RankingItem>? items;

  RankingDetails({required this.ranking});

  @override
  void onReady() {
    super.onReady();
    _getItems();
  }

  _getItems() async {
    items =
        (await FireCollection(refCollRankingItems(AuthDetails.currentUser!.uid, ranking.id), RankingItem()).data)
            .sortedByPosition;
    update();
  }
}
