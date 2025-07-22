import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/reminder_provider.dart';
import '../data/model/reminder.dart';
import '../common/request_state.dart';
import '../common/styles.dart';

class AlarmPage extends StatefulWidget {
  static const routeName = '/alarm';
  
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReminderProvider>(context, listen: false).loadActiveReminders();
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<ReminderProvider>(context, listen: false).loadActiveReminders();
  }

  Future<void> _showEditReminderDialog(Reminder reminder) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${reminder.restaurantName} Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current time: ${reminder.timeString}'),
            const SizedBox(height: 16),
            Text('What would you like to do?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editReminderTime(reminder);
            },
            child: const Text('Edit Time'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteReminder(reminder);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _editReminderTime(Reminder reminder) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
    );

    if (selectedTime != null && mounted) {
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      final success = await reminderProvider.updateReminder(
        id: reminder.id!,
        hour: selectedTime.hour,
        minute: selectedTime.minute,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder updated to ${selectedTime.format(context)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reminderProvider.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
    final success = await reminderProvider.deleteReminder(reminder.id!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reminderProvider.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleReminder(Reminder reminder, bool value) async {
    final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
    await reminderProvider.toggleReminderStatus(reminder.id!, value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        if (reminderProvider.state == RequestState.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: reminderProvider.reminders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.alarm_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Restaurant Reminders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Set reminders for your favorite restaurants\nfrom their detail pages',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: reminderProvider.reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminderProvider.reminders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor,
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            reminder.restaurantName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Reminder time: ${reminder.timeString}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (reminder.notificationMessage != null)
                                Text(
                                  reminder.notificationMessage!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          trailing: Switch(
                            value: reminder.isActive,
                            onChanged: (value) async {
                              await _toggleReminder(reminder, value);
                            },
                          ),
                          onTap: () => _showEditReminderDialog(reminder),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}