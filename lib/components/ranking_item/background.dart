import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labhouse/models/item.dart';
import 'package:labhouse/services/theme.dart';

class RankingItemCardBackground extends StatelessWidget {
  final RankingItem item;
  final double widthFactor;
  const RankingItemCardBackground({required this.item, required this.widthFactor, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(themeBorderRadius),
      child: Container(
        height: 110,
        width: context.mediaQuery.size.width * widthFactor,
        foregroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.5),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.6, 0.9],
          ),
        ),
        child:
            item.cover.isURL
                ? Align(
                  alignment: Alignment.centerRight,
                  child: Image(
                    image: NetworkImage(item.cover),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    width: context.mediaQuery.size.width * 0.4,
                  ),
                )
                : null,
      ),
    );
  }
}
