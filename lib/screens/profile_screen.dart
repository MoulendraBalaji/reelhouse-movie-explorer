// ENTRANCE SEQUENCE:
// 0ms: Patron identity canister slides in from top
// 200ms: Mechanical OdometerCounters roll into gear
// 350ms: PaintedChartReveal progressive pillars draw upward
// 550ms: Patron profile edit form and motion preferences reveal

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/responsive.dart';
import '../core/validators.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/section_header.dart';
import '../widgets/motion/odometer_counter_chart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _profileFormKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  String _selectedGenre = 'Science Fiction';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.user.name);
    _bioController = TextEditingController(text: auth.user.bio);
    _selectedGenre = auth.user.favoriteGenre;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_profileFormKey.currentState?.validate() ?? false) {
      final auth = context.read<AuthProvider>();
      auth.updateProfile(
        name: _nameController.text.trim(),
        email: auth.user.email,
        bio: _bioController.text.trim(),
        favoriteGenre: _selectedGenre,
      );
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: CinemaTokens.boothBrown,
          content: Text('PATRON CREDENTIALS UPDATED', style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final user = authProvider.user;

    final chartPoints = [
      const ChartDataPoint(label: 'SCI-FI', value: 16),
      const ChartDataPoint(label: 'DRAMA', value: 12),
      const ChartDataPoint(label: 'CRIME', value: 8),
      const ChartDataPoint(label: 'MYSTERY', value: 6),
      const ChartDataPoint(label: 'ACTION', value: 9),
    ];

    return AppScaffold(
      currentNavIndex: 4,
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
                    number: '05',
                    title: 'PATRON ARCHIVE CREDENTIALS',
                  ),
                  const SizedBox(height: 24),

                  // Patron Identity Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: CinemaTokens.boothBrown,
                      border: Border.all(color: CinemaTokens.hairline),
                      borderRadius: CinemaTokens.borderSharp,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar film reel
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            border: Border.all(color: CinemaTokens.projectorAmber, width: 2),
                            shape: BoxShape.circle,
                            color: CinemaTokens.celluloidBlack,
                          ),
                          child: const Center(
                            child: Icon(Icons.person, size: 36, color: CinemaTokens.projectorAmber),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Name, Email, Bio
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    user.name.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: CinemaTokens.fontDisplay,
                                      fontSize: 28,
                                      letterSpacing: 2,
                                      color: CinemaTokens.bone,
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => setState(() => _isEditing = !_isEditing),
                                    icon: Icon(_isEditing ? Icons.close : Icons.edit, size: 14),
                                    label: Text(_isEditing ? 'CANCEL' : 'EDIT CREDENTIALS'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(user.email, style: CinemaText.monoMeta(color: CinemaTokens.projectorAmber)),
                              const SizedBox(height: 8),
                              Text(user.bio, style: CinemaText.bodyMedium(color: CinemaTokens.ash)),
                              const SizedBox(height: 8),
                              Text('DISPATCH PATRON SINCE: ${user.memberSince}', style: CinemaText.monoBadge(color: CinemaTokens.ash)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Profile Form
                  if (_isEditing) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: CinemaTokens.boothBrownElevated,
                        border: Border.all(color: CinemaTokens.projectorAmber),
                        borderRadius: CinemaTokens.borderSharp,
                      ),
                      child: Form(
                        key: _profileFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MODIFY PATRON DOSSIER', style: CinemaText.monoLabel(color: CinemaTokens.projectorAmber)),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              validator: CinemaValidators.validateName,
                              style: CinemaText.bodyMedium(color: CinemaTokens.bone),
                              decoration: const InputDecoration(labelText: 'Patron Full Name'),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _bioController,
                              style: CinemaText.bodyMedium(color: CinemaTokens.bone),
                              decoration: const InputDecoration(labelText: 'Cinema Bio / Archival Role'),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text('SAVE CREDENTIALS'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 36),

                  // Mechanical Odometer Stats Row
                  Text(
                    'PROJECTION METRICS',
                    style: TextStyle(
                      fontFamily: CinemaTokens.fontDisplay,
                      fontSize: 24,
                      letterSpacing: 2,
                      color: CinemaTokens.projectorAmber,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildMetricCard(
                        title: 'FILMS SCREENED',
                        valueWidget: OdometerCounter(value: user.watchedCount),
                        subtitle: 'Spools viewed in full',
                      ),
                      _buildMetricCard(
                        title: 'PROJECTION RUNTIME',
                        valueWidget: OdometerCounter(value: user.totalHours, suffix: 'h'),
                        subtitle: 'Hours in theater darkness',
                      ),
                      _buildMetricCard(
                        title: 'FAVORITE GENRE',
                        valueWidget: Text(
                          user.favoriteGenre.toUpperCase(),
                          style: TextStyle(
                            fontFamily: CinemaTokens.fontDisplay,
                            fontSize: 28,
                            letterSpacing: 2,
                            color: CinemaTokens.projectorAmber,
                          ),
                        ),
                        subtitle: 'Primary aesthetic affinity',
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Progressive Drawn Chart: Screening History by Genre
                  Text(
                    'HISTORICAL SCREENINGS BY GENRE',
                    style: TextStyle(
                      fontFamily: CinemaTokens.fontDisplay,
                      fontSize: 24,
                      letterSpacing: 2,
                      color: CinemaTokens.projectorAmber,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CinemaTokens.boothBrown,
                      border: Border.all(color: CinemaTokens.hairline),
                      borderRadius: CinemaTokens.borderSharp,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FREQUENCY OF 35MM REELS UNSPOLLED', style: CinemaText.monoBadge(color: CinemaTokens.ash)),
                        const SizedBox(height: 16),
                        PaintedChartReveal(points: chartPoints, height: 180),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Accessibility & Motion Settings Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CinemaTokens.boothBrown,
                      border: Border.all(color: CinemaTokens.hairline),
                      borderRadius: CinemaTokens.borderSharp,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PROJECTION BOOTH PREFERENCES', style: CinemaText.monoLabel(color: CinemaTokens.projectorAmber)),
                        const SizedBox(height: 16),

                        // Reduce Motion Switch
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Reduce Motion / High-Frequency Flicker', style: CinemaText.monoMeta(color: CinemaTokens.bone)),
                          subtitle: Text('Replaces mechanical animations with simple opacity dissolves for comfortable viewing.', style: CinemaText.bodySmall(color: CinemaTokens.ash)),
                          value: settingsProvider.reduceMotion,
                          activeThumbColor: CinemaTokens.projectorAmber,
                          onChanged: (val) => settingsProvider.setReduceMotion(val),
                        ),

                        const Divider(color: CinemaTokens.hairline, height: 24),

                        // Sign Out Button
                        if (authProvider.isLoggedIn)
                          OutlinedButton.icon(
                            onPressed: () {
                              authProvider.logout();
                              Navigator.of(context).pushReplacementNamed('/home');
                            },
                            icon: const Icon(Icons.logout, size: 16, color: CinemaTokens.ticketRed),
                            label: Text('SIGN OUT OF PROJECTION BOOTH', style: CinemaText.monoLabel(color: CinemaTokens.ticketRed)),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed('/login'),
                            icon: const Icon(Icons.login, size: 16),
                            label: const Text('SIGN IN TO PATRON ACCOUNT'),
                          ),
                      ],
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

  Widget _buildMetricCard({
    required String title,
    required Widget valueWidget,
    required String subtitle,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CinemaTokens.boothBrown,
        border: Border.all(color: CinemaTokens.hairline),
        borderRadius: CinemaTokens.borderSharp,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CinemaText.monoBadge(color: CinemaTokens.ash)),
          const SizedBox(height: 8),
          valueWidget,
          const SizedBox(height: 6),
          Text(subtitle, style: CinemaText.bodySmall(color: CinemaTokens.ash)),
        ],
      ),
    );
  }
}
