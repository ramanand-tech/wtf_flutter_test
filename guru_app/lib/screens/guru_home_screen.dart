import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class GuruHomeScreen extends StatelessWidget {
  const GuruHomeScreen({super.key});

  void _openChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ChatListScreen(
          currentUserId: SeedData.dkId,
          currentRole: UserRole.member,
          primaryColor: AppColors.guruPrimary,
          appBarBadge: 'Member • DK',
        ),
      ),
    );
  }

  void _openChatDirect(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ConversationScreen(
          currentUserId: SeedData.dkId,
          currentRole: UserRole.member,
          peerId: SeedData.aaravId,
          peerName: 'Aarav (Lead Trainer)',
          primaryColor: AppColors.guruPrimary,
          chatId: SeedData.defaultChatId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guru Home'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: RoleBadge(label: 'Member • DK'),
          ),
        ],
      ),
      floatingActionButton: const DevPanelFab(buildInfo: 'guru_app v1.0.0'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HomeCard(
            title: 'Chat with Trainer',
            subtitle: 'Message Aarav — real-time feel',
            icon: Icons.chat,
            onTap: () => _openChat(context),
          ),
          const SizedBox(height: 8),
          HomeCard(
            title: 'Schedule Call',
            subtitle: 'Pick a slot — 100ms video',
            icon: Icons.calendar_month,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ScheduleCallScreen(
                    primaryColor: AppColors.guruPrimary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          HomeCard(
            title: 'My Sessions',
            subtitle: 'Logs, ratings, notes',
            icon: Icons.history,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SessionsListScreen(
                    currentUserId: SeedData.dkId,
                    isTrainerView: false,
                    primaryColor: AppColors.guruPrimary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _openChatDirect(context),
            child: const Text('Quick open chat'),
          ),
        ],
      ),
    );
  }

}
