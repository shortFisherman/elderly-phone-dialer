import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/models/contact.dart';
import 'package:phone_call2/services/contact_service.dart';

void main() {
  late ContactService service;

  setUp(() {
    service = ContactService.test();
  });

  test('getAll returns empty list initially', () {
    expect(service.getAll(), isEmpty);
  });

  test('add inserts contact and assigns color', () {
    final contact = Contact(id: '', name: 'Test', phoneNumber: '123', photoPath: '/p.jpg', colorIndex: 0);
    final added = service.add(contact);
    expect(added.id, isNotEmpty);
    expect(added.colorIndex, 0);
    expect(service.getAll().length, 1);
  });

  test('add increments colorIndex for subsequent contacts', () {
    service.add(Contact(id: '', name: 'A', phoneNumber: '1', photoPath: '/a.jpg', colorIndex: 0));
    final second = service.add(Contact(id: '', name: 'B', phoneNumber: '2', photoPath: '/b.jpg', colorIndex: 0));
    expect(second.colorIndex, 1);
  });

  test('update modifies existing contact', () {
    final added = service.add(Contact(id: '', name: 'Old', phoneNumber: '1', photoPath: '/a.jpg', colorIndex: 0));
    final updated = service.update(added.copyWith(name: 'New'));
    expect(updated.name, 'New');
    expect(service.getAll().first.name, 'New');
  });

  test('delete removes contact', () {
    final added = service.add(Contact(id: '', name: 'X', phoneNumber: '1', photoPath: '/a.jpg', colorIndex: 0));
    service.delete(added.id);
    expect(service.getAll(), isEmpty);
  });

  test('max 30 contacts enforced', () {
    for (int i = 0; i < 30; i++) {
      service.add(Contact(id: '', name: 'C$i', phoneNumber: '$i', photoPath: '/p.jpg', colorIndex: 0));
    }
    expect(() => service.add(Contact(id: '', name: 'Extra', phoneNumber: '99', photoPath: '/p.jpg', colorIndex: 0)),
        throwsA(isA<StateError>()));
  });
}
