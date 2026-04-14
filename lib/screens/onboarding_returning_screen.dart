import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import 'onboarding_questionnaire_screen.dart';

class OnboardingReturningScreen extends StatefulWidget {
  const OnboardingReturningScreen({super.key});

  @override
  State<OnboardingReturningScreen> createState() =>
      _OnboardingReturningScreenState();
}

class _OnboardingReturningScreenState
    extends State<OnboardingReturningScreen> {
  bool _importing = false;
  String? _error;

  Future<void> _importData() async {
    setState(() {
      _importing = true;
      _error = null;
    });

    final provider = context.read<AppProvider>();
    final success = await provider.importData();

    if (!mounted) return;

    if (success) {
      // Mark onboarding complete on the imported data
      await provider.completeOnboarding(
        profile: provider.data.profile,
      );
      // main.dart listener will switch to the main shell automatically
    } else {
      setState(() {
        _importing = false;
        _error = 'Could not import file. Make sure it is a valid TechnoGM backup.';
      });
    }
  }

  void _startFresh() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const OnboardingQuestionnaireScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechnoColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: TechnoColors.textSecondary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // ── Icon ─────────────────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TechnoColors.neonPurple.withValues(alpha: 0.12),
                  border: Border.all(
                      color: TechnoColors.neonPurple.withValues(alpha: 0.4),
                      width: 2),
                ),
                child: const Icon(Icons.login,
                    color: TechnoColors.neonPurple, size: 36),
              ),

              const SizedBox(height: 28),

              Text(
                'WELCOME BACK',
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Do you have a TechnoGM backup file?\nImport it to restore all your data.',
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  color: TechnoColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // ── Error message ─────────────────────────────────────────────
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TechnoColors.neonPink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: TechnoColors.neonPink.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: TechnoColors.neonPink, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: GoogleFonts.rajdhani(
                              color: TechnoColors.neonPink, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Buttons ───────────────────────────────────────────────────
              _importing
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: TechnoColors.neonCyan),
                    )
                  : NeonButton(
                      label: 'IMPORT MY DATA',
                      icon: Icons.upload_file,
                      color: TechnoColors.neonCyan,
                      onTap: _importData,
                    ),
              const SizedBox(height: 14),
              NeonButton(
                label: 'START FRESH',
                icon: Icons.add_circle_outline,
                color: TechnoColors.neonGreen,
                outlined: true,
                onTap: _importing ? null : _startFresh,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
