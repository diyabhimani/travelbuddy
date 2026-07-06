import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelbuddy2/screens/login_screen.dart';
import 'package:travelbuddy2/utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;

  String? profileImageUrl;
  String? name;
  String? bio;
  int? age;
  String? email;

  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      setState(() {
        name = data?['name'];
        bio = data?['bio'];
        age = data?['age'];
        email = data?['email'];
        profileImageUrl = data?['profileImage'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B5E3C)),
      )
          : CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: _buildBody(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ── Sliver App Bar with hero header ──────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF8B5E3C),
      elevation: 0,
      leading: const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Warm gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A2C17), Color(0xFFB07C4F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Decorative circles
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),

            // Profile content inside header
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Avatar with glow ring
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD89B), Color(0xFFB07C4F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: const Color(0xFF4A2C17),

                      backgroundImage: (profileImageUrl != null &&
                          profileImageUrl!.isNotEmpty &&
                          profileImageUrl!.startsWith("http"))
                          ? NetworkImage(profileImageUrl!)
                          : null,

                      child: (profileImageUrl == null ||
                          profileImageUrl!.isEmpty ||
                          !profileImageUrl!.startsWith("http"))
                          ? Text(
                        (name != null && name!.isNotEmpty)
                            ? name![0].toUpperCase()
                            : "?",
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD89B),
                        ),
                      )
                          : null,
                    )
                  ),

                  const SizedBox(height: 14),

                  // Name
                  Text(
                    name ?? 'Traveller',
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Email chip
                  if (email != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        email!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ── Main scrollable body ──────────────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Stats Row ───────────────────────────────────────────────────
          _buildStatsRow(),

          const SizedBox(height: 24),

          // ── About Card ──────────────────────────────────────────────────
          _buildSectionCard(
            title: 'About Me',
            icon: Icons.person_outline_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bio != null && bio!.isNotEmpty)
                  Text(
                    bio!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF5C4033),
                      height: 1.6,
                    ),
                  )
                else
                  const Text(
                    'No bio added yet. Tell the world about your travel story!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9E8375),
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Details Card ────────────────────────────────────────────────
          _buildSectionCard(
            title: 'Details',
            icon: Icons.info_outline_rounded,
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: age != null ? '$age years old' : '—',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email ?? '—',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Account Section ─────────────────────────────────────────────
          const Text(
            'ACCOUNT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9E8375),
              letterSpacing: 1.6,
            ),
          ),

          const SizedBox(height: 10),

          _buildActionTile(
            icon: Icons.logout_rounded,
            label: 'Logout',
            color: kDarkBrown,
            onTap: () async {
              final confirmed = await _showLogoutDialog(context);
              if (confirmed == true) {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// ── Stats chips (trips, countries, etc.) ─────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatChip(icon: Icons.flight_takeoff_rounded, label: 'Trips', value: '—'),
        const SizedBox(width: 12),
        _buildStatChip(icon: Icons.public_rounded, label: 'Countries', value: '—'),
        const SizedBox(width: 12),
        _buildStatChip(icon: Icons.star_rounded, label: 'Reviews', value: '—'),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5E3C).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF8B5E3C), size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C17),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9E8375),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ── Section card wrapper ──────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5E3C).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5EFE6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF8B5E3C), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A2C17),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// ── Detail row inside a card ──────────────────────────────────────────────
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFB07C4F)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5C4033),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7A5C4A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// ── Action tile (logout, etc.) ────────────────────────────────────────────
  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5E3C).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: color.withOpacity(0.5), size: 22),
          ],
        ),
      ),
    );
  }

  /// ── Logout confirmation dialog ────────────────────────────────────────────
  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF5EFE6),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Georgia',
            color: Color(0xFF4A2C17),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFF5C4033)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8B5E3C)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkBrown,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}