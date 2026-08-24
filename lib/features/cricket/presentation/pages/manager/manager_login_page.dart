import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trace_odd/core/config/api_config.dart';

import '../../blocs/cricket_auth/cricket_auth_bloc.dart';
import '../../blocs/match_list/match_list_bloc.dart';
import '../../blocs/tournament_hub/tournament_hub_bloc.dart';
import '../../blocs/live_score/live_score_bloc.dart';
import '../../blocs/camera_switcher/camera_switcher_bloc.dart';
import '../../blocs/voice_score/voice_score_bloc.dart';
import '../../blocs/sponsor/sponsor_bloc.dart';
import '../../../data/repositories/cricket_repository.dart';
import 'manager_dashboard_page.dart';
import 'package:trace_odd/shared/theme/colors.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

/// Cricket Manager login page — isolated Bearer token auth.
class ManagerLoginPage extends StatefulWidget {
  const ManagerLoginPage({super.key});

  @override
  State<ManagerLoginPage> createState() => _ManagerLoginPageState();
}

class _ManagerLoginPageState extends State<ManagerLoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<Map<String, dynamic>?>(
                    future: CricketRepository().getPublicBrand(),
                    builder: (ctx, snap) {
                      final brand = snap.data;
                      final name = brand?['name']?.toString();
                      final logoUrl = _resolveLogoUrl(
                        brand?['logo_url']?.toString(),
                      );
                      return Column(
                        children: [
                          if (logoUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                logoUrl,
                                width: 84,
                                height: 84,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const _FallbackBadge(),
                              ),
                            )
                          else
                            const _FallbackBadge(),
                          const SizedBox(height: 16),
                          Text(
                            name != null && name.isNotEmpty
                                ? name
                                : 'Cricket Manager',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CricketColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name != null && name.isNotEmpty
                                ? 'Cricket Manager Panel'
                                : 'Cricket Tournament',
                            style: TextStyle(
                              color: CricketColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    style: TextStyle(color: CricketColors.textPrimary),
                    decoration: _inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v?.isEmpty == true ? 'Email required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    style: TextStyle(color: CricketColors.textPrimary),
                    decoration: _inputDecoration('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: CricketColors.textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (v) =>
                        v?.isEmpty == true ? 'Password required' : null,
                  ),
                  const SizedBox(height: 24),
                  BlocConsumer<CricketAuthBloc, CricketAuthState>(
                    listener: (context, state) {
                      if (state is CricketAuthLoggedIn) {
                        final repo = RepositoryProvider.of<CricketRepository>(
                          context,
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => RepositoryProvider.value(
                              value: repo,
                              child: MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(
                                    value: context.read<CricketAuthBloc>(),
                                  ),
                                  BlocProvider(
                                    create: (_) => MatchListBloc(repo: repo),
                                  ),
                                  BlocProvider(
                                    create: (_) =>
                                        TournamentHubBloc(repo: repo),
                                  ),
                                  BlocProvider(
                                    create: (_) => LiveScoreBloc(repo: repo),
                                  ),
                                  BlocProvider(
                                    create: (_) =>
                                        CameraSwitcherBloc(repo: repo),
                                  ),
                                  BlocProvider(
                                    create: (_) => VoiceScoreBloc(repo: repo),
                                  ),
                                  BlocProvider(
                                    create: (_) => SponsorBloc(repo: repo),
                                  ),
                                ],
                                child: const ManagerDashboardPage(),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is CricketAuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    context.read<CricketAuthBloc>().add(
                                      CricketLogin(
                                        email: _emailCtrl.text.trim(),
                                        password: _passCtrl.text,
                                      ),
                                    );
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: CricketColors.textPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CricketColors.textPrimary,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  BlocBuilder<CricketAuthBloc, CricketAuthState>(
                    builder: (context, state) {
                      if (state is CricketAuthError)
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            state.message,
                            style: TextStyle(color: CricketColors.wicket),
                          ),
                        );
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: CricketColors.placeholder),
    filled: true,
    fillColor: CricketColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );

  String? _resolveLogoUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${ApiConfig.baseUrl}$url';
  }
}

/// Trace Odd badge shown when the active tournament has no custom logo yet.
class _FallbackBadge extends StatelessWidget {
  const _FallbackBadge();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo/traceodd_logo.svg',
      width: 84,
      height: 84,
    );
  }
}
