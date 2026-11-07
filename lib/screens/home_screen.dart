// ENTRANCE SEQUENCE:
// 0ms: ProjectorBeam & ambient particles fade in behind hero
// 150ms: HeroCarouselKenBurns starts Ken Burns pan/zoom and title reveals
// 350ms: MarqueeTicker ribbon rolls across projection screen
// 550ms: Section 01 Trending Dispatches staggered horizontal list rolls in
// 750ms: Section 02 Top Rated Reels staggered horizontal list rolls in
// 950ms: Section 03 Coming Soon Vault horizontal list reveals

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../theme/tokens.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';
import '../widgets/ticket_stub_card.dart';
import '../widgets/motion/tilt_poster_card.dart';
import '../widgets/motion/hero_carousel_ken_burns.dart';
import '../widgets/motion/projector_beam_particles.dart';
import '../widgets/motion/marquee_ticker.dart';
import '../widgets/motion/scroll_reveal_stagger.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/motion/film_leader_skeleton.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDetail(BuildContext context, Movie movie) {
    Navigator.of(context).pushNamed(
      '/detail',
      arguments: movie.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();

    if (movieProvider.isLoading && movieProvider.allMovies.isEmpty) {
      return const AppScaffold(
        currentNavIndex: 0,
        body: Center(
          child: FilmLeaderSkeleton(width: 320, height: 220),
        ),
      );
    }

    if (movieProvider.hasError && movieProvider.allMovies.isEmpty) {
      return AppScaffold(
        currentNavIndex: 0,
        body: ErrorState(
          title: 'THE REEL SNAPPED',
          message: movieProvider.errorMessage ?? 'Unable to spool films from projection booth.',
          onRetry: () => movieProvider.retry(),
        ),
      );
    }

    final nowShowing = movieProvider.nowShowing.isNotEmpty
        ? movieProvider.nowShowing
        : movieProvider.allMovies.take(5).toList();

    final trending = movieProvider.trending.isNotEmpty
        ? movieProvider.trending
        : movieProvider.allMovies.take(8).toList();

    final topRated = movieProvider.topRated.isNotEmpty
        ? movieProvider.topRated
        : movieProvider.allMovies.skip(4).take(8).toList();

    final comingSoon = movieProvider.comingSoon.isNotEmpty
        ? movieProvider.comingSoon
        : movieProvider.allMovies.skip(8).take(8).toList();

    final marqueeItems = movieProvider.allMovies
        .map((m) => '${m.title} (${m.rating.toStringAsFixed(1)})')
        .toList();

    return AppScaffold(
      currentNavIndex: 0,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero "NOW SHOWING" Section with Ken Burns & Projector Beam Particles
            Stack(
              children: [
                const Positioned.fill(
                  child: IgnorePointer(
                    child: ProjectorBeamParticles(height: 520),
                  ),
                ),
                HeroCarouselKenBurns(
                  movies: nowShowing,
                  onSelectMovie: (movie) => _openDetail(context, movie),
                ),
              ],
            ),

            // Continuous Marquee Ticker Strip
            MarqueeTicker(items: marqueeItems),

            const SizedBox(height: 36),

            // Main Content Body constrained to desktop max width
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: CinemaTokens.maxContentWidth),
                child: Padding(
                  padding: Responsive.getPagePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 01: Trending Dispatches
                      SectionHeader(
                        number: '01',
                        title: 'TRENDING DISPATCHES',
                        actionLabel: 'EXPLORE ALL',
                        onAction: () => Navigator.of(context).pushNamed('/explore'),
                        delay: const Duration(milliseconds: 200),
                      ),
                      const SizedBox(height: 20),
                      _buildHorizontalReelList(context, trending, 0),

                      const SizedBox(height: 52),

                      // Section 02: Top Rated Masterpieces
                      SectionHeader(
                        number: '02',
                        title: 'TOP RATED MASTERPIECES',
                        actionLabel: 'VIEW ARCHIVE',
                        onAction: () => Navigator.of(context).pushNamed('/explore'),
                        delay: const Duration(milliseconds: 350),
                      ),
                      const SizedBox(height: 20),
                      _buildHorizontalReelList(context, topRated, 4),

                      const SizedBox(height: 52),

                      // Section 03: Coming Soon Vault
                      SectionHeader(
                        number: '03',
                        title: 'UPCOMING PROJECTION SCHEDULE',
                        delay: const Duration(milliseconds: 500),
                      ),
                      const SizedBox(height: 20),
                      _buildHorizontalReelList(context, comingSoon, 8),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalReelList(BuildContext context, List<Movie> list, int baseIndex) {
    if (list.isEmpty) {
      return const EmptyState(message: 'No movie reels spooled in this category.');
    }

    return SizedBox(
      height: 360,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final movie = list[index];

          return ScrollRevealStagger(
            index: index,
            child: SizedBox(
              width: 220,
              height: 360,
              child: TiltPosterCard(
                onTap: () => _openDetail(context, movie),
                child: TicketStubCard(
                  movie: movie,
                  onTap: () => _openDetail(context, movie),
                  width: 220,
                  height: 360,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
