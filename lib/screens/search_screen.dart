// ENTRANCE SEQUENCE:
// 0ms: Search dispatch field expands and focuses with amber glow
// 150ms: Recent search canisters slide in horizontally
// 300ms: Search result grid reveals with staggered entrance

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';
import '../models/movie.dart';
import '../providers/search_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/ticket_stub_card.dart';
import '../widgets/motion/tilt_poster_card.dart';
import '../widgets/motion/reel_cursor.dart';
import '../widgets/empty_state.dart';
import '../widgets/mono_tag.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _openDetail(BuildContext context, Movie movie) {
    Navigator.of(context).pushNamed(
      '/detail',
      arguments: movie.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return AppScaffold(
      currentNavIndex: 2,
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
                    number: '03',
                    title: 'PROJECTOR DISPATCH SEARCH',
                  ),
                  const SizedBox(height: 24),

                  // Search Input Field
                  TextField(
                    controller: _textController,
                    onChanged: (val) => searchProvider.onQueryChanged(val),
                    style: CinemaText.bodyLarge(color: CinemaTokens.bone),
                    decoration: InputDecoration(
                      hintText: 'Search by title, director, actor, or genre (e.g. Nolan, Sci-Fi)...',
                      prefixIcon: const Icon(Icons.search, color: CinemaTokens.projectorAmber),
                      suffixIcon: _textController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: CinemaTokens.ash),
                              onPressed: () {
                                _textController.clear();
                                searchProvider.onQueryChanged('');
                              },
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recent Searches History
                  if (searchProvider.recentSearches.isNotEmpty) ...[
                    Row(
                      children: [
                        Text('RECENT DISPATCHES:', style: CinemaText.monoLabel(color: CinemaTokens.ash)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => searchProvider.clearRecent(),
                          child: Text('CLEAR ALL', style: CinemaText.monoBadge(color: CinemaTokens.ash)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final term in searchProvider.recentSearches)
                          MonoTag(
                            label: term,
                            onTap: () {
                              _textController.text = term;
                              searchProvider.onQueryChanged(term);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Search Status / Results Count
                  if (searchProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(CinemaTokens.projectorAmber),
                        ),
                      ),
                    )
                  else if (searchProvider.query.isNotEmpty && searchProvider.results.isEmpty)
                    EmptyState(
                      title: 'NO FILM REELS FOUND',
                      message: 'No movies in the 35mm vault match "${searchProvider.query}".',
                    )
                  else if (searchProvider.results.isNotEmpty) ...[
                    Text(
                      '${searchProvider.results.length} MATCHING REELS FOUND',
                      style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
                    ),
                    const SizedBox(height: 16),
                    ResponsiveGrid(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchProvider.results.length,
                      itemBuilder: (context, index) {
                        final movie = searchProvider.results[index];

                        return MouseRegion(
                          onEnter: (_) => ReelCursorScope.setMode(context, CursorMode.view),
                          onExit: (_) => ReelCursorScope.setMode(context, CursorMode.normal),
                          child: TiltPosterCard(
                            onTap: () => _openDetail(context, movie),
                            child: TicketStubCard(
                              movie: movie,
                              onTap: () => _openDetail(context, movie),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else
                    const EmptyState(
                      title: 'SEARCH THE VAULT',
                      message: 'Type any film title, director name, or genre keyword above to unspool archived reels.',
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
