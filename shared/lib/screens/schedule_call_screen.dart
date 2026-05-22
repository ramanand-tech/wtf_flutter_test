import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../utils/schedule_utils.dart';
import '../utils/seed_data.dart';
import '../utils/theme.dart';
import '../utils/validators.dart';
import 'my_requests_screen.dart';

class ScheduleCallScreen extends StatefulWidget {
  const ScheduleCallScreen({
    super.key,
    required this.primaryColor,
  });

  final Color primaryColor;

  @override
  State<ScheduleCallScreen> createState() => _ScheduleCallScreenState();
}

class _ScheduleCallScreenState extends State<ScheduleCallScreen> {
  final _days = nextThreeDays();
  final _slots = halfHourSlots();
  final _noteController = TextEditingController();
  late DateTime _selectedDay;
  TimeOfDay? _selectedTime;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _days.first;
    _noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  DateTime? get _scheduledDateTime {
    if (_selectedTime == null) return null;
    return combineDayAndTime(_selectedDay, _selectedTime!);
  }

  Future<void> _submit() async {
    final scheduled = _scheduledDateTime;
    if (scheduled == null) {
      _showError('Please select a time slot');
      return;
    }
    final noteError = Validators.scheduleNote(_noteController.text);
    if (noteError != null) {
      _showError(noteError);
      return;
    }
    setState(() => _submitting = true);
    try {
      await AppServices.instance.calls.createRequest(
        memberId: SeedData.dkId,
        trainerId: SeedData.aaravId,
        scheduledFor: scheduled,
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Call requested. Waiting for trainer approval.'),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => MyRequestsScreen(primaryColor: widget.primaryColor),
        ),
      );
    } on StateError catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Call'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MyRequestsScreen(primaryColor: widget.primaryColor),
                ),
              );
            },
            child: const Text('My Requests'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pick a day', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _days.map((day) {
              final selected = day == _selectedDay;
              return ChoiceChip(
                label: Text(dayChipLabel(day)),
                selected: selected,
                onSelected: (_) => setState(() {
                  _selectedDay = day;
                  _selectedTime = null;
                }),
                selectedColor: widget.primaryColor.withValues(alpha: 0.2),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Time slot (30 min)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _slots.map((slot) {
              final dt = combineDayAndTime(_selectedDay, slot);
              final past = isSlotInPast(dt);
              final selected = _selectedTime == slot;
              return FilterChip(
                label: Text(formatTimeSlot(slot)),
                selected: selected,
                onSelected: past
                    ? null
                    : (_) => setState(() => _selectedTime = slot),
                selectedColor: widget.primaryColor.withValues(alpha: 0.25),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _noteController,
            maxLength: 140,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note for trainer',
              hintText: 'e.g. Macros review',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Request Call'),
          ),
        ],
      ),
    );
  }
}
