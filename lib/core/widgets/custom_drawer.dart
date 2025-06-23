part of '../routes/app_routes.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x30FFFFFF),
              Color(0x20FFFFFF),
              Color(0x10FFFFFF),
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              border: Border(
                right: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Glassmorphic User Profile Header
                _buildGlassHeader(context, textTheme),
                
                const SizedBox(height: 10),

                // Navigation Items
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  route: '/dashboard',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.note_alt_rounded,
                  title: 'Notes',
                  route: '/notes',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.check_circle_outline_rounded,
                  title: 'To-Do List',
                  route: '/todos',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.photo_library_rounded,
                  title: 'Gallery',
                  route: '/gallery',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.style_rounded,
                  title: 'Flashcards',
                  route: '/flashcards',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.school_rounded,
                  title: 'Classes',
                  route: '/classes',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.quiz_rounded,
                  title: 'Quizzes',
                  route: '/quizzes',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.track_changes_rounded,
                  title: 'Habit Tracker',
                  route: '/habit-tracker',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.video_library_rounded,
                  title: 'YouTube Tools',
                  route: '/youtube-helper',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.chat_rounded,
                  title: 'AI Chat',
                  route: '/ai-chat',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.alarm_rounded,
                  title: 'Alarms',
                  route: '/alarms',
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.emoji_events_rounded,
                  title: 'Achievements',
                  route: '/achievements',
                ),

                // Glass Divider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                _buildDrawerItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  route: '/settings',
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassHeader(BuildContext context, TextTheme textTheme) {
    return Container(
      height: 225,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar with glass effect
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),

                const SizedBox(height: 15),

                // User Name
                Text(
                  'ZenLearn User',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // User Email
                Text(
                  'user@zenlearn.app',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.3),
                        Colors.green.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Online',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isSelected = currentRoute == route || currentRoute.startsWith('$route/');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.pop(context);
            if (!isSelected) {
              context.go(route);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.white.withOpacity(0.15),
                      ],
                    )
                  : null,
              border: isSelected
                  ? Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                if (isSelected) ...[  
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}