import 'package:flutter/services.dart';

class PhoneService {
  static const _channel = MethodChannel('com.elderly.phone_call2/phone');

  const PhoneService();

  Future<bool> call(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }
    try {
      final result = await _channel.invokeMethod<bool>('call', {
        'phoneNumber': cleaned,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}
