import 'package:flutter/foundation.dart';
import '../data/db/database_helper.dart';
import '../data/model/reminder.dart';
import '../utils/notification_helper.dart';
import '../common/request_state.dart';

class ReminderProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationHelper _notificationHelper = NotificationHelper();
  
  RequestState _state = RequestState.empty;
  List<Reminder> _reminders = [];
  String _message = '';

  RequestState get state => _state;
  List<Reminder> get reminders => _reminders;
  String get message => _message;

  Future<void> loadReminders() async {
    try {
      _state = RequestState.loading;
      notifyListeners();

      final reminders = await _databaseHelper.getReminders();
      _reminders = reminders;
      _state = reminders.isNotEmpty ? RequestState.data : RequestState.empty;
    } catch (e) {
      _state = RequestState.error;
      _message = 'Failed to load reminders: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadActiveReminders() async {
    try {
      _state = RequestState.loading;
      notifyListeners();

      final reminders = await _databaseHelper.getActiveReminders();
      _reminders = reminders;
      _state = reminders.isNotEmpty ? RequestState.data : RequestState.empty;
    } catch (e) {
      _state = RequestState.error;
      _message = 'Failed to load active reminders: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<bool> hasActiveReminderForRestaurant(String restaurantId) async {
    try {
      return await _databaseHelper.hasActiveReminderForRestaurant(restaurantId);
    } catch (e) {
      _message = 'Failed to check reminder: ${e.toString()}';
      return false;
    }
  }

  Future<Reminder?> getReminderByRestaurantId(String restaurantId) async {
    try {
      return await _databaseHelper.getReminderByRestaurantId(restaurantId);
    } catch (e) {
      _message = 'Failed to get reminder: ${e.toString()}';
      return null;
    }
  }

  Future<bool> addReminder({
    required String restaurantId,
    required String restaurantName,
    required int hour,
    required int minute,
    String? notificationMessage,
  }) async {
    try {
      // Check if reminder already exists for this restaurant
      final existingReminder = await _databaseHelper.getReminderByRestaurantId(restaurantId);
      if (existingReminder != null) {
        _message = 'Reminder already exists for this restaurant';
        return false;
      }

      final reminder = Reminder(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        hour: hour,
        minute: minute,
        notificationMessage: notificationMessage ?? 'Time to visit $restaurantName!',
      );

      final id = await _databaseHelper.insertReminder(reminder);
      
      // Schedule the alarm
      await _scheduleAlarm(reminder.copyWith(id: id));
      
      await loadActiveReminders();
      _message = 'Reminder added successfully';
      return true;
    } catch (e) {
      _message = 'Failed to add reminder: ${e.toString()}';
      return false;
    }
  }

  Future<bool> updateReminder({
    required int id,
    required int hour,
    required int minute,
    String? notificationMessage,
  }) async {
    try {
      final existingReminder = _reminders.firstWhere((r) => r.id == id);
      
      // Cancel existing alarm
      await _cancelAlarm(id);
      
      final updatedReminder = existingReminder.copyWith(
        hour: hour,
        minute: minute,
        notificationMessage: notificationMessage,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateReminder(updatedReminder);
      
      // Schedule new alarm
      await _scheduleAlarm(updatedReminder);
      
      await loadActiveReminders();
      _message = 'Reminder updated successfully';
      return true;
    } catch (e) {
      _message = 'Failed to update reminder: ${e.toString()}';
      return false;
    }
  }

  Future<bool> deleteReminder(int id) async {
    try {
      // Cancel the alarm
      await _cancelAlarm(id);
      
      // Delete from database
      await _databaseHelper.deleteReminder(id);
      
      await loadActiveReminders();
      _message = 'Reminder deleted successfully';
      return true;
    } catch (e) {
      _message = 'Failed to delete reminder: ${e.toString()}';
      return false;
    }
  }

  Future<bool> deleteReminderByRestaurantId(String restaurantId) async {
    try {
      // Get the reminder first to cancel the alarm
      final reminder = await _databaseHelper.getReminderByRestaurantId(restaurantId);
      if (reminder != null && reminder.id != null) {
        await _cancelAlarm(reminder.id!);
      }
      
      // Delete from database
      await _databaseHelper.deleteReminderByRestaurantId(restaurantId);
      
      await loadActiveReminders();
      _message = 'Reminder deleted successfully';
      return true;
    } catch (e) {
      _message = 'Failed to delete reminder: ${e.toString()}';
      return false;
    }
  }

  Future<bool> toggleReminderStatus(int id, bool isActive) async {
    try {
      if (isActive) {
        // Find the reminder and schedule alarm
        final reminder = _reminders.firstWhere((r) => r.id == id);
        await _scheduleAlarm(reminder);
      } else {
        // Cancel the alarm
        await _cancelAlarm(id);
      }
      
      await _databaseHelper.toggleReminderStatus(id, isActive);
      await loadActiveReminders();
      
      _message = isActive ? 'Reminder activated' : 'Reminder deactivated';
      return true;
    } catch (e) {
      _message = 'Failed to toggle reminder: ${e.toString()}';
      return false;
    }
  }

  Future<void> _scheduleAlarm(Reminder reminder) async {
    if (reminder.id == null) return;

    final now = DateTime.now();
    var scheduledDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    // Schedule the notification for both iOS and Android
    await _notificationHelper.scheduleReminderNotification(
      reminder.id!,
      'Restaurant Reminder - ${reminder.restaurantName}',
      reminder.notificationMessage ?? 'Time to visit ${reminder.restaurantName}!',
      scheduledDateTime,
      reminder.restaurantId,
    );
  }

  Future<void> _cancelAlarm(int id) async {
    // Cancel the scheduled notification
    await _notificationHelper.cancelScheduledNotification(id);
  }

  void clearMessage() {
    _message = '';
    notifyListeners();
  }
}