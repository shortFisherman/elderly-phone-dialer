import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/colors.dart';
import 'package:phone_call2/services/photo_service.dart';

/// Management screen for viewing, adding, editing, and deleting contacts.
///
/// Shows a scrollable list of contact cards with edit/delete actions and a FAB
/// for adding new contacts. An AppBar "完成" button calls [onClose] to return
/// to the home screen.
class ManageScreen extends StatefulWidget {
  /// The initial list of contacts to display.
  final List<Contact> contacts;

  /// Called whenever a contact is saved (created or updated).
  final Function(Contact)? onSave;

  /// Called when a contact is deleted, receiving the contact's [Contact.id].
  final Function(String)? onDelete;

  /// Called when the user taps the "完成" button in the AppBar.
  final VoidCallback? onClose;

  const ManageScreen({
    super.key,
    required this.contacts,
    this.onSave,
    this.onDelete,
    this.onClose,
  });

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final PhotoService _photoService = const PhotoService();
  late List<Contact> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = List.from(widget.contacts);
  }

  // ---------------------------------------------------------------------------
  // Editor navigation
  // ---------------------------------------------------------------------------

  /// Opens the [_ContactEditor] for a new contact when [contact] is null, or
  /// for editing an existing contact otherwise.
  void _openEditor(Contact? contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ContactEditor(
          contact: contact,
          photoService: _photoService,
          onSave: (updated) {
            setState(() {
              if (contact == null) {
                _contacts.add(updated);
              } else {
                final idx = _contacts.indexWhere((c) => c.id == updated.id);
                if (idx != -1) _contacts[idx] = updated;
              }
            });
            widget.onSave?.call(updated);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Contact deletion
  // ---------------------------------------------------------------------------

  void _deleteContact(Contact contact) {
    setState(() {
      _contacts.removeWhere((c) => c.id == contact.id);
    });
    widget.onDelete?.call(contact.id);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理联系人'),
        actions: [
          TextButton(
            onPressed: widget.onClose,
            child: const Text('完成'),
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text('暂无联系人'))
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) =>
                  _buildContactCard(_contacts[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContactCard(Contact contact) {
    final color = getContactColor(contact.colorIndex);
    final hasPhoto =
        contact.photoPath.isNotEmpty && File(contact.photoPath).existsSync();

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color,
          backgroundImage:
              hasPhoto ? FileImage(File(contact.photoPath)) : null,
          child: hasPhoto
              ? null
              : const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(contact.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(contact.phoneNumber,
            style: TextStyle(color: Colors.grey[600])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _openEditor(contact),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteContact(contact),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _ContactEditor
// =============================================================================

/// Inline widget for adding a new contact or editing an existing one.
///
/// Pushed as a full-screen route from [ManageScreen]. Provides a photo picker
/// area, name and phone text fields, and a "保存联系人" save button.
class _ContactEditor extends StatefulWidget {
  /// The contact to edit, or null to create a new contact.
  final Contact? contact;

  /// Service used for picking and saving a contact photo.
  final PhotoService photoService;

  /// Called with the saved [Contact] (new or updated) before the route is popped.
  final Function(Contact) onSave;

  const _ContactEditor({
    this.contact,
    required this.photoService,
    required this.onSave,
  });

  @override
  State<_ContactEditor> createState() => _ContactEditorState();
}

class _ContactEditorState extends State<_ContactEditor> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String _photoPath = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.contact?.phoneNumber ?? '');
    _photoPath = widget.contact?.photoPath ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Photo picking
  // ---------------------------------------------------------------------------

  Future<void> _pickPhoto() async {
    final path = await widget.photoService.pickAndSave();
    if (path.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('存储空间不足，请清理后重试')),
        );
      }
      return;
    }
    setState(() => _photoPath = path);
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  void _save() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) return;

    final contact = widget.contact != null
        ? widget.contact!.copyWith(
            name: name,
            phoneNumber: phone,
            photoPath: _photoPath,
          )
        : Contact(
            id: const Uuid().v4(),
            name: name,
            phoneNumber: phone,
            photoPath: _photoPath,
            colorIndex:
                DateTime.now().millisecondsSinceEpoch % contactColors.length,
          );

    widget.onSave(contact);
    Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;
    final color = getContactColor(widget.contact?.colorIndex ?? 0);
    final hasPhoto = _photoPath.isNotEmpty && File(_photoPath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑联系人' : '添加联系人'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: color,
                backgroundImage:
                    hasPhoto ? FileImage(File(_photoPath)) : null,
                child: hasPhoto
                    ? null
                    : const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _pickPhoto,
              child: const Text('选择照片'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '电话号码'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _save,
                child: const Text('保存联系人',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
