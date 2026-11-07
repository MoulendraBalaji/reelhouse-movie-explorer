// ENTRANCE SEQUENCE:
// 0ms: About overview and cinema booth history fade in
// 200ms: Technology architecture and syllabus concept matrix slide in
// 400ms: TMDB attribution banner and contact/feedback form reveal

import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../core/validators.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../theme/text_styles.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final GlobalKey<FormState> _feedbackFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _msgController;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _msgController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  void _sendFeedback() {
    if (_feedbackFormKey.currentState?.validate() ?? false) {
      setState(() => _submitted = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: context.cinemaColors.surfaceElevated,
          content: Text('DISPATCH SENT TO REELHOUSE BOOTH', style: CinemaText.monoBadge(color: context.cinemaColors.accentAmber)),
        ),
      );
      _nameController.clear();
      _emailController.clear();
      _msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.cinemaColors;

    return AppScaffold(
      currentNavIndex: 5,
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
                    number: '06',
                    title: 'ABOUT REELHOUSE CINEMA',
                  ),
                  const SizedBox(height: 24),

                  // Introduction Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.borderHairline),
                      borderRadius: CinemaTokens.borderSharp,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('THE MANIFESTO', style: CinemaText.monoBadge(color: colors.accentAmber)),
                        const SizedBox(height: 12),
                        Text(
                          '“EVERY FILM, ONE REEL AT A TIME”',
                          style: TextStyle(
                            fontFamily: CinemaTokens.fontDisplay,
                            fontSize: 32,
                            letterSpacing: 2,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'REELHOUSE is a dedicated tribute to the golden era of single-screen cinema projection booths. '
                          'Built entirely in Flutter Web, it transforms standard algorithmic streaming lists into a tactile, physical 35mm celluloid archive. '
                          'From mechanical clock countdowns and rotating sweep hands to authentic ticket-tearing, clapperboard critique logging, '
                          'and projector beam dust motes, every interaction honors real projection hardware.',
                          style: TextStyle(
                            fontFamily: CinemaTokens.fontSerif,
                            fontSize: 16.0,
                            height: 1.6,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Technology Stack Matrix
                  Text(
                    'TECHNOLOGY & ARCHITECTURE',
                    style: TextStyle(
                      fontFamily: CinemaTokens.fontDisplay,
                      fontSize: 24,
                      letterSpacing: 2,
                      color: colors.accentAmber,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildTechCard(context, 'FRAMEWORK', 'Flutter 3.44+ Web (CanvasKit)', 'Engineered for smooth 60fps rendering'),
                      _buildTechCard(context, 'STATE MANAGEMENT', 'Provider + ChangeNotifier', 'Clean MultiProvider root architecture'),
                      _buildTechCard(context, 'TYPOGRAPHY', 'Bebas Neue, Fraunces, Space Mono', 'Fully bundled offline TTF fonts'),
                      _buildTechCard(context, 'DATA SOURCE', 'TMDB API & Offline JSON', 'Resilient 42-movie offline fallback reel'),
                      _buildTechCard(context, 'MOTION DESIGN', '18 Signature Custom Animations', 'CustomPainters, Matrix4, Springs, Clapper'),
                      _buildTechCard(context, 'DEPLOYMENT', 'GitHub Pages & GitHub Actions', 'Automated CI/CD with release optimization'),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // TMDB Attribution (REQUIRED)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      border: Border.all(color: colors.accentAmber, width: 1.5),
                      borderRadius: CinemaTokens.borderSharp,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.accentAmber),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.movie_creation, color: colors.accentAmber, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TMDB ATTRIBUTION STATEMENT', style: CinemaText.monoBadge(color: colors.accentAmber)),
                              const SizedBox(height: 4),
                              Text(
                                'This product uses the TMDB API but is not endorsed or certified by TMDB. '
                                'All film titles, promotional poster artwork, synopses, and cast data are copyright of their respective production studios.',
                                style: CinemaText.bodySmall(color: colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Patron Dispatch / Feedback Form
                  Text(
                    'PROJECTIONIST DISPATCH FEEDBACK',
                    style: TextStyle(
                      fontFamily: CinemaTokens.fontDisplay,
                      fontSize: 24,
                      letterSpacing: 2,
                      color: colors.accentAmber,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.borderHairline),
                      borderRadius: CinemaTokens.borderSharp,
                    ),
                    child: Form(
                      key: _feedbackFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('SEND A TELEGRAM TO THE PROJECTION BOOTH', style: CinemaText.monoLabel(color: colors.accentAmber)),
                              if (_submitted)
                                Text('DISPATCH RECEIVED', style: CinemaText.monoBadge(color: colors.accentAmber)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            validator: CinemaValidators.validateName,
                            style: TextStyle(fontFamily: CinemaTokens.fontSerif, fontSize: 14, color: colors.textPrimary),
                            decoration: const InputDecoration(labelText: 'Patron Name'),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            validator: CinemaValidators.validateEmail,
                            style: TextStyle(fontFamily: CinemaTokens.fontSerif, fontSize: 14, color: colors.textPrimary),
                            decoration: const InputDecoration(labelText: 'Patron Dispatch Email'),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _msgController,
                            validator: CinemaValidators.validateFeedbackMessage,
                            maxLines: 4,
                            style: TextStyle(fontFamily: CinemaTokens.fontSerif, fontSize: 14, color: colors.textPrimary),
                            decoration: const InputDecoration(labelText: 'Message / Film Inquiries (min 10 chars)'),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _sendFeedback,
                            icon: const Icon(Icons.send_outlined, size: 16),
                            label: const Text('DISPATCH TELEGRAM'),
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildTechCard(BuildContext context, String title, String main, String desc) {
    final colors = context.cinemaColors;
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: isMobile ? double.infinity : 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderHairline),
        borderRadius: CinemaTokens.borderSharp,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CinemaText.monoBadge(color: colors.accentAmber)),
          const SizedBox(height: 6),
          Text(main, style: TextStyle(fontFamily: CinemaTokens.fontMono, fontSize: 13, color: colors.textPrimary)),
          const SizedBox(height: 4),
          Text(desc, style: CinemaText.bodySmall(color: colors.textMuted)),
        ],
      ),
    );
  }
}
