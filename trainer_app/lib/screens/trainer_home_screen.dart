import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  static bool _coldStartReported = false;

  @override
  void initState() {
    super.initState();
    if (!_coldStartReported) {
      _coldStartReported = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PerfTracker.report(PerfMarks.coldStart, budgetMs: PerfBudgets.coldStartMs);
      });
    }
  }

  void _openChats(BuildContext context) {
    Navigator.of(context).push(
      appPageRoute(
        const ChatListScreen(
          currentUserId: SeedData.aaravId,
          currentRole: UserRole.trainer,
          primaryColor: AppColors.trainerPrimary,
          appBarBadge: 'Trainer • Aarav',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Home'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: RoleBadge(label: 'Trainer • Aarav'),
          ),
        ],
      ),
      floatingActionButton: const DevPanelFab(buildInfo: 'trainer_app v1.0.0'),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(AppSpacing.sm),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          _tile(context, 'Members', Icons.people, (ctx) => _snack(ctx, 'CRM list (Phase 3+)')),
          _tile(context, 'Chats', Icons.chat, _openChats),
          _tile(context, 'Requests', Icons.pending_actions, (ctx) {
            Navigator.of(ctx).push(appPageRoute(const TrainerRequestsScreen()));
          }),
          _tile(context, 'Sessions', Icons.history, (ctx) {
            Navigator.of(ctx).push(
              appPageRoute(
                const SessionsListScreen(
                  currentUserId: SeedData.aaravId,
                  isTrainerView: true,
                  primaryColor: AppColors.trainerPrimary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _tile(
    BuildContext context,
    String title,
    IconData icon,
    void Function(BuildContext) onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: () => onTap(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: AppColors.trainerPrimary),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
