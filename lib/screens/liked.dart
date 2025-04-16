import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labhouse/components/ranking_item/card.dart';
import 'package:labhouse/controllers/favorite.dart';
import 'package:labhouse/models/item.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavoritesDetails>(
      init: FavoritesDetails(),
      builder: (details) {
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 50),
            children: [
              const SizedBox(height: 24),
              Text('Your Favorites', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ListView.separated(
                itemCount: details.items?.length ?? 10,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder:
                    (context, idx) =>
                        RankingItemCard(item: details.items?[idx] ?? RankingItem.loader(), widthFactor: 1),
              ),
            ],
          ),
        );
      },
    );
  }
}
