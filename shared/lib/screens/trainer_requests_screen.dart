import 'package:flutter/material.dart';

import '../models/call_request.dart';
import '../models/enums.dart';
import '../services/app_services.dart';
import '../utils/extensions.dart';
import '../utils/seed_data.dart';
import '../utils/theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/join_call_button.dart';
import '../widgets/request_status_chip.dart';

class TrainerRequestsScreen extends StatefulWidget {
  const TrainerRequestsScreen({super.key});

  @override
  State<TrainerRequestsScreen> createState() => _TrainerRequestsScreenState();
}

class _TrainerRequestsScreenState extends State<TrainerRequestsScreen> {
  List<CallRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    AppServices.instance.calls.watchRequests().listen((list) {
      if (!mounted) return;
      setState(() {
        _requests = list.where((r) => r.trainerId == SeedData.aaravId).toList();
      });
    });
  }

  Future<void> _refresh() async {
    await AppServices.instance.calls.pullRemote();
  }

  Future<void> _approve(CallRequest r) async {
    try {
      await AppServices.instance.calls.approve(r.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Call approved for ${r.scheduledFor.toScheduleLabel()}.'),
        ),
      );
    } on StateError catch (e) {
      _snack(e.message, isError: true);
    }
  }

  Future<void> _decline(CallRequest r) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Decline request'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'Let DK know why',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.pop(ctx, controller.text.trim());
              },
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
    if (reason == null || reason.isEmpty) return;
    await AppServices.instance.calls.decline(r.id, reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Call request declined. Reason: $reason')),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _requests.where((r) => r.status == CallRequestStatus.pending).toList();
    final upcoming = AppServices.instance.calls.upcomingForTrainer(SeedData.aaravId);
    final upcomingIds = upcoming.map((r) => r.id).toSet();
    final others = _requests
        .where(
          (r) =>
              r.status != CallRequestStatus.pending && !upcomingIds.contains(r.id),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Call Requests')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _requests.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    title: 'No requests',
                    subtitle: 'When DK schedules a call, it will appear here.',
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text('No pending requests'),
                    )
                  else ...[
                    Text('Pending', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...pending.map((r) => _pendingCard(r)),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Upcoming Calls', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...upcoming.map(
                      (r) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DK — ${r.scheduledFor.toScheduleLabel()}'),
                              const SizedBox(height: 8),
                              JoinCallButton(
                                request: r,
                                currentUserId: SeedData.aaravId,
                                currentRole: UserRole.trainer,
                                primaryColor: AppColors.trainerPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (others.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('History', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...others.map(_historyTile),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _pendingCard(CallRequest r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Text('DK')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DK', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(r.scheduledFor.toScheduleLabel()),
                    ],
                  ),
                ),
                const RequestStatusChip(status: CallRequestStatus.pending),
              ],
            ),
            const SizedBox(height: 12),
            Text('Note: ${r.note}'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _decline(r),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.trainerPrimary),
                    onPressed: () => _approve(r),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyTile(CallRequest r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('DK — ${r.scheduledFor.toScheduleLabel()}'),
        subtitle: Text(r.note),
        trailing: RequestStatusChip(status: r.status),
      ),
    );
  }
}
