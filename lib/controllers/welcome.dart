import 'dart:async';

import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_utils/src/extensions/num_extensions.dart';
import 'package:labhouse/services/ai.dart';

class WelcomeDetails extends GetxController {
  bool loadingRankings = false;

  List<String> selected = [];
  List<String> categories = [];

  Timer? _timer;
  final List<String> _texts = [
    'Searching Top 10...',
    'Preparing the results',
    'Looking for additional information',
    'Almost there...',
  ];
  int _index = 0;
  String get loadingText => _texts[_index];

  List<String> original = [
    'movies',
    'books',
    'tv shows',
    'games',
    'podcasts',
    'comics',
    'news',
    'food',
    'music',
    'sports',
    'art',
    'travel',
    'fashion',
    'technology',
    'health',
    'fitness',
    'photography',
    'business',
    'finance',
    'education',
    'pets',
    'hobbies',
    'crafts',
    'home improvement',
    'gardening',
    'self-help',
    'personal development',
    'spirituality',
    'religion',
    'philosophy',
    'history',
    'politics',
  ];

  categorySelected(String category) {
    if (selected.contains(category)) {
      selected.remove(category);
    } else {
      selected.add(category);
    }
    if (selected.length == 4) {
      _loadRankings();
    }
    update();
  }

  _loadRankings() async {
    loadingRankings = true;
    update();
    _changeLoadingText();
    final promises = <Future<bool>>[];
    for (var category in selected) {
      promises.add(generateRanking('Create for this category: $category'));
    }
    final res = await Future.wait(promises);

    if (res.every((r) => !r)) {
      _timer?.cancel();
      selected.clear();
      loadingRankings = false;
      _index = 0;
      update();
    }
  }

  _changeLoadingText() {
    _timer?.cancel();
    _timer = Timer.periodic(8.seconds, (_) {
      if (_index == _texts.length - 1) {
        _timer?.cancel();
        return;
      }
      _index++;
      update();
    });
  }
}
