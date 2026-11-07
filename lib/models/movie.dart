import 'cast_member.dart';

class Movie {
  final int id;
  final String title;
  final String tagline;
  final int year;
  final String releaseDate;
  final List<String> genres;
  final double rating;
  final int runtime;
  final String overview;
  final String director;
  final List<CastMember> cast;
  final String posterUrl;
  final String backdropUrl;
  final String trailerYoutubeKey;
  final String category;

  const Movie({
    required this.id,
    required this.title,
    this.tagline = '',
    required this.year,
    required this.releaseDate,
    required this.genres,
    required this.rating,
    required this.runtime,
    required this.overview,
    this.director = 'Unknown Director',
    this.cast = const [],
    required this.posterUrl,
    required this.backdropUrl,
    this.trailerYoutubeKey = '',
    this.category = 'trending',
  });

  /// Formatted duration in cinema reel style: e.g. "2h 46m"
  String get formattedRuntime {
    if (runtime <= 0) return 'N/A';
    final hours = runtime ~/ 60;
    final minutes = runtime % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> parsedGenres = [];
    if (json['genres'] != null) {
      if (json['genres'] is List) {
        parsedGenres = (json['genres'] as List).map((g) {
          if (g is Map) return g['name']?.toString() ?? '';
          return g.toString();
        }).where((s) => s.isNotEmpty).toList();
      }
    }

    List<CastMember> parsedCast = [];
    if (json['cast'] != null && json['cast'] is List) {
      parsedCast = (json['cast'] as List)
          .map((c) => CastMember.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    return Movie(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] as String? ?? 'Untitled Film',
      tagline: json['tagline'] as String? ?? '',
      year: json['year'] is int
          ? json['year'] as int
          : (int.tryParse(json['year']?.toString() ?? '') ?? 0),
      releaseDate: json['release_date'] as String? ?? '',
      genres: parsedGenres,
      rating: (json['rating'] as num?)?.toDouble() ??
          (json['vote_average'] as num?)?.toDouble() ??
          0.0,
      runtime: json['runtime'] is int
          ? json['runtime'] as int
          : (int.tryParse(json['runtime']?.toString() ?? '') ?? 120),
      overview: json['overview'] as String? ?? 'No overview available in cinema archives.',
      director: json['director'] as String? ?? 'Director Uncredited',
      cast: parsedCast,
      posterUrl: json['poster_url'] as String? ??
          (json['poster_path'] != null ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}' : ''),
      backdropUrl: json['backdrop_url'] as String? ??
          (json['backdrop_path'] != null ? 'https://image.tmdb.org/t/p/original${json['backdrop_path']}' : ''),
      trailerYoutubeKey: json['trailer_key'] as String? ?? json['trailer_youtube_key'] as String? ?? '',
      category: json['category'] as String? ?? 'trending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tagline': tagline,
      'year': year,
      'release_date': releaseDate,
      'genres': genres,
      'rating': rating,
      'runtime': runtime,
      'overview': overview,
      'director': director,
      'cast': cast.map((c) => c.toJson()).toList(),
      'poster_url': posterUrl,
      'backdrop_url': backdropUrl,
      'trailer_key': trailerYoutubeKey,
      'category': category,
    };
  }
}
