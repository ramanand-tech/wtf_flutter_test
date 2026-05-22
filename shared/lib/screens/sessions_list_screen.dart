import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/session_log.dart';
import '../services/app_services.dart';
import '../utils/extensions.dart';
import '../utils/session_log_utils.dart';
import '../utils/theme.dart';
import '../widgets/empty_state.dart';

class SessionsListScreen extends StatefulWidget {
  const SessionsListScreen({
    super.key,
    required this.currentUserId,
    required this.isTrainerView,
    required this.primaryColor,
  });

  final String currentUserId;
  final bool isTrainerView;
  final Color primaryColor;

  @override
  State<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen> {
  SessionLogFilter _filter = SessionLogFilter.all;
  List<SessionLog> _allLogs = [];

  @override
  void initState() {
    super.initState();
    AppServices.instance.logs.pullRemote();
    AppServices.instance.logs.watchLogs().listen((_) {
      if (!mounted) return;
      setState(() {
        _allLogs = AppServices.instance.logs.forUser(
          widget.currentUserId,
          isTrainer: widget.isTrainerView,
        );
      });
    });
  }

  List<SessionLog> get _filtered => filterSessionLogs(_allLogs, _filter);

  Future<void> _refresh() async {
    await AppServices.instance.logs.pullRemote();
  }

  void _showDetail(SessionLog log) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.startedAt.toScheduleLabel(),
                style: Theme.of(ctx).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text('Duration: ${formatDurationSec(log.durationSec)}'),
              if (log.rating != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < log.rating! ? Icons.star : Icons.star_border,
                      color: AppColors.warning,
                    );
                  }),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Member notes', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(log.memberNotes ?? '—'),
              const SizedBox(height: 12),
              const Text('Trainer notes', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(log.trainerNotes ?? '—'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: sessionLogShareText(log)));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Summary copied')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Copy summary'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isTrainerView ? 'Sessions' : 'My Sessions')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 8,
              children: SessionLogFilter.values.map((f) {
                final label = switch (f) {
                  SessionLogFilter.all => 'All',
                  SessionLogFilter.last7Days => 'Last 7 days',
                  SessionLogFilter.thisMonth => 'This Month',
                };
                return FilterChip(
                  label: Text(label),
                  selected: _filter == f,
                  onSelected: (_) => setState(() => _filter = f),
                  selectedColor: widget.primaryColor.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _filtered.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyState(
                          title: 'No sessions yet',
                          subtitle: 'Schedule your first call',
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final log = _filtered[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: widget.primaryColor.withValues(alpha: 0.15),
                              child: Icon(Icons.history, color: widget.primaryColor),
                            ),
                            title: Text(
                              DateFormat('MMM d, h:mm a').format(log.startedAt),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${formatDurationSec(log.durationSec)}'
                              '${log.rating != null ? ' · ${log.rating}★' : ''}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _showDetail(log),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
