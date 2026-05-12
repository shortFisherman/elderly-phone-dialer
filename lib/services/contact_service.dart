import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:phone_call2/models/contact.dart';

class ContactService extends ChangeNotifier {
  final List<Contact> _contacts = [];
  final Uuid _uuid = const Uuid();
  int _nextColorIndex = 0;
  static const int _colorCount = 10;
  static const int maxContacts = 30;

  ContactService() {
    _load();
  }

  ContactService.test() {
    // In-memory only, skip file load
  }

  List<Contact> getAll() => List.unmodifiable(_contacts);

  Contact add(Contact contact) {
    if (_contacts.length >= maxContacts) {
      throw StateError('Maximum of $maxContacts contacts reached');
    }
    final newContact = Contact(
      id: _uuid.v4(),
      name: contact.name,
      phoneNumber: contact.phoneNumber,
      photoPath: contact.photoPath,
      colorIndex: _nextColorIndex % _colorCount,
    );
    _nextColorIndex++;
    _contacts.add(newContact);
    notifyListeners();
    _save();
    return newContact;
  }

  Contact update(Contact contact) {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index == -1) throw StateError('Contact not found');
    _contacts[index] = contact;
    notifyListeners();
    _save();
    return contact;
  }

  void delete(String id) {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/contacts.json');
    final json = _contacts.map((c) => c.toJson()).toList();
    await file.writeAsString(jsonEncode(json));
  }

  Future<void> _load() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/contacts.json');
    if (await file.exists()) {
      final json = jsonDecode(await file.readAsString()) as List<dynamic>;
      _contacts.clear();
      _contacts.addAll(json.map((j) => Contact.fromJson(j as Map<String, dynamic>)));
      if (_contacts.isNotEmpty) {
        _nextColorIndex = _contacts.last.colorIndex + 1;
      }
    }
  }
}
