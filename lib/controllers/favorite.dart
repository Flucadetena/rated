import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:labhouse/controllers/auth.dart';
import 'package:labhouse/models/item.dart';
import 'package:labhouse/services/firebase/references.dart';
import 'package:labhouse/services/firebase/retrieve.dart';

class FavoritesDetails extends GetxController {
  List<RankingItem>? items;

  @override
  void onReady() {
    super.onReady();
    _getItems();
  }

  _getItems() async {
    items =
        (await FireCollection(refCollGroupRankingItems(AuthDetails.currentUser!.uid).where('saved', isNull: false), RankingItem()).data)
            .sortedByPosition;
    update();
  }
}
