import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labhouse/components/ranking_item/card.dart';
import 'package:labhouse/controllers/ranking.dart';
import 'package:labhouse/models/item.dart';
import 'package:labhouse/models/ranking.dart';
import 'package:labhouse/services/extensions.dart';

class RankingScreen extends StatelessWidget {
  final Ranking ranking;
  const RankingScreen({required this.ranking, super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RankingDetails>(
      init: RankingDetails(ranking: ranking),
      builder: (details) {
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 50),
            children: [
              const SizedBox(height: 24),
              Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(ranking.name, style: Theme.of(context).textTheme.headlineSmall)),
                  Column(
                    children: [
                      Text(
                        'Updated',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                      Text(
                        ranking.updated.toDate().ddMMM,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(ranking.description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Divider(endIndent: 70),
              const SizedBox(height: 12),
              Text('Top 10', style: Theme.of(context).textTheme.headlineMedium),
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
