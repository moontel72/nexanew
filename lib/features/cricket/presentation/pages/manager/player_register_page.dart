import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/core/config/api_config.dart';
import 'package:trace_odd/features/cricket/data/models/cricket_models.dart';
import 'package:trace_odd/features/cricket/data/repositories/cricket_repository.dart';

class PlayerRegisterPage extends StatefulWidget {
  final String? teamId;
  final String? teamName;
  const PlayerRegisterPage({super.key, this.teamId, this.teamName});

  @override
  State<PlayerRegisterPage> createState() => _PlayerRegisterPageState();
}

class _PlayerRegisterPageState extends State<PlayerRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _jerseyCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _idCardCtrl = TextEditingController();
  String? _selectedTeamId;
  String? _selectedTeamName;
  String _position = 'player';
  String? _role;
  String? _battingStyle;
  String? _bowlingStyle;
  DateTime? _dob;
  List<TeamModel> _teams = [];
  bool _isSubmitting = false;
  bool _loadingTeams = true;
  PlayerModel? _createdPlayer;
  Uint8List? _selectedPhotoBytes;
  String? _photoFileName;

  static const _positions = [
    'player',
    'captain',
    'vice_captain',
    'coach',
    'manager',
    'extra',
  ];
  static const _positionLabels = {
    'player': 'Player',
    'captain': 'Captain',
    'vice_captain': 'Vice Captain',
    'coach': 'Coach',
    'manager': 'Team Manager',
    'extra': 'Extra Player',
  };
  static const _battingStyles = ['right_hand', 'left_hand'];
  static const _bowlingStyles = [
    'right_arm_fast',
    'left_arm_fast',
    'right_arm_off_spin',
    'right_arm_leg_spin',
    'left_arm_orthodox',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTeamId = widget.teamId;
    _selectedTeamName = widget.teamName;
    _loadTeams();
  }

  CricketRepository? _safeRepo() {
    try {
      return RepositoryProvider.of<CricketRepository>(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Service unavailable — please go back and try again.',
            ),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
      return null;
    }
  }

  String _fullUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiConfig.baseUrl}$path';
  }

  Future<void> _loadTeams() async {
    try {
      final repo = _safeRepo();
      if (repo == null) return;
      final teams = await repo.getAllTeams();
      if (mounted)
        setState(() {
          _teams = teams;
          _loadingTeams = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loadingTeams = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _jerseyCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _idCardCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a team'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final repo = _safeRepo();
      if (repo == null) {
        setState(() => _isSubmitting = false);
        return;
      }
      var player = await repo.createPlayer(
        teamId: _selectedTeamId!,
        name: _nameCtrl.text.trim(),
        role: _role,
        position: _position,
        jerseyNumber: _jerseyCtrl.text.trim().isEmpty
            ? null
            : _jerseyCtrl.text.trim(),
        battingStyle: _battingStyle,
        bowlingStyle: _bowlingStyle,
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        idCardNumber: _idCardCtrl.text.trim().isEmpty
            ? null
            : _idCardCtrl.text.trim(),
        dateOfBirth: _dob?.toIso8601String().split('T').first,
      );
      if (_selectedPhotoBytes != null) {
        try {
          final photoUrl = await repo.uploadPlayerPhoto(
            player.id,
            _selectedPhotoBytes!,
            _photoFileName ?? 'photo.jpg',
          );
          if (photoUrl != null && photoUrl.isNotEmpty) {
            player = player.copyWith(photoUrl: photoUrl);
          }
        } catch (_) {
          // Photo upload failed but player was created — non-fatal
        }
      }
      if (mounted)
        setState(() {
          _isSubmitting = false;
          _createdPlayer = player;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_createdPlayer != null) return _successView();

    return Scaffold(
      backgroundColor: const Color(0xFF0C1D2C),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Register New Player',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2936),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Color(0xFF10B981)),
            tooltip: 'Back to Dashboard',
            onPressed: () {
              try {
                Navigator.of(context).popUntil(
                  (route) =>
                      route.settings.name == 'cricket_manager_dashboard' ||
                      route.isFirst,
                );
              } catch (_) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
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
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_add, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Player Registration',
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
                      'Register a new player with auto-generated 3-digit code.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Photo picker
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                    withData: true,
                  );
                  if (result != null && result.files.isNotEmpty) {
                    setState(() {
                      _selectedPhotoBytes = result.files.first.bytes;
                      _photoFileName = result.files.first.name;
                    });
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2936),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x40FFFFFF)),
                  ),
                  child: _selectedPhotoBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _selectedPhotoBytes!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Color(0xFFBDD8DB),
                              size: 32,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Photo',
                              style: TextStyle(
                                color: Color(0xFFBDD8DB),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
              if (_photoFileName != null)
                Text(
                  _photoFileName!,
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                  ),
                ),
              const SizedBox(height: 24),
              _buildField('Player Name *', _nameCtrl, 'Enter player name'),
              const SizedBox(height: 16),
              // Team selector
              const Text(
                'Team *',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _loadingTeams
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedTeamId,
                      dropdownColor: const Color(0xFF0F2936),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFF0F2936),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x20FFFFFF)),
                        ),
                      ),
                      hint: const Text(
                        'Select team',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                      items: _teams
                          .map(
                            (t) => DropdownMenuItem(
                              value: t.id,
                              child: Text(
                                '${t.name} ${t.teamCode != null ? '(${t.teamCode})' : ''}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedTeamId = v;
                        _selectedTeamName = _teams
                            .firstWhere((t) => t.id == v)
                            .name;
                      }),
                    ),
              const SizedBox(height: 16),
              // Position
              const Text(
                'Position *',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _position,
                dropdownColor: const Color(0xFF0F2936),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0F2936),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x20FFFFFF)),
                  ),
                ),
                items: _positions
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(_positionLabels[p] ?? p),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _position = v!),
              ),
              const SizedBox(height: 16),
              const Text(
                'Role Type',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _role,
                dropdownColor: const Color(0xFF0F2936),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0F2936),
                  hintText: 'None',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x20FFFFFF)),
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'None',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'batsman',
                    child: Text('Batsman'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'bowler',
                    child: Text('Bowler'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'all_rounder',
                    child: Text('All Rounder'),
                  ),
                  const DropdownMenuItem<String?>(
                    value: 'wicket_keeper',
                    child: Text('Wicket Keeper'),
                  ),
                ],
                onChanged: (v) => setState(() => _role = v),
              ),
              const SizedBox(height: 16),
              // Batting style
              const Text(
                'Batting Style',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _battingStyle,
                dropdownColor: const Color(0xFF0F2936),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0F2936),
                  hintText: 'None',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x20FFFFFF)),
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'None',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                  ..._battingStyles.map(
                    (s) => DropdownMenuItem<String?>(
                      value: s,
                      child: Text(s.replaceAll('_', ' ').toUpperCase()),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _battingStyle = v),
              ),
              // Bowling style
              const SizedBox(height: 16),
              const Text(
                'Bowling Style',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _bowlingStyle,
                dropdownColor: const Color(0xFF0F2936),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0F2936),
                  hintText: 'None',
                  hintStyle: TextStyle(color: Color(0xFF6B7280)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0x20FFFFFF)),
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'None',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                  ..._bowlingStyles.map(
                    (s) => DropdownMenuItem<String?>(
                      value: s,
                      child: Text(s.replaceAll('_', ' ').toUpperCase()),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _bowlingStyle = v),
              ),
              const SizedBox(height: 16),
              _buildField('Jersey Number', _jerseyCtrl, 'e.g. 7'),
              const SizedBox(height: 16),
              _buildField(
                'Email (Optional)',
                _emailCtrl,
                'Enter email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildField(
                'Phone (Optional)',
                _phoneCtrl,
                'Enter phone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildField(
                'ID Card Number (Optional)',
                _idCardCtrl,
                'Enter ID card',
              ),
              const SizedBox(height: 16),
              const Text(
                'Date of Birth (Optional)',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dob ?? DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    builder: (ctx, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF10B981),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() => _dob = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2936),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x20FFFFFF)),
                  ),
                  child: Text(
                    _dob != null
                        ? '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}'
                        : 'Select Date',
                    style: TextStyle(
                      color: _dob != null
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
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
                          'CREATE PLAYER',
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

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    String hint, {
    TextInputType? keyboardType,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: keyboardType,
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

  Widget _successView() => Scaffold(
    backgroundColor: const Color(0xFF0C1D2C),
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context, true),
      ),
      backgroundColor: const Color(0xFF0F2936),
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.home, color: Color(0xFF10B981)),
          tooltip: 'Back to Dashboard',
          onPressed: () {
            try {
              Navigator.of(context).popUntil(
                (route) =>
                    route.settings.name == 'cricket_manager_dashboard' ||
                    route.isFirst,
              );
            } catch (_) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      ],
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Color(0xFF10B981)),
            if (_createdPlayer?.photoUrl != null &&
                _createdPlayer!.photoUrl!.isNotEmpty) ...[
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFF2563EB),
                backgroundImage: NetworkImage(
                  _fullUrl(_createdPlayer!.photoUrl!),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Player Created!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _createdPlayer?.name ?? '',
              style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 18),
            ),
            if (_createdPlayer?.playerCode != null &&
                _createdPlayer!.playerCode!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2936),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Player Code',
                      style: TextStyle(color: Color(0xFFBDD8DB), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _createdPlayer!.playerCode!,
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
            ],
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
                onPressed: () => Navigator.pop(context, true),
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
