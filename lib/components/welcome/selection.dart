import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labhouse/components/welcome/categories.dart';

class WelcomeSelection extends StatelessWidget {
  const WelcomeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        const SizedBox(height: 32),
        Text(
          'RATED',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w900,
            fontFamily: GoogleFonts.workSans().fontFamily,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Text(
          'Get the Top 10 Movies, Books, TV Shows, and Games,... anything you can imagine with the power of AI.\n\nLets start by creating a couple with the categories you love.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        CategoriesAnimatedList(),
        CategoriesAnimatedList(reversed: true),
        CategoriesAnimatedList(),
        CategoriesAnimatedList(reversed: true),
        const SizedBox(height: 50),
      ],
    );
  }
}
