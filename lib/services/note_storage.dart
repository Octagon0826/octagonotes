
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NoteStorage {
  static const String _storageKey = 'octagonotes_notes';

  // Mengambil seluruh catatan.
  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(_storageKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(data);

    return decoded
        .map((item) => Note.fromMap(item))
        .toList();
  }

  // Menyimpan seluruh catatan.
  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();

    final String data = jsonEncode(
      notes.map((note) => note.toMap()).toList(),
    );

    await prefs.setString(_storageKey, data);
  }

  // Menambahkan catatan.
  Future<void> addNote(Note note) async {
    final notes = await getNotes();

    notes.insert(0, note);

    await saveNotes(notes);
  }

  // Memperbarui catatan.
  Future<void> updateNote(Note updatedNote) async {
    final notes = await getNotes();

    final index = notes.indexWhere(
      (note) => note.id == updatedNote.id,
    );

    if (index != -1) {
      notes[index] = updatedNote;
      await saveNotes(notes);
    }
  }

  // Menghapus catatan.
  Future<void> deleteNote(String id) async {
    final notes = await getNotes();

    notes.removeWhere((note) => note.id == id);

    await saveNotes(notes);
  }
}
