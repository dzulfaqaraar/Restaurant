import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant/data/model/reminder.dart';

void main() {
  group('Reminder Model Tests', () {
    final testDateTime = DateTime(2024, 1, 15, 10, 30);
    
    test('should create Reminder with all fields', () {
      // Arrange & Act
      final reminder = Reminder(
        id: 1,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
        hour: 14,
        minute: 30,
        isActive: true,
        notificationMessage: 'Time to visit!',
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      // Assert
      expect(reminder.id, 1);
      expect(reminder.restaurantId, 'restaurant_1');
      expect(reminder.restaurantName, 'Test Restaurant');
      expect(reminder.hour, 14);
      expect(reminder.minute, 30);
      expect(reminder.isActive, true);
      expect(reminder.notificationMessage, 'Time to visit!');
      expect(reminder.createdAt, testDateTime);
      expect(reminder.updatedAt, testDateTime);
    });

    test('should create Reminder with default values', () {
      // Arrange & Act
      final reminder = Reminder(
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
        hour: 14,
        minute: 30,
      );

      // Assert
      expect(reminder.id, null);
      expect(reminder.isActive, true);
      expect(reminder.notificationMessage, null);
      expect(reminder.createdAt, isA<DateTime>());
      expect(reminder.updatedAt, isA<DateTime>());
    });

    test('should format time string correctly', () {
      // Arrange
      final reminder1 = Reminder(
        restaurantId: 'test',
        restaurantName: 'Test',
        hour: 9,
        minute: 5,
      );
      
      final reminder2 = Reminder(
        restaurantId: 'test',
        restaurantName: 'Test',
        hour: 14,
        minute: 30,
      );

      // Act & Assert
      expect(reminder1.timeString, '09:05');
      expect(reminder2.timeString, '14:30');
    });

    test('should convert to map correctly', () {
      // Arrange
      final reminder = Reminder(
        id: 1,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
        hour: 14,
        minute: 30,
        isActive: true,
        notificationMessage: 'Time to visit!',
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      // Act
      final map = reminder.toMap();

      // Assert
      expect(map['id'], 1);
      expect(map['restaurant_id'], 'restaurant_1');
      expect(map['restaurant_name'], 'Test Restaurant');
      expect(map['hour'], 14);
      expect(map['minute'], 30);
      expect(map['is_active'], 1);
      expect(map['notification_message'], 'Time to visit!');
      expect(map['created_at'], testDateTime.toIso8601String());
      expect(map['updated_at'], testDateTime.toIso8601String());
    });

    test('should create from map correctly', () {
      // Arrange
      final map = {
        'id': 1,
        'restaurant_id': 'restaurant_1',
        'restaurant_name': 'Test Restaurant',
        'hour': 14,
        'minute': 30,
        'is_active': 1,
        'notification_message': 'Time to visit!',
        'created_at': testDateTime.toIso8601String(),
        'updated_at': testDateTime.toIso8601String(),
      };

      // Act
      final reminder = Reminder.fromMap(map);

      // Assert
      expect(reminder.id, 1);
      expect(reminder.restaurantId, 'restaurant_1');
      expect(reminder.restaurantName, 'Test Restaurant');
      expect(reminder.hour, 14);
      expect(reminder.minute, 30);
      expect(reminder.isActive, true);
      expect(reminder.notificationMessage, 'Time to visit!');
      expect(reminder.createdAt, testDateTime);
      expect(reminder.updatedAt, testDateTime);
    });

    test('should handle inactive state correctly', () {
      // Arrange
      final map = {
        'id': 1,
        'restaurant_id': 'restaurant_1',
        'restaurant_name': 'Test Restaurant',
        'hour': 14,
        'minute': 30,
        'is_active': 0,
        'notification_message': 'Time to visit!',
        'created_at': testDateTime.toIso8601String(),
        'updated_at': testDateTime.toIso8601String(),
      };

      // Act
      final reminder = Reminder.fromMap(map);

      // Assert
      expect(reminder.isActive, false);
    });

    test('should create copy with updated fields', () {
      // Arrange
      final originalReminder = Reminder(
        id: 1,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
        hour: 14,
        minute: 30,
        isActive: true,
        createdAt: testDateTime,
        updatedAt: testDateTime,
      );

      // Act
      final updatedReminder = originalReminder.copyWith(
        hour: 16,
        minute: 45,
        isActive: false,
      );

      // Assert
      expect(updatedReminder.id, 1);
      expect(updatedReminder.restaurantId, 'restaurant_1');
      expect(updatedReminder.restaurantName, 'Test Restaurant');
      expect(updatedReminder.hour, 16);
      expect(updatedReminder.minute, 45);
      expect(updatedReminder.isActive, false);
      expect(updatedReminder.createdAt, testDateTime);
      expect(updatedReminder.updatedAt, testDateTime);
    });

    test('should implement equality correctly', () {
      // Arrange
      final reminder1 = Reminder(
        id: 1,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
        hour: 14,
        minute: 30,
      );

      final reminder2 = Reminder(
        id: 1,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
        hour: 14,
        minute: 30,
      );

      final reminder3 = Reminder(
        id: 2,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
        hour: 14,
        minute: 30,
      );

      // Act & Assert
      expect(reminder1, equals(reminder2));
      expect(reminder1, isNot(equals(reminder3)));
      expect(reminder1.hashCode, equals(reminder2.hashCode));
    });

    test('should convert to string correctly', () {
      // Arrange
      final reminder = Reminder(
        id: 1,
        restaurantId: 'restaurant_1',
        restaurantName: 'Test Restaurant',
        hour: 14,
        minute: 30,
        isActive: true,
      );

      // Act
      final stringRepresentation = reminder.toString();

      // Assert
      expect(stringRepresentation, contains('Test Restaurant'));
      expect(stringRepresentation, contains('14:30'));
      expect(stringRepresentation, contains('true'));
    });
  });
}