import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/ui/alarm_page.dart';
import 'package:restaurant/provider/reminder_provider.dart';
import 'package:restaurant/data/model/reminder.dart';
import 'package:restaurant/common/request_state.dart';

void main() {
  group('AlarmPage Widget Tests', () {
    Widget createTestWidget({List<Reminder> reminders = const [], RequestState state = RequestState.data}) {
      return MaterialApp(
        home: ChangeNotifierProvider<ReminderProvider>(
          create: (_) => MockReminderProvider(reminders: reminders, state: state),
          child: const AlarmPage(),
        ),
      );
    }

    group('Empty State Tests', () {
      testWidgets('should show empty state when no reminders exist', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(reminders: [], state: RequestState.empty));
        await tester.pumpAndSettle();

        // Check for empty state elements
        expect(find.byIcon(Icons.alarm_off), findsOneWidget);
        expect(find.text('No Restaurant Reminders'), findsOneWidget);
        expect(find.text('Set reminders for your favorite restaurants\nfrom their detail pages'), findsOneWidget);
      });
    });

    group('Loading State Tests', () {
      testWidgets('should show loading indicator when loading', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(state: RequestState.loading));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('Reminder List Tests', () {
      testWidgets('should display list of reminders when data is available', (WidgetTester tester) async {
        final testReminders = [
          Reminder(
            id: 1,
            restaurantId: 'restaurant_1',
            restaurantName: 'Restaurant A',
            hour: 12,
            minute: 0,
            isActive: true,
            notificationMessage: 'Time to visit Restaurant A!',
          ),
          Reminder(
            id: 2,
            restaurantId: 'restaurant_2',
            restaurantName: 'Restaurant B',
            hour: 18,
            minute: 30,
            isActive: true,
            notificationMessage: 'Time to visit Restaurant B!',
          ),
        ];

        await tester.pumpWidget(createTestWidget(reminders: testReminders));
        await tester.pumpAndSettle();

        // Check for reminder cards
        expect(find.byType(Card), findsNWidgets(2));
        expect(find.text('Restaurant A'), findsOneWidget);
        expect(find.text('Restaurant B'), findsOneWidget);
        expect(find.text('Reminder time: 12:00'), findsOneWidget);
        expect(find.text('Reminder time: 18:30'), findsOneWidget);
      });

      testWidgets('should show restaurant icon in each reminder card', (WidgetTester tester) async {
        final testReminders = [
          Reminder(
            id: 1,
            restaurantId: 'restaurant_1',
            restaurantName: 'Test Restaurant',
            hour: 14,
            minute: 30,
            isActive: true,
          ),
        ];

        await tester.pumpWidget(createTestWidget(reminders: testReminders));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.restaurant), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
      });

      testWidgets('should show switch for each reminder', (WidgetTester tester) async {
        final testReminders = [
          Reminder(
            id: 1,
            restaurantId: 'restaurant_1',
            restaurantName: 'Test Restaurant',
            hour: 14,
            minute: 30,
            isActive: true,
          ),
        ];

        await tester.pumpWidget(createTestWidget(reminders: testReminders));
        await tester.pumpAndSettle();

        expect(find.byType(Switch), findsOneWidget);
        
        final switch_ = tester.widget<Switch>(find.byType(Switch));
        expect(switch_.value, true);
      });

      testWidgets('should show notification message when available', (WidgetTester tester) async {
        final testReminders = [
          Reminder(
            id: 1,
            restaurantId: 'restaurant_1',
            restaurantName: 'Test Restaurant',
            hour: 14,
            minute: 30,
            isActive: true,
            notificationMessage: 'Custom reminder message',
          ),
        ];

        await tester.pumpWidget(createTestWidget(reminders: testReminders));
        await tester.pumpAndSettle();

        expect(find.text('Custom reminder message'), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should trigger onTap when reminder card is tapped', (WidgetTester tester) async {
        final testReminders = [
          Reminder(
            id: 1,
            restaurantId: 'restaurant_1',
            restaurantName: 'Test Restaurant',
            hour: 14,
            minute: 30,
            isActive: true,
          ),
        ];

        await tester.pumpWidget(createTestWidget(reminders: testReminders));
        await tester.pumpAndSettle();

        // Tap on the ListTile
        await tester.tap(find.byType(ListTile));
        await tester.pump();

        // The tap should not cause errors (actual dialog testing would require more complex setup)
        expect(tester.takeException(), isNull);
      });

      testWidgets('should support pull-to-refresh', (WidgetTester tester) async {
        final testReminders = [
          Reminder(
            id: 1,
            restaurantId: 'restaurant_1',
            restaurantName: 'Test Restaurant',
            hour: 14,
            minute: 30,
            isActive: true,
          ),
        ];

        await tester.pumpWidget(createTestWidget(reminders: testReminders));
        await tester.pumpAndSettle();

        // Find the RefreshIndicator
        expect(find.byType(RefreshIndicator), findsOneWidget);

        // Perform pull-to-refresh gesture
        await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
        await tester.pump();

        // Should not cause errors
        expect(tester.takeException(), isNull);
      });
    });

    group('Time Display Tests', () {
      testWidgets('should format time correctly in display', (WidgetTester tester) async {
        final testReminders = [
          Reminder(
            id: 1,
            restaurantId: 'restaurant_1',
            restaurantName: 'Test Restaurant',
            hour: 9,
            minute: 5,
            isActive: true,
          ),
          Reminder(
            id: 2,
            restaurantId: 'restaurant_2',
            restaurantName: 'Another Restaurant',
            hour: 23,
            minute: 59,
            isActive: true,
          ),
        ];

        await tester.pumpWidget(createTestWidget(reminders: testReminders));
        await tester.pumpAndSettle();

        expect(find.text('Reminder time: 09:05'), findsOneWidget);
        expect(find.text('Reminder time: 23:59'), findsOneWidget);
      });
    });

    group('Card Layout Tests', () {
      testWidgets('should have proper card margins and spacing', (WidgetTester tester) async {
        final testReminders = [
          Reminder(
            id: 1,
            restaurantId: 'restaurant_1',
            restaurantName: 'Test Restaurant',
            hour: 14,
            minute: 30,
            isActive: true,
          ),
        ];

        await tester.pumpWidget(createTestWidget(reminders: testReminders));
        await tester.pumpAndSettle();

        final card = tester.widget<Card>(find.byType(Card));
        expect(card.margin, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
      });

      testWidgets('should show subtitle with proper layout', (WidgetTester tester) async {
        final testReminders = [
          Reminder(
            id: 1,
            restaurantId: 'restaurant_1',
            restaurantName: 'Test Restaurant',
            hour: 14,
            minute: 30,
            isActive: true,
            notificationMessage: 'Test message',
          ),
        ];

        await tester.pumpWidget(createTestWidget(reminders: testReminders));
        await tester.pumpAndSettle();

        // Check for Column in subtitle
        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.subtitle, isA<Column>());
      });
    });
  });
}

// Mock ReminderProvider for testing
class MockReminderProvider extends ReminderProvider {
  final List<Reminder> _testReminders;
  final RequestState _testState;

  MockReminderProvider({
    required List<Reminder> reminders,
    required RequestState state,
  }) : _testReminders = reminders, _testState = state;

  @override
  RequestState get state => _testState;

  @override
  List<Reminder> get reminders => _testReminders;

  @override
  String get message => '';

  @override
  Future<void> loadActiveReminders() async {
    // Mock implementation - does nothing
  }

  @override
  Future<bool> toggleReminderStatus(int id, bool isActive) async {
    // Mock implementation - returns success
    return true;
  }
}