import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cricket_models.dart';
import '../../blocs/sponsor/sponsor_bloc.dart';
import '../../widgets/cricket_lookups.dart';
import '../../widgets/cricket_top_sheet.dart';
import '../../widgets/sponsor_lookups.dart';

/// Add / edit sponsor form. All reactive state lives in [SponsorBloc];
/// form selections use ValueNotifiers (no setState).
class SponsorFormSheet extends StatefulWidget {
  final SponsorModel? existing;
  const SponsorFormSheet({super.key, this.existing});

  @override
  State<SponsorFormSheet> createState() => _SponsorFormSheetState();
}

class _SponsorFormSheetState extends State<SponsorFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _logoCtrl;
  late final TextEditingController _bannerCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _orderCtrl;
  final _tier = ValueNotifier<String>('silver');

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _logoCtrl = TextEditingController(text: s?.logoUrl ?? '');
    _bannerCtrl = TextEditingController(text: s?.bannerImageUrl ?? '');
    _websiteCtrl = TextEditingController(text: s?.websiteUrl ?? '');
    _orderCtrl = TextEditingController(
      text: s != null && s.displayOrder > 0 ? '${s.displayOrder}' : '',
    );
    if (s?.tier != null && sponsorTiers.contains(s!.tier)) {
      _tier.value = s.tier;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _logoCtrl.dispose();
    _bannerCtrl.dispose();
    _websiteCtrl.dispose();
    _orderCtrl.dispose();
    _tier.dispose();
    super.dispose();
  }

  String? _optional(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sponsor name is required.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    context.read<SponsorBloc>().add(
      SaveSponsorRequested(
        id: widget.existing?.id,
        name: name,
        tier: _tier.value,
        logoUrl: _optional(_logoCtrl.text),
        bannerImageUrl: _optional(_bannerCtrl.text),
        websiteUrl: _optional(_websiteCtrl.text),
        displayOrder: int.tryParse(_orderCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SponsorBloc, SponsorState>(
      listenWhen: (_, state) =>
          state is SponsorNotice &&
          state.action == 'saveSponsor' &&
          state.success,
      listener: (context, state) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CricketSheetHeader(
                title: widget.existing == null ? 'Add Sponsor' : 'Edit Sponsor',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: cricketFieldDecoration('Sponsor name *'),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String>(
                valueListenable: _tier,
                builder: (context, value, _) => DropdownButtonFormField<String>(
                  value: value,
                  isExpanded: true,
                  decoration: cricketFieldDecoration('Tier'),
                  dropdownColor: const Color(0xFF0F2936),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: sponsorTiers
                      .map(
                        (t) => DropdownMenuItem<String>(
                          value: t,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: sponsorTierColor(t),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                sponsorTierLabel(t),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => _tier.value = v ?? 'silver',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _logoCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: cricketFieldDecoration('Logo URL (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bannerCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: cricketFieldDecoration(
                  'Banner image URL (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _websiteCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: cricketFieldDecoration('Website URL (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _orderCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: cricketFieldDecoration('Display order (0 = first)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(
                  widget.existing == null ? 'SAVE SPONSOR' : 'UPDATE SPONSOR',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
