import 'dart:io';

import 'package:flutter/material.dart';

import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/colors.dart';

/// A circular avatar widget for a contact.
///
/// Displays the contact's photo if available, or a person icon placeholder.
/// Uses the contact's assigned color as the background. Supports a long-press
/// animation (scale up + shadow) and an [onLongPress] callback.
class ContactAvatar extends StatefulWidget {
  /// The contact whose photo and color to display.
  final Contact contact;

  /// The diameter of the avatar circle, in logical pixels.
  final double size;

  /// Called when the user long-presses the avatar.
  ///
  /// If null the long-press gesture is still recognised so the press animation
  /// plays, but no external action is triggered.
  final VoidCallback? onLongPress;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.size = 56.0,
    this.onLongPress,
  });

  @override
  State<ContactAvatar> createState() => _ContactAvatarState();
}

class _ContactAvatarState extends State<ContactAvatar> {
  bool _isPressed = false;

  ImageProvider? _resolvePhoto() {
    final path = widget.contact.photoPath;
    if (path.isEmpty) return null;

    final file = File(path);
    if (!file.existsSync()) return null;

    return FileImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final Color color = getContactColor(widget.contact.colorIndex);
    final double radius = widget.size / 2;
    final ImageProvider? photo = _resolvePhoto();

    return GestureDetector(
      onLongPressStart: (_) => _setPressed(true),
      onLongPressEnd: (_) => _setPressed(false),
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? color.withOpacity(0.5)
                    : color.withOpacity(0.2),
                blurRadius: _isPressed ? 12.0 : 4.0,
                spreadRadius: _isPressed ? 2.0 : 0.0,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: color,
            backgroundImage: photo,
            child: photo == null
                ? Icon(Icons.person, size: radius * 1.2, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }
}
