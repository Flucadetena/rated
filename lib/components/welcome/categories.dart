import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:labhouse/controllers/welcome.dart';

class CategoriesAnimatedList extends StatefulWidget {
  final bool reversed;
  const CategoriesAnimatedList({this.reversed = false, super.key});

  @override
  State<CategoriesAnimatedList> createState() => _CategoriesAnimatedListState();
}

class _CategoriesAnimatedListState extends State<CategoriesAnimatedList> {
  final ScrollController _controller = ScrollController();

  /// [_listAppended] ensures [sponsors] is only appended once per cycle.
  bool _listAppended = false;
  Timer? animation;

  @override
  void initState() {
    super.initState();
    _setLists();
    listenToScroll();
  }

  @override
  void dispose() {
    _controller.dispose();
    animation?.cancel();
    super.dispose();
  }

  _setLists() {
    final WelcomeDetails(:categories, :original) = Get.find<WelcomeDetails>();
    if (categories.length < 100) {
      categories.addAll(original.shuffled());
      _setLists();
    } else {
      if (mounted) {
        setState(() {});
        _startScroll();
      }
    }
  }

  listenToScroll() {
    final WelcomeDetails(:categories, :original) = Get.find<WelcomeDetails>();

    /// The [_controller] will notify [_list] to be appended when the animation is near completion.
    _controller.addListener(() {
      if (_controller.position.pixels > _controller.position.maxScrollExtent * 0.7 &&
          _controller.position.userScrollDirection == ScrollDirection.forward) {
        if (_listAppended == false) {
          categories.addAll(original.shuffled());
          _listAppended = true;
          if (mounted) setState(() {});
        }
      }

      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _listAppended = false;
      }
    });
  }

  void _startScroll() async {
    final WelcomeDetails(:categories) = Get.find<WelcomeDetails>();

    animation?.cancel();
    animation = Timer(1.seconds, () {
      if (!mounted) return;
      double seconds = categories.length * 3;
      double totalExt = _controller.position.maxScrollExtent;
      double duration = ((totalExt - _controller.position.pixels) / totalExt) * seconds;
      duration = duration < 0 ? seconds : duration;

      // Verify that the duration is finite before using it
      if (duration.isFinite) {
        _controller.animateTo(_controller.position.maxScrollExtent, duration: duration.seconds, curve: Curves.linear);
      } else {
        // Handle the invalid duration case by setting a default duration
        _controller.animateTo(_controller.position.maxScrollExtent, duration: 1.seconds, curve: Curves.linear);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WelcomeDetails>(
      builder: (details) {
        return GestureDetector(
          onTapUp: (details) {
            _startScroll();
          },
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.idle) _startScroll();
              return false;
            },
            child: SizedBox(
              height: 60,
              child: ListView(
                shrinkWrap: true,
                controller: _controller,
                scrollDirection: Axis.horizontal,
                reverse: widget.reversed,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                cacheExtent: (details.categories.length / 2) * MediaQuery.of(context).size.width,
                children:
                    details.categories
                        .mapIndexed(
                          (idx, cat) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            alignment: Alignment.center,
                            child: OutlinedButton(
                              key: Key('${cat}_$idx'),
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    details.selected.contains(cat) ? Theme.of(context).colorScheme.primary : null,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: Text(cat),
                              onPressed: () => details.categorySelected(cat),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
