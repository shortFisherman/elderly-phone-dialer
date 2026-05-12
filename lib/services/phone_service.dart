import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PhoneService {
  static const _channel = MethodChannel('com.elderly.phone_call2/phone');

  const PhoneService();

  Future<bool> call(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }

    final status = await Permission.phone.request();
    if (!status.isGranted) {
      debugPrint('PhoneService: CALL_PHONE permission denied');
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('call', {
        'phoneNumber': cleaned,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('PhoneService: call failed - $e');
      return false;
    }
  }
}
