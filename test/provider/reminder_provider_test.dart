import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant/provider/reminder_provider.dart';
import 'package:restaurant/common/request_state.dart';

void main() {
  group('ReminderProvider Tests', () {
    late ReminderProvider reminderProvider;

    setUp(() {
      reminderProvider = ReminderProvider();
    });

    group('Initial State Tests', () {
      test('should have correct initial state', () {
        // Assert
        expect(reminderProvider.state, RequestState.empty);
        expect(reminderProvider.reminders, isEmpty);
        expect(reminderProvider.message, '');
      });
    });

    group('Message Management', () {
      test('should clear message', () {
        // Arrange
        reminderProvider.clearMessage();

        // Act & Assert
        expect(reminderProvider.message, '');
      });
    });

    group('State Management', () {
      test('should notify listeners when clearing message', () {
        // Arrange
        var notifyCount = 0;
        reminderProvider.addListener(() {
          notifyCount++;
        });

        // Act
        reminderProvider.clearMessage();

        // Assert
        expect(notifyCount, 1);
      });
    });
  });
}