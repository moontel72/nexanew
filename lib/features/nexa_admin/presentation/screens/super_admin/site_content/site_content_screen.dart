// Site Content Screen — Super Admin CMS
//
// Lets the Super Admin edit the runtime content of traceodd.com (landing)
// and docs.traceodd.com (manual blocks) and upload screenshots — all
// without a rebuild or code push.

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:trace_odd/core/config/environment.dart';
import 'package:trace_odd/features/nexa_admin/data/repositories/site_content_repository.dart';

class SiteContentScreen extends StatefulWidget {
  const SiteContentScreen({super.key, this.inShell = false});

  final bool inShell;

  @override
  State<SiteContentScreen> createState() => _SiteContentScreenState();
}

class _SiteContentScreenState extends State<SiteContentScreen> {
  final SiteContentRepository _repo = SiteContentRepository();

  final TextEditingController _newSlugCtrl = TextEditingController();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _textEnCtrl = TextEditingController();
  final TextEditingController _textUrCtrl = TextEditingController();
  final TextEditingController _jsonCtrl = TextEditingController();

  List<Map<String, dynamic>> _blocks = const [];
  String? _selectedSlug;
  bool _loadingList = true;
  bool _loadingBlock = false;
  bool _saving = false;
  bool _uploading = false;
  String? _imageUrl;

  bool get _isLanding => _selectedSlug == 'landing';

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  @override
  void dispose() {
    _newSlugCtrl.dispose();
    _titleCtrl.dispose();
    _textEnCtrl.dispose();
    _textUrCtrl.dispose();
    _jsonCtrl.dispose();
    super.dispose();
  }

  // ── Data ─────────────────────────────────────────────────────────────

  Future<void> _loadList() async {
    setState(() => _loadingList = true);
    try {
      final blocks = await _repo.listBlocks();
      if (!mounted) return;
      setState(() {
        _blocks = blocks;
        _loadingList = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingList = false);
      _snack('Failed to load blocks: $e', isError: true);
    }
  }

  Future<void> _selectBlock(String slug) async {
    setState(() {
      _selectedSlug = slug;
      _loadingBlock = true;
      _imageUrl = null;
    });
    final block = await _repo.getBlock(slug);
    if (!mounted) return;
    final payload = block?['payload'] is Map
        ? Map<String, dynamic>.from(block!['payload'] as Map)
        : <String, dynamic>{};
    setState(() {
      _loadingBlock = false;
      _titleCtrl.text = (block?['title'] ?? payload['title'] ?? '').toString();
      if (_isLanding) {
        _jsonCtrl.text = const JsonEncoder.withIndent('  ').convert(payload);
      } else {
        _textEnCtrl.text = (payload['text_en'] ?? '').toString();
        _textUrCtrl.text = (payload['text_ur'] ?? '').toString();
        _imageUrl = payload['image']?.toString();
      }
    });
  }

  Future<void> _save() async {
    if (_selectedSlug == null) return;
    setState(() => _saving = true);
    try {
      if (_isLanding) {
        final decoded = jsonDecode(_jsonCtrl.text.trim());
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Landing JSON must be an object.');
        }
        await _repo.saveBlock(
          'landing',
          title: 'Landing Content',
          payload: decoded,
        );
      } else {
        await _repo.saveBlock(
          _selectedSlug!,
          title: _titleCtrl.text.trim().isEmpty
              ? _selectedSlug
              : _titleCtrl.text.trim(),
          payload: {
            'title': _titleCtrl.text.trim(),
            'text_en': _textEnCtrl.text.trim(),
            'text_ur': _textUrCtrl.text.trim(),
            'image': (_imageUrl ?? '').trim().isEmpty
                ? null
                : _imageUrl!.trim(),
          },
        );
      }
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Saved ✓ — live websites will pick it up on next load.');
      await _loadList();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Save failed: $e', isError: true);
    }
  }

  Future<void> _deleteSelected() async {
    final slug = _selectedSlug;
    if (slug == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete block?'),
        content: Text(
          '"$slug" will be removed. Public sites will fall back to their '
          'built-in content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.deleteBlock(slug);
      if (!mounted) return;
      setState(() => _selectedSlug = null);
      _snack('Deleted.');
      await _loadList();
    } catch (e) {
      if (!mounted) return;
      _snack('Delete failed: $e', isError: true);
    }
  }

  Future<void> _createBlock() async {
    final slug = _newSlugCtrl.text.trim().toLowerCase().replaceAll(' ', '-');
    if (slug.isEmpty) {
      _snack('Enter a block slug first (e.g. book2-login).', isError: true);
      return;
    }
    try {
      await _repo.saveBlock(
        slug,
        title: null,
        payload: const {'title': '', 'text_en': '', 'text_ur': ''},
      );
      if (!mounted) return;
      _newSlugCtrl.clear();
      _snack('Block created — now edit it.');
      await _loadList();
      await _selectBlock(slug);
    } catch (e) {
      if (!mounted) return;
      _snack('Create failed: $e', isError: true);
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isLanding) {
      _snack(
        'For the landing page, put the image URL inside the JSON.',
        isError: true,
      );
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) return;

    setState(() => _uploading = true);
    try {
      final url = await _repo.uploadImage(
        bytes: file.bytes!,
        fileName: file.name,
        filePath: file.path ?? '',
      );
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _imageUrl = url;
      });
      _snack('Screenshot uploaded ✓ — press Save to attach it.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      _snack('Upload failed: $e', isError: true);
    }
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }

  /// Resolves a relative /storage/… URL against the API origin.
  String _resolveMediaUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = Environment.apiBaseUrl;
    return base.endsWith('/')
        ? '${base}${url.replaceFirst('/', '')}'
        : '$base$url';
  }

  // ── UI ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 300, child: _buildBlockList()),
        const VerticalDivider(width: 1),
        Expanded(child: _buildEditor()),
      ],
    );
  }

  Widget _buildBlockList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newSlugCtrl,
                  decoration: const InputDecoration(
                    labelText: 'New block slug',
                    hintText: 'book2-login',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _createBlock(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Create block',
                icon: const Icon(Icons.add_circle),
                onPressed: _createBlock,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loadingList
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _blocks.length,
                  itemBuilder: (context, index) {
                    final block = _blocks[index];
                    final slug = block['slug']?.toString() ?? '';
                    final title = block['title']?.toString() ?? '';
                    return ListTile(
                      dense: true,
                      selected: slug == _selectedSlug,
                      leading: Icon(
                        slug == 'landing'
                            ? Icons.public
                            : Icons.article_outlined,
                        size: 20,
                      ),
                      title: Text(
                        title.isEmpty ? slug : title,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        slug,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () => _selectBlock(slug),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'landing  → traceodd.com\nbook2-* / book3-* → docs.traceodd.com',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildEditor() {
    if (_selectedSlug == null) {
      return const Center(
        child: Text('Select a block from the list — or create a new one.'),
      );
    }
    if (_loadingBlock) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Editing: $_selectedSlug',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Delete block',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: _deleteSelected,
              ),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text(_saving ? 'Saving…' : 'Save'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLanding) ...[
            const Text(
              'Landing page content (traceodd.com) — full JSON document. '
              'Edit any text/URL here and Save.',
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _jsonCtrl,
              maxLines: 24,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ] else ...[
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title (section heading)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textEnCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Text — English',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textUrCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Text — Roman Urdu',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _imageUrl ?? '(no screenshot)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _pickAndUploadImage,
                  icon: _uploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(_uploading ? 'Uploading…' : 'Upload'),
                ),
              ],
            ),
            if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: Image.network(
                  _resolveMediaUrl(_imageUrl!),
                  errorBuilder: (_, __, ___) => const Text(
                    '(image preview unavailable)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
