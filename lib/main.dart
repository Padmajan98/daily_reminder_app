import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

void main() {
  runApp(ReminderApp());
}

class ReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderHomePage(),
    );
  }
}

class ReminderHomePage extends StatefulWidget {
  @override
  _ReminderHomePageState createState() => _ReminderHomePageState();
}

class _ReminderHomePageState extends State<ReminderHomePage> {
  String _selectedDay = 'Monday';
  TimeOfDay? _selectedTime;
  String _selectedActivity = 'Wake up';
  final AudioPlayer _audioPlayer = AudioPlayer();

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _setReminder() {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a time.')));
      return;
    }

    final now = DateTime.now();
    final reminderDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final dayDifference = (_getDayIndex(_selectedDay) - now.weekday + 7) % 7;
    final reminderDate = reminderDateTime.add(Duration(days: dayDifference));

    final duration = reminderDate.difference(now);

    if (duration.isNegative) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Selected time has already passed for today.')));
      return;
    }

    Timer(duration, () {
      _audioPlayer.play(AssetSource('chime.mp3'));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Time for $_selectedActivity')));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set for $_selectedActivity on $_selectedDay at ${_selectedTime!.format(context)}')));
  }

  int _getDayIndex(String day) {
    switch (day) {
      case 'Sunday':
        return 7;
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Reminder Application'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: InputDecoration(labelText: 'Day of the week'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDay = newValue!;
                });
              },
              items: <String>['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => _selectTime(context),
              child: Text(_selectedTime == null ? 'Choose Time' : _selectedTime!.format(context)),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedActivity,
              decoration: InputDecoration(labelText: 'Activity'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedActivity = newValue!;
                });
              },
              items: <String>[
                'Wake up',
                'Go to gym',
                'Breakfast',
                'Meetings',
                'Lunch',
                'Quick nap',
                'Go to library',
                'Dinner',
                'Go to sleep'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _setReminder,
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
