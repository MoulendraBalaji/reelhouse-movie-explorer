// CONCEPT: Responsive Shell & Navigation Architecture
// Seamless adaptive navigation:
// - Wide screens (>= 1024px): Full desktop navigation tabs in top AppBar.
// - Mid screens (820px - 1023px): Compact navigation tabs in top AppBar with zero overflow.
// - Narrow screens (< 820px): Clean Drawer menu in AppBar + BottomNavigationBar with 5 destinations.
// Incorporates LampThemeSwitch, Offline Reel Badge, TMDB Attribution Footer.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    if (index == currentNavIndex) return;

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
    final width = MediaQuery.of(context).size.width;
    final showAllTabs = width >= 1024.0;
    final showCompactTabs = width >= 820.0 && width < 1024.0;
    final isNarrow = width < 820.0;

    final movieProvider = context.watch<MovieProvider>();
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: showHeader
          ? AppBar(
              toolbarHeight: 64,
              titleSpacing: isNarrow ? 0 : 16,
              leading: isNarrow
                  ? Builder(
                      builder: (scaffoldContext) => IconButton(
                        icon: const Icon(Icons.menu, color: CinemaTokens.projectorAmber),
                        tooltip: 'Open Cinema Navigation Menu',
                        onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                      ),
                    )
                  : null,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Film Reel App Icon & Brand Name
                  InkWell(
                    onTap: () => _navigateToIndex(context, 0),
                    borderRadius: CinemaTokens.borderSharp,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                        const SizedBox(width: 8),
                        Text(
                          CinemaConstants.appName,
                          style: TextStyle(
                            fontFamily: CinemaTokens.fontDisplay,
                            fontSize: 24,
                            letterSpacing: 2.5,
                            color: isDark ? CinemaTokens.bone : CinemaTokens.matineeInk,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Offline Reel Badge (Full badge on wide screens, small dot indicator on smaller)
                  if (movieProvider.isOffline) ...[
                    const SizedBox(width: 10),
                    if (showAllTabs)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                            const SizedBox(width: 4),
                            Text(
                              'OFFLINE REEL',
                              style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
                            ),
                          ],
                        ),
                      )
                    else
                      Tooltip(
                        message: 'Offline Reel Active',
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: CinemaTokens.projectorAmber,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
              actions: [
                // Wide Desktop Navigation Tabs (>= 1024px)
                if (showAllTabs) ...[
                  _NavLink(title: 'NOW SHOWING', index: 0, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 0)),
                  _NavLink(title: 'EXPLORE', index: 1, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 1)),
                  _NavLink(title: 'SEARCH', index: 2, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 2)),
                  _NavLink(title: 'WATCHLIST', index: 3, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 3)),
                  _NavLink(title: 'PROFILE', index: 4, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 4)),
                  _NavLink(title: 'ABOUT', index: 5, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 5)),
                  const SizedBox(width: 8),
                ],

                // Mid Screen Compact Navigation Tabs (820px - 1023px)
                if (showCompactTabs) ...[
                  _NavLink(title: 'HOME', index: 0, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 0)),
                  _NavLink(title: 'EXPLORE', index: 1, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 1)),
                  _NavLink(title: 'SEARCH', index: 2, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 2)),
                  _NavLink(title: 'SAVED', index: 3, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 3)),
                  _NavLink(title: 'PROFILE', index: 4, currentIndex: currentNavIndex, onTap: () => _navigateToIndex(context, 4)),
                  const SizedBox(width: 8),
                ],

                // Narrow Screen Quick Search Icon (< 820px)
                if (isNarrow)
                  IconButton(
                    icon: const Icon(Icons.search, color: CinemaTokens.projectorAmber),
                    tooltip: 'Search Reels',
                    onPressed: () => _navigateToIndex(context, 2),
                  ),

                // Lamp Theme Switch (Midnight <-> Matinee)
                const LampThemeSwitch(),
                const SizedBox(width: 6),

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
                const SizedBox(width: 8),
              ],
            )
          : null,

      // Mobile Navigation Drawer (< 820px)
      drawer: isNarrow ? _buildCinemaDrawer(context, isDark, currentNavIndex) : null,

      // Main Clean Body
      body: Column(
        children: [
          Expanded(child: body),
          if (showFooter) _buildFooter(context, isDark),
        ],
      ),

      // Bottom Navigation Bar on Narrow Screens (< 820px)
      bottomNavigationBar: isNarrow
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
                BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'SAVED'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
              ],
            )
          : null,
    );
  }

  Widget _buildCinemaDrawer(BuildContext context, bool isDark, int activeIndex) {
    return Drawer(
      backgroundColor: isDark ? CinemaTokens.boothBrown : CinemaTokens.matineeSurface,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? CinemaTokens.celluloidBlack : CinemaTokens.matineeBg,
                border: Border(bottom: BorderSide(color: isDark ? CinemaTokens.hairline : CinemaTokens.matineeHairline)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: CinemaTokens.projectorAmber, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.movie_filter, color: CinemaTokens.projectorAmber, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        CinemaConstants.appName,
                        style: TextStyle(
                          fontFamily: CinemaTokens.fontDisplay,
                          fontSize: 28,
                          letterSpacing: 2,
                          color: isDark ? CinemaTokens.bone : CinemaTokens.matineeInk,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CinemaConstants.appTagline.toUpperCase(),
                    style: CinemaText.monoBadge(color: CinemaTokens.ash),
                  ),
                ],
              ),
            ),
            _DrawerTile(
              title: 'NOW SHOWING',
              icon: Icons.theaters_outlined,
              isSelected: activeIndex == 0,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToIndex(context, 0);
              },
            ),
            _DrawerTile(
              title: 'EXPLORE VAULT',
              icon: Icons.grid_view,
              isSelected: activeIndex == 1,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToIndex(context, 1);
              },
            ),
            _DrawerTile(
              title: 'SEARCH DISPATCH',
              icon: Icons.search,
              isSelected: activeIndex == 2,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToIndex(context, 2);
              },
            ),
            _DrawerTile(
              title: 'WATCHLIST REELS',
              icon: Icons.bookmark_border,
              isSelected: activeIndex == 3,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToIndex(context, 3);
              },
            ),
            _DrawerTile(
              title: 'PATRON PROFILE',
              icon: Icons.person_outline,
              isSelected: activeIndex == 4,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToIndex(context, 4);
              },
            ),
            _DrawerTile(
              title: 'ABOUT CINEMA',
              icon: Icons.info_outline,
              isSelected: activeIndex == 5,
              onTap: () {
                Navigator.of(context).pop();
                _navigateToIndex(context, 5);
              },
            ),
          ],
        ),
      ),
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
                  'Film data provided by TMDB. Offline reel fallback active.',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: CinemaTokens.borderSharp,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: CinemaTokens.fontMono,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 1.1,
                  color: isSelected
                      ? CinemaTokens.projectorAmber
                      : (isDark ? CinemaTokens.bone : CinemaTokens.matineeInk),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: isSelected ? 24 : 0,
                color: isSelected ? CinemaTokens.projectorAmber : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? CinemaTokens.projectorAmber : CinemaTokens.ash),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: CinemaTokens.fontMono,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? CinemaTokens.projectorAmber : CinemaTokens.bone,
        ),
      ),
      tileColor: isSelected ? CinemaTokens.celluloidBlack : null,
      onTap: onTap,
    );
  }
}
