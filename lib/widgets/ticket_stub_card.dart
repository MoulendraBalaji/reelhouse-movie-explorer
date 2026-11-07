// SIGNATURE WIDGET: TicketStubCard
// Cinema ticket card with side notch cutouts, perforated tear line, movie poster, and metadata.

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import '../models/movie.dart';
import 'clapper_rating.dart';
import 'mono_tag.dart';
import 'poster_image.dart';

class TicketStubClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double notchFraction; // Vertical fraction where the side notches sit

  TicketStubClipper({
    this.notchRadius = 8.0,
    this.notchFraction = 0.68,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchY = size.height * notchFraction;

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, notchY - notchRadius);

    // Right notch
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, notchY + notchRadius);

    // Left notch
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TicketStubClipper oldClipper) => false;
}

class TicketStubCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const TicketStubCard({
    super.key,
    required this.movie,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.cinemaColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: CinemaTokens.borderSharp,
        child: ClipPath(
          clipper: TicketStubClipper(notchRadius: 8.0, notchFraction: 0.68),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(color: colors.borderHairline, width: 1.0),
              borderRadius: CinemaTokens.borderSharp,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Poster Artwork
                Expanded(
                  flex: 68,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterImage(
                        imageUrl: movie.posterUrl,
                        title: movie.title,
                        fit: BoxFit.cover,
                      ),
                      // Rating badge overlay on poster top right
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            border: Border.all(color: CinemaTokens.projectorAmber, width: 1),
                            borderRadius: CinemaTokens.borderSharp,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 11, color: CinemaTokens.projectorAmber),
                              const SizedBox(width: 4),
                              Text(
                                movie.rating.toStringAsFixed(1),
                                style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Perforated Dashed Tear Line
                SizedBox(
                  height: 1,
                  child: CustomPaint(
                    painter: HorizontalDashedLinePainter(color: colors.borderHairline),
                  ),
                ),

                // Ticket Stub Bottom Details
                Expanded(
                  flex: 32,
                  child: Container(
                    color: colors.surfaceElevated,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Title
                        Text(
                          movie.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: CinemaTokens.fontDisplay,
                            fontSize: 15,
                            letterSpacing: 0.8,
                            color: colors.textPrimary,
                          ),
                        ),

                        // Metadata row: Year & Runtime
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${movie.year}',
                              style: TextStyle(
                                fontFamily: CinemaTokens.fontMono,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors.accentAmber,
                              ),
                            ),
                            Text(
                              movie.formattedRuntime,
                              style: TextStyle(
                                fontFamily: CinemaTokens.fontMono,
                                fontSize: 11,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),

                        // Genre tag & Clapper
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (movie.genres.isNotEmpty)
                              Flexible(
                                child: MonoTag(label: movie.genres.first, isSmall: true),
                              )
                            else
                              const SizedBox.shrink(),
                            const SizedBox(width: 4),
                            ClapperRating(rating: movie.rating, size: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HorizontalDashedLinePainter extends CustomPainter {
  final Color color;

  HorizontalDashedLinePainter({this.color = CinemaTokens.hairline});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 10.0; // keep notch ends clean

    while (startX < size.width - 10.0) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalDashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
