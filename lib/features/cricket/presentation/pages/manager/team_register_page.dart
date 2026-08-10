import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';

class TeamRegisterPage extends StatefulWidget {
  const TeamRegisterPage({super.key});
  @override
  State<TeamRegisterPage> createState() => _TeamRegisterPageState();
}

class _TeamRegisterPageState extends State<TeamRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _shortCodeCtrl = TextEditingController();
  final _homeCityCtrl = TextEditingController();
  Color _selectedColor = const Color(0xFF2563EB);
  bool _isSubmitting = false;
  TeamModel? _createdTeam;

  static const _colorOptions = [
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortCodeCtrl.dispose();
    _homeCityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = RepositoryProvider.of<CricketRepository>(context);
      final team = await repo.createTeam(
        name: _nameCtrl.text.trim(),
        shortCode: _shortCodeCtrl.text.trim().isEmpty
            ? null
            : _shortCodeCtrl.text.trim(),
        homeCity: _homeCityCtrl.text.trim().isEmpty
            ? null
            : _homeCityCtrl.text.trim(),
        primaryColor: '#${_selectedColor.value.toRadixString(16).substring(2)}',
      );
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _createdTeam = team;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create team'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_createdTeam != null)
      return _SuccessView(
        team: _createdTeam!,
        onDone: () => Navigator.pop(context, true),
      );

    return Scaffold(
      backgroundColor: const Color(0xFF0C1D2C),
      appBar: AppBar(
        title: const Text(
          'Register New Team',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2936),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.group_add, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Team Registration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create a new team with auto-generated 3-digit code.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildField('Team Name *', _nameCtrl, 'Enter team name'),
              const SizedBox(height: 16),
              _buildField('Short Code', _shortCodeCtrl, 'e.g. IND, AUS'),
              const SizedBox(height: 16),
              _buildField('Home City', _homeCityCtrl, 'e.g. Mumbai'),
              const SizedBox(height: 20),
              const Text(
                'Primary Color',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _colorOptions
                    .map(
                      (c) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == c
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'CREATE TEAM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint) =>
      TextFormField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFBDD8DB)),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          filled: true,
          fillColor: const Color(0xFF0F2936),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0x20FFFFFF)),
          ),
        ),
        validator: (v) => label.contains('*') && (v == null || v.trim().isEmpty)
            ? 'Required'
            : null,
      );
}

class _SuccessView extends StatelessWidget {
  final TeamModel team;
  final VoidCallback onDone;
  const _SuccessView({required this.team, required this.onDone});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0C1D2C),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Color(0xFF10B981)),
            const SizedBox(height: 24),
            const Text(
              'Team Created!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              team.name,
              style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 18),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2936),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Team Code',
                    style: TextStyle(color: Color(0xFFBDD8DB), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    team.teamCode ?? '---',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onDone,
                child: const Text(
                  'DONE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
