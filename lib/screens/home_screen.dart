
import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_storage.dart';
import '../widgets/note_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteStorage _storage = NoteStorage();

  List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await _storage.getNotes();

      if (!mounted) return;

      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint('Gagal memuat catatan: $e');
    }
  }

  Future<void> _showNoteDialog({Note? note}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return NoteEditorDialog(note: note);
      },
    );

    if (result == null || !mounted) return;

    final now = DateTime.now();

    try {
      if (note == null) {
        await _storage.addNote(
          Note(
            id: now.microsecondsSinceEpoch.toString(),
            title: result['title']!,
            content: result['content']!,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await _storage.updateNote(
          Note(
            id: note.id,
            title: result['title']!,
            content: result['content']!,
            createdAt: note.createdAt,
            updatedAt: now,
          ),
        );
      }

      await _loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            note == null
                ? 'Catatan berhasil ditambahkan'
                : 'Catatan berhasil diperbarui',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Gagal menyimpan catatan: $e');
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Catatan?'),
          content: Text(
            'Apakah kamu yakin ingin menghapus "${note.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await _storage.deleteNote(note.id);
      await _loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan berhasil dihapus'),
        ),
      );
    } catch (e) {
      debugPrint('Gagal menghapus catatan: $e');
    }
  }

  List<Note> get _filteredNotes {
    final query = _searchQuery.toLowerCase();

    if (query.isEmpty) return _notes;

    return _notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.note_alt_outlined,
              size: 75,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Catatan tidak ditemukan'
                  : 'Belum ada catatan',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Coba gunakan kata kunci lain.'
                  : 'Mulai tulis ide dan kegiatanmu hari ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filteredNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.edit_note_rounded,
              color: Color(0xFF315C9B),
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'OCTAGONOTES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari catatan...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Catatan Saya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_notes.length} Catatan',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredNotes.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadNotes,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              4,
                              20,
                              100,
                            ),
                            itemCount: filteredNotes.length,
                            itemBuilder: (context, index) {
                              final note = filteredNotes[index];

                              return NoteCard(
                                note: note,
                                onEdit: () {
                                  _showNoteDialog(note: note);
                                },
                                onDelete: () {
                                  _deleteNote(note);
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Catatan Baru'),
      ),
    );
  }
}

class NoteEditorDialog extends StatefulWidget {
  final Note? note;

  const NoteEditorDialog({
    super.key,
    this.note,
  });

  @override
  State<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<NoteEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );

    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.note == null ? 'Catatan Baru' : 'Edit Catatan',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Catatan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Isi catatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _saveNote,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
