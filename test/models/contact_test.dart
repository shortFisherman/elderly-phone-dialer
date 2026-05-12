import 'package:flutter_test/flutter_test.dart';
import 'package:phone_call2/models/contact.dart';

void main() {
  group('Contact', () {
    test('toJson and fromJson round-trip', () {
      final contact = Contact(
        id: 'id-1',
        name: 'Son',
        phoneNumber: '13900002222',
        photoPath: '/photos/son.jpg',
        colorIndex: 0,
      );
      final json = contact.toJson();
      final restored = Contact.fromJson(json);
      expect(restored.id, contact.id);
      expect(restored.name, contact.name);
      expect(restored.phoneNumber, contact.phoneNumber);
      expect(restored.photoPath, contact.photoPath);
      expect(restored.colorIndex, contact.colorIndex);
    });

    test('copyWith returns new instance with updated fields', () {
      final contact = Contact(
        id: 'id-3',
        name: 'Dad',
        phoneNumber: '13600004444',
        photoPath: '/photos/dad.jpg',
        colorIndex: 1,
      );
      final updated = contact.copyWith(name: 'NewDad');
      expect(updated.id, contact.id);
      expect(updated.name, 'NewDad');
      expect(updated.phoneNumber, contact.phoneNumber);
      expect(updated.photoPath, contact.photoPath);
    });
  });
}
