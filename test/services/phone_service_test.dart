import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/services/phone_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PhoneService service;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.elderly.phone_call2/phone'),
      (MethodCall methodCall) async => true,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'requestPermissions') {
          return {'status': 1}; // granted
        }
        return null;
      },
    );
    service = const PhoneService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.elderly.phone_call2/phone'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      null,
    );
  });

  test('call strips non-digit characters and returns true', () async {
    final result = await service.call('138-0000-1111');
    expect(result, true);
  });

  test('call throws ArgumentError for empty phone number', () async {
    expect(() => service.call(''), throwsA(isA<ArgumentError>()));
  });

  test('call throws ArgumentError for whitespace-only', () async {
    expect(() => service.call('  '), throwsA(isA<ArgumentError>()));
  });
}
