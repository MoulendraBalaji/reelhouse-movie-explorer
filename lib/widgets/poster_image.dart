// REUSABLE WIDGET: PosterImage
// Network image loader with CORS proxy support, cinema loading skeleton, and fallback lobby card.

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import '../core/image_helper.dart';

class PosterImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? title;

  const PosterImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.cinemaColors;
    final proxiedUrl = ImageUrlHelper.format(imageUrl);

    if (proxiedUrl.isEmpty) {
      return _buildPlaceholder(colors);
    }

    return Image.network(
      proxiedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: colors.surface,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.accentAmber),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(colors),
    );
  }

  Widget _buildPlaceholder(CinemaColors colors) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderHairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.accentAmber.withValues(alpha: 0.5), width: 1.5),
                color: colors.surfaceElevated,
              ),
              child: Center(
                child: Icon(Icons.movie_creation_outlined, size: 22, color: colors.accentAmber),
              ),
            ),
            const SizedBox(height: 12),
            if (title != null && title!.isNotEmpty) ...[
              Text(
                title!.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: CinemaTokens.fontDisplay,
                  fontSize: 16,
                  letterSpacing: 1.0,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              '35MM ARCHIVE REEL',
              textAlign: TextAlign.center,
              style: CinemaText.monoBadge(color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
