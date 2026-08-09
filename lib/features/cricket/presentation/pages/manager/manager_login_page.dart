import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/cricket_auth/cricket_auth_bloc.dart';

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports_cricket,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Cricket Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Valley Soon Tournament Control',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v?.isEmpty == true ? 'Email required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Password'),
                    obscureText: true,
                    validator: (v) =>
                        v?.isEmpty == true ? 'Password required' : null,
                  ),
                  const SizedBox(height: 24),
                  BlocConsumer<CricketAuthBloc, CricketAuthState>(
                    listener: (context, state) {
                      if (state is CricketAuthLoggedIn) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const ManagerDashboardPage(),
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
                            backgroundColor: Colors.green,
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
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  if (state is CricketAuthError)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
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
    labelStyle: const TextStyle(color: Colors.grey),
    filled: true,
    fillColor: const Color(0xFF1A1E31),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );
}

/// Manager dashboard — navigation hub after login.
class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CricketAuthBloc, CricketAuthState>(
      builder: (context, state) {
        final manager = state is CricketAuthLoggedIn ? state.manager : null;
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E21),
          appBar: AppBar(
            title: Text(manager?.name ?? 'Dashboard'),
            backgroundColor: const Color(0xFF1A1E31),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<CricketAuthBloc>().add(CricketLogout());
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ManagerLoginPage()),
                  );
                },
              ),
            ],
          ),
          body: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _DashboardCard(
                icon: Icons.scoreboard,
                label: 'Live Scoring',
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManagerScorePage(matchId: ''),
                  ),
                ),
              ),
              _DashboardCard(
                icon: Icons.videocam,
                label: 'Cameras',
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CameraSwitcherPage(matchId: ''),
                  ),
                ),
              ),
              _DashboardCard(
                icon: Icons.mic,
                label: 'Voice Score',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VoiceScorePage(matchId: ''),
                  ),
                ),
              ),
              _DashboardCard(
                icon: Icons.campaign,
                label: 'Sponsors',
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SponsorManagePage(matchId: ''),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E31),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
