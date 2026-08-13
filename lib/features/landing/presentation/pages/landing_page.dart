// Landing Page — www.traceodd.com
//
// Single-page brand landing site. Composes all sections and renders them
// exclusively from LandingContentLoaded state — 100% JSON-driven UI.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/landing_content.dart';
import '../blocs/countdown/countdown_bloc.dart';
import '../blocs/landing_content/landing_content_bloc.dart';
import '../blocs/launch_signup/launch_signup_bloc.dart';
import '../landing_palette.dart';
import '../widgets/hero_section.dart';
import '../widgets/landing_anchors.dart';
import '../widgets/landing_footer.dart';
import '../widgets/landing_nav_bar.dart';
import '../widgets/pricing_section.dart';
import '../widgets/roadmap_section.dart';
import '../widgets/signup_section.dart';
import '../widgets/stats_strip.dart';
import '../widgets/verticals_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LandingPalette.background,
      body: BlocConsumer<LandingContentBloc, LandingContentState>(
        listener: (context, state) {
          // Once content is loaded, arm the countdown from the JSON meta.
          if (state is LandingContentLoaded) {
            final target = state.content.meta.launchTarget;
            if (target != null) {
              context.read<CountdownBloc>().add(CountdownStarted(target));
            }
          }
        },
        builder: (context, state) => switch (state) {
          LandingContentInitial() => const _LoadingView(),
          LandingContentLoading() => const _LoadingView(),
          LandingContentLoaded(:final content) => _LoadedView(content: content),
          LandingContentError(:final message) => _ErrorView(message: message),
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final LandingContent content;

  const _LoadedView({required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          LandingNavBar(meta: content.meta, links: content.nav),
          HeroSection(
            hero: content.hero,
            announcementBadge: content.meta.announcementBadge,
            logoAsset: content.meta.logoAsset,
          ),
          StatsStrip(stats: content.stats),
          KeyedSubtree(
            key: LandingAnchors.verticals,
            child: VerticalsSection(verticals: content.verticals),
          ),
          KeyedSubtree(
            key: LandingAnchors.pricing,
            child: PricingSection(pricing: content.pricing),
          ),
          KeyedSubtree(
            key: LandingAnchors.roadmap,
            child: RoadmapSection(roadmap: content.roadmap),
          ),
          KeyedSubtree(
            key: LandingAnchors.signup,
            child: SignupSection(
              signup: content.signup,
              defaultInterest: content.meta.defaultInterest,
            ),
          ),
          LandingFooterSection(
            footer: content.footer,
            logoAsset: content.meta.logoAsset,
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(color: LandingPalette.accent),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off,
            size: 56,
            color: LandingPalette.textTertiary,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: LandingPalette.textSecondary),
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: LandingPalette.accent,
              foregroundColor: LandingPalette.background,
            ),
            onPressed: () => context.read<LandingContentBloc>().add(
              const RetryLoadLandingContent(),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Convenience providers wrapper used by the landing entrypoint.
class LandingProviders extends StatelessWidget {
  final Widget child;

  const LandingProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => LandingContentBloc()..add(const LoadLandingContent()),
        ),
        BlocProvider(create: (_) => CountdownBloc()),
        BlocProvider(create: (_) => LaunchSignupBloc()),
      ],
      child: child,
    );
  }
}
