import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/playlist_source.dart';
import '../../providers/playlist_source_provider.dart';
import '../../services/playlist_fetch_service.dart';

class AddPlaylistSheet extends ConsumerStatefulWidget {
  const AddPlaylistSheet({super.key});

  @override
  ConsumerState<AddPlaylistSheet> createState() => _AddPlaylistSheetState();
}

class _AddPlaylistSheetState extends ConsumerState<AddPlaylistSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  PlaylistType _type = PlaylistType.direct;
  bool _testing = false;
  String? _testResult;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Add Playlist',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<PlaylistType>(
                    segments: const [
                      ButtonSegment(
                        value: PlaylistType.direct,
                        label: Text('Direct URL'),
                        icon: Icon(Icons.link),
                      ),
                      ButtonSegment(
                        value: PlaylistType.xtreamCodes,
                        label: Text('Xtream'),
                        icon: Icon(Icons.dns),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) =>
                        setState(() => _type = s.first),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: _type == PlaylistType.direct
                          ? 'M3U URL'
                          : 'Server URL',
                      hintText: _type == PlaylistType.direct
                          ? 'https://example.com/playlist.m3u'
                          : 'http://server:port',
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: _type == PlaylistType.xtreamCodes
                        ? TextInputAction.next
                        : TextInputAction.done,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final uri = Uri.tryParse(v);
                      if (uri == null || !uri.hasScheme) return 'Invalid URL';
                      return null;
                    },
                  ),
                  if (_type == PlaylistType.xtreamCodes) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration:
                          const InputDecoration(labelText: 'Username'),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          _type == PlaylistType.xtreamCodes &&
                                  (v == null || v.isEmpty)
                              ? 'Required'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration:
                          const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          _type == PlaylistType.xtreamCodes &&
                                  (v == null || v.isEmpty)
                              ? 'Required'
                              : null,
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (_testResult != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _testResult!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _testResult!.startsWith('Success')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  OutlinedButton.icon(
                    onPressed: _testing ? null : _testConnection,
                    icon: _testing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering),
                    label:
                        Text(_testing ? 'Testing...' : 'Test Connection'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add Playlist'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testing = true;
      _testResult = null;
    });

    final source = _buildSource();
    final ok =
        await PlaylistFetchService.testConnection(source.effectiveUrl);

    if (mounted) {
      setState(() {
        _testing = false;
        _testResult =
            ok ? 'Success! Connection works.' : 'Failed to connect.';
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final source = _buildSource();
    ref.read(playlistSourcesProvider.notifier).add(source);
    Navigator.pop(context);
  }

  PlaylistSource _buildSource() {
    return PlaylistSource(
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      username: _type == PlaylistType.xtreamCodes
          ? _usernameController.text.trim()
          : null,
      password: _type == PlaylistType.xtreamCodes
          ? _passwordController.text.trim()
          : null,
      type: _type,
    );
  }
}
