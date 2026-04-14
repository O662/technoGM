import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import 'onboarding_questionnaire_screen.dart';
import 'onboarding_returning_screen.dart';

class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechnoColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ── Logo / wordmark ────────────────────────────────────────────
              Text(
                'TECHNO',
                style: GoogleFonts.orbitron(
                  color: TechnoColors.neonCyan,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(
                      color: TechnoColors.neonCyan.withValues(alpha: 0.6),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
              Text(
                'GM',
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textPrimary,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                ),
              ),

              const SizedBox(height: 40),

              // ── Divider line ───────────────────────────────────────────────
              Container(
                width: 60,
                height: 2,
                decoration: BoxDecoration(
                  color: TechnoColors.neonCyan,
                  boxShadow: [
                    BoxShadow(
                      color: TechnoColors.neonCyan.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Question text ──────────────────────────────────────────────
              Text(
                'Welcome.',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Have you used TechnoGM before?',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  color: TechnoColors.textSecondary,
                  fontSize: 18,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 4),

              // ── Buttons ────────────────────────────────────────────────────
              NeonButton(
                label: "I'M NEW!",
                icon: Icons.rocket_launch_outlined,
                color: TechnoColors.neonCyan,
                onTap: () => Navigator.push(
                  context,
                  _slide(const OnboardingQuestionnaireScreen()),
                ),
              ),
              const SizedBox(height: 14),
              NeonButton(
                label: 'RETURNING',
                icon: Icons.login_outlined,
                color: TechnoColors.neonPurple,
                outlined: true,
                onTap: () => Navigator.push(
                  context,
                  _slide(const OnboardingReturningScreen()),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PageRoute<T> _slide<T>(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, _,  _) => page,
      transitionsBuilder: (_, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
