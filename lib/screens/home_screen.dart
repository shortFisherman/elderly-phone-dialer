import 'dart:async';
import 'package:flutter/material.dart';

import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/phone_service.dart';
import 'package:phone_call2/widgets/contact_avatar.dart';

/// The main home screen -- a 3-column photo grid for elderly users.
///
/// Each contact is shown as a [ContactAvatar].  Long-pressing an avatar places
/// a phone call via [PhoneService].  A small "+" button in the bottom-right
/// corner requires five consecutive taps to enter management mode (a safety
/// measure against accidental activation).
class HomeScreen extends StatefulWidget {
  /// The contacts to display in the grid.
  final List<Contact> contacts;

  /// Called after five consecutive taps on the "+" button.
  final VoidCallback onManageTap;

  const HomeScreen({
    super.key,
    required this.contacts,
    required this.onManageTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PhoneService _phoneService = const PhoneService();
  int _plusTapCount = 0;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _call(Contact contact) async {
    await _phoneService.call(contact.phoneNumber);
  }

  void _onPlusTap() {
    _resetTimer?.cancel();
    _plusTapCount++;
    if (_plusTapCount >= 5) {
      _plusTapCount = 0;
      widget.onManageTap();
    } else {
      _resetTimer = Timer(const Duration(seconds: 3), () {
        _plusTapCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Center(
          child: Container(
            width: 120,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
      ),
      body: widget.contacts.isEmpty ? _buildEmptyState() : _buildGrid(),
      floatingActionButton: _buildPlusButton(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.contacts_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '点击右下角 + 添加联系人',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.contacts.length,
      itemBuilder: (context, index) {
        final contact = widget.contacts[index];
        return ContactAvatar(
          contact: contact,
          size: 88,
          onLongPress: () => _call(contact),
        );
      },
    );
  }

  Widget _buildPlusButton() {
    return GestureDetector(
      onTap: _onPlusTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.8),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Icon(Icons.add, size: 18, color: Colors.grey[600]),
      ),
    );
  }
}
