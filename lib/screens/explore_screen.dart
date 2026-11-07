// ENTRANCE SEQUENCE:
// 0ms: Page heading and filter options slide in from top
// 200ms: Genre filter chips and year slider fade in
// 350ms: Responsive poster grid staggers in with 60ms stagger per item

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';
import '../widgets/genre_filter_bar.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/ticket_stub_card.dart';
import '../widgets/motion/tilt_poster_card.dart';
import '../widgets/motion/reel_cursor.dart';
import '../widgets/empty_state.dart';

enum MovieSortOption { ratingDesc, yearDesc, titleAsc }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedGenre = 'ALL';
  MovieSortOption _sortOption = MovieSortOption.ratingDesc;
  RangeValues _yearRange = const RangeValues(1920, 2025);

  void _openDetail(BuildContext context, Movie movie) {
    Navigator.of(context).pushNamed(
      '/detail',
      arguments: movie.id,
    );
  }

  List<Movie> _filterAndSort(List<Movie> all) {
    var filtered = all.where((m) {
      final matchesGenre = _selectedGenre == 'ALL' ||
          m.genres.any((g) => g.toLowerCase() == _selectedGenre.toLowerCase());
      final matchesYear = m.year >= _yearRange.start && m.year <= _yearRange.end;
      return matchesGenre && matchesYear;
    }).toList();

    switch (_sortOption) {
      case MovieSortOption.ratingDesc:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case MovieSortOption.yearDesc:
        filtered.sort((a, b) => b.year.compareTo(a.year));
        break;
      case MovieSortOption.titleAsc:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final allMovies = movieProvider.allMovies;
    final displayedMovies = _filterAndSort(allMovies);

    return AppScaffold(
      currentNavIndex: 1,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: CinemaTokens.maxContentWidth),
            child: Padding(
              padding: Responsive.getPagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    number: '02',
                    title: 'EXPLORE CINEMA ARCHIVES',
                  ),
                  const SizedBox(height: 20),

                  // Genre Filter Bar
                  GenreFilterBar(
                    selectedGenre: _selectedGenre,
                    onGenreSelected: (genre) {
                      setState(() {
                        _selectedGenre = genre;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Secondary Filter Row: Sort by dropdown + Year range slider
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: [
                      // Sort Dropdown
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('SORT BY:', style: CinemaText.monoLabel(color: CinemaTokens.ash)),
                          const SizedBox(width: 8),
                          DropdownButton<MovieSortOption>(
                            value: _sortOption,
                            dropdownColor: CinemaTokens.boothBrown,
                            underline: Container(height: 1, color: CinemaTokens.projectorAmber),
                            style: CinemaText.monoMeta(color: CinemaTokens.projectorAmber),
                            items: const [
                              DropdownMenuItem(
                                value: MovieSortOption.ratingDesc,
                                child: Text('HIGHEST RATED'),
                              ),
                              DropdownMenuItem(
                                value: MovieSortOption.yearDesc,
                                child: Text('NEWEST TO OLDEST'),
                              ),
                              DropdownMenuItem(
                                value: MovieSortOption.titleAsc,
                                child: Text('FILM TITLE (A-Z)'),
                              ),
                            ],
                            onChanged: (opt) {
                              if (opt != null) {
                                setState(() => _sortOption = opt);
                              }
                            },
                          ),
                        ],
                      ),

                      // Year Range Slider
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ERA: ${_yearRange.start.toInt()} – ${_yearRange.end.toInt()}',
                            style: CinemaText.monoLabel(color: CinemaTokens.ash),
                          ),
                          SizedBox(
                            width: 200,
                            child: RangeSlider(
                              values: _yearRange,
                              min: 1920,
                              max: 2025,
                              divisions: 21,
                              labels: RangeLabels(
                                '${_yearRange.start.toInt()}',
                                '${_yearRange.end.toInt()}',
                              ),
                              onChanged: (vals) => setState(() => _yearRange = vals),
                            ),
                          ),
                        ],
                      ),

                      // Result count badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: CinemaTokens.boothBrown,
                          border: Border.all(color: CinemaTokens.hairline),
                          borderRadius: CinemaTokens.borderSharp,
                        ),
                        child: Text(
                          '${displayedMovies.length} REELS FOUND',
                          style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Animated Grid
                  if (displayedMovies.isEmpty)
                    const EmptyState(
                      title: 'NO REELS MATCH CRITERIA',
                      message: 'Adjust your genre filters or release era to discover archived reels.',
                    )
                  else
                    ResponsiveGrid(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedMovies.length,
                      itemBuilder: (context, index) {
                        final movie = displayedMovies[index];

                        return MouseRegion(
                          onEnter: (_) => ReelCursorScope.setMode(context, CursorMode.view),
                          onExit: (_) => ReelCursorScope.setMode(context, CursorMode.normal),
                          child: TiltPosterCard(
                            onTap: () => _openDetail(context, movie),
                            child: TicketStubCard(movie: movie),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
