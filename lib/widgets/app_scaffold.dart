// CONCEPT: Responsive Shell & Navigation Architecture
// Mobile = BottomNavigationBar, Tablet = NavigationRail, Desktop = Persistent Nav & Max Width 1280.
// Incorporates LampThemeSwitch, Offline Reel Badge, TMDB Attribution Footer, and FilmGrainOverlay.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../core/constants.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';
import '../providers/theme_provider.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import 'motion/lamp_theme_switch.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int currentNavIndex;
  final ValueChanged<int>? onNavChanged;
  final bool showHeader;
  final bool showFooter;

  const AppScaffold({
    super.key,
    required this.body,
    this.currentNavIndex = 0,
    this.onNavChanged,
    this.showHeader = true,
    this.showFooter = true,
  });

  void _navigateToIndex(BuildContext context, int index) {
    if (onNavChanged != null) {
      onNavChanged!(index);
      return;
    }
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/explore');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/search');
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/watchlist');
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
      case 5:
        Navigator.of(context).pushReplacementNamed('/about');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);
    final movieProvider = context.watch<MovieProvider>();
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: showHeader
              ? AppBar(
                  toolbarHeight: 64,
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Film Reel App Icon
                      InkWell(
                        onTap: () => _navigateToIndex(context, 0),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: CinemaTokens.projectorAmber, width: 1.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.movie_filter_outlined, size: 18, color: CinemaTokens.projectorAmber),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              CinemaConstants.appName,
                              style: TextStyle(
                                fontFamily: CinemaTokens.fontDisplay,
                                fontSize: 26,
                                letterSpacing: 3.0,
                                color: isDark ? CinemaTokens.bone : CinemaTokens.matineeInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Offline Reel Badge (Section 2 requirement)
                      if (movieProvider.isOffline)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: CinemaTokens.boothBrown,
                            border: Border.all(color: CinemaTokens.projectorAmber, width: 1),
                            borderRadius: CinemaTokens.borderSharp,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: CinemaTokens.projectorAmber,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'OFFLINE REEL',
                                style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    // Desktop Navigation Links
                    if (isDesktop) ...[
                      _NavLink(title: 'NOW SHOWING', index: 0, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 0)),
                      _NavLink(title: 'EXPLORE VAULT', index: 1, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 1)),
                      _NavLink(title: 'SEARCH', index: 2, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 2)),
                      _NavLink(title: 'WATCHLIST', index: 3, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 3)),
                      _NavLink(title: 'PROFILE', index: 4, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 4)),
                      _NavLink(title: 'ABOUT', index: 5, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 5)),
                      const SizedBox(width: 16),
                    ],

                    // Lamp Theme Switch
                    const LampThemeSwitch(),
                    const SizedBox(width: 12),

                    // Patron Auth Icon
                    IconButton(
                      icon: Icon(
                        authProvider.isLoggedIn ? Icons.account_circle : Icons.person_outline,
                        color: authProvider.isLoggedIn ? CinemaTokens.projectorAmber : CinemaTokens.ash,
                      ),
                      tooltip: authProvider.isLoggedIn ? 'Patron: ${authProvider.user.name}' : 'Sign In',
                      onPressed: () {
                        if (authProvider.isLoggedIn) {
                          _navigateToIndex(context, 4);
                        } else {
                          Navigator.of(context).pushNamed('/login');
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                )
              : null,
          body: Row(
            children: [
              // Tablet NavigationRail
              if (isTablet)
                NavigationRail(
                  selectedIndex: currentNavIndex.clamp(0, 5),
                  onDestinationSelected: (idx) => _navigateToIndex(context, idx),
                  backgroundColor: isDark ? CinemaTokens.boothBrown : CinemaTokens.matineeSurface,
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(color: CinemaTokens.projectorAmber),
                  unselectedIconTheme: const IconThemeData(color: CinemaTokens.ash),
                  selectedLabelTextStyle: CinemaText.monoLabel(color: CinemaTokens.projectorAmber),
                  unselectedLabelTextStyle: CinemaText.monoLabel(color: CinemaTokens.ash),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.theater_comedy_outlined), label: Text('HOME')),
                    NavigationRailDestination(icon: Icon(Icons.grid_view), label: Text('EXPLORE')),
                    NavigationRailDestination(icon: Icon(Icons.search), label: Text('SEARCH')),
                    NavigationRailDestination(icon: Icon(Icons.bookmark_border), label: Text('SAVED')),
                    NavigationRailDestination(icon: Icon(Icons.person_outline), label: Text('PROFILE')),
                    NavigationRailDestination(icon: Icon(Icons.info_outline), label: Text('ABOUT')),
                  ],
                ),

              // Main Body Content with Desktop Width Limiter & TMDB Footer
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: body),

                    // TMDB Attribution & Cinema Footer
                    if (showFooter) _buildFooter(context, isDark),
                  ],
                ),
              ),
            ],
          ),

          // Mobile BottomNavigationBar
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  currentIndex: currentNavIndex.clamp(0, 4),
                  onTap: (idx) => _navigateToIndex(context, idx),
                  backgroundColor: isDark ? CinemaTokens.celluloidBlack : CinemaTokens.matineeBg,
                  selectedItemColor: CinemaTokens.projectorAmber,
                  unselectedItemColor: CinemaTokens.ash,
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
                  unselectedLabelStyle: CinemaText.monoBadge(color: CinemaTokens.ash),
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.theaters_outlined), label: 'HOME'),
                    BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'EXPLORE'),
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'SEARCH'),
                    BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'WATCHLIST'),
                    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
                  ],
                )
              : null,
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? CinemaTokens.celluloidBlack : CinemaTokens.matineeBg,
        border: Border(top: BorderSide(color: isDark ? CinemaTokens.hairline : CinemaTokens.matineeHairline)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: CinemaTokens.maxContentWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'REELHOUSE • EST. 1934 • 35MM CINEMA EXPERIENCE',
                  style: CinemaText.monoLabel(color: CinemaTokens.ash),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Film data provided by TMDB. This product uses the TMDB API but is not endorsed or certified by TMDB.',
                  style: CinemaText.monoBadge(color: CinemaTokens.ash),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String title;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavLink({
    required this.title,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? CinemaTokens.projectorAmber : CinemaTokens.bone,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: CinemaTokens.fontMono,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 1.2,
                color: isSelected ? CinemaTokens.projectorAmber : CinemaTokens.bone,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                color: CinemaTokens.projectorAmber,
              ),
          ],
        ),
      ),
    );
  }
}
