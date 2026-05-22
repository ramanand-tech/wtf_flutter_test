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

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key, required this.primaryColor});

  final Color primaryColor;

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  List<CallRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    AppServices.instance.calls.watchRequests().listen((list) {
      if (!mounted) return;
      setState(() {
        _requests = list.where((r) => r.memberId == SeedData.dkId).toList();
      });
    });
  }

  Future<void> _refresh() async {
    await AppServices.instance.calls.pullRemote();
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = AppServices.instance.calls.upcomingForMember(SeedData.dkId);
    final pending = _requests.where((r) => r.status == CallRequestStatus.pending).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _requests.isEmpty && upcoming.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    title: 'No requests yet',
                    subtitle: 'Schedule your first call with your trainer.',
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (pending.isNotEmpty) ...[
                    Text(
                      'Pending approval by Aarav',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...pending.map(_requestTile),
                    const SizedBox(height: 16),
                  ],
                  if (upcoming.isNotEmpty) ...[
                    Text(
                      'Upcoming Calls',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...upcoming.map(
                      (r) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.videocam, color: AppColors.guruPrimary),
                                title: Text(r.scheduledFor.toScheduleLabel()),
                                subtitle: Text(r.note),
                              ),
                              JoinCallButton(
                                request: r,
                                currentUserId: SeedData.dkId,
                                currentRole: UserRole.member,
                                primaryColor: widget.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text('All requests', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._requests.map(_requestTile),
                ],
              ),
      ),
    );
  }

  Widget _requestTile(CallRequest r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(r.scheduledFor.toScheduleLabel()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(r.note, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (r.status == CallRequestStatus.declined && r.declineReason != null)
              Text(
                'Call request declined. Reason: ${r.declineReason}',
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            if (r.status == CallRequestStatus.pending)
              const Text(
                'Call requested. Waiting for trainer approval.',
                style: TextStyle(fontSize: 12, color: AppColors.warning),
              ),
          ],
        ),
        trailing: RequestStatusChip(status: r.status),
      ),
    );
  }
}
