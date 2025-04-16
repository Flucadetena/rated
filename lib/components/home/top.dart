import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labhouse/components/ranking_item/card.dart';
import 'package:labhouse/controllers/rankings.dart';
import 'package:labhouse/models/item.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TopChoicesList extends StatelessWidget {
  const TopChoicesList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RankingsDetails>(
      builder:
          (details) => SizedBox(
            height: 132,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: details.top10?.length ?? 10,
              itemBuilder: (context, index) {
                final item = details.top10?[index] ?? RankingItem.loader();

                return Skeletonizer(
                  enabled: details.top10 == null,
                  child: Padding(padding: const EdgeInsets.only(right: 12), child: RankingItemCard(item: item)),
                );
              },
            ),
          ),
    );
  }
}
