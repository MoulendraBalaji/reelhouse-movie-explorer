// REUSABLE WIDGET: GenreFilterBar
// Horizontal scrollable strip of uppercase mono genre filter tags.

import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'mono_tag.dart';

class GenreFilterBar extends StatelessWidget {
  final String selectedGenre;
  final ValueChanged<String> onGenreSelected;

  const GenreFilterBar({
    super.key,
    required this.selectedGenre,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: CinemaConstants.genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = CinemaConstants.genres[index];
          final isSelected = genre.toLowerCase() == selectedGenre.toLowerCase();

          return MonoTag(
            label: genre,
            isSelected: isSelected,
            onTap: () => onGenreSelected(genre),
          );
        },
      ),
    );
  }
}
