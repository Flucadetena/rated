import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:labhouse/components/items/info.dart';
import 'package:labhouse/models/item.dart';
import 'package:labhouse/services/helpers.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class RakingItemScreen extends StatelessWidget {
  final RankingItem item;
  const RakingItemScreen({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image:
            item.cover.isURL
                ? DecorationImage(
                  image: NetworkImage(item.cover),
                  onError:
                      (exception, stackTrace) =>
                          crashError(exception, 'Error loading the image for ${item.name}', stack: stackTrace),
                  fit: BoxFit.cover,
                )
                : null,
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.5, 1],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            actions: [
              Text(
                '#${item.position}',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 250, bottom: 50),
            children: [
              Text(item.name, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                item.category.toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Divider(indent: 50, endIndent: 50),
              const SizedBox(height: 12),
              Text(item.description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.justify),
              const SizedBox(height: 12),

              Text(item.description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.justify),
              const SizedBox(height: 12),
              ...item.info.entries.map((entry) => ItemExtraInfo(info: entry)),
              const SizedBox(height: 32),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Remix.heart_3_line),
                    onPressed: () => item.ref!.update({'saved': Timestamp.now()}),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          item.link == null
                              ? null
                              : () async {
                                if (item.link case String url when await canLaunchUrl(Uri.parse(url))) {
                                  launchUrl(formatUrl(url), mode: LaunchMode.externalApplication);
                                }
                              },
                      child: Text('LINK'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
