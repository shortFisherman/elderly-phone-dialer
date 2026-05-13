import 'package:flutter/material.dart';
import 'package:phone_call2/services/contact_service.dart';
import 'package:phone_call2/screens/home_screen.dart';
import 'package:phone_call2/screens/manage_screen.dart';

class ElderlyPhoneApp extends StatelessWidget {
  const ElderlyPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '亲情电话',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final ContactService _contactService = ContactService();
  bool _inManageMode = false;

  @override
  void initState() {
    super.initState();
    _contactService.addListener(_onContactsChanged);
  }

  @override
  void dispose() {
    _contactService.removeListener(_onContactsChanged);
    super.dispose();
  }

  void _onContactsChanged() {
    if (mounted) setState(() {});
  }

  void _enterManageMode() {
    setState(() => _inManageMode = true);
  }

  void _exitManageMode() {
    setState(() => _inManageMode = false);
    if (_contactService.getAll().isEmpty) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _contactService.ready,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (_inManageMode) {
          return ManageScreen(
            contacts: List.from(_contactService.getAll()),
            onSave: (contact) {
              final exists =
                  _contactService.getAll().any((c) => c.id == contact.id);
              if (exists) {
                _contactService.update(contact);
              } else {
                _contactService.add(contact);
              }
            },
            onDelete: (id) => _contactService.delete(id),
            onClose: _exitManageMode,
          );
        }

        final contacts = _contactService.getAll();

        if (contacts.isEmpty) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _enterManageMode());
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return HomeScreen(
          contacts: contacts,
          onManageTap: _enterManageMode,
        );
      },
    );
  }
}
