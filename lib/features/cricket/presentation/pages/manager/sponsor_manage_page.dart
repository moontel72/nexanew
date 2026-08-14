import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_odd/shared/theme/cricket_colors.dart';

import '../../blocs/sponsor/sponsor_bloc.dart';
import '../../../data/models/cricket_models.dart';
import '../../widgets/cricket_top_sheet.dart';
import '../../widgets/sponsor_lookups.dart';
import 'assign_sponsor_sheet.dart';
import 'sponsor_form_sheet.dart';

/// Sponsor management — manager-owned sponsor library and match
/// banner assignment. Sponsors belong to the Cricket Operations
/// Manager's tournament, not to any admin panel.
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
    context.read<SponsorBloc>().add(LoadSponsors(widget.matchId));
  }

  void _openSponsorForm({SponsorModel? existing}) {
    // Re-provide the bloc: dialog routes live above the page's providers.
    final bloc = context.read<SponsorBloc>();
    showCricketTopSheet(
      context,
      child: BlocProvider.value(
        value: bloc,
        child: SponsorFormSheet(existing: existing),
      ),
    );
  }

  void _openAssignSheet() {
    final bloc = context.read<SponsorBloc>();
    showCricketTopSheet(
      context,
      child: BlocProvider.value(
        value: bloc,
        child: AssignSponsorSheet(matchId: widget.matchId),
      ),
    );
  }

  Future<void> _confirmDeleteSponsor(SponsorModel sponsor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F2936),
        title: const Text(
          'Delete Sponsor?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '"${sponsor.name}" will be removed from your sponsor library and '
          'from every match it is assigned to.',
          style: const TextStyle(color: Color(0xFFBDD8DB)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<SponsorBloc>().add(DeleteSponsorRequested(sponsor.id));
    }
  }

  Future<void> _confirmRemove(SponsorModel sponsor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F2936),
        title: const Text(
          'Remove from Match?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '"${sponsor.name}" will no longer be shown on this match.',
          style: const TextStyle(color: Color(0xFFBDD8DB)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('REMOVE'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<SponsorBloc>().add(
        RemoveSponsor(widget.matchId, sponsor.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SponsorBloc, SponsorState>(
      listener: (context, state) {
        if (state is SponsorNotice && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: state.success
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              duration: Duration(seconds: state.success ? 3 : 10),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0C1D2C),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Sponsor Management',
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
        body: BlocBuilder<SponsorBloc, SponsorState>(
          builder: (context, state) {
            if (state is SponsorLoading || state is SponsorInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SponsorError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.campaign,
                        size: 64,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFBDD8DB),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                        onPressed: () => context.read<SponsorBloc>().add(
                          const RefreshSponsors(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is SponsorLoaded) {
              return _SponsorContent(
                state: state,
                hasMatch: widget.matchId.isNotEmpty,
                onAddSponsor: () => _openSponsorForm(),
                onEditSponsor: (s) => _openSponsorForm(existing: s),
                onDeleteSponsor: (s) => _confirmDeleteSponsor(s),
                onAssign: _openAssignSheet,
                onRemove: (s) => _confirmRemove(s),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _SponsorContent extends StatelessWidget {
  final SponsorLoaded state;
  final bool hasMatch;
  final VoidCallback onAddSponsor;
  final void Function(SponsorModel) onEditSponsor;
  final void Function(SponsorModel) onDeleteSponsor;
  final VoidCallback onAssign;
  final void Function(SponsorModel) onRemove;

  const _SponsorContent({
    required this.state,
    required this.hasMatch,
    required this.onAddSponsor,
    required this.onEditSponsor,
    required this.onDeleteSponsor,
    required this.onAssign,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<SponsorBloc>().add(const RefreshSponsors());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(
            icon: Icons.inventory_2_outlined,
            title: 'Sponsor Library',
            subtitle:
                'Your sponsors for this tournament. Revenue belongs '
                'to your operations.',
            actionLabel: 'Add Sponsor',
            onAction: onAddSponsor,
          ),
          if (state.library.isEmpty)
            const _EmptyCard(
              icon: Icons.campaign,
              text: 'No sponsors yet. Add your first sponsor.',
            )
          else
            ...state.library.map(
              (s) => _LibrarySponsorCard(
                sponsor: s,
                onEdit: () => onEditSponsor(s),
                onDelete: () => onDeleteSponsor(s),
              ),
            ),
          const SizedBox(height: 24),
          _SectionHeader(
            icon: Icons.live_tv,
            title: 'Match Banners',
            subtitle: hasMatch
                ? 'Sponsors shown during this match'
                : 'Select a match in Live Console to assign banners',
            actionLabel: 'Assign Sponsor',
            onAction: hasMatch ? onAssign : null,
          ),
          if (!hasMatch)
            const _EmptyCard(
              icon: Icons.sports_cricket,
              text: 'No match selected. Go back and pick a match first.',
            )
          else if (state.sponsors.isEmpty)
            const _EmptyCard(
              icon: Icons.live_tv,
              text: 'No sponsors assigned to this match yet.',
            )
          else
            ...state.sponsors.map(
              (s) => _MatchSponsorCard(sponsor: s, onRemove: () => onRemove(s)),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (onAction != null)
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 16),
              label: Text(actionLabel),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2936),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x20FFFFFF)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF6B7280)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFBDD8DB), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LibrarySponsorCard extends StatelessWidget {
  final SponsorModel sponsor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LibrarySponsorCard({
    required this.sponsor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = sponsorTierColor(sponsor.tier);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2936),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tierColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tierColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: tierColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sponsor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Badge(
                      label: sponsorTierLabel(sponsor.tier).toUpperCase(),
                      color: tierColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Order ${sponsor.displayOrder}',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (sponsor.websiteUrl != null &&
                    sponsor.websiteUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      sponsor.websiteUrl!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFFF59E0B)),
            tooltip: 'Edit',
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: CricketColors.wicket),
            tooltip: 'Delete',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _MatchSponsorCard extends StatelessWidget {
  final SponsorModel sponsor;
  final VoidCallback onRemove;

  const _MatchSponsorCard({required this.sponsor, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final tierColor = sponsorTierColor(sponsor.tier);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2936),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tierColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tierColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.business, color: tierColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sponsor.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Badge(
                      label: sponsorTierLabel(sponsor.tier).toUpperCase(),
                      color: tierColor,
                    ),
                    if (sponsor.placement != null) ...[
                      const SizedBox(width: 8),
                      _Badge(
                        label: sponsorPlacementLabel(sponsor.placement!),
                        color: CricketColors.teamA,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.link_off, color: CricketColors.wicket),
            tooltip: 'Remove from match',
            onPressed: onRemove,
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
