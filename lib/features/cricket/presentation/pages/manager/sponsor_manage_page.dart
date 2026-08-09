import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/sponsor/sponsor_bloc.dart';
import '../../../data/models/cricket_models.dart';

/// Sponsor & banner management — active sponsors for a match.
class SponsorManagePage extends StatefulWidget {
  final String matchId;

  const SponsorManagePage({super.key, required this.matchId});

  @override
  State<SponsorManagePage> createState() => _SponsorManagePageState();
}

class _SponsorManagePageState extends State<SponsorManagePage> {
  @override
  void initState() {
    super.initState();
    if (widget.matchId.isNotEmpty) {
      context.read<SponsorBloc>().add(LoadSponsors(widget.matchId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Sponsor Management'),
        backgroundColor: const Color(0xFF1A1E31),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<SponsorBloc, SponsorState>(
        builder: (context, state) => switch (state) {
          SponsorLoading() => const Center(
            child: CircularProgressIndicator(color: Colors.green),
          ),
          SponsorLoaded(:final sponsors) => _buildSponsorList(sponsors),
          SponsorError(:final message) => Center(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
          _ => const Center(
            child: Text(
              'Load sponsors for a match.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _showAddSponsorDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSponsorList(List<SponsorModel> sponsors) {
    if (sponsors.isEmpty) {
      return const Center(
        child: Text(
          'No sponsors assigned.\nTap + to add.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sponsors.length,
      itemBuilder: (context, index) {
        final s = sponsors[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1E31),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _tierColor(s.tier).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              // Sponsor logo / tier icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _tierColor(s.tier).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business,
                  color: _tierColor(s.tier),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Badge(
                          label: s.tier.toUpperCase(),
                          color: _tierColor(s.tier),
                        ),
                        if (s.placement != null) ...[
                          const SizedBox(width: 8),
                          _Badge(
                            label: s.placement!
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            color: Colors.blue,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  // Remove sponsor — call Sub-Admin API
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _tierColor(String tier) => switch (tier) {
    'title' => Colors.amber,
    'gold' => Colors.amber.shade700,
    'silver' => Colors.grey.shade400,
    'bronze' => Colors.brown,
    _ => Colors.grey,
  };

  void _showAddSponsorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1E31),
        title: const Text('Add Sponsor', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Use the Sub-Admin panel to add sponsors.\n\nSponsors can be assigned to matches from the Super Admin dashboard.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}
