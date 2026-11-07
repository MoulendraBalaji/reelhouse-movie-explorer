// ENTRANCE SEQUENCE:
// 0ms: HeroFlightShuttle rotates poster and draws sprocket borders
// 250ms: SliverAppBar backdrop fades up with parallax scroll
// 450ms: Film title, tagline, and mono metadata row slide up
// 650ms: Director, cast list, and synopsis unspool
// 850ms: Watchlist TicketTearAnimation and critique form reveal

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/responsive.dart';
import '../core/validators.dart';
import '../core/image_helper.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../providers/watchlist_provider.dart';
import '../providers/reviews_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/clapper_rating.dart';
import '../widgets/mono_tag.dart';
import '../widgets/rating_input.dart';
import '../widgets/poster_image.dart';
import '../widgets/motion/ticket_tear_animation.dart';
import '../widgets/motion/clapperboard_clap.dart';
import '../widgets/motion/hero_flight_shuttle.dart';
import '../widgets/film_strip_border.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  final int movieId;

  const DetailScreen({super.key, required this.movieId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final GlobalKey<FormState> _reviewFormKey = GlobalKey<FormState>();
  final GlobalKey<ClapperboardClapState> _clapperKey = GlobalKey<ClapperboardClapState>();

  late final TextEditingController _critiqueController;
  double _inputRating = 5.0;

  @override
  void initState() {
    super.initState();
    _critiqueController = TextEditingController();
  }

  @override
  void dispose() {
    _critiqueController.dispose();
    super.dispose();
  }

  void _submitReview(Movie movie) {
    if (_reviewFormKey.currentState?.validate() ?? false) {
      final auth = context.read<AuthProvider>();
      final reviews = context.read<ReviewsProvider>();

      reviews.addReview(
        movieId: movie.id,
        userName: auth.isLoggedIn ? auth.user.name : 'Cinema Patron',
        rating: _inputRating,
        comment: _critiqueController.text.trim(),
      );

      _clapperKey.currentState?.snapClapper();
      _critiqueController.clear();
    }
  }

  Future<void> _openTrailer(String key) async {
    if (key.isEmpty) return;
    final uri = Uri.parse('https://www.youtube.com/watch?v=$key');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();
    final reviewsProvider = context.watch<ReviewsProvider>();

    final movies = movieProvider.allMovies;
    Movie? foundMovie;
    try {
      foundMovie = movies.firstWhere((m) => m.id == widget.movieId);
    } catch (_) {
      foundMovie = movies.isNotEmpty ? movies.first : null;
    }

    if (foundMovie == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('REEL NOT FOUND')),
        body: const EmptyState(message: 'This film reel could not be located in the projection booth.'),
      );
    }
    final movie = foundMovie;

    final isSaved = watchlistProvider.isWatchlisted(movie.id);
    final movieReviews = reviewsProvider.getReviewsForMovie(movie.id);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: CinemaTokens.celluloidBlack,
      body: CustomScrollView(
        slivers: [
          // Parallax Backdrop SliverAppBar
          SliverAppBar(
            expandedHeight: isDesktop ? 440.0 : 320.0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: CinemaTokens.projectorAmber),
              tooltip: 'Return to Cinema Catalog',
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    ImageUrlHelper.format(
                      movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl,
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(color: CinemaTokens.boothBrown),
                  ),
                  // Dark Celluloid Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          CinemaTokens.celluloidBlack.withValues(alpha: 0.2),
                          CinemaTokens.celluloidBlack.withValues(alpha: 0.8),
                          CinemaTokens.celluloidBlack,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Film Detail Content
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: CinemaTokens.maxContentWidth),
                child: Padding(
                  padding: Responsive.getPagePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Hero Poster + Core Metadata
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Poster with custom flightShuttleBuilder
                          SizedBox(
                            width: isDesktop ? 220 : 140,
                            height: isDesktop ? 330 : 210,
                            child: Hero(
                              tag: 'poster_${movie.id}',
                              flightShuttleBuilder: cinemaFlightShuttleBuilder,
                              child: FilmStripBorder(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: CinemaTokens.projectorAmber, width: 1.5),
                                    borderRadius: CinemaTokens.borderSharp,
                                  ),
                                  child: PosterImage(
                                    imageUrl: movie.posterUrl,
                                    title: movie.title,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Title, Tagline, Director & Year
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: CinemaTokens.fontDisplay,
                                    fontSize: isDesktop ? 44 : 28,
                                    letterSpacing: 2.0,
                                    color: CinemaTokens.bone,
                                    height: 1.0,
                                  ),
                                ),
                                if (movie.tagline.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '“${movie.tagline}”',
                                    style: CinemaText.quote(color: CinemaTokens.projectorAmber),
                                  ),
                                ],
                                const SizedBox(height: 14),

                                // Metadata items
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text('${movie.year}', style: CinemaText.monoMeta(color: CinemaTokens.projectorAmber)),
                                    const Text('•', style: TextStyle(color: CinemaTokens.ash)),
                                    Text(movie.formattedRuntime, style: CinemaText.monoMeta(color: CinemaTokens.bone)),
                                    const Text('•', style: TextStyle(color: CinemaTokens.ash)),
                                    Text('DIR: ${movie.director}', style: CinemaText.monoMeta(color: CinemaTokens.bone)),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Clapper Rating
                                ClapperRating(rating: movie.rating, size: 20),
                                const SizedBox(height: 14),

                                // Genre Tags
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final genre in movie.genres)
                                      MonoTag(label: genre),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Trailer CTA Button
                                if (movie.trailerYoutubeKey.isNotEmpty)
                                  ElevatedButton.icon(
                                    onPressed: () => _openTrailer(movie.trailerYoutubeKey),
                                    icon: const Icon(Icons.play_circle_outline, size: 18),
                                    label: const Text('WATCH 35MM TRAILER'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Watchlist Ticket Tear Interactive Button
                      TicketTearAnimation(
                        isSaved: isSaved,
                        title: movie.title.toUpperCase(),
                        onToggle: () => watchlistProvider.toggleWatchlist(movie.id),
                      ),

                      const SizedBox(height: 36),

                      // Synopsis
                      Text(
                        'SYNOPSIS',
                        style: TextStyle(
                          fontFamily: CinemaTokens.fontDisplay,
                          fontSize: 24,
                          letterSpacing: 2,
                          color: CinemaTokens.projectorAmber,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.overview,
                        style: CinemaText.bodyLarge(color: CinemaTokens.bone),
                      ),

                      const SizedBox(height: 36),

                      // Cast Members
                      if (movie.cast.isNotEmpty) ...[
                        Text(
                          'FEATURED CAST',
                          style: TextStyle(
                            fontFamily: CinemaTokens.fontDisplay,
                            fontSize: 24,
                            letterSpacing: 2,
                            color: CinemaTokens.projectorAmber,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 110,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: movie.cast.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final member = movie.cast[index];
                              return Container(
                                width: 140,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: CinemaTokens.boothBrown,
                                  border: Border.all(color: CinemaTokens.hairline),
                                  borderRadius: CinemaTokens.borderSharp,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      member.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: CinemaText.monoLabel(color: CinemaTokens.bone),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      member.character,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: CinemaText.bodySmall(color: CinemaTokens.ash),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],

                      // Community Reviews & Clapperboard Submission
                      Text(
                        'PATRON CRITIQUES & DISPATCHES',
                        style: TextStyle(
                          fontFamily: CinemaTokens.fontDisplay,
                          fontSize: 24,
                          letterSpacing: 2,
                          color: CinemaTokens.projectorAmber,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Review Submission Form with ClapperboardClap
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CinemaTokens.boothBrown,
                          border: Border.all(color: CinemaTokens.hairline),
                          borderRadius: CinemaTokens.borderSharp,
                        ),
                        child: Form(
                          key: _reviewFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SUBMIT YOUR 35MM CRITIQUE',
                                style: CinemaText.monoLabel(color: CinemaTokens.projectorAmber),
                              ),
                              const SizedBox(height: 14),

                              // Interactive Rating Spools
                              RatingInput(
                                rating: _inputRating,
                                onRatingChanged: (r) => setState(() => _inputRating = r),
                              ),
                              const SizedBox(height: 16),

                              // Critique Text Field with Form validation
                              TextFormField(
                                controller: _critiqueController,
                                maxLines: 4,
                                validator: CinemaValidators.validateReviewText,
                                style: CinemaText.bodyMedium(color: CinemaTokens.bone),
                                decoration: const InputDecoration(
                                  hintText: 'Share your cinematic impression (10 to 500 characters)...',
                                ),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _submitReview(movie),
                                    icon: const Icon(Icons.movie, size: 18),
                                    label: const Text('CLAP & LOG CRITIQUE'),
                                  ),
                                  const SizedBox(width: 16),
                                  ClapperboardClap(
                                    key: _clapperKey,
                                    successChild: Text(
                                      'CRITIQUE DISPATCHED TO ARCHIVE!',
                                      style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Existing Reviews List
                      if (movieReviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'No patron critiques yet. Be the first to clap for this film!',
                            style: TextStyle(color: CinemaTokens.ash),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: movieReviews.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final rev = movieReviews[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CinemaTokens.boothBrownElevated,
                                border: Border.all(color: CinemaTokens.hairline),
                                borderRadius: CinemaTokens.borderSharp,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(rev.userName, style: CinemaText.monoLabel(color: CinemaTokens.projectorAmber)),
                                      ClapperRating(rating: rev.rating * 2.0, size: 12, showNumeric: false),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(rev.comment, style: CinemaText.bodyMedium(color: CinemaTokens.bone)),
                                ],
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
        ],
      ),
    );
  }
}
