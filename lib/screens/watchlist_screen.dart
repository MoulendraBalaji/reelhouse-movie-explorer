// ENTRANCE SEQUENCE:
// 0ms: Page header and animated tab ribbon slide into view
// 200ms: Saved film cards stagger in with 60ms delay per row

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import '../models/movie.dart';
import '../providers/watchlist_provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';
import '../widgets/motion/animated_tab_indicator.dart';
import '../widgets/motion/dismiss_spring.dart';
import '../widgets/poster_image.dart';
import '../widgets/clapper_rating.dart';
import '../widgets/empty_state.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  int _activeTab = 0; // 0 = TO WATCH, 1 = WATCHED

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = context.watch<WatchlistProvider>();
    final movieProvider = context.watch<MovieProvider>();

    final allMovies = movieProvider.allMovies;
    final toWatchIds = watchlistProvider.watchlist.where((id) => !watchlistProvider.isWatched(id)).toList();
    final watchedIds = watchlistProvider.watched;

    final displayedIds = _activeTab == 0 ? toWatchIds : watchedIds;
    final displayedMovies = displayedIds.map((id) {
      try {
        return allMovies.firstWhere((m) => m.id == id);
      } catch (_) {
        return null;
      }
    }).whereType<Movie>().toList();

    return AppScaffold(
      currentNavIndex: 3,
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
                    number: '04',
                    title: 'PATRON REEL VAULT',
                  ),
                  const SizedBox(height: 24),

                  // Animated Tab Indicator
                  SizedBox(
                    width: 300,
                    child: CinemaAnimatedTabs(
                      tabs: [
                        'TO WATCH (${toWatchIds.length})',
                        'WATCHED (${watchedIds.length})',
                      ],
                      selectedIndex: _activeTab,
                      onTabSelected: (idx) => setState(() => _activeTab = idx),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Animated Switcher with Slide-Fade for Tab Transitions
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: cinemaSlideFadeTransition,
                    child: displayedMovies.isEmpty
                        ? EmptyState(
                            key: ValueKey('empty_$_activeTab'),
                            title: _activeTab == 0
                                ? 'NO UNWATCHED FILM SPOOLS'
                                : 'NO WATCHED REELS LOGGED',
                            message: _activeTab == 0
                                ? 'Browse Now Showing or Explore Archives and tear ticket stubs to store them in your vault.'
                                : 'Mark saved films as watched to compile your personal projection history.',
                            action: ElevatedButton(
                              onPressed: () => Navigator.of(context).pushNamed('/explore'),
                              child: const Text('DISCOVER FILMS'),
                            ),
                          )
                        : ListView.separated(
                            key: ValueKey('list_$_activeTab'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedMovies.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final movie = displayedMovies[index];

                              return DismissSpring(
                                itemKey: ValueKey('dismiss_${movie.id}_$_activeTab'),
                                onDismissed: () {
                                  watchlistProvider.removeFromWatchlist(movie.id);
                                },
                                onUndo: () {
                                  watchlistProvider.undoRemove();
                                },
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      '/detail',
                                      arguments: movie.id,
                                    );
                                  },
                                  child: Builder(
                                    builder: (context) {
                                      final colors = context.cinemaColors;
                                      return Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: colors.surface,
                                          border: Border.all(color: colors.borderHairline),
                                          borderRadius: CinemaTokens.borderSharp,
                                        ),
                                        child: Row(
                                          children: [
                                            // Poster thumbnail
                                            SizedBox(
                                              width: 72,
                                              height: 100,
                                              child: PosterImage(
                                                imageUrl: movie.posterUrl,
                                                title: movie.title,
                                              ),
                                            ),
                                            const SizedBox(width: 16),

                                            // Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    movie.title.toUpperCase(),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: CinemaTokens.fontDisplay,
                                                      fontSize: 20,
                                                      letterSpacing: 1.0,
                                                      color: colors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text('${movie.year}', style: CinemaText.monoMeta(color: colors.accentAmber)),
                                                      const SizedBox(width: 8),
                                                      Text('•', style: TextStyle(color: colors.textMuted)),
                                                      const SizedBox(width: 8),
                                                      Text(movie.formattedRuntime, style: CinemaText.monoMeta(color: colors.textMuted)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  ClapperRating(rating: movie.rating, size: 12),
                                                ],
                                              ),
                                            ),

                                            // Mark Watched Toggle Button
                                            IconButton(
                                              icon: Icon(
                                                watchlistProvider.isWatched(movie.id)
                                                    ? Icons.check_circle
                                                    : Icons.check_circle_outline,
                                                color: watchlistProvider.isWatched(movie.id)
                                                    ? colors.accentAmber
                                                    : colors.textMuted,
                                              ),
                                              tooltip: watchlistProvider.isWatched(movie.id)
                                                  ? 'Mark as Unwatched'
                                                  : 'Mark as Watched',
                                              onPressed: () {
                                                watchlistProvider.toggleWatched(movie.id);
                                              },
                                            ),

                                        // Delete Button
                                        IconButton(
                                          icon: Icon(Icons.delete_outline, color: colors.textMuted),
                                          tooltip: 'Remove from Watchlist',
                                          onPressed: () {
                                            watchlistProvider.removeFromWatchlist(movie.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                backgroundColor: colors.surfaceElevated,
                                                content: Text(
                                                  '${movie.title} removed from vault',
                                                  style: CinemaText.monoLabel(color: colors.textPrimary),
                                                ),
                                                action: SnackBarAction(
                                                  label: 'RESTORE',
                                                  textColor: colors.accentAmber,
                                                  onPressed: () => watchlistProvider.undoRemove(),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
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
