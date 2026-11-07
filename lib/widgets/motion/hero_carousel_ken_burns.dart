// ANIMATION: explicit (AnimationController + Ken Burns Zoom/Pan + Masked Slide-up + Parallax PageView)
// HeroCarouselKenBurns: Cinematic hero section with slow Ken Burns pan/zoom, masked title reveal,
// film-burn dissolve between slides, and animated progress bar.

import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';
import '../../theme/text_styles.dart';
import '../../models/movie.dart';
import '../../core/image_helper.dart';
import '../mono_tag.dart';
import '../clapper_rating.dart';

class HeroCarouselKenBurns extends StatefulWidget {
  final List<Movie> movies;
  final ValueChanged<Movie> onSelectMovie;

  const HeroCarouselKenBurns({
    super.key,
    required this.movies,
    required this.onSelectMovie,
  });

  @override
  State<HeroCarouselKenBurns> createState() => _HeroCarouselKenBurnsState();
}

class _HeroCarouselKenBurnsState extends State<HeroCarouselKenBurns>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _kenBurnsController;
  late final AnimationController _progressController;
  late final AnimationController _titleRevealController;

  int _currentIndex = 0;
  Timer? _autoAdvanceTimer;
  double _pageScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _pageScrollOffset = _pageController.page ?? 0.0;
        });
      }
    });

    // Ken Burns slow zoom and subtle pan (8 seconds per cycle)
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat(reverse: true);

    // Progress bar for auto-advance (6 seconds)
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    // Title reveal animation (masked slide-up & letter spacing tightening)
    _titleRevealController = AnimationController(
      vsync: this,
      duration: CinemaMotion.slow,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _advanceToNextSlide();
      }
    });

    _startSlideShow();
  }

  void _startSlideShow() {
    _progressController.reset();
    _progressController.forward();
    _titleRevealController.forward(from: 0.0);
  }

  void _advanceToNextSlide() {
    if (!mounted || widget.movies.isEmpty) return;
    final next = (_currentIndex + 1) % widget.movies.length;
    _pageController.animateToPage(
      next,
      duration: CinemaMotion.base,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    _kenBurnsController.dispose();
    _progressController.dispose();
    _titleRevealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    final isReduced = CinemaMotion.isReducedMotion(context);

    return RepaintBoundary(
      child: Container(
        height: 520,
        color: CinemaTokens.celluloidBlack,
        child: Stack(
          children: [
            // PageView of Film Backdrops with Ken Burns & Parallax
            PageView.builder(
              controller: _pageController,
              itemCount: widget.movies.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _startSlideShow();
              },
              itemBuilder: (context, index) {
                final movie = widget.movies[index];
                // Parallax offset relative to current page
                final pageDiff = index - _pageScrollOffset;
                final parallaxX = pageDiff * 60.0;

                return AnimatedBuilder(
                  animation: _kenBurnsController,
                  builder: (context, _) {
                    final zoom = isReduced
                        ? 1.05
                        : 1.05 + (_kenBurnsController.value * 0.10); // 1.05 to 1.15
                    final panY = isReduced
                        ? 0.0
                        : (_kenBurnsController.value - 0.5) * 16.0;

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Backdrop Image with Ken Burns Matrix transform
                        Transform.translate(
                          offset: Offset(parallaxX, panY),
                          child: Transform.scale(
                            scale: zoom,
                            child: Image.network(
                              ImageUrlHelper.format(
                                movie.backdropUrl.isNotEmpty
                                    ? movie.backdropUrl
                                    : movie.posterUrl,
                              ),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                color: CinemaTokens.boothBrown,
                                child: const Center(
                                  child: Icon(Icons.movie, size: 64, color: CinemaTokens.ash),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Atmospheric Celluloid Gradients (Vignette & Deep Bottom Shadow)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                CinemaTokens.celluloidBlack.withValues(alpha: 0.3),
                                CinemaTokens.celluloidBlack.withValues(alpha: 0.7),
                                CinemaTokens.celluloidBlack,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 1.1,
                              colors: [
                                Colors.transparent,
                                CinemaTokens.celluloidBlack.withValues(alpha: 0.65),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // Content Overlay (Title masked slide-up, tags, clapper rating, CTA)
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: CinemaTokens.maxContentWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: AnimatedBuilder(
                      animation: _titleRevealController,
                      builder: (context, _) {
                        final currentMovie = widget.movies[_currentIndex];
                        final revealProgress = isReduced ? 1.0 : _titleRevealController.value;
                        final translateY = (1.0 - revealProgress) * 36.0;
                        final letterSpacing = 2.0 + (1.0 - revealProgress) * 4.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // "NOW SHOWING" Reel Flag
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  color: CinemaTokens.projectorAmber,
                                  child: Text(
                                    'NOW SHOWING',
                                    style: CinemaText.monoBadge(color: CinemaTokens.celluloidBlack),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '35MM PROJECTION • HALL A',
                                  style: CinemaText.monoLabel(color: CinemaTokens.ash),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Masked Slide-Up Movie Title
                            ClipRect(
                              child: Transform.translate(
                                offset: Offset(0, translateY),
                                child: Text(
                                  currentMovie.title.toUpperCase(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: CinemaTokens.fontDisplay,
                                    fontSize: 48.0,
                                    letterSpacing: letterSpacing,
                                    height: 0.95,
                                    color: CinemaTokens.bone,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xDD000000),
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Metadata row: Year, Runtime, Genres, Clapper rating
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                Text('${currentMovie.year}', style: CinemaText.monoMeta(color: CinemaTokens.projectorAmber)),
                                const Text('•', style: TextStyle(color: CinemaTokens.ash)),
                                Text(currentMovie.formattedRuntime, style: CinemaText.monoMeta(color: CinemaTokens.bone)),
                                const Text('•', style: TextStyle(color: CinemaTokens.ash)),
                                ClapperRating(rating: currentMovie.rating, size: 16),
                                for (final genre in currentMovie.genres.take(2))
                                  MonoTag(label: genre),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Action buttons
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => widget.onSelectMovie(currentMovie),
                                  icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                                  label: const Text('EXPLORE FILM REEL'),
                                ),
                                const SizedBox(width: 16),
                                OutlinedButton.icon(
                                  onPressed: () => widget.onSelectMovie(currentMovie),
                                  icon: const Icon(Icons.info_outline, size: 18),
                                  label: const Text('DETAILS'),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Carousel Slide Dots & Progress Bar Indicator
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, _) {
                  return Column(
                    children: [
                      // Thin amber progress line for auto-advance
                      LinearProgressIndicator(
                        value: isReduced ? 0.0 : _progressController.value,
                        backgroundColor: CinemaTokens.hairline.withValues(alpha: 0.4),
                        valueColor: const AlwaysStoppedAnimation<Color>(CinemaTokens.projectorAmber),
                        minHeight: 2.0,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
