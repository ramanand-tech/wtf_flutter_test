import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/session_log.dart';
import '../services/app_services.dart';
import '../utils/extensions.dart';
import '../utils/session_log_utils.dart';
import '../utils/app_snackbar.dart';
import '../utils/spacing.dart';
import '../utils/theme.dart';
import '../widgets/app_buttons.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_skeleton.dart';

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
  bool _loading = true;
  bool _syncError = false;

  @override
  void initState() {
    super.initState();
    _load();
    AppServices.instance.logs.watchLogs().listen((_) {
      if (!mounted) return;
      setState(() {
        _allLogs = AppServices.instance.logs.forUser(
          widget.currentUserId,
          isTrainer: widget.isTrainerView,
        );
        _loading = false;
      });
    });
  }

  Future<void> _load() async {
    await AppServices.instance.logs.pullRemote();
    if (!mounted) return;
    setState(() {
      _syncError = !AppServices.instance.syncClient.lastSessionsOk;
      _loading = false;
      _allLogs = AppServices.instance.logs.forUser(
        widget.currentUserId,
        isTrainer: widget.isTrainerView,
      );
    });
  }

  List<SessionLog> get _filtered => filterSessionLogs(_allLogs, _filter);

  Future<void> _refresh() async {
    setState(() => _syncError = false);
    await _load();
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
                    child: AppSecondaryButton(
                      label: 'Copy summary',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: sessionLogShareText(log)));
                        Navigator.pop(ctx);
                        AppSnackbar.showInfo(context, 'Summary copied');
                      },
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
    if (_syncError) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.isTrainerView ? 'Sessions' : 'My Sessions')),
        body: ErrorState(
          message: 'Session logs could not sync. Check token_server and retry.',
          onRetry: _refresh,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.isTrainerView ? 'Sessions' : 'My Sessions')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              0,
            ),
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
              child: _loading
                  ? const CardListSkeleton()
                  : _filtered.isEmpty
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
