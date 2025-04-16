import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labhouse/controllers/rankings.dart';
import 'package:labhouse/models/ranking.dart';
import 'package:labhouse/screens/ranking.dart';
import 'package:labhouse/services/theme.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RankingsList extends StatelessWidget {
  const RankingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RankingsDetails>(
      builder:
          (details) => ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: details.rankings?.length ?? 10,
            itemBuilder: (context, index) {
              final ranking = details.rankings?[index] ?? Ranking.loader();

              return Skeletonizer(
                enabled: details.rankings == null,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => Get.to(() => RankingScreen(ranking: ranking)),
                    titleAlignment: ListTileTitleAlignment.top,
                    tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    titleTextStyle: Theme.of(context).textTheme.titleSmall,
                    subtitleTextStyle: Theme.of(context).textTheme.bodySmall,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(themeBorderRadius)),
                    title: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(ranking.name, maxLines: 2)),
                    subtitle: Text(ranking.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: Text(
                          ranking.cover,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
