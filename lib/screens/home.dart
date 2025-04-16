import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labhouse/components/home/input.dart';
import 'package:labhouse/components/home/rankings.dart';
import 'package:labhouse/components/home/top.dart';
import 'package:labhouse/controllers/auth.dart';
import 'package:labhouse/screens/liked.dart';
import 'package:remixicon/remixicon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RATED',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w900,
            fontFamily: GoogleFonts.workSans().fontFamily,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        actions: [
          IconButton(icon: Icon(Remix.heart_3_line), onPressed: () => Get.to(() => const FavoritesScreen())),
          const SizedBox(width: 8),
          GetBuilder<AuthDetails>(
            builder:
                (controller) => CircleAvatar(
                  backgroundImage:
                      (controller.user?.photoURL?.isNotEmpty ?? false)
                          ? NetworkImage(controller.user!.photoURL!)
                          : null,
                  child: Text(controller.user?.displayName ?? 'R'),
                ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 150),
            children: [
              _SectionTitle(title: 'Top choices #1'),
              TopChoicesList(),
              _SectionTitle(title: 'Rankings For you'),
              RankingsList(),
            ],
          ),
          Positioned(bottom: 50, left: 16, child: GenerateRankingInput()),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 32, bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
