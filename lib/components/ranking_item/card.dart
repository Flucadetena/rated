import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labhouse/components/ranking_item/background.dart';
import 'package:labhouse/models/item.dart';
import 'package:labhouse/screens/item.dart';

class RankingItemCard extends StatelessWidget {
  final RankingItem item;
  final double widthFactor;
  const RankingItemCard({required this.item, this.widthFactor = 0.75, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => RakingItemScreen(item: item)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          RankingItemCardBackground(item: item, widthFactor: widthFactor),
          Container(
            height: 110,
            width: context.mediaQuery.size.width * widthFactor,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(item.name, style: Theme.of(context).textTheme.titleMedium, maxLines: 2)),
                    Text(
                      '#${item.position}',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
