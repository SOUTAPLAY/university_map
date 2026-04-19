import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          // Profile section
          userAsync.when(
            loading: () => const ListTile(title: Text('読み込み中...')),
            error: (_, __) => const SizedBox.shrink(),
            data: (profile) => profile == null
                ? const SizedBox.shrink()
                : ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(profile.displayName.isNotEmpty
                        ? profile.displayName
                        : '名前未設定'),
                    subtitle: Text(profile.email),
                  ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('アプリについて'),
            subtitle: Text('明星大学キャンパスマップ v1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('3Dマップについて'),
            subtitle: const Text('3D都市モデル: Project PLATEAU（国土交通省）'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ログアウト',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
