import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_services.dart';
import '../services/call_service.dart' show kDefaultHmsRoomId;
import '../services/sync_config.dart';
import '../utils/app_logger.dart';
import '../utils/mask_utils.dart';
import '../utils/spacing.dart';
import '../utils/theme.dart';
import 'app_buttons.dart';

class DevPanelFab extends StatelessWidget {
  const DevPanelFab({super.key, this.buildInfo = 'dev'});

  final String buildInfo;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'dev_panel',
      tooltip: 'Developer panel',
      onPressed: () => _open(context),
      child: const Text('⋮', style: TextStyle(fontSize: 18)),
    );
  }

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => _DevPanelSheet(buildInfo: buildInfo),
    );
  }
}

class _DevPanelSheet extends StatefulWidget {
  const _DevPanelSheet({required this.buildInfo});

  final String buildInfo;

  @override
  State<_DevPanelSheet> createState() => _DevPanelSheetState();
}

class _DevPanelSheetState extends State<_DevPanelSheet> {
  LogTag? _filter;

  String get _syncUrl {
    try {
      return AppServices.instance.syncClient.baseUrl;
    } catch (_) {
      return SyncConfig.defaultBaseUrl;
    }
  }

  Color _tagColor(LogTag tag) {
    return switch (tag) {
      LogTag.chat => AppColors.guruPrimary,
      LogTag.rtc => AppColors.warning,
      LogTag.schedule => AppColors.success,
      LogTag.auth => AppColors.neutral700,
      LogTag.perf => const Color(0xFF7C3AED),
    };
  }

  @override
  Widget build(BuildContext context) {
    final all = AppLogger.instance.logEntries.reversed.toList();
    final logs = _filter == null
        ? all
        : all.where((e) => e.tag == _filter).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      minChildSize: 0.35,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Dev Panel', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('Build: ${widget.buildInfo}', style: Theme.of(context).textTheme.bodyMedium),
              Text('Sync: ${maskUrl(_syncUrl)}', style: Theme.of(context).textTheme.bodySmall),
              Text(
                'HMS room: ${maskId(kDefaultHmsRoomId)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  ...LogTag.values.map(
                    (t) => FilterChip(
                      label: Text(t.bracket),
                      selected: _filter == t,
                      onSelected: (_) => setState(() => _filter = t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Last ${AppLogger.maxEntries} logs (${logs.length} shown)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: logs.isEmpty
                    ? Center(
                        child: Text(
                          'No logs yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        itemCount: logs.length,
                        itemBuilder: (context, i) {
                          final e = logs[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: SelectableText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${e.tag.bracket} ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      color: _tagColor(e.tag),
                                    ),
                                  ),
                                  TextSpan(
                                    text: e.message,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      color: AppColors.neutral900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'Copy logs',
                      onPressed: () {
                        final text = logs.map((e) => e.line).join('\n');
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logs copied')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  AppTertiaryButton(
                    label: 'Clear',
                    onPressed: () {
                      AppLogger.instance.clear();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
