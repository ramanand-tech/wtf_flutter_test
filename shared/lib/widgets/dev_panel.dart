import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_logger.dart';

class DevPanelFab extends StatelessWidget {
  const DevPanelFab({super.key, this.buildInfo = 'dev'});

  final String buildInfo;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'dev_panel',
      onPressed: () => _open(context),
      child: const Text('⋮', style: TextStyle(fontSize: 18)),
    );
  }

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final logs = AppLogger.instance.entries.reversed.toList();
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dev Panel', style: Theme.of(ctx).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Build: $buildInfo'),
                  Text('Token URL: [masked] — see README'),
                  const SizedBox(height: 12),
                  const Text('Last 20 logs', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: logs.length,
                      itemBuilder: (_, i) => SelectableText(
                        logs[i],
                        style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final text = logs.join('\n');
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Logs copied')),
                      );
                    },
                    child: const Text('Copy logs'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
