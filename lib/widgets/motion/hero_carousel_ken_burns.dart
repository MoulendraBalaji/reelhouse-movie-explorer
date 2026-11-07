// ANIMATION: explicit (AnimationController + Ken Burns Zoom/Pan + Masked Slide-up + Parallax PageView)
// HeroCarouselKenBurns: Cinematic hero section with slow Ken Burns pan/zoom, masked title reveal,
// film-burn dissolve between slides, and animated progress bar.

import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

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
    final colors = context.cinemaColors;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;
    final heroHeight = isMobile ? 440.0 : 520.0;
    final titleFontSize = isMobile ? 30.0 : (isTablet ? 38.0 : 48.0);

    return RepaintBoundary(
      child: Container(
        height: heroHeight,
        color: colors.bg,
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

                return AnimatedBuilder(
                  animation: Listenable.merge([_kenBurnsController, _pageController]),
                  builder: (context, _) {
                    final pageOffset = _pageController.hasClients && _pageController.page != null
                        ? _pageController.page!
                        : _currentIndex.toDouble();
                    final pageDiff = index - pageOffset;
                    final parallaxX = pageDiff * 50.0;

                    final zoom = isReduced
                        ? 1.04
                        : 1.04 + (_kenBurnsController.value * 0.08);
                    final panY = isReduced
                        ? 0.0
                        : (_kenBurnsController.value - 0.5) * 12.0;

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
                                color: colors.surface,
                                child: Center(
                                  child: Icon(Icons.movie, size: 64, color: colors.textMuted),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Atmospheric Gradients: top dark tint, bottom blend into background
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.35),
                                Colors.black.withValues(alpha: 0.65),
                                colors.bg,
                              ],
                              stops: const [0.0, 0.60, 1.0],
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
                                Colors.black.withValues(alpha: 0.5),
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
              bottom: isMobile ? 24 : 36,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: CinemaTokens.maxContentWidth),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: AnimatedBuilder(
                      animation: _titleRevealController,
                      builder: (context, _) {
                        final currentMovie = widget.movies[_currentIndex];
                        final revealProgress = isReduced ? 1.0 : _titleRevealController.value;
                        final translateY = (1.0 - revealProgress) * 30.0;
                        final letterSpacing = 1.2 + (1.0 - revealProgress) * 2.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // "NOW SHOWING" Reel Flag
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  color: colors.accentAmber,
                                  child: Text(
                                    'NOW SHOWING',
                                    style: CinemaText.monoBadge(color: Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '35MM PROJECTION • HALL A',
                                  style: CinemaText.monoLabel(color: colors.isDark ? CinemaTokens.ash : Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

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
                                    fontSize: titleFontSize,
                                    letterSpacing: letterSpacing,
                                    height: 0.96,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0xCC000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Metadata row: Year, Runtime, Genres, Clapper rating
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                Text('${currentMovie.year}', style: CinemaText.monoMeta(color: CinemaTokens.projectorAmber)),
                                const Text('•', style: TextStyle(color: Colors.white54)),
                                Text(currentMovie.formattedRuntime, style: CinemaText.monoMeta(color: Colors.white)),
                                const Text('•', style: TextStyle(color: Colors.white54)),
                                ClapperRating(rating: currentMovie.rating, size: 15),
                                for (final genre in currentMovie.genres.take(2))
                                  MonoTag(label: genre),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Action buttons in a Wrap to never overflow
                            Wrap(
                              spacing: 12,
                              runSpacing: 10,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => widget.onSelectMovie(currentMovie),
                                  icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                                  label: const Text('EXPLORE FILM REEL'),
                                ),
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
                  return LinearProgressIndicator(
                    value: isReduced ? 0.0 : _progressController.value,
                    backgroundColor: colors.borderHairline.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accentAmber),
                    minHeight: 2.0,
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
