import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../screens/add_reminder_screen.dart';
import '../widgets/fast_page_route.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderService _reminderService = ReminderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reminders'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Reminder>>(
        stream: _reminderService.getUserReminders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reminders = snapshot.data ?? [];
          if (reminders.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return _buildReminderCard(reminder);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            FastPageRoute(page: const AddReminderScreen()),
          );
        },
        backgroundColor: Colors.green.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No reminders set',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to scheduled your farming tasks',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    final String timeStr = DateFormat('jm').format(reminder.dateTime);
    final String dateStr = DateFormat('MMM d, yyyy').format(reminder.dateTime);

    IconData catIcon;
    switch (reminder.category) {
      case 'Crop Care': catIcon = Icons.eco; break;
      case 'Weather': catIcon = Icons.wb_sunny; break;
      case 'Market': catIcon = Icons.storefront; break;
      default: catIcon = Icons.event_note;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: reminder.isActive ? Colors.green.shade100 : Colors.grey.shade200,
              child: Icon(catIcon, color: reminder.isActive ? Colors.green.shade800 : Colors.grey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: reminder.isActive ? TextDecoration.none : TextDecoration.lineThrough,
                      color: reminder.isActive ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (reminder.description.isNotEmpty)
                    Text(
                      reminder.description,
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      Text(timeStr, style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(dateStr, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                  if (reminder.repeatType != 'None')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          '🔁 ${reminder.repeatType}',
                          style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  activeColor: Colors.green.shade600,
                  value: reminder.isActive,
                  onChanged: (val) {
                    _reminderService.toggleReminderStatus(reminder);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    _showDeleteDialog(reminder.id);
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              _reminderService.deleteReminder(id);
              Navigator.pop(context);
            }, 
            child: const Text('Delete')
          ),
        ],
      ),
    );
  }
}
